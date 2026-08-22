class SavingsModel {
  final int id;
  final String accountName;
  final String? bankName;
  final String? accountNumber;
  final double currentBalance;
  final double? targetAmount;
  final double interestRate;
  final String? notes;

  SavingsModel({
    required this.id,
    required this.accountName,
    this.bankName,
    this.accountNumber,
    required this.currentBalance,
    this.targetAmount,
    this.interestRate = 0.0,
    this.notes,
  });

  factory SavingsModel.fromJson(Map<String, dynamic> json) {
    return SavingsModel(
      id: json['id'] as int? ?? 0,
      accountName: json['accountName']?.toString() ?? '',
      bankName: json['bankName']?.toString(),
      accountNumber: json['accountNumber']?.toString(),
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      targetAmount: (json['targetAmount'] as num?)?.toDouble(),
      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountName': accountName,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'currentBalance': currentBalance,
      'targetAmount': targetAmount,
      'interestRate': interestRate,
      'notes': notes,
    };
  }
}

class SavingsGoalModel {
  final int id;
  final int? childProfileId;
  final String? childName;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final double progressPercentage;
  final String? deadline;
  final String status;
  final String category;
  final String icon;
  final String? notes;

  SavingsGoalModel({
    required this.id,
    this.childProfileId,
    this.childName,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.progressPercentage,
    this.deadline,
    required this.status,
    required this.category,
    required this.icon,
    this.notes,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'] as int? ?? 0,
      childProfileId: json['childProfileId'] as int?,
      childName: json['childName']?.toString(),
      title: json['title']?.toString() ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      deadline: json['deadline']?.toString(),
      status: json['status']?.toString() ?? 'IN_PROGRESS',
      category: json['category']?.toString() ?? 'General',
      icon: json['icon']?.toString() ?? 'star',
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline,
      'status': status,
      'category': category,
      'icon': icon,
      'notes': notes,
    };
  }
}
