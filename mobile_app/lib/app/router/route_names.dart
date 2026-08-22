/// Route names for the application
class RouteNames {
  // Private constructor to prevent instantiation
  RouteNames._();

  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Onboarding routes
  static const String onboardingWelcome = '/onboarding/welcome';
  static const String onboardingPersonal = '/onboarding/personal';
  static const String onboardingHousehold = '/onboarding/household';
  static const String onboardingEmployment = '/onboarding/employment';
  static const String onboardingFinancial = '/onboarding/financial';

  // Main app routes
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';

  // Income routes
  static const String incomeList = '/income';
  static const String addIncome = '/income/add';
  static const String editIncome = '/income/edit';

  // Expense routes
  static const String expenseList = '/expense';
  static const String addExpense = '/expense/add';
  static const String editExpense = '/expense/edit';

  // Budget routes
  static const String budgetDashboard = '/budget';
  static const String createBudget = '/budget/create';
  static const String editBudget = '/budget/edit';

  // AI Insights routes
  static const String aiInsights = '/ai-insights';
  static const String financialHealth = '/ai-insights/health';
  static const String financialRisk = '/ai-insights/risk';
  static const String expenseForecast = '/ai-insights/forecast';
  static const String aiRecommendations = '/ai-insights/recommendations';
  static const String aiRecommendationDetail = '/ai-insights/recommendation-detail';

  // Reports routes
  static const String reports = '/reports';
  static const String monthlyReport = '/reports/monthly';

  // Savings routes
  static const String savingsGoals = '/savings';
  static const String createSavingsGoal = '/savings/create';
  static const String savingsGoalDetail = '/savings/detail';
  static const String aiSavingsPlan = '/savings/ai-plan';

  // Child Literacy routes
  static const String childDashboard = '/child';
  static const String childSavingsGoal = '/child/goal';
  static const String choresRewards = '/child/chores';
  static const String financialQuiz = '/child/quiz';
  static const String quizResult = '/child/quiz-result';
  static const String wishlist = '/child/wishlist';
  static const String rewards = '/child/rewards';

  // Automatic Transaction Detection routes
  static const String detectedTransactions = '/transactions/detected';
  static const String detectionSettings = '/transactions/detection-settings';
  static const String transactionReview = '/transactions/detected/review';

  // Settings routes
  static const String settings = '/settings';
  static const String notificationSettings = '/settings/notifications';
}
