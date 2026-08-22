import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/network/dio_client.dart';
import '../models/report_model.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ReportRepository(dioClient: dioClient);
});

class ReportRepository {
  final DioClient dioClient;

  ReportRepository({required this.dioClient});

  Future<MonthlyReportModel> getMonthlyReport({String? month}) async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/reports/monthly',
      queryParameters: month != null ? {'month': month} : null,
    );
    final data = response['data'] as Map<String, dynamic>;
    return MonthlyReportModel.fromJson(data);
  }
}
