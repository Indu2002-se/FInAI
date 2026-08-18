# FinAI Flutter Frontend -- Complete Implementation Plan

## 1. Current Status

Already completed: - \[x\] Flutter project and Clean Architecture
foundation - \[x\] Riverpod - \[x\] GoRouter - \[x\] Dio - \[x\] Flutter
Secure Storage - \[x\] Shared Preferences - \[x\] Google Fonts - \[x\]
App theme - \[x\] Splash screen - \[x\] Login route/placeholder - \[x\]
GitHub Actions Flutter CI - \[x\] CI build/analyze/test passing

Do not recreate the foundation unless a real issue is found.

## 2. Target Architecture

``` text
Flutter Mobile App
        |
        | REST API
        v
Spring Boot Backend
        |
        | REST API
        v
FastAPI AI/ML Service
        |
   XGBoost / Prophet / SHAP

Spring Boot <----> MySQL
```

Flutter is the client application. Spring Boot owns authentication and
financial business logic. FastAPI owns ML processing. The frontend must
not duplicate backend or ML business logic.

## 3. Frontend Folder Structure

``` text
mobile_app/lib/
├── app/
│   ├── app.dart
│   ├── router/app_router.dart
│   ├── theme/app_theme.dart
│   └── core/
│       ├── constants/
│       ├── errors/
│       ├── network/
│       ├── storage/
│       └── widgets/
├── features/
│   ├── authentication/{data,domain,presentation}/
│   ├── onboarding/{data,domain,presentation}/
│   ├── dashboard/{data,domain,presentation}/
│   ├── income/{data,domain,presentation}/
│   ├── expense/{data,domain,presentation}/
│   ├── savings/{data,domain,presentation}/
│   ├── budget/{data,domain,presentation}/
│   ├── ai_insights/{data,domain,presentation}/
│   ├── reports/{data,domain,presentation}/
│   ├── children/{data,domain,presentation}/
│   └── profile/{data,domain,presentation}/
└── main.dart
```

## 4. Common Clean Architecture Rule

Use:

``` text
Screen
  -> Riverpod Provider/Notifier
  -> Use Case
  -> Repository
  -> Remote Data Source
  -> Dio
  -> Spring Boot API
```

UI must not call Dio directly.

## 5. Implementation Order

### Step 1 --- Authentication

**Issue:** `frontend: implement authentication integration`

**Branch:** `feature/flutter-authentication`

Implement: - Login - Registration - Form validation - JWT storage - Auth
state - Session restoration - Logout - Unauthorized handling - Protected
routes - Splash authentication check

Done when: - Register/login work - Invalid credentials show an error -
Token is securely stored - Restart preserves valid session - Logout
clears the token - Protected routes are blocked

### Step 2 --- Onboarding

**Issue:** `frontend: implement user onboarding and demographic profile`

**Branch:** `feature/flutter-onboarding`

Implement: - Age - Employment status/category - Occupation - Family
size - Income sources - Monthly income - Household/dependency
information - Multi-step wizard - Validation - Backend submission

Done when completed users go to Dashboard and incomplete users are
redirected to onboarding.

### Step 3 --- Dashboard

**Issue:** `frontend: implement financial dashboard`

**Branch:** `feature/flutter-dashboard`

Display: - Total income - Total expenses - Savings - Budget status -
Recent transactions - Financial Health Score - Risk indicator - Expense
forecast summary - AI recommendation summary

Quick actions: - Add income - Add expense - Add saving - Budget - AI
insights - Reports

### Step 4 --- Income

**Issue:** `frontend: implement income management`

**Branch:** `feature/flutter-income`

Implement: - List - Add - Edit - Delete - Multiple income sources -
Amount/date/category/description

### Step 5 --- Expense

**Issue:** `frontend: implement expense management`

**Branch:** `feature/flutter-expense`

Implement: - List - Add/edit/delete - Categories -
Amount/date/description - Filtering - Monthly summary - Category summary

Categories should support food, utilities, transportation, education,
healthcare, entertainment and other household expenses.

### Step 6 --- Savings and Debt

**Issue:** `frontend: implement savings and debt management`

**Branch:** `feature/flutter-savings-debt`

Implement: - Savings balance/history - Savings goals and progress - Debt
information - Debt payments

### Step 7 --- Budget

**Issue:** `frontend: implement budget management and alerts`

**Branch:** `feature/flutter-budget`

Implement: - Create/edit/delete budget - Category/monthly budgets -
Spent amount - Remaining amount - Progress - Overspending indicators -
Budget alert state

### Step 8 --- AI Insights

**Issue:** `frontend: implement AI insights integration`

**Branch:** `feature/flutter-ai-insights`

Implement UI/API integration for: - Financial Health Score (1--100) -
Financial risk level - Risk factors - Expense forecast -
Monthly/category forecast - Trend visualization - Financial pressure
indicators - SHAP explanations - Personalized recommendations

Do not implement XGBoost, Prophet or SHAP in Flutter. Consume results
from the backend.

### Step 9 --- Reports

**Issue:** `frontend: implement financial reports`

**Branch:** `feature/flutter-reports`

Implement: - Monthly financial summary - Income summary - Expense
summary - Savings summary - Budget summary - Prediction summary -
Forecast summary - AI recommendation summary

### Step 10 --- Children's Savings

**Issue:** `frontend: implement children's savings module`

**Branch:** `feature/flutter-children`

Implement: - Child profile - Child savings balance - Savings
goals/progress - Chores/rewards - Child dashboard

This is medium priority; do it after the core financial and AI flow is
stable.

### Step 11 --- Financial Literacy and Gamification

**Issue:** `frontend: implement financial literacy and gamification`

**Branch:** `feature/flutter-financial-literacy`

Implement: - Financial quizzes - Answer selection/submission - Scores -
Badges - Rewards - Learning progress -
Budgeting/saving/responsible-spending/needs-vs-wants topics

### Step 12 --- Profile and Settings

**Issue:** `frontend: implement profile and settings`

**Branch:** `feature/flutter-profile-settings`

Implement: - View/edit profile - Household information - Income source
information - Logout - Basic app/account preferences

## 6. Navigation

``` text
Splash
  |
Authentication Check
  |-- Not Authenticated -> Login -> Register
  |
  `-- Authenticated
        |
     Profile Complete?
       |-- No -> Onboarding
       `-- Yes -> Dashboard
                     |-- Income
                     |-- Expenses
                     |-- Savings/Debt
                     |-- Budget
                     |-- AI Insights
                     |-- Reports
                     |-- Children
                     `-- Profile
```

Use GoRouter guards. Users must not bypass authentication or required
onboarding.

## 7. Network Layer

Create one reusable Dio client for: - Base URL - JWT authorization
header - Timeouts - JSON requests/responses - HTTP errors - Unauthorized
handling - Network failures

Do not create separate Dio instances per feature.

## 8. Riverpod State Management

Create feature-level providers/notifiers for: - Auth - Profile -
Dashboard - Income - Expense - Savings - Budget - AI insights -
Reports - Children - Quizzes

Avoid global mutable state.

## 9. UI/UX

Use the existing Material 3 FinAI theme.

Every API screen must support: - Loading - Success - Empty - Error

Use reusable cards, buttons, form fields, spacing, typography and
navigation components.

## 10. Security

-   Store JWT securely.
-   Never hard-code credentials or production secrets.
-   Use HTTPS in production.
-   Clear auth data on logout.
-   Protect authenticated routes.
-   Do not log sensitive financial data.
-   Do not duplicate security/business logic from Spring Boot.

Google authentication is optional and should only be added if the Spring
Boot backend is explicitly prepared to support it.

## 11. Testing

For each feature add: - Unit tests for use cases/validators/state -
Widget tests for forms/screens - Integration tests for important user
flows

Main integration flow:

``` text
Register
-> Login
-> Onboarding
-> Dashboard
-> Add Income
-> Add Expense
-> Budget
-> AI Insights
-> Reports
-> Logout
```

## 12. Final Integration

**Issue:**
`frontend: integrate and stabilize complete mobile application`

**Branch:** `feature/flutter-final-integration`

Final checks:

-   [ ] Authentication
-   [ ] Onboarding
-   [ ] Dashboard
-   [ ] Income
-   [ ] Expenses
-   [ ] Savings/debt
-   [ ] Budget
-   [ ] AI insights
-   [ ] Expense forecast
-   [ ] Recommendations
-   [ ] Reports
-   [ ] Children's module
-   [ ] Financial literacy
-   [ ] Profile/settings
-   [ ] Loading/error/empty states
-   [ ] Route guards
-   [ ] Logout
-   [ ] No hard-coded secrets
-   [ ] `flutter analyze`
-   [ ] `flutter test`
-   [ ] Release APK build
-   [ ] GitHub Actions CI

## 13. Definition of Done

The frontend is complete when the user can register, log in, complete
the demographic profile, manage income/expenses/savings/debt/budgets,
view dashboard data, receive AI financial-risk and expense-forecast
results, understand SHAP-based recommendations, generate/view reports,
use the scoped children's/financial-literacy features, and complete the
main flow without navigation or API-state errors.

## 14. Scope Rule

Do not add unnecessary frontend features.

Priority is:

**Personal Finance → AI Risk Prediction → Expense Forecasting →
Explainable Recommendations → Financial Reports → Financial
Literacy/Gamification.**

The Flutter app is the client; Spring Boot owns financial business logic
and authentication; FastAPI owns AI/ML processing.
