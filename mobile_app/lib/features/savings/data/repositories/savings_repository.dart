import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/network/dio_client.dart';
import '../models/savings_model.dart';

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SavingsRepository(dioClient: dioClient);
});

class SavingsRepository {
  final DioClient dioClient;

  SavingsRepository({required this.dioClient});

  Future<List<SavingsModel>> getSavings() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/savings',
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => SavingsModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<SavingsGoalModel>> getGoals() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/savings/goals',
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => SavingsGoalModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<SavingsGoalModel> createGoal(SavingsGoalModel goal) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/v1/savings/goals',
      data: goal.toJson(),
    );
    return SavingsGoalModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<SavingsGoalModel> updateGoal(int id, SavingsGoalModel goal) async {
    final response = await dioClient.put<Map<String, dynamic>>(
      endpoint: '/v1/savings/goals/$id',
      data: goal.toJson(),
    );
    return SavingsGoalModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteGoal(int id) async {
    await dioClient.delete<Map<String, dynamic>>(
      endpoint: '/v1/savings/goals/$id',
    );
  }
}
