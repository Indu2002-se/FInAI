class BudgetModel {
  final int id;
  final String category;
  final double allocatedAmount;
  final double spentAmount;
  final double remainingAmount;
  final double usagePercentage;
  final bool isOverBudget;
  final String budgetMonth;

  BudgetModel({
    required this.id,
    required this.category,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.usagePercentage,
    required this.isOverBudget,
    required this.budgetMonth,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as int? ?? 0,
      category: json['category']?.toString() ?? 'OTHER',
      allocatedAmount: (json['allocatedAmount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      usagePercentage: (json['usagePercentage'] as num?)?.toDouble() ?? 0.0,
      isOverBudget: json['isOverBudget'] as bool? ?? false,
      budgetMonth: json['budgetMonth']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'allocatedAmount': allocatedAmount,
      'budgetMonth': budgetMonth,
    };
  }
}

class BudgetStatusModel {
  final String month;
  final double totalAllocated;
  final double totalSpent;
  final double totalRemaining;
  final double overallUsagePercentage;
  final bool isOverallOverBudget;
  final List<BudgetModel> categoryBudgets;

  BudgetStatusModel({
    required this.month,
    required this.totalAllocated,
    required this.totalSpent,
    required this.totalRemaining,
    required this.overallUsagePercentage,
    required this.isOverallOverBudget,
    required this.categoryBudgets,
  });

  factory BudgetStatusModel.fromJson(Map<String, dynamic> json) {
    return BudgetStatusModel(
      month: json['month']?.toString() ?? '',
      totalAllocated: (json['totalAllocated'] as num?)?.toDouble() ?? 0.0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      totalRemaining: (json['totalRemaining'] as num?)?.toDouble() ?? 0.0,
      overallUsagePercentage: (json['overallUsagePercentage'] as num?)?.toDouble() ?? 0.0,
      isOverallOverBudget: json['isOverallOverBudget'] as bool? ?? false,
      categoryBudgets: (json['categoryBudgets'] as List<dynamic>?)
              ?.map((e) => BudgetModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
