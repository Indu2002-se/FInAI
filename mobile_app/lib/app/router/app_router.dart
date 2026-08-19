import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Authentication
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';

// Onboarding
import '../../features/onboarding/presentation/screens/employment_income_screen.dart';
import '../../features/onboarding/presentation/screens/financial_profile_screen.dart';
import '../../features/onboarding/presentation/screens/household_information_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_welcome_screen.dart';
import '../../features/onboarding/presentation/screens/personal_information_screen.dart';

// Dashboard & Profile
import '../../features/dashboard/presentation/screens/main_dashboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

// Income Management
import '../../features/income/presentation/screens/income_list_screen.dart';
import '../../features/income/presentation/screens/add_income_screen.dart';
import '../../features/income/presentation/screens/edit_income_screen.dart';

// Expense Management
import '../../features/expense/presentation/screens/expense_list_screen.dart';
import '../../features/expense/presentation/screens/add_expense_screen.dart';
import '../../features/expense/presentation/screens/edit_expense_screen.dart';

// Budget Management
import '../../features/budget/presentation/screens/budget_dashboard_screen.dart';
import '../../features/budget/presentation/screens/create_budget_screen.dart';
import '../../features/budget/presentation/screens/edit_budget_screen.dart';

// AI Insights
import '../../features/ai_insights/presentation/screens/ai_insights_dashboard_screen.dart';
import '../../features/ai_insights/presentation/screens/financial_health_score_screen.dart';
import '../../features/ai_insights/presentation/screens/financial_risk_prediction_screen.dart';
import '../../features/ai_insights/presentation/screens/expense_forecast_screen.dart';
import '../../features/ai_insights/presentation/screens/ai_recommendations_screen.dart';
import '../../features/ai_insights/presentation/screens/ai_recommendation_detail_screen.dart';

// Reports
import '../../features/reports/presentation/screens/reports_dashboard_screen.dart';
import '../../features/reports/presentation/screens/monthly_report_screen.dart';

// Savings Goals
import '../../features/savings/presentation/screens/savings_goals_dashboard_screen.dart';
import '../../features/savings/presentation/screens/create_savings_goal_screen.dart';
import '../../features/savings/presentation/screens/savings_goal_detail_screen.dart';

// Child Financial Literacy
import '../../features/child_literacy/presentation/screens/child_savings_dashboard_screen.dart';
import '../../features/child_literacy/presentation/screens/child_savings_goal_screen.dart';
import '../../features/child_literacy/presentation/screens/chores_rewards_screen.dart';
import '../../features/child_literacy/presentation/screens/financial_quiz_screen.dart';
import '../../features/child_literacy/presentation/screens/quiz_result_screen.dart';
import '../../features/child_literacy/presentation/screens/wishlist_screen.dart';
import '../../features/child_literacy/presentation/screens/rewards_screen.dart';

// Settings
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/notification_settings_screen.dart';

import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      // ==================== Authentication Routes ====================
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ==================== Onboarding Routes ====================
      GoRoute(
        path: RouteNames.onboardingWelcome,
        name: 'onboarding-welcome',
        builder: (context, state) => const OnboardingWelcomeScreen(),
      ),
      GoRoute(
        path: RouteNames.onboardingPersonal,
        name: 'onboarding-personal',
        builder: (context, state) => const PersonalInformationScreen(),
      ),
      GoRoute(
        path: RouteNames.onboardingHousehold,
        name: 'onboarding-household',
        builder: (context, state) => const HouseholdInformationScreen(),
      ),
      GoRoute(
        path: RouteNames.onboardingEmployment,
        name: 'onboarding-employment',
        builder: (context, state) => const EmploymentIncomeScreen(),
      ),
      GoRoute(
        path: RouteNames.onboardingFinancial,
        name: 'onboarding-financial',
        builder: (context, state) => const FinancialProfileScreen(),
      ),

      // ==================== Main Dashboard & Profile ====================
      GoRoute(
        path: RouteNames.dashboard,
        name: 'dashboard',
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // ==================== Income Management Routes ====================
      GoRoute(
        path: RouteNames.incomeList,
        name: 'income-list',
        builder: (context, state) => const IncomeListScreen(),
      ),
      GoRoute(
        path: RouteNames.addIncome,
        name: 'add-income',
        builder: (context, state) => const AddIncomeScreen(),
      ),
      GoRoute(
        path: '${RouteNames.editIncome}/:id',
        name: 'edit-income',
        builder: (context, state) {
          // TODO: Pass incomeId to screen once constructor supports it
          return const EditIncomeScreen();
        },
      ),

      // ==================== Expense Management Routes ====================
      GoRoute(
        path: RouteNames.expenseList,
        name: 'expense-list',
        builder: (context, state) => const ExpenseListScreen(),
      ),
      GoRoute(
        path: RouteNames.addExpense,
        name: 'add-expense',
        builder: (context, state) => const AddExpenseScreen(),
      ),
      GoRoute(
        path: '${RouteNames.editExpense}/:id',
        name: 'edit-expense',
        builder: (context, state) {
          // TODO: Pass expenseId to screen once constructor supports it
          return const EditExpenseScreen();
        },
      ),

      // ==================== Budget Management Routes ====================
      GoRoute(
        path: RouteNames.budgetDashboard,
        name: 'budget-dashboard',
        builder: (context, state) => const BudgetDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.createBudget,
        name: 'create-budget',
        builder: (context, state) => const CreateBudgetScreen(),
      ),
      GoRoute(
        path: '${RouteNames.editBudget}/:id',
        name: 'edit-budget',
        builder: (context, state) {
          // TODO: Pass budgetId to screen once constructor supports it
          return const EditBudgetScreen();
        },
      ),

      // ==================== AI Insights Routes ====================
      GoRoute(
        path: RouteNames.aiInsights,
        name: 'ai-insights',
        builder: (context, state) => const AIInsightsDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.financialHealth,
        name: 'financial-health',
        builder: (context, state) => const FinancialHealthScoreScreen(),
      ),
      GoRoute(
        path: RouteNames.financialRisk,
        name: 'financial-risk',
        builder: (context, state) => const FinancialRiskPredictionScreen(),
      ),
      GoRoute(
        path: RouteNames.expenseForecast,
        name: 'expense-forecast',
        builder: (context, state) => const ExpenseForecastScreen(),
      ),
      GoRoute(
        path: RouteNames.aiRecommendations,
        name: 'ai-recommendations',
        builder: (context, state) => const AIRecommendationsScreen(),
      ),
      GoRoute(
        path: '${RouteNames.aiRecommendationDetail}/:id',
        name: 'ai-recommendation-detail',
        builder: (context, state) {
          // TODO: Pass recommendationId to screen once constructor supports it
          return const AIRecommendationDetailScreen();
        },
      ),

      // ==================== Reports Routes ====================
      GoRoute(
        path: RouteNames.reports,
        name: 'reports',
        builder: (context, state) => const ReportsDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.monthlyReport,
        name: 'monthly-report',
        builder: (context, state) => const MonthlyReportScreen(),
      ),

      // ==================== Savings Goals Routes ====================
      GoRoute(
        path: RouteNames.savingsGoals,
        name: 'savings-goals',
        builder: (context, state) => const SavingsGoalsDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.createSavingsGoal,
        name: 'create-savings-goal',
        builder: (context, state) => const CreateSavingsGoalScreen(),
      ),
      GoRoute(
        path: '${RouteNames.savingsGoalDetail}/:id',
        name: 'savings-goal-detail',
        builder: (context, state) {
          // TODO: Pass goalId to screen once constructor supports it
          return const SavingsGoalDetailScreen();
        },
      ),

      // ==================== Child Financial Literacy Routes ====================
      GoRoute(
        path: RouteNames.childDashboard,
        name: 'child-dashboard',
        builder: (context, state) => const ChildSavingsDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.childSavingsGoal,
        name: 'child-savings-goal',
        builder: (context, state) => const ChildSavingsGoalScreen(),
      ),
      GoRoute(
        path: RouteNames.choresRewards,
        name: 'chores-rewards',
        builder: (context, state) => const ChoresRewardsScreen(),
      ),
      GoRoute(
        path: RouteNames.financialQuiz,
        name: 'financial-quiz',
        builder: (context, state) => const FinancialQuizScreen(),
      ),
      GoRoute(
        path: RouteNames.quizResult,
        name: 'quiz-result',
        builder: (context, state) => const QuizResultScreen(),
      ),
      GoRoute(
        path: RouteNames.wishlist,
        name: 'wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: RouteNames.rewards,
        name: 'rewards',
        builder: (context, state) => const RewardsScreen(),
      ),

      // ==================== Settings Routes ====================
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.notificationSettings,
        name: 'notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
    ],
  );
});
