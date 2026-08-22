class DashboardModel {
  final String userName;
  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final double totalSavingsBalance;
  final double totalDebt;
  final double monthlyBudgetAllocated;
  final double monthlyBudgetSpent;
  final double budgetUsagePercentage;
  final double financialHealthScore;
  final String riskLevel;
  final double riskProbability;
  final String topRiskDriver;
  final String forecastSummary;
  final String latestRecommendation;
  final List<DashboardTransactionItem> recentExpenses;
  final List<DashboardIncomeItem> recentIncomes;
  final List<DashboardAlertItem> alerts;

  DashboardModel({
    required this.userName,
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.totalSavingsBalance,
    required this.totalDebt,
    required this.monthlyBudgetAllocated,
    required this.monthlyBudgetSpent,
    required this.budgetUsagePercentage,
    required this.financialHealthScore,
    required this.riskLevel,
    required this.riskProbability,
    required this.topRiskDriver,
    required this.forecastSummary,
    required this.latestRecommendation,
    required this.recentExpenses,
    required this.recentIncomes,
    required this.alerts,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      userName: json['userName']?.toString() ?? 'User',
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
      netSavings: (json['netSavings'] as num?)?.toDouble() ?? 0.0,
      totalSavingsBalance: (json['totalSavingsBalance'] as num?)?.toDouble() ?? 0.0,
      totalDebt: (json['totalDebt'] as num?)?.toDouble() ?? 0.0,
      monthlyBudgetAllocated: (json['monthlyBudgetAllocated'] as num?)?.toDouble() ?? 0.0,
      monthlyBudgetSpent: (json['monthlyBudgetSpent'] as num?)?.toDouble() ?? 0.0,
      budgetUsagePercentage: (json['budgetUsagePercentage'] as num?)?.toDouble() ?? 0.0,
      financialHealthScore: (json['financialHealthScore'] as num?)?.toDouble() ?? 75.0,
      riskLevel: json['riskLevel']?.toString() ?? 'Low Risk',
      riskProbability: (json['riskProbability'] as num?)?.toDouble() ?? 0.20,
      topRiskDriver: json['topRiskDriver']?.toString() ?? 'Expense Ratio',
      forecastSummary: json['forecastSummary']?.toString() ?? 'Expense trend is stable',
      latestRecommendation: json['latestRecommendation']?.toString() ?? 'Keep building emergency savings.',
      recentExpenses: (json['recentExpenses'] as List<dynamic>?)
              ?.map((e) => DashboardTransactionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentIncomes: (json['recentIncomes'] as List<dynamic>?)
              ?.map((e) => DashboardIncomeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      alerts: (json['alerts'] as List<dynamic>?)
              ?.map((e) => DashboardAlertItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DashboardTransactionItem {
  final int id;
  final String category;
  final double amount;
  final String expenseDate;
  final String? description;
  final String? paymentMethod;

  DashboardTransactionItem({
    required this.id,
    required this.category,
    required this.amount,
    required this.expenseDate,
    this.description,
    this.paymentMethod,
  });

  factory DashboardTransactionItem.fromJson(Map<String, dynamic> json) {
    return DashboardTransactionItem(
      id: json['id'] as int? ?? 0,
      category: json['category']?.toString() ?? 'OTHER',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      expenseDate: json['expenseDate']?.toString() ?? '',
      description: json['description']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
    );
  }
}

class DashboardIncomeItem {
  final int id;
  final String source;
  final String category;
  final double amount;
  final String incomeDate;
  final String? description;

  DashboardIncomeItem({
    required this.id,
    required this.source,
    required this.category,
    required this.amount,
    required this.incomeDate,
    this.description,
  });

  factory DashboardIncomeItem.fromJson(Map<String, dynamic> json) {
    return DashboardIncomeItem(
      id: json['id'] as int? ?? 0,
      source: json['source']?.toString() ?? '',
      category: json['category']?.toString() ?? 'SALARY',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      incomeDate: json['incomeDate']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }
}

class DashboardAlertItem {
  final int id;
  final String title;
  final String message;
  final String alertType;
  final bool isRead;

  DashboardAlertItem({
    required this.id,
    required this.title,
    required this.message,
    required this.alertType,
    required this.isRead,
  });

  factory DashboardAlertItem.fromJson(Map<String, dynamic> json) {
    return DashboardAlertItem(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      alertType: json['alertType']?.toString() ?? 'INFO',
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
