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

class _AppState extends ConsumerState<App> {
  StreamSubscription<Map<String, dynamic>>? _captureSubscription;

  @override
  void initState() {
    super.initState();
    _captureSubscription = NativeTransactionCapture.events.listen(
      _recordCapturedTransaction,
    );
  }

  Future<void> _recordCapturedTransaction(Map<String, dynamic> event) async {
    final sourceType = event['sourceType']?.toString();
    if (sourceType == null) return;

    final settings = await ref.read(detectionSettingsProvider.future);
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
