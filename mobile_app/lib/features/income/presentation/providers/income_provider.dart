import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/income_model.dart';
import '../../data/repositories/income_repository.dart';

final incomeListProvider = FutureProvider.autoDispose<List<IncomeModel>>((ref) async {
  final repo = ref.watch(incomeRepositoryProvider);
  return repo.getIncomes();
});
