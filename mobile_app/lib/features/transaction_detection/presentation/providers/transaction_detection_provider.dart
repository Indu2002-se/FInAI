import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai_insights/presentation/providers/ai_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../expense/presentation/providers/expense_provider.dart';
import '../../../income/presentation/providers/income_provider.dart';
import '../../data/datasources/native_transaction_capture.dart';
import '../../data/datasources/notification_datasource.dart';
import '../../data/datasources/sms_datasource.dart';
import '../../data/models/detected_transaction.dart';
import '../../data/models/detection_settings.dart';
import '../../data/repositories/transaction_detection_repository.dart';

final pendingDetectedTransactionsProvider =
    FutureProvider.autoDispose<List<DetectedTransactionModel>>((ref) async {
  final repo = ref.watch(transactionDetectionRepositoryProvider);
  return repo.getPendingTransactions();
});

final allDetectedTransactionsProvider =
    FutureProvider.autoDispose<List<DetectedTransactionModel>>((ref) async {
  final repo = ref.watch(transactionDetectionRepositoryProvider);
  return repo.getAllDetectedTransactions();
});

final detectionSettingsProvider =
    FutureProvider.autoDispose<DetectionSettingsModel>((ref) async {
  final repo = ref.watch(transactionDetectionRepositoryProvider);
  return repo.getSettings();
});

/// Whether the OS has granted READ/RECEIVE SMS for transaction detection.
final smsPermissionGrantedProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  return NativeTransactionCapture.hasSmsPermission();
});

final pendingCountProvider = Provider.autoDispose<int>((ref) {
  final pendingAsync = ref.watch(pendingDetectedTransactionsProvider);
  return pendingAsync.value?.length ?? 0;
});

/// True when the user hasn't enabled SMS detection or hasn't granted OS permission.
final needsSmsAllowPromptProvider = Provider.autoDispose<bool>((ref) {
  final settingsAsync = ref.watch(detectionSettingsProvider);
  final permissionAsync = ref.watch(smsPermissionGrantedProvider);

  final isSmsEnabled = settingsAsync.maybeWhen(
    data: (s) => s.smsEnabled,
    orElse: () => false,
  );
  final isPermissionGranted = permissionAsync.maybeWhen(
    data: (granted) => granted,
    orElse: () => false,
  );

  return !isSmsEnabled || !isPermissionGranted;
});

class TransactionDetectionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final TransactionDetectionRepository repo;
  final SmsDatasource smsDatasource = SmsDatasource();
  final NotificationDatasource notificationDatasource = NotificationDatasource();

  TransactionDetectionNotifier(this.ref, this.repo) : super(const AsyncValue.data(null));

  Future<bool> confirmTransaction(int id, ConfirmTransactionPayload payload) async {
    state = const AsyncValue.loading();
    try {
      await repo.confirmTransaction(id, payload);
      // Invalidate all related providers so the entire app reflects the new income/expense immediately
      ref.invalidate(pendingDetectedTransactionsProvider);
      ref.invalidate(allDetectedTransactionsProvider);
      ref.invalidate(dashboardFutureProvider);
      ref.invalidate(expenseListProvider);
      ref.invalidate(incomeListProvider);
      ref.invalidate(currentBudgetStatusProvider);
      ref.invalidate(latestAiAnalysisProvider);
      ref.invalidate(riskPredictionProvider);
      ref.invalidate(expenseForecastProvider);
      ref.invalidate(aiRecommendationProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> ignoreTransaction(int id) async {
    state = const AsyncValue.loading();
    try {
      await repo.ignoreTransaction(id);
      ref.invalidate(pendingDetectedTransactionsProvider);
      ref.invalidate(allDetectedTransactionsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<DetectedTransactionModel?> recordTransaction(DetectedTransactionModel transaction) async {
    state = const AsyncValue.loading();
    try {
      final res = await repo.recordDetectedTransaction(transaction);
      ref.invalidate(pendingDetectedTransactionsProvider);
      ref.invalidate(allDetectedTransactionsProvider);
      state = const AsyncValue.data(null);
      return res;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<DetectedTransactionModel?> simulateSmsMessage(String sender, String body) async {
    final parsed = smsDatasource.processIncomingSms(sender: sender, messageBody: body);
    if (parsed == null) return null;
    return recordTransaction(parsed);
  }

  Future<DetectedTransactionModel?> simulateNotification(String app, String title, String text) async {
    final parsed = notificationDatasource.processIncomingNotification(
      packageName: app,
      title: title,
      notificationText: text,
    );
    if (parsed == null) return null;
    return recordTransaction(parsed);
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

  /// Enable SMS detection and import debit/credit SMS from the full recent inbox.
  Future<int> enableSmsAndSyncInbox() async {
    final current = await repo.getSettings();
    await repo.updateSettings(current.copyWith(smsEnabled: true));
    ref.invalidate(detectionSettingsProvider);

    final hasPermission = await NativeTransactionCapture.hasSmsPermission();
    if (!hasPermission) return 0;

    await NativeTransactionCapture.startSmsListener();

    // Full recent-inbox scan (sinceMs=0 → last 365 days on Android).
    await NativeTransactionCapture.setLastSmsSyncMs(0);
    final inbox = await NativeTransactionCapture.readSmsInbox(sinceMs: 0);
    final queued = await NativeTransactionCapture.drainPendingEvents();
    final allEvents = <Map<String, dynamic>>[...queued, ...inbox];

    final toRecord = <DetectedTransactionModel>[];
    final seenHashes = <String>{};

    for (final event in allEvents) {
      final text = event['text']?.toString() ?? '';
      if (text.isEmpty) continue;
      final parsed = smsDatasource.processIncomingSms(
        sender: event['sender']?.toString() ?? 'Unknown sender',
        messageBody: text,
        transactionDate: _extractEventDate(event),
      );
      if (parsed == null) continue;
      // Debit & credit only.
      if (parsed.transactionType != 'DEBIT' &&
          parsed.transactionType != 'CREDIT') {
        continue;
      }
      final hash = parsed.rawTextHash;
      if (hash != null && seenHashes.add(hash)) {
        toRecord.add(parsed);
      }
    }

    var saved = 0;
    if (toRecord.isNotEmpty) {
      try {
        final savedList = await repo.recordBatchDetectedTransactions(toRecord);
        saved = savedList.where((e) => e.status != 'DUPLICATE').length;
      } catch (_) {
        for (final item in toRecord) {
          try {
            final res = await repo.recordDetectedTransaction(item);
            if (res.status != 'DUPLICATE') saved++;
          } catch (_) {}
        }
      }
    }

    await NativeTransactionCapture.setLastSmsSyncMs(
      DateTime.now().millisecondsSinceEpoch,
    );
    ref.invalidate(pendingDetectedTransactionsProvider);
    ref.invalidate(allDetectedTransactionsProvider);
    ref.invalidate(pendingCountProvider);
    return saved;
  }

  /// Sync any new SMS messages received while logged out or in background.
  Future<int> syncNewSmsMessages() async {
    try {
      final settings = await repo.getSettings();
      if (!settings.smsEnabled) return 0;

      final hasPermission = await NativeTransactionCapture.hasSmsPermission();
      if (!hasPermission) return 0;

      await NativeTransactionCapture.startSmsListener();

      final lastSync = await NativeTransactionCapture.getLastSmsSyncMs();
      final sinceMs = lastSync > 5000 ? lastSync - 5000 : 0;
      final inbox = await NativeTransactionCapture.readSmsInbox(sinceMs: sinceMs);
      final queued = await NativeTransactionCapture.drainPendingEvents();
      final allEvents = <Map<String, dynamic>>[...queued, ...inbox];

      if (allEvents.isEmpty) return 0;

      final toRecord = <DetectedTransactionModel>[];
      final seenHashes = <String>{};

      for (final event in allEvents) {
        final text = event['text']?.toString() ?? '';
        if (text.isEmpty) continue;
        final parsed = smsDatasource.processIncomingSms(
          sender: event['sender']?.toString() ?? 'Unknown sender',
          messageBody: text,
          transactionDate: _extractEventDate(event),
        );
        if (parsed == null) continue;
        if (parsed.transactionType != 'DEBIT' &&
            parsed.transactionType != 'CREDIT') {
          continue;
        }
        final hash = parsed.rawTextHash;
        if (hash != null && seenHashes.add(hash)) {
          toRecord.add(parsed);
        }
      }

      var saved = 0;
      if (toRecord.isNotEmpty) {
        try {
          final savedList = await repo.recordBatchDetectedTransactions(toRecord);
          saved = savedList.where((e) => e.status != 'DUPLICATE').length;
        } catch (_) {
          for (final item in toRecord) {
            try {
              final res = await repo.recordDetectedTransaction(item);
              if (res.status != 'DUPLICATE') saved++;
            } catch (_) {}
          }
        }
      }

      await NativeTransactionCapture.setLastSmsSyncMs(
        DateTime.now().millisecondsSinceEpoch,
      );
      ref.invalidate(pendingDetectedTransactionsProvider);
      ref.invalidate(allDetectedTransactionsProvider);
      ref.invalidate(pendingCountProvider);
      return saved;
    } catch (_) {
      return 0;
    }
  }

  Future<bool> updateSettings(DetectionSettingsModel settings) async {
    state = const AsyncValue.loading();
    try {
      await repo.updateSettings(settings);
      ref.invalidate(detectionSettingsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final transactionDetectionNotifierProvider =
    StateNotifierProvider<TransactionDetectionNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(transactionDetectionRepositoryProvider);
  return TransactionDetectionNotifier(ref, repo);
});
