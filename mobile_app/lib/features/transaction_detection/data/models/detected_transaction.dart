class DetectedTransactionModel {
  final int id;
  final String sourceType; // SMS, NOTIFICATION, MANUAL
  final String? sourceApp;
  final String? sourceSender;
  final double amount;
  final String transactionType; // DEBIT, CREDIT, TRANSFER, UNKNOWN
  final String? merchant;
  final String? accountReference;
  final String? transactionDate;
  final String? reference;
  final String? rawTextHash;
  final double confidence;
  final String status; // PENDING, CONFIRMED, IGNORED, FAILED, DUPLICATE
  final String? suggestedCategory;
  final int? confirmedIncomeId;
  final int? confirmedExpenseId;
  final String? createdAt;
  final String? updatedAt;

  DetectedTransactionModel({
    required this.id,
    required this.sourceType,
    this.sourceApp,
    this.sourceSender,
    required this.amount,
    required this.transactionType,
    this.merchant,
    this.accountReference,
    this.transactionDate,
    this.reference,
    this.rawTextHash,
    this.confidence = 1.0,
    required this.status,
    this.suggestedCategory,
    this.confirmedIncomeId,
    this.confirmedExpenseId,
    this.createdAt,
    this.updatedAt,
  });

  factory DetectedTransactionModel.fromJson(Map<String, dynamic> json) {
    return DetectedTransactionModel(
      id: json['id'] as int? ?? 0,
      sourceType: json['sourceType']?.toString() ?? 'SMS',
      sourceApp: json['sourceApp']?.toString(),
      sourceSender: json['sourceSender']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      transactionType: json['transactionType']?.toString() ?? 'DEBIT',
      merchant: json['merchant']?.toString(),
      accountReference: json['accountReference']?.toString(),
      transactionDate: json['transactionDate']?.toString(),
      reference: json['reference']?.toString(),
      rawTextHash: json['rawTextHash']?.toString(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      status: json['status']?.toString() ?? 'PENDING',
      suggestedCategory: json['suggestedCategory']?.toString(),
      confirmedIncomeId: json['confirmedIncomeId'] as int?,
      confirmedExpenseId: json['confirmedExpenseId'] as int?,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceType': sourceType,
      'sourceApp': sourceApp,
      'sourceSender': sourceSender,
      'amount': amount,
      'transactionType': transactionType,
      'merchant': merchant,
      'accountReference': accountReference,
      'transactionDate': transactionDate,
      'reference': reference,
      'rawTextHash': rawTextHash,
      'confidence': confidence,
      'suggestedCategory': suggestedCategory,
    };
  }

  DetectedTransactionModel copyWith({
    int? id,
    String? sourceType,
    String? sourceApp,
    String? sourceSender,
    double? amount,
    String? transactionType,
    String? merchant,
    String? accountReference,
    String? transactionDate,
    String? reference,
    String? rawTextHash,
    double? confidence,
    String? status,
    String? suggestedCategory,
    int? confirmedIncomeId,
    int? confirmedExpenseId,
    String? createdAt,
    String? updatedAt,
  }) {
    return DetectedTransactionModel(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceApp: sourceApp ?? this.sourceApp,
      sourceSender: sourceSender ?? this.sourceSender,
      amount: amount ?? this.amount,
      transactionType: transactionType ?? this.transactionType,
      merchant: merchant ?? this.merchant,
      accountReference: accountReference ?? this.accountReference,
      transactionDate: transactionDate ?? this.transactionDate,
      reference: reference ?? this.reference,
      rawTextHash: rawTextHash ?? this.rawTextHash,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
      suggestedCategory: suggestedCategory ?? this.suggestedCategory,
      confirmedIncomeId: confirmedIncomeId ?? this.confirmedIncomeId,
      confirmedExpenseId: confirmedExpenseId ?? this.confirmedExpenseId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ConfirmTransactionPayload {
  final double? amount;
  final String? expenseCategory;
  final String? incomeCategory;
  final String? description;
  final String? transactionDate;
  final String? paymentMethodOrSource;

  ConfirmTransactionPayload({
    this.amount,
    this.expenseCategory,
    this.incomeCategory,
    this.description,
    this.transactionDate,
    this.paymentMethodOrSource,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (amount != null) map['amount'] = amount;
    if (expenseCategory != null) map['expenseCategory'] = expenseCategory;
    if (incomeCategory != null) map['incomeCategory'] = incomeCategory;
    if (description != null) map['description'] = description;
    if (transactionDate != null) map['transactionDate'] = transactionDate;
    if (paymentMethodOrSource != null) map['paymentMethodOrSource'] = paymentMethodOrSource;
    return map;
  }
}
