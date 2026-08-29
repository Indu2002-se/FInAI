import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/child_profile_model.dart';
import '../../data/models/child_models.dart';
import '../../data/repositories/child_repository.dart';

/// Provider to get the list of all children for the logged-in parent
final parentChildrenListProvider =
    FutureProvider.autoDispose<ParentChildrenListResponse>((ref) async {
  final repo = ref.watch(childRepositoryProvider);
  return repo.getParentChildren();
});

/// Provider to track the currently selected child (for parents viewing child dashboard)
final selectedChildProvider = StateProvider<ChildProfileModel?>((ref) => null);

/// Notifier to manage selected child
class SelectedChildNotifier extends StateNotifier<ChildProfileModel?> {
  SelectedChildNotifier() : super(null);

  void selectChild(ChildProfileModel child) {
    state = child;
  }

  void clearSelection() {
    state = null;
  }

  int? get selectedChildId => state?.id;
}

final selectedChildNotifierProvider =
    StateNotifierProvider<SelectedChildNotifier, ChildProfileModel?>(
  (ref) => SelectedChildNotifier(),
);

/// Get dashboard data for a specific child (used by parents)
final parentViewChildDashboardProvider =
    FutureProvider.autoDispose.family<ChildDashboardModel, int>(
  (ref, childId) async {
    final repo = ref.watch(childRepositoryProvider);
    return repo.getChildDashboard(childId: childId);
  },
);

/// Get dashboard data for the selected child
final selectedChildDashboardProvider =
    FutureProvider.autoDispose<ChildDashboardModel>((ref) async {
  final selectedChild = ref.watch(selectedChildProvider);
  
  if (selectedChild == null) {
    throw Exception('No child selected');
  }

  final repo = ref.watch(childRepositoryProvider);
  return repo.getChildDashboard(childId: selectedChild.id);
});

/// Get the child profile data for a specific child
final childProfileProvider =
    FutureProvider.autoDispose.family<ChildProfileModel, int>(
  (ref, childId) async {
    final repo = ref.watch(childRepositoryProvider);
    return repo.getChildProfile(childId);
  },
);
