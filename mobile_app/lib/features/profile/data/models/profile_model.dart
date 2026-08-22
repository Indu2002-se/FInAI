class UserProfileModel {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final int? age;
  final String? gender;
  final String? education;
  final String? maritalStatus;
  final String? occupation;
  final String? employmentStatus;
  final int householdSize;
  final int dependentsCount;
  final double? monthlyIncome;
  final double? monthlyExpense;
  final double? savingsGoal;
  final double? totalDebt;
  final int creditScore;
  final String preferredCurrency;
  final String? financialKnowledgeLevel;
  final bool profileComplete;

  UserProfileModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.age,
    this.gender,
    this.education,
    this.maritalStatus,
    this.occupation,
    this.employmentStatus,
    this.householdSize = 1,
    this.dependentsCount = 0,
    this.monthlyIncome,
    this.monthlyExpense,
    this.savingsGoal,
    this.totalDebt,
    this.creditScore = 700,
    this.preferredCurrency = 'LKR',
    this.financialKnowledgeLevel,
    this.profileComplete = false,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString(),
      age: json['age'] as int?,
      gender: json['gender']?.toString(),
      education: json['education']?.toString(),
      maritalStatus: json['maritalStatus']?.toString(),
      occupation: json['occupation']?.toString(),
      employmentStatus: json['employmentStatus']?.toString(),
      householdSize: json['householdSize'] as int? ?? 1,
      dependentsCount: json['dependentsCount'] as int? ?? 0,
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble(),
      monthlyExpense: (json['monthlyExpense'] as num?)?.toDouble(),
      savingsGoal: (json['savingsGoal'] as num?)?.toDouble(),
      totalDebt: (json['totalDebt'] as num?)?.toDouble(),
      creditScore: json['creditScore'] as int? ?? 700,
      preferredCurrency: json['preferredCurrency']?.toString() ?? 'LKR',
      financialKnowledgeLevel: json['financialKnowledgeLevel']?.toString(),
      profileComplete: json['profileComplete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'age': age,
      'gender': gender,
      'education': education,
      'maritalStatus': maritalStatus,
      'occupation': occupation,
      'employmentStatus': employmentStatus,
      'householdSize': householdSize,
      'dependentsCount': dependentsCount,
      'monthlyIncome': monthlyIncome,
      'monthlyExpense': monthlyExpense,
      'savingsGoal': savingsGoal,
      'totalDebt': totalDebt,
      'creditScore': creditScore,
      'preferredCurrency': preferredCurrency,
      'financialKnowledgeLevel': financialKnowledgeLevel,
    };
  }
}
