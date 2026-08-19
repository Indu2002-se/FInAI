import 'package:flutter/foundation.dart';
import '../../router/route_names.dart';

/// Navigation Helper Utility
/// Provides utilities for testing and debugging navigation
class NavigationHelper {
  NavigationHelper._();

  /// Get all available routes in the app
  static List<NavigationRoute> getAllRoutes() {
    return [
      // Authentication Routes
      NavigationRoute(
        name: 'Splash',
        path: RouteNames.splash,
        category: 'Authentication',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Login',
        path: RouteNames.login,
        category: 'Authentication',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Register',
        path: RouteNames.register,
        category: 'Authentication',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Forgot Password',
        path: RouteNames.forgotPassword,
        category: 'Authentication',
        hasBottomNav: false,
      ),

      // Onboarding Routes
      NavigationRoute(
        name: 'Onboarding Welcome',
        path: RouteNames.onboardingWelcome,
        category: 'Onboarding',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Personal Information',
        path: RouteNames.onboardingPersonal,
        category: 'Onboarding',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Household Information',
        path: RouteNames.onboardingHousehold,
        category: 'Onboarding',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Employment Income',
        path: RouteNames.onboardingEmployment,
        category: 'Onboarding',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Financial Profile',
        path: RouteNames.onboardingFinancial,
        category: 'Onboarding',
        hasBottomNav: false,
      ),

      // Main Dashboard
      NavigationRoute(
        name: 'Dashboard',
        path: RouteNames.dashboard,
        category: 'Main',
        hasBottomNav: true,
        bottomNavIndex: 0,
      ),
      NavigationRoute(
        name: 'Profile',
        path: RouteNames.profile,
        category: 'Main',
        hasBottomNav: true,
        bottomNavIndex: 4,
      ),

      // Income Routes
      NavigationRoute(
        name: 'Income List',
        path: RouteNames.incomeList,
        category: 'Income',
        hasBottomNav: true,
        bottomNavIndex: 1,
      ),
      NavigationRoute(
        name: 'Add Income',
        path: RouteNames.addIncome,
        category: 'Income',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Edit Income',
        path: RouteNames.editIncome,
        category: 'Income',
        hasBottomNav: false,
        requiresParameter: true,
      ),

      // Expense Routes
      NavigationRoute(
        name: 'Expense List',
        path: RouteNames.expenseList,
        category: 'Expense',
        hasBottomNav: true,
        bottomNavIndex: 1,
      ),
      NavigationRoute(
        name: 'Add Expense',
        path: RouteNames.addExpense,
        category: 'Expense',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Edit Expense',
        path: RouteNames.editExpense,
        category: 'Expense',
        hasBottomNav: false,
        requiresParameter: true,
      ),

      // Budget Routes
      NavigationRoute(
        name: 'Budget Dashboard',
        path: RouteNames.budgetDashboard,
        category: 'Budget',
        hasBottomNav: true,
        bottomNavIndex: 2,
      ),
      NavigationRoute(
        name: 'Create Budget',
        path: RouteNames.createBudget,
        category: 'Budget',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Edit Budget',
        path: RouteNames.editBudget,
        category: 'Budget',
        hasBottomNav: false,
        requiresParameter: true,
      ),

      // AI Insights Routes
      NavigationRoute(
        name: 'AI Insights Dashboard',
        path: RouteNames.aiInsights,
        category: 'AI Insights',
        hasBottomNav: true,
        bottomNavIndex: 3,
      ),
      NavigationRoute(
        name: 'Financial Health',
        path: RouteNames.financialHealth,
        category: 'AI Insights',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Financial Risk',
        path: RouteNames.financialRisk,
        category: 'AI Insights',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Expense Forecast',
        path: RouteNames.expenseForecast,
        category: 'AI Insights',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'AI Recommendations',
        path: RouteNames.aiRecommendations,
        category: 'AI Insights',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'AI Recommendation Detail',
        path: RouteNames.aiRecommendationDetail,
        category: 'AI Insights',
        hasBottomNav: false,
        requiresParameter: true,
      ),

      // Reports Routes
      NavigationRoute(
        name: 'Reports Dashboard',
        path: RouteNames.reports,
        category: 'Reports',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Monthly Report',
        path: RouteNames.monthlyReport,
        category: 'Reports',
        hasBottomNav: false,
      ),

      // Savings Routes
      NavigationRoute(
        name: 'Savings Goals',
        path: RouteNames.savingsGoals,
        category: 'Savings',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Create Savings Goal',
        path: RouteNames.createSavingsGoal,
        category: 'Savings',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Savings Goal Detail',
        path: RouteNames.savingsGoalDetail,
        category: 'Savings',
        hasBottomNav: false,
        requiresParameter: true,
      ),

      // Child Literacy Routes
      NavigationRoute(
        name: 'Child Dashboard',
        path: RouteNames.childDashboard,
        category: 'Child Literacy',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Child Savings Goal',
        path: RouteNames.childSavingsGoal,
        category: 'Child Literacy',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Chores Rewards',
        path: RouteNames.choresRewards,
        category: 'Child Literacy',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Financial Quiz',
        path: RouteNames.financialQuiz,
        category: 'Child Literacy',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Quiz Result',
        path: RouteNames.quizResult,
        category: 'Child Literacy',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Wishlist',
        path: RouteNames.wishlist,
        category: 'Child Literacy',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Rewards',
        path: RouteNames.rewards,
        category: 'Child Literacy',
        hasBottomNav: false,
      ),

      // Settings Routes
      NavigationRoute(
        name: 'Settings',
        path: RouteNames.settings,
        category: 'Settings',
        hasBottomNav: false,
      ),
      NavigationRoute(
        name: 'Notification Settings',
        path: RouteNames.notificationSettings,
        category: 'Settings',
        hasBottomNav: false,
      ),
    ];
  }

  /// Get routes by category
  static List<NavigationRoute> getRoutesByCategory(String category) {
    return getAllRoutes().where((route) => route.category == category).toList();
  }

  /// Get all bottom navigation routes
  static List<NavigationRoute> getBottomNavRoutes() {
    return getAllRoutes()
        .where((route) => route.hasBottomNav)
        .toList()
      ..sort((a, b) =>
          (a.bottomNavIndex ?? 0).compareTo(b.bottomNavIndex ?? 0));
  }

  /// Get route statistics
  static NavigationStats getStats() {
    final routes = getAllRoutes();
    final categories = routes.map((r) => r.category).toSet();

    return NavigationStats(
      totalRoutes: routes.length,
      totalCategories: categories.length,
      bottomNavRoutes: routes.where((r) => r.hasBottomNav).length,
      parameterizedRoutes: routes.where((r) => r.requiresParameter).length,
      categoryCounts: {
        for (var category in categories)
          category: routes.where((r) => r.category == category).length,
      },
    );
  }

  /// Print navigation summary (for debugging)
  static void printNavigationSummary() {
    if (kDebugMode) {
      final stats = getStats();
      print('=== FinAI Navigation Summary ===');
      print('Total Routes: ${stats.totalRoutes}');
      print('Total Categories: ${stats.totalCategories}');
      print('Bottom Nav Routes: ${stats.bottomNavRoutes}');
      print('Parameterized Routes: ${stats.parameterizedRoutes}');
      print('\nRoutes by Category:');
      stats.categoryCounts.forEach((category, count) {
        print('  $category: $count routes');
      });
      print('================================');
    }
  }

  /// Validate route path format
  static bool isValidRoutePath(String path) {
    return path.startsWith('/') && path.isNotEmpty;
  }
}

/// Represents a navigation route in the app
class NavigationRoute {
  final String name;
  final String path;
  final String category;
  final bool hasBottomNav;
  final int? bottomNavIndex;
  final bool requiresParameter;

  NavigationRoute({
    required this.name,
    required this.path,
    required this.category,
    this.hasBottomNav = false,
    this.bottomNavIndex,
    this.requiresParameter = false,
  });

  @override
  String toString() {
    return 'NavigationRoute(name: $name, path: $path, category: $category)';
  }
}

/// Navigation statistics
class NavigationStats {
  final int totalRoutes;
  final int totalCategories;
  final int bottomNavRoutes;
  final int parameterizedRoutes;
  final Map<String, int> categoryCounts;

  NavigationStats({
    required this.totalRoutes,
    required this.totalCategories,
    required this.bottomNavRoutes,
    required this.parameterizedRoutes,
    required this.categoryCounts,
  });
}
