import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/child_models.dart';
import '../../data/models/child_profile_model.dart';
import '../../data/repositories/child_repository.dart';
import 'child_selection_provider.dart';

/// Active child profile id when a parent has selected a child; null for child JWT.
final activeChildIdProvider = Provider<int?>((ref) {
  return ref.watch(selectedChildProvider)?.id;
});

/// Dashboard scoped to child JWT or parent-selected child.
final childDashboardProvider =
    FutureProvider.autoDispose<ChildDashboardModel>((ref) async {
  final repo = ref.watch(childRepositoryProvider);
  final childId = ref.watch(activeChildIdProvider);
  return repo.getChildDashboard(childId: childId);
});

final childQuizzesProvider =
    FutureProvider.autoDispose<List<ChildQuizModel>>((ref) async {
  final repo = ref.watch(childRepositoryProvider);
  final childId = ref.watch(activeChildIdProvider);
  return repo.getQuizzes(childId: childId);
});

final childQuizDetailProvider =
    FutureProvider.autoDispose.family<ChildQuizModel, int>((ref, quizId) async {
  final repo = ref.watch(childRepositoryProvider);
  final childId = ref.watch(activeChildIdProvider);
  return repo.getQuiz(quizId, childId: childId);
});

final childRewardsProvider =
    FutureProvider.autoDispose<List<ChildRewardModel>>((ref) async {
  final repo = ref.watch(childRepositoryProvider);
  final childId = ref.watch(activeChildIdProvider);
  return repo.getRewards(childId: childId);
});

final childProgressProvider =
    FutureProvider.autoDispose<List<ChildQuizResultModel>>((ref) async {
  final repo = ref.watch(childRepositoryProvider);
  final childId = ref.watch(activeChildIdProvider);
  return repo.getProgress(childId: childId);
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
      rethrow;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final createChildNotifierProvider =
    StateNotifierProvider<CreateChildNotifier, AsyncValue<ChildProfileModel?>>(
        (ref) {
  final repository = ref.watch(childRepositoryProvider);
  return CreateChildNotifier(repository);
});
