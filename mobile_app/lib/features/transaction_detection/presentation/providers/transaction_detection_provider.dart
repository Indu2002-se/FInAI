import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai_insights/presentation/providers/ai_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../expense/presentation/providers/expense_provider.dart';
import '../../../income/presentation/providers/income_provider.dart';
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

final pendingCountProvider = Provider.autoDispose<int>((ref) {
  final pendingAsync = ref.watch(pendingDetectedTransactionsProvider);
  return pendingAsync.value?.length ?? 0;
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
