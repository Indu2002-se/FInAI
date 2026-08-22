import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/network/dio_client.dart';
import '../models/child_models.dart';

final childRepositoryProvider = Provider<ChildRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChildRepository(dioClient: dioClient);
});

class ChildRepository {
  final DioClient dioClient;

  ChildRepository({required this.dioClient});

  Future<ChildDashboardModel> getChildDashboard() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/child/dashboard',
    );
    final data = response['data'] as Map<String, dynamic>;
    return ChildDashboardModel.fromJson(data);
  }

  Future<List<ChildQuizModel>> getQuizzes() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/child/quizzes',
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => ChildQuizModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ChildQuizModel> getQuiz(int quizId) async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/child/quizzes/$quizId',
    );
    final data = response['data'] as Map<String, dynamic>;
    return ChildQuizModel.fromJson(data);
  }

  Future<ChildQuizResultModel> submitQuiz(int quizId, Map<String, int> answers) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/v1/child/quizzes/$quizId/attempt',
      data: {'answers': answers},
    );
    final data = response['data'] as Map<String, dynamic>;
    return ChildQuizResultModel.fromJson(data);
  }

  Future<List<ChildRewardModel>> getRewards() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/child/rewards',
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => ChildRewardModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ChildQuizResultModel>> getProgress() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/child/progress',
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => ChildQuizResultModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
