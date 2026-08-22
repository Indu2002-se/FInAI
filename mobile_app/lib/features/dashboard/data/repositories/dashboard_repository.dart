import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/network/dio_client.dart';
import '../models/dashboard_model.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DashboardRepository(dioClient: dioClient);
});

class DashboardRepository {
  final DioClient dioClient;

  DashboardRepository({required this.dioClient});

  Future<DashboardModel> getDashboard() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/dashboard',
    );
    final data = response['data'] as Map<String, dynamic>;
    return DashboardModel.fromJson(data);
  }
}
