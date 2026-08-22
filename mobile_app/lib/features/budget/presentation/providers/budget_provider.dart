import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';

final budgetStatusProvider = FutureProvider.autoDispose.family<BudgetStatusModel, String?>((ref, month) async {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.getBudgetStatus(month: month);
});

final currentBudgetStatusProvider = FutureProvider.autoDispose<BudgetStatusModel>((ref) async {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.getBudgetStatus();
});

final budgetListProvider = FutureProvider.autoDispose.family<List<BudgetModel>, String?>((ref, month) async {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.getBudgets(month: month);
});
