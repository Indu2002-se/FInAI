import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/child_models.dart';
import '../../data/repositories/child_repository.dart';

final childDashboardProvider = FutureProvider.autoDispose<ChildDashboardModel>((ref) async {
  final repo = ref.watch(childRepositoryProvider);
  return repo.getChildDashboard();
});

final childQuizzesProvider = FutureProvider.autoDispose<List<ChildQuizModel>>((ref) async {
  final repo = ref.watch(childRepositoryProvider);
  return repo.getQuizzes();
});

final childQuizDetailProvider = FutureProvider.autoDispose.family<ChildQuizModel, int>((ref, quizId) async {
  final repo = ref.watch(childRepositoryProvider);
  return repo.getQuiz(quizId);
});

final childRewardsProvider = FutureProvider.autoDispose<List<ChildRewardModel>>((ref) async {
  final repo = ref.watch(childRepositoryProvider);
  return repo.getRewards();
});

final childProgressProvider = FutureProvider.autoDispose<List<ChildQuizResultModel>>((ref) async {
  final repo = ref.watch(childRepositoryProvider);
  return repo.getProgress();
});
