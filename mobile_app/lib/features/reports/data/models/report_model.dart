class MonthlyReportModel {
  final String month;
  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final double savingsRate;
  final double expenseToIncomeRatio;
  final Map<String, double> categoryExpenses;
  final double budgetAllocated;
  final double budgetSpent;
  final double budgetVariance;
  final double financialHealthScore;
  final String riskLevel;
  final String topRiskDriver;
  final String aiRecommendation;

  MonthlyReportModel({
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRate,
    required this.expenseToIncomeRatio,
    required this.categoryExpenses,
    required this.budgetAllocated,
    required this.budgetSpent,
    required this.budgetVariance,
    required this.financialHealthScore,
    required this.riskLevel,
    required this.topRiskDriver,
    required this.aiRecommendation,
  });

  factory MonthlyReportModel.fromJson(Map<String, dynamic> json) {
    Map<String, double> cats = {};
    if (json['categoryExpenses'] is Map<String, dynamic>) {
      (json['categoryExpenses'] as Map<String, dynamic>).forEach((key, value) {
        cats[key] = (value as num?)?.toDouble() ?? 0.0;
      });
    }

    return MonthlyReportModel(
      month: json['month']?.toString() ?? '',
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
      netSavings: (json['netSavings'] as num?)?.toDouble() ?? 0.0,
      savingsRate: (json['savingsRate'] as num?)?.toDouble() ?? 0.0,
      expenseToIncomeRatio: (json['expenseToIncomeRatio'] as num?)?.toDouble() ?? 0.0,
      categoryExpenses: cats,
      budgetAllocated: (json['budgetAllocated'] as num?)?.toDouble() ?? 0.0,
      budgetSpent: (json['budgetSpent'] as num?)?.toDouble() ?? 0.0,
      budgetVariance: (json['budgetVariance'] as num?)?.toDouble() ?? 0.0,
      financialHealthScore: (json['financialHealthScore'] as num?)?.toDouble() ?? 75.0,
      riskLevel: json['riskLevel']?.toString() ?? 'Low Risk',
      topRiskDriver: json['topRiskDriver']?.toString() ?? 'Expense Ratio',
      aiRecommendation: json['aiRecommendation']?.toString() ?? 'Maintain balanced spending habits.',
    );
  }
}
