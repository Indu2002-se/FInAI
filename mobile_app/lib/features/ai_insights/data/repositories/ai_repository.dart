import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/network/dio_client.dart';
import '../models/ai_models.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AiRepository(dioClient: dioClient);
});

class AiRepository {
  final DioClient dioClient;

  AiRepository({required this.dioClient});

  Future<AiAnalysisModel> runFullAnalysis() async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/v1/ai/analyze',
    );
    final data = response['data'] as Map<String, dynamic>;
    return AiAnalysisModel.fromJson(data);
  }

  Future<AiAnalysisModel> getLatestAiResults() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/ai/latest',
    );
    final data = response['data'] as Map<String, dynamic>;
    return AiAnalysisModel.fromJson(data);
  }

  Future<FinancialRiskModel> getRisk() async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/v1/ai/risk',
    );
    final data = response['data'] as Map<String, dynamic>;
    return FinancialRiskModel.fromJson(data);
  }

  Future<ExpenseForecastModel> getForecast() async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/v1/ai/forecast',
    );
    final data = response['data'] as Map<String, dynamic>;
    return ExpenseForecastModel.fromJson(data);
  }

  Future<AiRecommendationModel> getRecommendation() async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/v1/ai/recommendation',
    );
    final data = response['data'] as Map<String, dynamic>;
    return AiRecommendationModel.fromJson(data);
  }

  Future<SavingsPlanModel> getSavingsPlan(int goalId) async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/ai/savings-plan/$goalId',
    );
    final data = response['data'] as Map<String, dynamic>;
    return SavingsPlanModel.fromJson(data);
  }
}
