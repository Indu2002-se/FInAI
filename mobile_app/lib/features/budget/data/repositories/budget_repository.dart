import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/network/dio_client.dart';
import '../models/budget_model.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BudgetRepository(dioClient: dioClient);
});

class BudgetRepository {
  final DioClient dioClient;

  BudgetRepository({required this.dioClient});

  Future<List<BudgetModel>> getBudgets({String? month}) async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/budgets',
      queryParameters: month != null ? {'month': month} : null,
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => BudgetModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BudgetStatusModel> getBudgetStatus({String? month}) async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/budgets/status',
      queryParameters: month != null ? {'month': month} : null,
    );
    return BudgetStatusModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<BudgetModel> createBudget(BudgetModel budget) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/v1/budgets',
      data: budget.toJson(),
    );
    return BudgetModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<BudgetModel> updateBudget(int id, BudgetModel budget) async {
    final response = await dioClient.put<Map<String, dynamic>>(
      endpoint: '/v1/budgets/$id',
      data: budget.toJson(),
    );
    return BudgetModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteBudget(int id) async {
    await dioClient.delete<Map<String, dynamic>>(
      endpoint: '/v1/budgets/$id',
    );
  }
}
