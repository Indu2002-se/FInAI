class ExpenseModel {
  final int id;
  final String category;
  final double amount;
  final String expenseDate;
  final String? description;
  final String? paymentMethod;
  final String? createdAt;

  ExpenseModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.expenseDate,
    this.description,
    this.paymentMethod,
    this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as int? ?? 0,
      category: json['category']?.toString() ?? 'OTHER',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      expenseDate: json['expenseDate']?.toString() ?? '',
      description: json['description']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'expenseDate': expenseDate,
      'description': description,
      'paymentMethod': paymentMethod,
    };
  }
}
