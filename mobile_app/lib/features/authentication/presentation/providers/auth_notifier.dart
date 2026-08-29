import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai_insights/presentation/providers/ai_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../expense/presentation/providers/expense_provider.dart';
import '../../../income/presentation/providers/income_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../reports/presentation/providers/report_provider.dart';
import '../../../savings/presentation/providers/savings_provider.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/google_login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../../transaction_detection/data/models/detection_settings.dart';
import '../../../transaction_detection/data/repositories/transaction_detection_repository.dart';
import '../../../transaction_detection/presentation/providers/transaction_detection_provider.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GoogleLoginUseCase googleLoginUseCase;

  AuthNotifier({
    required this.ref,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.googleLoginUseCase,
  }) : super(const AuthState.initial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final result = await loginUseCase(email: email, password: password);
      _invalidateUserScopedProviders();
      state = AuthState.authenticated(result);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = const AuthState.loading();
    try {
      final result = await registerUseCase(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      _invalidateUserScopedProviders();
      // Ensure SMS detection toggle is OFF by default for newly signed up user
      try {
        final detectionRepo = ref.read(transactionDetectionRepositoryProvider);
        await detectionRepo.updateSettings(
          DetectionSettingsModel(
            id: 0,
            smsEnabled: false,
            notificationEnabled: true,
            confirmationRequired: true,
          ),
        );
      } catch (_) {
        // Fallback gracefully if backend is offline; DetectionSettingsModel defaults to false
      }
      ref.invalidate(detectionSettingsProvider);
      ref.invalidate(pendingDetectedTransactionsProvider);
      ref.invalidate(allDetectedTransactionsProvider);
      state = AuthState.authenticated(result);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();
    try {
      final result = await googleLoginUseCase();
      // Closing the account picker is expected and should not show an error.
      if (result == null) {
        state = const AuthState.initial();
        return;
      }
      _invalidateUserScopedProviders();
      state = AuthState.authenticated(result);
    } catch (error) {
      state = AuthState.error(error.toString());
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase();
      _invalidateUserScopedProviders();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  void clearError() {
    state = const AuthState.initial();
  }

  /// Clears cached finance data so the next user never sees another account's list.
  void _invalidateUserScopedProviders() {
    ref.invalidate(expenseListProvider);
    ref.invalidate(incomeListProvider);
    ref.invalidate(dashboardFutureProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(savingsListProvider);
    ref.invalidate(savingsGoalsListProvider);
    ref.invalidate(monthlyReportProvider);
    ref.invalidate(currentBudgetStatusProvider);
    ref.invalidate(budgetStatusProvider);
    ref.invalidate(budgetListProvider);
    ref.invalidate(latestAiAnalysisProvider);
    ref.invalidate(riskPredictionProvider);
    ref.invalidate(expenseForecastProvider);
    ref.invalidate(aiRecommendationProvider);
    ref.invalidate(savingsPlanProvider);
    ref.invalidate(detectionSettingsProvider);
    ref.invalidate(pendingDetectedTransactionsProvider);
    ref.invalidate(allDetectedTransactionsProvider);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final registerUseCase = ref.watch(registerUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final googleLoginUseCase = ref.watch(googleLoginUseCaseProvider);

  return AuthNotifier(
    ref: ref,
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    logoutUseCase: logoutUseCase,
    googleLoginUseCase: googleLoginUseCase,
  );
});
