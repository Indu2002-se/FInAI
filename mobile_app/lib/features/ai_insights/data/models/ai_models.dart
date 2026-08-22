class FinancialRiskModel {
  final double financialHealthScore;
  final String riskLevel;
  final double riskProbability;
  final String topDriver;
  final String topDriverReadable;
  final List<DriverDetailModel> drivers;

  FinancialRiskModel({
    required this.financialHealthScore,
    required this.riskLevel,
    required this.riskProbability,
    required this.topDriver,
    required this.topDriverReadable,
    required this.drivers,
  });

  factory FinancialRiskModel.fromJson(Map<String, dynamic> json) {
    return FinancialRiskModel(
      financialHealthScore: (json['financialHealthScore'] as num?)?.toDouble() ?? 75.0,
      riskLevel: json['riskLevel']?.toString() ?? 'Low Risk',
      riskProbability: (json['riskProbability'] as num?)?.toDouble() ?? 0.20,
      topDriver: json['topDriver']?.toString() ?? 'Expense Ratio',
      topDriverReadable: json['topDriverReadable']?.toString() ?? 'Monthly Expense Ratio',
      drivers: (json['drivers'] as List<dynamic>?)
              ?.map((e) => DriverDetailModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DriverDetailModel {
  final String feature;
  final double impact;
  final String direction;
  final String readableName;
  final String description;

  DriverDetailModel({
    required this.feature,
    required this.impact,
    required this.direction,
    required this.readableName,
    required this.description,
  });

  factory DriverDetailModel.fromJson(Map<String, dynamic> json) {
    return DriverDetailModel(
      feature: json['feature']?.toString() ?? '',
      impact: (json['impact'] as num?)?.toDouble() ?? 0.0,
      direction: json['direction']?.toString() ?? 'increase_risk',
      readableName: json['readableName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

class ForecastPointModel {
  final String date;
  final double predictedAmount;
  final double lowerBound;
  final double upperBound;

  ForecastPointModel({
    required this.date,
    required this.predictedAmount,
    required this.lowerBound,
    required this.upperBound,
  });

  factory ForecastPointModel.fromJson(Map<String, dynamic> json) {
    return ForecastPointModel(
      date: json['date']?.toString() ?? '',
      predictedAmount: (json['predictedAmount'] as num?)?.toDouble() ?? 0.0,
      lowerBound: (json['lowerBound'] as num?)?.toDouble() ?? 0.0,
      upperBound: (json['upperBound'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ExpenseForecastModel {
  final List<ForecastPointModel> food;
  final List<ForecastPointModel> nonFood;
  final List<ForecastPointModel> total;

  ExpenseForecastModel({
    required this.food,
    required this.nonFood,
    required this.total,
  });

  factory ExpenseForecastModel.fromJson(Map<String, dynamic> json) {
    return ExpenseForecastModel(
      food: (json['food'] as List<dynamic>?)
              ?.map((e) => ForecastPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nonFood: (json['nonFood'] as List<dynamic>?)
              ?.map((e) => ForecastPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (json['total'] as List<dynamic>?)
              ?.map((e) => ForecastPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ActionItemModel {
  final String step;
  final String priority;
  final double estimatedMonthlySavings;

  ActionItemModel({
    required this.step,
    required this.priority,
    required this.estimatedMonthlySavings,
  });

  factory ActionItemModel.fromAny(dynamic item) {
    if (item is String) {
      return ActionItemModel(
        step: item,
        priority: 'MEDIUM',
        estimatedMonthlySavings: 0.0,
      );
    } else if (item is Map<String, dynamic>) {
      return ActionItemModel(
        step: item['step']?.toString() ?? '',
        priority: item['priority']?.toString() ?? 'MEDIUM',
        estimatedMonthlySavings: (item['estimatedMonthlySavings'] as num?)?.toDouble() ?? 0.0,
      );
    }
    return ActionItemModel(
      step: item?.toString() ?? '',
      priority: 'MEDIUM',
      estimatedMonthlySavings: 0.0,
    );
  }

  factory ActionItemModel.fromJson(Map<String, dynamic> json) {
    return ActionItemModel.fromAny(json);
  }
}

class AiRecommendationModel {
  final String recommendationText;
  final String category;
  final String urgency;
  final List<ActionItemModel> actionItems;

  AiRecommendationModel({
    required this.recommendationText,
    required this.category,
    required this.urgency,
    required this.actionItems,
  });

  factory AiRecommendationModel.fromJson(Map<String, dynamic> json) {
    return AiRecommendationModel(
      recommendationText: json['recommendationText']?.toString() ??
          'Keep building positive financial habits.',
      category: json['category']?.toString() ?? 'Savings & Budgeting',
      urgency: json['urgency']?.toString() ?? 'MEDIUM',
      actionItems: (json['actionItems'] as List<dynamic>?)
              ?.map((e) => ActionItemModel.fromAny(e))
              .toList() ??
          [],
    );
  }
}

class AiAnalysisModel {
  final FinancialRiskModel? risk;
  final ExpenseForecastModel? forecast;
  final AiRecommendationModel? recommendation;

  AiAnalysisModel({
    this.risk,
    this.forecast,
    this.recommendation,
  });

  factory AiAnalysisModel.fromJson(Map<String, dynamic> json) {
    return AiAnalysisModel(
      risk: json['risk'] != null
          ? FinancialRiskModel.fromJson(json['risk'] as Map<String, dynamic>)
          : null,
      forecast: json['forecast'] != null
          ? ExpenseForecastModel.fromJson(json['forecast'] as Map<String, dynamic>)
          : null,
      recommendation: json['recommendation'] != null
          ? AiRecommendationModel.fromJson(
              json['recommendation'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SavingsPlanCategoryReduction {
  final String category;
  final double suggestedCut;
  final String action;

  SavingsPlanCategoryReduction({
    required this.category,
    required this.suggestedCut,
    required this.action,
  });

  factory SavingsPlanCategoryReduction.fromJson(Map<String, dynamic> json) {
    return SavingsPlanCategoryReduction(
      category: json['category']?.toString() ?? '',
      suggestedCut: (json['suggestedCut'] as num?)?.toDouble() ?? 0.0,
      action: json['action']?.toString() ?? '',
    );
  }
}

class SavingsPlanMilestone {
  final int month;
  final double targetAccumulated;
  final double completionPercentage;

  SavingsPlanMilestone({
    required this.month,
    required this.targetAccumulated,
    required this.completionPercentage,
  });

  factory SavingsPlanMilestone.fromJson(Map<String, dynamic> json) {
    return SavingsPlanMilestone(
      month: json['month'] as int? ?? 1,
      targetAccumulated: (json['targetAccumulated'] as num?)?.toDouble() ?? 0.0,
      completionPercentage: (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SavingsPlanModel {
  final String goalTitle;
  final double targetAmount;
  final double currentAmount;
  final int targetMonths;
  final double monthlyRequiredSavings;
  final double monthlySurplus;
  final double feasibilityScore;
  final String feasibilityStatus;
  final String difficultyLevel;
  final List<SavingsPlanCategoryReduction> categoryReductions;
  final List<SavingsPlanMilestone> milestones;
  final String aiStrategyReport;

  SavingsPlanModel({
    required this.goalTitle,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetMonths,
    required this.monthlyRequiredSavings,
    required this.monthlySurplus,
    required this.feasibilityScore,
    required this.feasibilityStatus,
    required this.difficultyLevel,
    required this.categoryReductions,
    required this.milestones,
    required this.aiStrategyReport,
  });

  factory SavingsPlanModel.fromJson(Map<String, dynamic> json) {
    return SavingsPlanModel(
      goalTitle: json['goalTitle']?.toString() ?? 'Savings Goal',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      targetMonths: json['targetMonths'] as int? ?? 6,
      monthlyRequiredSavings: (json['monthlyRequiredSavings'] as num?)?.toDouble() ?? 0.0,
      monthlySurplus: (json['monthlySurplus'] as num?)?.toDouble() ?? 0.0,
      feasibilityScore: (json['feasibilityScore'] as num?)?.toDouble() ?? 75.0,
      feasibilityStatus: json['feasibilityStatus']?.toString() ?? 'Achievable',
      difficultyLevel: json['difficultyLevel']?.toString() ?? 'MEDIUM',
      categoryReductions: (json['categoryReductions'] as List<dynamic>?)
              ?.map((e) => SavingsPlanCategoryReduction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      milestones: (json['milestones'] as List<dynamic>?)
              ?.map((e) => SavingsPlanMilestone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      aiStrategyReport: json['aiStrategyReport']?.toString() ?? '',
    );
  }
}

