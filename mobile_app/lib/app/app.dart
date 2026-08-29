import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../features/authentication/presentation/providers/auth_notifier.dart';
import '../features/authentication/presentation/providers/auth_state.dart';
import '../features/transaction_detection/data/datasources/native_transaction_capture.dart';
import '../features/transaction_detection/data/datasources/notification_datasource.dart';
import '../features/transaction_detection/data/datasources/sms_datasource.dart';
import '../features/transaction_detection/presentation/providers/transaction_detection_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  StreamSubscription<Map<String, dynamic>>? _captureSubscription;
  Timer? _inboxPollTimer;
  bool _syncInProgress = false;
  final Set<String> _recentEventKeys = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _captureSubscription = NativeTransactionCapture.events.listen(
      (event) => unawaited(_recordCapturedTransaction(event)),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapSmsCapture());
    });
  }

  DateTime? _extractEventDate(Map<String, dynamic> event) {
    final atMs = event['receivedAtMs'];
    if (atMs != null) {
      final ms = int.tryParse(atMs.toString());
      if (ms != null && ms > 0) {
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
    }
    return null;
  }

  Future<void> _bootstrapSmsCapture() async {
    final authState = ref.read(authNotifierProvider);
    final isAuthenticated = authState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    if (!isAuthenticated) return;

    await _syncCapturedTransactions();
    await _ensureLiveSmsListener();
    _startInboxPollingIfNeeded();
  }

  Future<void> _onUserAuthenticated() async {
    ref.invalidate(detectionSettingsProvider);
    ref.invalidate(pendingDetectedTransactionsProvider);
    ref.invalidate(allDetectedTransactionsProvider);
    ref.invalidate(pendingCountProvider);

    try {
      final settings = await ref.read(detectionSettingsProvider.future);
      if (settings.smsEnabled) {
        final hasPermission = await NativeTransactionCapture.hasSmsPermission();
        if (hasPermission) {
          await NativeTransactionCapture.startSmsListener();
          await _syncCapturedTransactions();
          _startInboxPollingIfNeeded();
        }
      } else {
        await NativeTransactionCapture.stopSmsListener();
        _stopInboxPolling();
      }
    } catch (e) {
      debugPrint('Auth detection sync error: $e');
    }
  }

  void _onUserUnauthenticated() {
    _stopInboxPolling();
    unawaited(NativeTransactionCapture.stopSmsListener());
    _recentEventKeys.clear();
  }

  Future<void> _ensureLiveSmsListener() async {
    try {
      final settings = await ref.read(detectionSettingsProvider.future);
      if (!settings.smsEnabled) {
        await NativeTransactionCapture.stopSmsListener();
        return;
      }
      if (await NativeTransactionCapture.hasSmsPermission()) {
        await NativeTransactionCapture.startSmsListener();
      }
    } catch (e) {
      debugPrint('SMS listener start failed: $e');
    }
  }

  void _startInboxPollingIfNeeded() {
    _inboxPollTimer?.cancel();
    _inboxPollTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      unawaited(_syncCapturedTransactions());
    });
  }

  void _stopInboxPolling() {
    _inboxPollTimer?.cancel();
    _inboxPollTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_bootstrapSmsCapture());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Keep polling only while visible; resume will restart.
      _stopInboxPolling();
    }
  }

  /// Drain queued events + scan SMS inbox for new debit/credit messages smoothly.
  Future<void> _syncCapturedTransactions() async {
    if (_syncInProgress) return;
    _syncInProgress = true;
    try {
      final settings = await ref.read(detectionSettingsProvider.future);

      if (settings.notificationEnabled) {
        final queued = await NativeTransactionCapture.drainPendingEvents();
        for (final event in queued) {
          if (event['sourceType'] == 'NOTIFICATION') {
            await _recordCapturedTransaction(event, settingsOverride: settings);
          }
        }
      }

      if (settings.smsEnabled) {
        final hasPermission = await NativeTransactionCapture.hasSmsPermission();
        if (hasPermission) {
          await ref
              .read(transactionDetectionNotifierProvider.notifier)
              .syncNewSmsMessages();
        }
      }
    } catch (e, st) {
      debugPrint('Transaction capture sync failed: $e\n$st');
    } finally {
      _syncInProgress = false;
    }
  }

  String _eventKey(Map<String, dynamic> event) {
    final sender = event['sender']?.toString() ?? '';
    final text = event['text']?.toString() ?? '';
    final at = event['receivedAtMs']?.toString() ?? '';
    return '$sender|$at|${text.hashCode}';
  }

  Future<void> _recordCapturedTransaction(
    Map<String, dynamic> event, {
    dynamic settingsOverride,
  }) async {
    final sourceType = event['sourceType']?.toString();
    if (sourceType == null) return;

    final key = _eventKey(event);
    if (_recentEventKeys.contains(key)) return;
    _recentEventKeys.add(key);
    if (_recentEventKeys.length > 400) {
      _recentEventKeys.remove(_recentEventKeys.first);
    }

    try {
      final settings =
          settingsOverride ?? await ref.read(detectionSettingsProvider.future);
      if ((sourceType == 'SMS' && !settings.smsEnabled) ||
          (sourceType == 'NOTIFICATION' && !settings.notificationEnabled)) {
        return;
      }

      final date = _extractEventDate(event);
      final transaction = sourceType == 'SMS'
          ? SmsDatasource().processIncomingSms(
              sender: event['sender']?.toString() ?? 'Unknown sender',
              messageBody: event['text']?.toString() ?? '',
              transactionDate: date,
            )
          : NotificationDatasource().processIncomingNotification(
              packageName: event['packageName']?.toString() ?? '',
              title: event['title']?.toString() ?? '',
              notificationText: event['text']?.toString() ?? '',
            );

      if (transaction == null) return;
      if (sourceType == 'SMS' &&
          transaction.transactionType != 'DEBIT' &&
          transaction.transactionType != 'CREDIT') {
        return;
      }
      final saved = await ref
          .read(transactionDetectionNotifierProvider.notifier)
          .recordTransaction(transaction);
      if (saved != null) {
        debugPrint(
          'Captured ${saved.sourceType} transaction ${saved.transactionType}: ${saved.amount}',
        );
        ref.invalidate(pendingDetectedTransactionsProvider);
        ref.invalidate(allDetectedTransactionsProvider);
        ref.invalidate(pendingCountProvider);
      }
    } catch (e, st) {
      debugPrint('Failed to record captured transaction: $e\n$st');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _captureSubscription?.cancel();
    _stopInboxPolling();
    unawaited(NativeTransactionCapture.stopSmsListener());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Automatically trigger message sync and start SMS listener when an existing or new user logs in
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.whenOrNull(
        authenticated: (_) {
          unawaited(_onUserAuthenticated());
        },
        unauthenticated: () {
          _onUserUnauthenticated();
        },
      );
    });

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'FinAI',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
