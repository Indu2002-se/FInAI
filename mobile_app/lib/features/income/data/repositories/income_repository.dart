import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/network/dio_client.dart';
import '../models/income_model.dart';

final incomeRepositoryProvider = Provider<IncomeRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return IncomeRepository(dioClient: dioClient);
});

class IncomeRepository {
  final DioClient dioClient;

  IncomeRepository({required this.dioClient});

  Future<List<IncomeModel>> getIncomes() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/income',
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => IncomeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<IncomeModel> createIncome(IncomeModel income) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/v1/income',
      data: income.toJson(),
    );
    return IncomeModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<IncomeModel> updateIncome(int id, IncomeModel income) async {
    final response = await dioClient.put<Map<String, dynamic>>(
      endpoint: '/v1/income/$id',
      data: income.toJson(),
    );
    return IncomeModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteIncome(int id) async {
    await dioClient.delete<Map<String, dynamic>>(
      endpoint: '/v1/income/$id',
    );
  }
}
