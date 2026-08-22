import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/network/dio_client.dart';
import '../models/expense_model.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ExpenseRepository(dioClient: dioClient);
});

class ExpenseRepository {
  final DioClient dioClient;

  ExpenseRepository({required this.dioClient});

  Future<List<ExpenseModel>> getExpenses() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/expenses',
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/v1/expenses',
      data: expense.toJson(),
    );
    return ExpenseModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<ExpenseModel> updateExpense(int id, ExpenseModel expense) async {
    final response = await dioClient.put<Map<String, dynamic>>(
      endpoint: '/v1/expenses/$id',
      data: expense.toJson(),
    );
    return ExpenseModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteExpense(int id) async {
    await dioClient.delete<Map<String, dynamic>>(
      endpoint: '/v1/expenses/$id',
    );
  }
}
