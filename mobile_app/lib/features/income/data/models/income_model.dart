class IncomeModel {
  final int id;
  final String source;
  final String category;
  final double amount;
  final String incomeDate;
  final String? description;
  final bool isRecurring;
  final String? createdAt;

  IncomeModel({
    required this.id,
    required this.source,
    required this.category,
    required this.amount,
    required this.incomeDate,
    this.description,
    this.isRecurring = false,
    this.createdAt,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'] as int? ?? 0,
      source: json['source']?.toString() ?? '',
      category: json['category']?.toString() ?? 'SALARY',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      incomeDate: json['incomeDate']?.toString() ?? '',
      description: json['description']?.toString(),
      isRecurring: json['isRecurring'] as bool? ?? false,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'category': category,
      'amount': amount,
      'incomeDate': incomeDate,
      'description': description,
      'isRecurring': isRecurring,
    };
  }
}
