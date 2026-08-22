import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ai_models.dart';
import '../../data/repositories/ai_repository.dart';

final latestAiAnalysisProvider = FutureProvider.autoDispose<AiAnalysisModel>((ref) async {
  final repo = ref.watch(aiRepositoryProvider);
  return repo.getLatestAiResults();
});

final riskPredictionProvider = FutureProvider.autoDispose<FinancialRiskModel>((ref) async {
  final repo = ref.watch(aiRepositoryProvider);
  return repo.getRisk();
});

final expenseForecastProvider = FutureProvider.autoDispose<ExpenseForecastModel>((ref) async {
  final repo = ref.watch(aiRepositoryProvider);
  return repo.getForecast();
});

final aiRecommendationProvider = FutureProvider.autoDispose<AiRecommendationModel>((ref) async {
  final repo = ref.watch(aiRepositoryProvider);
  return repo.getRecommendation();
});

final savingsPlanProvider = FutureProvider.autoDispose.family<SavingsPlanModel, int>((ref, goalId) async {
  final repo = ref.watch(aiRepositoryProvider);
  return repo.getSavingsPlan(goalId);
});

