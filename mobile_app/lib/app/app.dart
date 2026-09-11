import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
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
  bool _syncInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _captureSubscription = NativeTransactionCapture.events.listen(
      _recordCapturedTransaction,
    );
    // Catch up after first frame so auth/token are ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_syncCapturedTransactions());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_syncCapturedTransactions());
    }
  }

  /// Drain queued closed-app events + scan SMS inbox for transaction-like messages.
  Future<void> _syncCapturedTransactions() async {
    if (_syncInProgress) return;
    _syncInProgress = true;
    try {
      final settings = await ref.read(detectionSettingsProvider.future);

      if (settings.smsEnabled || settings.notificationEnabled) {
        final queued = await NativeTransactionCapture.drainPendingEvents();
        for (final event in queued) {
          await _recordCapturedTransaction(event, settingsOverride: settings);
        }
      }

      if (settings.smsEnabled) {
        var hasPermission = await NativeTransactionCapture.hasSmsPermission();
        if (!hasPermission) {
          hasPermission = await NativeTransactionCapture.requestSmsPermission();
        }
        if (hasPermission || await NativeTransactionCapture.hasSmsPermission()) {
          final lastSync = await NativeTransactionCapture.getLastSmsSyncMs();
          final inbox = await NativeTransactionCapture.readSmsInbox(sinceMs: lastSync);
          for (final event in inbox) {
            await _recordCapturedTransaction(event, settingsOverride: settings);
          }
          await NativeTransactionCapture.setLastSmsSyncMs(
            DateTime.now().millisecondsSinceEpoch,
          );
        }
      }
    } catch (e, st) {
      debugPrint('Transaction capture sync failed: $e\n$st');
    } finally {
      _syncInProgress = false;
    }
  }

  Future<void> _recordCapturedTransaction(
    Map<String, dynamic> event, {
    dynamic settingsOverride,
  }) async {
    final sourceType = event['sourceType']?.toString();
    if (sourceType == null) return;

    final settings = settingsOverride ?? await ref.read(detectionSettingsProvider.future);
    if ((sourceType == 'SMS' && !settings.smsEnabled) ||
        (sourceType == 'NOTIFICATION' && !settings.notificationEnabled)) {
      return;
    }

    final transaction = sourceType == 'SMS'
        ? SmsDatasource().processIncomingSms(
            sender: event['sender']?.toString() ?? 'Unknown sender',
            messageBody: event['text']?.toString() ?? '',
          )
        : NotificationDatasource().processIncomingNotification(
            packageName: event['packageName']?.toString() ?? '',
            title: event['title']?.toString() ?? '',
            notificationText: event['text']?.toString() ?? '',
          );

    if (transaction == null) return;
    final saved = await ref
        .read(transactionDetectionNotifierProvider.notifier)
        .recordTransaction(transaction);
    if (saved != null) {
      debugPrint(
        'Captured ${saved.sourceType} transaction ${saved.transactionType}: ${saved.amount}',
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _captureSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'FinAI',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
