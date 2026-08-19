# FinAI Mobile App - Navigation Guide

## Overview
This document provides a comprehensive guide to navigation in the FinAI mobile app, including all 40 screens, their routes, and navigation patterns.

## Navigation Architecture

### Router: GoRouter
- **Package**: `go_router`
- **Configuration**: `lib/app/router/app_router.dart`
- **Route Names**: `lib/app/router/route_names.dart`

### Navigation Methods
1. **Push Navigation**: `context.push('/route')` - Adds new screen to navigation stack
2. **Go Navigation**: `context.go('/route')` - Replaces current screen
3. **Pop Navigation**: `context.pop()` - Returns to previous screen

## Screen Categories & Routes

### 1. Authentication Screens (4 screens)

#### Splash Screen
- **Route**: `/` (RouteNames.splash)
- **Path**: `lib/features/authentication/presentation/screens/splash_screen.dart`
- **Navigation**: Auto-navigates to login after delay
- **Access**: Initial app entry point

#### Login Screen
- **Route**: `/login` (RouteNames.login)
- **Path**: `lib/features/authentication/presentation/screens/login_screen.dart`
- **Navigation**: 
  - Sign Up → `/register`
  - Forgot Password → `/forgot-password`
  - Success → `/dashboard`
- **Bottom Nav**: No

#### Register Screen
- **Route**: `/register` (RouteNames.register)
- **Path**: `lib/features/authentication/presentation/screens/register_screen.dart`
- **Navigation**: 
  - Back → pop()
  - Success → `/onboarding/welcome` or `/dashboard`
- **Bottom Nav**: No

#### Forgot Password Screen
- **Route**: `/forgot-password` (RouteNames.forgotPassword)
- **Path**: `lib/features/authentication/presentation/screens/forgot_password_screen.dart`
- **Navigation**: 
  - Back → pop()
  - Success → `/login`
- **Bottom Nav**: No

---

### 2. Onboarding Screens (5 screens)

#### Onboarding Welcome
- **Route**: `/onboarding/welcome` (RouteNames.onboardingWelcome)
- **Path**: `lib/features/onboarding/presentation/screens/onboarding_welcome_screen.dart`
- **Navigation**: Next → `/onboarding/personal`
- **Bottom Nav**: No

#### Personal Information (Step 1/4)
- **Route**: `/onboarding/personal` (RouteNames.onboardingPersonal)
- **Path**: `lib/features/onboarding/presentation/screens/personal_information_screen.dart`
- **Navigation**: 
  - Back → pop()
  - Next → `/onboarding/household`
- **Bottom Nav**: No

#### Household Information (Step 2/4)
- **Route**: `/onboarding/household` (RouteNames.onboardingHousehold)
- **Path**: `lib/features/onboarding/presentation/screens/household_information_screen.dart`
- **Navigation**: 
  - Back → pop()
  - Next → `/onboarding/employment`
- **Bottom Nav**: No

#### Employment & Income (Step 3/4)
- **Route**: `/onboarding/employment` (RouteNames.onboardingEmployment)
- **Path**: `lib/features/onboarding/presentation/screens/employment_income_screen.dart`
- **Navigation**: 
  - Back → pop()
  - Next → `/onboarding/financial`
- **Bottom Nav**: No

#### Financial Profile (Step 4/4)
- **Route**: `/onboarding/financial` (RouteNames.onboardingFinancial)
- **Path**: `lib/features/onboarding/presentation/screens/financial_profile_screen.dart`
- **Navigation**: 
  - Back → pop()
  - Complete → `/dashboard`
- **Bottom Nav**: No

---

### 3. Main Dashboard (1 screen)

#### Main Dashboard
- **Route**: `/dashboard` (RouteNames.dashboard)
- **Path**: `lib/features/dashboard/presentation/screens/main_dashboard_screen.dart`
- **Navigation**: 
  - Quick Actions → `/income/add`, `/expense/add`, `/budget`
  - Health Score → `/ai-insights/health`
  - Transactions → `/expense`
  - Reports → `/reports`
  - Recommendations → `/ai-insights/recommendations`
- **Bottom Nav**: Yes (Index: 0)

---

### 4. Income Management (3 screens)

#### Income List
- **Route**: `/income` (RouteNames.incomeList)
- **Path**: `lib/features/income/presentation/screens/income_list_screen.dart`
- **Navigation**: 
  - Add Income → `/income/add`
  - Edit Income → `/income/edit/:id`
- **Bottom Nav**: Yes (Index: 1)

#### Add Income
- **Route**: `/income/add` (RouteNames.addIncome)
- **Path**: `lib/features/income/presentation/screens/add_income_screen.dart`
- **Navigation**: 
  - Cancel → pop()
  - Save → pop()
- **Bottom Nav**: No

#### Edit Income
- **Route**: `/income/edit/:id` (RouteNames.editIncome)
- **Path**: `lib/features/income/presentation/screens/edit_income_screen.dart`
- **Navigation**: 
  - Cancel → pop()
  - Update → pop()
  - Delete → pop()
- **Bottom Nav**: No

---

### 5. Expense Management (3 screens)

#### Expense List
- **Route**: `/expense` (RouteNames.expenseList)
- **Path**: `lib/features/expense/presentation/screens/expense_list_screen.dart`
- **Navigation**: 
  - Add Expense → `/expense/add`
  - Edit Expense → `/expense/edit/:id`
- **Bottom Nav**: Yes (Index: 1)

#### Add Expense
- **Route**: `/expense/add` (RouteNames.addExpense)
- **Path**: `lib/features/expense/presentation/screens/add_expense_screen.dart`
- **Navigation**: 
  - Cancel → pop()
  - Save → pop()
- **Bottom Nav**: No

#### Edit Expense
- **Route**: `/expense/edit/:id` (RouteNames.editExpense)
- **Path**: `lib/features/expense/presentation/screens/edit_expense_screen.dart`
- **Navigation**: 
  - Cancel → pop()
  - Update → pop()
  - Delete → pop()
- **Bottom Nav**: No

---

### 6. Budget Management (3 screens)

#### Budget Dashboard
- **Route**: `/budget` (RouteNames.budgetDashboard)
- **Path**: `lib/features/budget/presentation/screens/budget_dashboard_screen.dart`
- **Navigation**: 
  - Create Budget → `/budget/create`
  - Edit Budget → `/budget/edit/:id`
- **Bottom Nav**: Yes (Index: 2)

#### Create Budget
- **Route**: `/budget/create` (RouteNames.createBudget)
- **Path**: `lib/features/budget/presentation/screens/create_budget_screen.dart`
- **Navigation**: 
  - Cancel → pop()
  - Save → pop()
- **Bottom Nav**: No

#### Edit Budget
- **Route**: `/budget/edit/:id` (RouteNames.editBudget)
- **Path**: `lib/features/budget/presentation/screens/edit_budget_screen.dart`
- **Navigation**: 
  - Cancel → pop()
  - Update → pop()
  - Delete → pop()
- **Bottom Nav**: No

---

### 7. AI Insights (6 screens)

#### AI Insights Dashboard
- **Route**: `/ai-insights` (RouteNames.aiInsights)
- **Path**: `lib/features/ai_insights/presentation/screens/ai_insights_dashboard_screen.dart`
- **Navigation**: 
  - Health Score → `/ai-insights/health`
  - Risk Prediction → `/ai-insights/risk`
  - Forecast → `/ai-insights/forecast`
  - Recommendations → `/ai-insights/recommendations`
- **Bottom Nav**: Yes (Index: 3)

#### Financial Health Score
- **Route**: `/ai-insights/health` (RouteNames.financialHealth)
- **Path**: `lib/features/ai_insights/presentation/screens/financial_health_score_screen.dart`
- **Navigation**: Back → pop()
- **Bottom Nav**: No

#### Financial Risk Prediction
- **Route**: `/ai-insights/risk` (RouteNames.financialRisk)
- **Path**: `lib/features/ai_insights/presentation/screens/financial_risk_prediction_screen.dart`
- **Navigation**: Back → pop()
- **Bottom Nav**: No

#### Expense Forecast
- **Route**: `/ai-insights/forecast` (RouteNames.expenseForecast)
- **Path**: `lib/features/ai_insights/presentation/screens/expense_forecast_screen.dart`
- **Navigation**: Back → pop()
- **Bottom Nav**: No

#### AI Recommendations List
- **Route**: `/ai-insights/recommendations` (RouteNames.aiRecommendations)
- **Path**: `lib/features/ai_insights/presentation/screens/ai_recommendations_screen.dart`
- **Navigation**: Recommendation → `/ai-insights/recommendation-detail/:id`
- **Bottom Nav**: No

#### AI Recommendation Detail
- **Route**: `/ai-insights/recommendation-detail/:id` (RouteNames.aiRecommendationDetail)
- **Path**: `lib/features/ai_insights/presentation/screens/ai_recommendation_detail_screen.dart`
- **Navigation**: Back → pop()
- **Bottom Nav**: No

---

### 8. Financial Reports (2 screens)

#### Reports Dashboard
- **Route**: `/reports` (RouteNames.reports)
- **Path**: `lib/features/reports/presentation/screens/reports_dashboard_screen.dart`
- **Navigation**: Monthly Report → `/reports/monthly`
- **Bottom Nav**: No

#### Monthly Report
- **Route**: `/reports/monthly` (RouteNames.monthlyReport)
- **Path**: `lib/features/reports/presentation/screens/monthly_report_screen.dart`
- **Navigation**: Back → pop()
- **Bottom Nav**: No

---

### 9. Savings Goals (3 screens)

#### Savings Goals Dashboard
- **Route**: `/savings` (RouteNames.savingsGoals)
- **Path**: `lib/features/savings/presentation/screens/savings_goals_dashboard_screen.dart`
- **Navigation**: 
  - Create Goal → `/savings/create`
  - Goal Detail → `/savings/detail/:id`
- **Bottom Nav**: No

#### Create Savings Goal
- **Route**: `/savings/create` (RouteNames.createSavingsGoal)
- **Path**: `lib/features/savings/presentation/screens/create_savings_goal_screen.dart`
- **Navigation**: 
  - Cancel → pop()
  - Save → pop()
- **Bottom Nav**: No

#### Savings Goal Detail
- **Route**: `/savings/detail/:id` (RouteNames.savingsGoalDetail)
- **Path**: `lib/features/savings/presentation/screens/savings_goal_detail_screen.dart`
- **Navigation**: 
  - Back → pop()
  - Add Contribution → Show dialog
- **Bottom Nav**: No

---

### 10. Child Financial Literacy (7 screens)

#### Child Dashboard
- **Route**: `/child` (RouteNames.childDashboard)
- **Path**: `lib/features/child_literacy/presentation/screens/child_savings_dashboard_screen.dart`
- **Navigation**: 
  - Savings Goal → `/child/goal`
  - Chores → `/child/chores`
  - Quiz → `/child/quiz`
  - Wishlist → `/child/wishlist`
  - Rewards → `/child/rewards`
- **Bottom Nav**: No

#### Child Savings Goal
- **Route**: `/child/goal` (RouteNames.childSavingsGoal)
- **Path**: `lib/features/child_literacy/presentation/screens/child_savings_goal_screen.dart`
- **Navigation**: Back → pop()
- **Bottom Nav**: No

#### Chores & Rewards
- **Route**: `/child/chores` (RouteNames.choresRewards)
- **Path**: `lib/features/child_literacy/presentation/screens/chores_rewards_screen.dart`
- **Navigation**: Back → pop()
- **Bottom Nav**: No

#### Financial Quiz
- **Route**: `/child/quiz` (RouteNames.financialQuiz)
- **Path**: `lib/features/child_literacy/presentation/screens/financial_quiz_screen.dart`
- **Navigation**: Complete → `/child/quiz-result`
- **Bottom Nav**: No

#### Quiz Result
- **Route**: `/child/quiz-result` (RouteNames.quizResult)
- **Path**: `lib/features/child_literacy/presentation/screens/quiz_result_screen.dart`
- **Navigation**: 
  - Retry → pop()
  - Back → pop()
- **Bottom Nav**: No

#### Wishlist
- **Route**: `/child/wishlist` (RouteNames.wishlist)
- **Path**: `lib/features/child_literacy/presentation/screens/wishlist_screen.dart`
- **Navigation**: Back → pop()
- **Bottom Nav**: No

#### Rewards
- **Route**: `/child/rewards` (RouteNames.rewards)
- **Path**: `lib/features/child_literacy/presentation/screens/rewards_screen.dart`
- **Navigation**: Back → pop()
- **Bottom Nav**: No

---

### 11. Profile & Settings (3 screens)

#### Profile Screen
- **Route**: `/profile` (RouteNames.profile)
- **Path**: `lib/features/profile/presentation/screens/profile_screen.dart`
- **Navigation**: 
  - Edit Profile → Show dialog
  - Settings → `/settings`
  - Logout → `/login`
- **Bottom Nav**: Yes (Index: 4)

#### Settings
- **Route**: `/settings` (RouteNames.settings)
- **Path**: `lib/features/settings/presentation/screens/settings_screen.dart`
- **Navigation**: 
  - Notifications → `/settings/notifications`
  - Back → pop()
- **Bottom Nav**: No

#### Notification Settings
- **Route**: `/settings/notifications` (RouteNames.notificationSettings)
- **Path**: `lib/features/settings/presentation/screens/notification_settings_screen.dart`
- **Navigation**: Back → pop()
- **Bottom Nav**: No

---

## Bottom Navigation Structure

The app uses a persistent bottom navigation bar on 5 main screens:

| Index | Icon | Label | Route |
|-------|------|-------|-------|
| 0 | home_rounded | Home | /dashboard |
| 1 | receipt_long_rounded | Transactions | /expense |
| 2 | pie_chart_rounded | Budget | /budget |
| 3 | auto_awesome_rounded | AI Insights | /ai-insights |
| 4 | person_rounded | Profile | /profile |

### Bottom Navigation Implementation
- **Component**: `BottomNavigation` widget
- **Path**: `lib/app/core/widgets/bottom_navigation.dart`
- **Features**:
  - Gradient background for active items
  - Icon shadows
  - Smooth transitions
  - Active state management

---

## Navigation Patterns

### 1. Stack Navigation (Push/Pop)
Used for detail screens and forms:
```dart
// Push
context.push('/expense/add');

// Pop
context.pop();
```

### 2. Root Navigation (Go)
Used for main screens and replacing stack:
```dart
context.go('/dashboard');
```

### 3. Parameterized Routes
For detail screens with IDs:
```dart
context.push('/expense/edit/123');
context.push('/savings/detail/456');
```

---

## Testing Navigation

### Manual Testing Checklist

#### Authentication Flow
- [ ] Splash → Login
- [ ] Login → Dashboard
- [ ] Login → Register
- [ ] Register → Onboarding
- [ ] Onboarding (4 steps) → Dashboard

#### Bottom Navigation
- [ ] Dashboard → Transactions
- [ ] Transactions → Budget
- [ ] Budget → AI Insights
- [ ] AI Insights → Profile
- [ ] Profile → Dashboard

#### Income Management
- [ ] Dashboard → Add Income
- [ ] Income List → Add Income
- [ ] Income List → Edit Income
- [ ] Edit Income → Delete → Income List

#### Expense Management
- [ ] Dashboard → Add Expense
- [ ] Expense List → Add Expense
- [ ] Expense List → Edit Expense
- [ ] Edit Expense → Delete → Expense List

#### Budget Management
- [ ] Dashboard → Budget Dashboard
- [ ] Budget Dashboard → Create Budget
- [ ] Budget Dashboard → Edit Budget

#### AI Insights
- [ ] Dashboard → Financial Health
- [ ] AI Dashboard → All 4 sub-screens
- [ ] Recommendations List → Recommendation Detail

#### Deep Navigation
- [ ] Profile → Settings → Notifications
- [ ] Child Dashboard → All 7 child screens
- [ ] Savings → Create Goal → Save → Dashboard

---

## Common Navigation Issues & Solutions

### Issue: Back button not working
**Solution**: Ensure screen has proper AppBar with leading IconButton:
```dart
leading: IconButton(
  icon: Icon(Icons.arrow_back),
  onPressed: () => context.pop(),
)
```

### Issue: Bottom nav not showing on main screen
**Solution**: Add BottomNavigation widget:
```dart
bottomNavigationBar: const BottomNavigation(currentIndex: 0),
```

### Issue: Route not found
**Solution**: Check route is defined in `app_router.dart` and RouteNames constant exists

### Issue: Navigation state lost
**Solution**: Use `context.go()` for root navigation, `context.push()` for stack navigation

---

## Future Enhancements

1. **Deep Linking**: Add URL-based navigation for web and app links
2. **Route Guards**: Add authentication checks before route access
3. **Transition Animations**: Custom page transitions between screens
4. **Navigation History**: Track and display user navigation history
5. **Back Button Override**: Handle Android back button properly

---

## Summary

✅ **Total Screens**: 40
✅ **Total Routes**: 40
✅ **Bottom Nav Screens**: 5
✅ **Authentication Screens**: 4
✅ **Onboarding Screens**: 5
✅ **Main Feature Screens**: 26

All screens are properly connected with navigation, and the app provides a seamless user experience across all features.
