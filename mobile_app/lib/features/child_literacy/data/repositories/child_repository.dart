import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/network/dio_client.dart';
import '../models/child_models.dart';
import '../models/child_profile_model.dart';

final childRepositoryProvider = Provider<ChildRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ChildRepository(dioClient: dioClient);
});

class ChildRepository {
  final DioClient dioClient;

  ChildRepository({required this.dioClient});

  // ==================== Parent Operations ====================

  /// Create a new child account (parent action)
  Future<ChildProfileModel> createChildAccount({
    required String firstName,
    required String lastName,
    required int age,
    required String email,
    required String password,
    String? avatar,
    double initialSavings = 0.0,
  }) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/api/v1/children',
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'usernameOrEmail': email,
        'password': password,
        'avatar': avatar,
        'initialSavings': initialSavings,
      },
    );
    final data = response['data'] as Map<String, dynamic>;
    return ChildProfileModel.fromJson(data);
  }

  /// Get list of all children for the logged-in parent
  Future<ParentChildrenListResponse> getParentChildren() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/api/v1/children',
    );
    final children = (response['data'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ChildProfileModel.fromJson)
        .toList();
    return ParentChildrenListResponse(
      children: children,
      totalChildren: children.length,
      parentId: '',
      parentName: 'Parent',
    );
  }

  /// Get specific child's profile
  Future<ChildProfileModel> getChildProfile(int childId) async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/api/v1/children/$childId',
    );
    final data = response['data'] as Map<String, dynamic>;
    return ChildProfileModel.fromJson(data);
  }

  // ==================== Child Dashboard Data ====================

  /// Get child dashboard data for a specific child (for parent viewing)
  Future<ChildDashboardModel> getChildDashboard({int? childId}) async {
    final endpoint = childId != null 
        ? '/api/v1/children/$childId/dashboard'
        : '/api/v1/child/dashboard';
    
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: endpoint,
    );
    final data = response['data'] as Map<String, dynamic>;
    return ChildDashboardModel.fromJson(data);
  }

  // ==================== Child Savings Goals ====================

  /// Get child's savings goals (for parent to view/edit)
  Future<List<ChildSavingsGoalModel>> getChildSavingsGoals({int? childId}) async {
    final endpoint = childId != null
        ? '/api/v1/children/$childId/goals'
        : '/api/v1/child/goals';
    
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: endpoint,
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => ChildSavingsGoalModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Create a new savings goal for a child (parent action)
  Future<ChildSavingsGoalModel> createChildSavingsGoal(
    int childId,
    ChildSavingsGoalModel goal,
  ) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/api/v1/children/$childId/goals',
      data: goal.toJson(),
    );
    final data = response['data'] as Map<String, dynamic>;
    return ChildSavingsGoalModel.fromJson(data);
  }

  /// Update a child's savings goal (parent action)
  Future<ChildSavingsGoalModel> updateChildSavingsGoal(
    int childId,
    int goalId,
    ChildSavingsGoalModel goal,
  ) async {
    final response = await dioClient.put<Map<String, dynamic>>(
      endpoint: '/api/v1/children/$childId/goals/$goalId',
      data: goal.toJson(),
    );
    final data = response['data'] as Map<String, dynamic>;
    return ChildSavingsGoalModel.fromJson(data);
  }

  /// Delete a child's savings goal (parent action)
  Future<void> deleteChildSavingsGoal(int childId, int goalId) async {
    await dioClient.delete<Map<String, dynamic>>(
      endpoint: '/api/v1/children/$childId/goals/$goalId',
    );
  }

  /// Update goal progress (parent adding savings to child's goal)
  Future<ChildSavingsGoalModel> updateGoalProgress(
    int childId,
    int goalId,
    double amountToAdd,
  ) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/api/v1/children/$childId/goals/$goalId/progress',
      data: {'amountToAdd': amountToAdd},
    );
    final data = response['data'] as Map<String, dynamic>;
    return ChildSavingsGoalModel.fromJson(data);
  }

  // ==================== Child Quizzes ====================

  Future<List<ChildQuizModel>> getQuizzes({int? childId}) async {
    final endpoint = childId != null
        ? '/api/v1/children/$childId/quizzes'
        : '/api/v1/child/quizzes';
    
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: endpoint,
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => ChildQuizModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ChildQuizModel> getQuiz(int quizId, {int? childId}) async {
    final endpoint = childId != null
        ? '/api/v1/children/$childId/quizzes/$quizId'
        : '/api/v1/child/quizzes/$quizId';
    
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: endpoint,
    );
    final data = response['data'] as Map<String, dynamic>;
    return ChildQuizModel.fromJson(data);
  }

  Future<ChildQuizResultModel> submitQuiz(
    int quizId,
    Map<String, int> answers, {
    int? childId,
  }) async {
    final endpoint = childId != null
        ? '/api/v1/children/$childId/quizzes/$quizId/attempt'
        : '/api/v1/child/quizzes/$quizId/attempt';
    
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: endpoint,
      data: {'answers': answers},
    );
    final data = response['data'] as Map<String, dynamic>;
    return ChildQuizResultModel.fromJson(data);
  }

  // ==================== Child Rewards ====================

  Future<List<ChildRewardModel>> getRewards({int? childId}) async {
    final endpoint = childId != null
        ? '/api/v1/children/$childId/rewards'
        : '/api/v1/child/rewards';
    
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: endpoint,
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => ChildRewardModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ChildQuizResultModel>> getProgress({int? childId}) async {
    final endpoint = childId != null
        ? '/api/v1/children/$childId/progress'
        : '/api/v1/child/progress';
    
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: endpoint,
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => ChildQuizResultModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class ChildSavingsGoalModel {
  final int? id;
  final String goalName;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String category;
  final String? description;
  final bool achieved;

  ChildSavingsGoalModel({
    this.id,
    required this.goalName,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    required this.category,
    this.description,
    this.achieved = false,
  });

  factory ChildSavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return ChildSavingsGoalModel(
      id: json['id'] as int?,
      goalName: json['goalName']?.toString() ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: json['targetDate'] != null
          ? DateTime.tryParse(json['targetDate'].toString())
          : null,
      category: json['category']?.toString() ?? 'OTHER',
      description: json['description']?.toString(),
      achieved: json['achieved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalName': goalName,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate?.toIso8601String(),
      'category': category,
      'description': description,
      'achieved': achieved,
    };
  }

  double get progressPercentage {
    if (targetAmount == 0) return 0;
    final progress = (currentAmount / targetAmount * 100).clamp(0.0, 100.0);
    return progress;
  }
}
