import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/savings_model.dart';
import '../../data/repositories/savings_repository.dart';

final savingsListProvider = FutureProvider.autoDispose<List<SavingsModel>>((ref) async {
  final repo = ref.watch(savingsRepositoryProvider);
  return repo.getSavings();
});

final savingsGoalsListProvider = FutureProvider.autoDispose<List<SavingsGoalModel>>((ref) async {
  final repo = ref.watch(savingsRepositoryProvider);
  return repo.getGoals();
});
