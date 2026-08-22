import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds wizard form data as the user progresses through steps.
/// Data is accumulated across screens and submitted on the final step.
class OnboardingState {
  // Step 1 – Personal Information
  final String name;
  final int age;
  final String gender;
  final String location;

  // Step 2 – Household Information
  final int householdSize;
  final int dependentsCount;

  // Step 3 – Employment & Income
  final String employmentStatus; // maps to EmploymentStatus enum
  final double monthlyIncome;

  // Step 4 – Financial Profile
  final double monthlyExpense;
  final double savingsGoal;
  final String financialKnowledgeLevel; // maps to FinancialKnowledgeLevel enum
  final double currentDebt;
  final String riskTolerance;

  // Currency (always LKR for Sri Lanka)
  final String preferredCurrency;

  const OnboardingState({
    this.name = '',
    this.age = 0,
    this.gender = '',
    this.location = '',
    this.householdSize = 1,
    this.dependentsCount = 0,
    this.employmentStatus = 'EMPLOYED',
    this.monthlyIncome = 0,
    this.monthlyExpense = 0,
    this.savingsGoal = 0,
    this.financialKnowledgeLevel = 'BEGINNER',
    this.currentDebt = 0,
    this.riskTolerance = '',
    this.preferredCurrency = 'LKR',
  });

  OnboardingState copyWith({
    String? name,
    int? age,
    String? gender,
    String? location,
    int? householdSize,
    int? dependentsCount,
    String? employmentStatus,
    double? monthlyIncome,
    double? monthlyExpense,
    double? savingsGoal,
    String? financialKnowledgeLevel,
    double? currentDebt,
    String? riskTolerance,
    String? preferredCurrency,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      householdSize: householdSize ?? this.householdSize,
      dependentsCount: dependentsCount ?? this.dependentsCount,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      financialKnowledgeLevel:
          financialKnowledgeLevel ?? this.financialKnowledgeLevel,
      currentDebt: currentDebt ?? this.currentDebt,
      riskTolerance: riskTolerance ?? this.riskTolerance,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
    );
  }

  /// Builds the wizard API payload matching WizardRequest.java
  Map<String, dynamic> toWizardJson() {
    return {
      'monthlyIncome': monthlyIncome,
      'monthlyExpense': monthlyExpense,
      'savingsGoal': savingsGoal,
      'employmentStatus': employmentStatus,
      'financialKnowledgeLevel': financialKnowledgeLevel,
      'preferredCurrency': preferredCurrency,
    };
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void updatePersonal({
    required String name,
    required int age,
    required String gender,
    required String location,
  }) {
    state = state.copyWith(
      name: name,
      age: age,
      gender: gender,
      location: location,
    );
  }

  void updateHousehold({
    required int householdSize,
    required int dependentsCount,
  }) {
    state = state.copyWith(
      householdSize: householdSize,
      dependentsCount: dependentsCount,
    );
  }

  void updateEmployment({
    required String employmentStatus,
    required double monthlyIncome,
  }) {
    state = state.copyWith(
      employmentStatus: employmentStatus,
      monthlyIncome: monthlyIncome,
    );
  }

  void updateFinancial({
    required double monthlyExpense,
    required double savingsGoal,
    required String financialKnowledgeLevel,
    required double currentDebt,
    required String riskTolerance,
  }) {
    state = state.copyWith(
      monthlyExpense: monthlyExpense,
      savingsGoal: savingsGoal,
      financialKnowledgeLevel: financialKnowledgeLevel,
      currentDebt: currentDebt,
      riskTolerance: riskTolerance,
    );
  }

  void reset() {
    state = const OnboardingState();
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);
