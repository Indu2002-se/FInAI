import '../../../savings/data/models/savings_model.dart';

class ChildDashboardModel {
  final int childProfileId;
  final String childName;
  final int age;
  final String avatar;
  final double currentSavings;
  final int totalPoints;
  final List<SavingsGoalModel> savingsGoals;
  final List<ChildQuizModel> recommendedQuizzes;
  final List<ChildRewardModel> recentRewards;

  ChildDashboardModel({
    required this.childProfileId,
    required this.childName,
    required this.age,
    required this.avatar,
    required this.currentSavings,
    required this.totalPoints,
    required this.savingsGoals,
    required this.recommendedQuizzes,
    required this.recentRewards,
  });

  factory ChildDashboardModel.fromJson(Map<String, dynamic> json) {
    return ChildDashboardModel(
      childProfileId: json['childProfileId'] as int? ?? 0,
      childName: json['childName']?.toString() ?? 'Kid',
      age: json['age'] as int? ?? 10,
      avatar: json['avatar']?.toString() ?? 'avatar_default.png',
      currentSavings: (json['currentSavings'] as num?)?.toDouble() ?? 0.0,
      totalPoints: json['totalPoints'] as int? ?? 0,
      savingsGoals: (json['savingsGoals'] as List<dynamic>?)
              ?.map((e) => SavingsGoalModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recommendedQuizzes: (json['recommendedQuizzes'] as List<dynamic>?)
              ?.map((e) => ChildQuizModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentRewards: (json['recentRewards'] as List<dynamic>?)
              ?.map((e) => ChildRewardModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ChildQuizModel {
  final int id;
  final String title;
  final String category;
  final String? description;
  final String difficulty;
  final int rewardPoints;
  final String? badgeUrl;
  final String? icon;
  final int totalQuestions;
  final bool isCompleted;
  final int lastScore;
  final List<ChildQuestionModel> questions;

  ChildQuizModel({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    required this.difficulty,
    required this.rewardPoints,
    this.badgeUrl,
    this.icon,
    required this.totalQuestions,
    required this.isCompleted,
    required this.lastScore,
    required this.questions,
  });

  factory ChildQuizModel.fromJson(Map<String, dynamic> json) {
    return ChildQuizModel(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      description: json['description']?.toString(),
      difficulty: json['difficulty']?.toString() ?? 'BEGINNER',
      rewardPoints: json['rewardPoints'] as int? ?? 50,
      badgeUrl: json['badgeUrl']?.toString(),
      icon: json['icon']?.toString(),
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      lastScore: json['lastScore'] as int? ?? 0,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => ChildQuestionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ChildQuestionModel {
  final int id;
  final String questionText;
  final String? explanation;
  final int orderIndex;
  final List<ChildOptionModel> options;

  ChildQuestionModel({
    required this.id,
    required this.questionText,
    this.explanation,
    required this.orderIndex,
    required this.options,
  });

  factory ChildQuestionModel.fromJson(Map<String, dynamic> json) {
    return ChildQuestionModel(
      id: json['id'] as int? ?? 0,
      questionText: json['questionText']?.toString() ?? '',
      explanation: json['explanation']?.toString(),
      orderIndex: json['orderIndex'] as int? ?? 0,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => ChildOptionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ChildOptionModel {
  final int id;
  final String optionText;

  ChildOptionModel({
    required this.id,
    required this.optionText,
  });

  factory ChildOptionModel.fromJson(Map<String, dynamic> json) {
    return ChildOptionModel(
      id: json['id'] as int? ?? 0,
      optionText: json['optionText']?.toString() ?? '',
    );
  }
}

class ChildRewardModel {
  final int id;
  final String title;
  final String? description;
  final String? badgeIcon;
  final String rewardType;
  final int pointsAwarded;
  final String? unlockedAt;

  ChildRewardModel({
    required this.id,
    required this.title,
    this.description,
    this.badgeIcon,
    required this.rewardType,
    required this.pointsAwarded,
    this.unlockedAt,
  });

  factory ChildRewardModel.fromJson(Map<String, dynamic> json) {
    return ChildRewardModel(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      badgeIcon: json['badgeIcon']?.toString(),
      rewardType: json['rewardType']?.toString() ?? 'BADGE',
      pointsAwarded: json['pointsAwarded'] as int? ?? 50,
      unlockedAt: json['unlockedAt']?.toString(),
    );
  }
}

class ChildQuizResultModel {
  final int id;
  final int quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final double scorePercentage;
  final bool passed;
  final int earnedPoints;
  final String? earnedBadge;
  final String completedAt;

  ChildQuizResultModel({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.scorePercentage,
    required this.passed,
    required this.earnedPoints,
    this.earnedBadge,
    required this.completedAt,
  });

  factory ChildQuizResultModel.fromJson(Map<String, dynamic> json) {
    return ChildQuizResultModel(
      id: json['id'] as int? ?? 0,
      quizId: json['quizId'] as int? ?? 0,
      quizTitle: json['quizTitle']?.toString() ?? '',
      score: json['score'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      scorePercentage: (json['scorePercentage'] as num?)?.toDouble() ?? 0.0,
      passed: json['passed'] as bool? ?? false,
      earnedPoints: json['earnedPoints'] as int? ?? 0,
      earnedBadge: json['earnedBadge']?.toString(),
      completedAt: json['completedAt']?.toString() ?? '',
    );
  }
}
