import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/child_models.dart';
import '../../data/models/child_profile_model.dart';
import '../../data/repositories/child_repository.dart';

/// Get child dashboard data for the currently logged-in child
final childDashboardProvider = FutureProvider.autoDispose<ChildDashboardModel>((ref) async {
  final repo = ref.watch(childRepositoryProvider);
  return repo.getChildDashboard();
});

/// Get quizzes for the currently logged-in child
final childQuizzesProvider = FutureProvider.autoDispose<List<ChildQuizModel>>((ref) async {
  final repo = ref.watch(childRepositoryProvider);
  return repo.getQuizzes();
});

/// Get specific quiz details
final childQuizDetailProvider = FutureProvider.autoDispose.family<ChildQuizModel, int>((ref, quizId) async {
  final repo = ref.watch(childRepositoryProvider);
  return repo.getQuiz(quizId);
});

/// Get rewards for the currently logged-in child
final childRewardsProvider = FutureProvider.autoDispose<List<ChildRewardModel>>((ref) async {
  final repo = ref.watch(childRepositoryProvider);
  return repo.getRewards();
});

/// Get progress/quiz results for the currently logged-in child
final childProgressProvider = FutureProvider.autoDispose<List<ChildQuizResultModel>>((ref) async {
  final repo = ref.watch(childRepositoryProvider);
  return repo.getProgress();
});

/// Notifier for creating a new child account
class CreateChildNotifier extends StateNotifier<AsyncValue<ChildProfileModel?>> {
  final ChildRepository repository;

  CreateChildNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> createChild({
    required String firstName,
    required String lastName,
    required int age,
    required String email,
    required String password,
    String? avatar,
    double initialSavings = 0.0,
  }) async {
    state = const AsyncValue.loading();
    try {
      final child = await repository.createChildAccount(
        firstName: firstName,
        lastName: lastName,
        age: age,
        email: email,
        password: password,
        avatar: avatar,
        initialSavings: initialSavings,
      );
      state = AsyncValue.data(child);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // The create screen awaits this operation.  Do not swallow failures here:
      // doing so made the UI report a successful account creation even when the
      // HTTP request failed before it reached the production backend.
      rethrow;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final createChildNotifierProvider =
    StateNotifierProvider<CreateChildNotifier, AsyncValue<ChildProfileModel?>>((ref) {
  final repository = ref.watch(childRepositoryProvider);
  return CreateChildNotifier(repository);
});
