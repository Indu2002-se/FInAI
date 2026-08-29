# FinAI Mobile App - Class Diagram

## Architecture Overview

```mermaid
classDiagram
    %% ==================== Authentication Layer ====================
    class AuthEntity {
        +int id
        +String email
        +String firstName
        +String lastName
        +String token
        +String refreshToken
        +UserType userType
        +bool profileComplete
        +int? childProfileId
        +bool get isParent
        +bool get isChild
        +String get fullName
    }

    class UserType {
        <<enum>>
        parent
        child
    }

    class LoginResponse {
        +String token
        +String refreshToken
        +UserData user
        +String userType
        +int? childProfileId
        +factory LoginResponse.fromJson(Map json)
        +Map toJson()
    }

    class UserData {
        +int id
        +String email
        +String firstName
        +String lastName
        +bool profileComplete
        +String? userType
        +factory UserData.fromJson(Map json)
        +Map toJson()
    }

    class AuthRepositoryImpl {
        +final SecureStorageService secureStorage
        +final ApiClient apiClient
        +Future~AuthEntity~ login(String email, String password)
        +Future~AuthEntity~ register(...)
        +Future~void~ logout()
        +Future~AuthEntity?~ getStoredUser()
        -UserType _mapUserType(String? userTypeStr)
    }

    class SecureStorageService {
        +Future~void~ saveToken(String token)
        +Future~String?~ getToken()
        +Future~void~ saveRefreshToken(String token)
        +Future~String?~ getRefreshToken()
        +Future~void~ clearAll()
    }

    %% ==================== State Management ====================
    class AuthState {
        <<sealed>>
        +initial()
        +loading()
        +authenticated(AuthEntity user)
        +error(String message)
    }

    class AuthNotifier {
        +StateNotifier~AuthState~
        +AuthEntity? _currentUser
        +Future~void~ login(String email, String password)
        +Future~void~ register(...)
        +Future~void~ logout()
        +Future~void~ loadStoredUser()
        -Future~void~ _setAuthState(AuthEntity user)
    }

    class DashboardProvider {
        +FutureProvider~DashboardModel~
        +fetchDashboardData()
    }

    class DashboardModel {
        +String userName
        +double totalIncome
        +double totalExpense
        +double netSavings
        +double totalDebt
        +double financialHealthScore
        +String riskLevel
        +String topRiskDriver
        +double monthlyBudgetAllocated
        +double monthlyBudgetSpent
        +double budgetUsagePercentage
        +List~ExpenseModel~ recentExpenses
        +List~IncomeModel~ recentIncomes
        +String latestRecommendation
        +String forecastSummary
    }

    %% ==================== Child Management ====================
    class ChildProfileModel {
        +int id
        +String name
        +int age
        +String profilePicture
        +double totalSavings
        +int savingsGoalsCount
        +String? lastActivityDate
        +factory ChildProfileModel.fromJson(Map json)
    }

    class ChildSelectionProvider {
        +StateProvider~ChildProfileModel?~ selectedChildProvider
        +FutureProvider~ParentChildrenListResponse~ parentChildrenListProvider
        +FutureProvider~ChildDashboardModel~ selectedChildDashboardProvider
    }

    class SelectedChildNotifier {
        +StateNotifier~ChildProfileModel?~
        +void selectChild(ChildProfileModel child)
        +void clearSelection()
        +int? get selectedChildId
    }

    class ChildDashboardModel {
        +int childId
        +String childName
        +int childAge
        +double totalSavings
        +List~SavingsGoalModel~ savingsGoals
        +List~AlertModel~ alerts
        +List~ChoreRewardModel~ chores
        +List~WishlistItemModel~ wishlist
    }

    class SavingsGoalModel {
        +int id
        +String title
        +String category
        +double targetAmount
        +double currentAmount
        +DateTime targetDate
        +String status
        +double get progress
        +factory SavingsGoalModel.fromJson(Map json)
    }

    class ParentChildrenListResponse {
        +List~ChildProfileModel~ children
        +int totalCount
        +factory ParentChildrenListResponse.fromJson(Map json)
    }

    %% ==================== Repositories ====================
    class ChildRepository {
        +final ApiClient apiClient
        +Future~ParentChildrenListResponse~ getParentChildren()
        +Future~ChildDashboardModel~ getChildDashboard(int childId)
        +Future~ChildProfileModel~ getChildProfile(int childId)
    }

    class DashboardRepository {
        +final ApiClient apiClient
        +Future~DashboardModel~ getDashboardData()
    }

    %% ==================== Screens/Widgets ====================
    class IntroScreen {
        +build(BuildContext context)
    }

    class UserTypeSelectionScreen {
        +build(BuildContext context)
        -_buildSelectionCard()
    }

    class LoginScreen {
        +_LoginScreenState
        -_formKey
        -_emailController
        -_passwordController
        -_handleLogin()
    }

    class ChildLoginScreen {
        +_ChildLoginScreenState
        -_formKey
        -_emailController
        -_passwordController
        -_handleLogin()
    }

    class MainDashboardScreen {
        +ConsumerWidget
        +build(BuildContext context, WidgetRef ref)
        -_DashboardHeader
        -_DashboardBody
    }

    class ChildProfileSelectorScreen {
        +ConsumerStatefulWidget
        +build(BuildContext context, WidgetRef ref)
        -_buildChildCard()
    }

    class ChildSavingsDashboardScreen {
        +ConsumerStatefulWidget
        +build(BuildContext context, WidgetRef ref)
        -_buildGoalCard()
        -_getIconForCategory()
    }

    %% ==================== API & HTTP ====================
    class ApiClient {
        +final String baseUrl
        +final Dio httpClient
        +Future~T~ get~T~(String endpoint)
        +Future~T~ post~T~(String endpoint, Map body)
        +Future~void~ setAuthToken(String token)
    }

    class Dio {
        +Future~Response~ get(String path)
        +Future~Response~ post(String path, Map data)
        +Future~Response~ put(String path, Map data)
        +Future~Response~ delete(String path)
    }

    %% ==================== Router ====================
    class AppRouter {
        +final List~RouteBase~ routes
        +GoRouter get router
    }

    class RouteNames {
        <<constants>>
        +String intro
        +String splash
        +String login
        +String childLogin
        +String userTypeSelection
        +String dashboard
        +String childProfileSelector
        +String childDashboard
    }

    %% ==================== Theme ====================
    class AppTheme {
        <<static>>
        +ThemeData get lightTheme
        +Color get primaryColor
        +Color get accentColor
    }

    class AppColors {
        <<static>>
        +Color primary
        +Color darkTeal
        +Color tealLight
        +Color white
        +Color success
        +Color error
        +Color warning
    }

    %% ==================== Constants ====================
    class AppConstants {
        <<static>>
        +String get baseUrl
        +Duration connectTimeout
        +Duration receiveTimeout
        +String tokenKey
        +String refreshTokenKey
    }

    %% ==================== Relationships ====================
    
    %% Authentication relationships
    AuthEntity --> UserType : uses
    LoginResponse --> UserData : contains
    AuthRepositoryImpl --> AuthEntity : returns
    AuthRepositoryImpl --> SecureStorageService : uses
    AuthRepositoryImpl --> ApiClient : uses
    AuthNotifier --> AuthEntity : manages
    AuthNotifier --> AuthRepositoryImpl : uses
    AuthState --> AuthEntity : contains

    %% Dashboard relationships
    DashboardProvider --> DashboardModel : returns
    DashboardModel --> ExpenseModel : contains
    DashboardModel --> IncomeModel : contains
    DashboardRepository --> DashboardModel : returns
    DashboardRepository --> ApiClient : uses

    %% Child management relationships
    ChildProfileModel --> SavingsGoalModel : contains
    ChildSelectionProvider --> ChildProfileModel : manages
    SelectedChildNotifier --> ChildProfileModel : manages
    ChildDashboardModel --> SavingsGoalModel : contains
    ChildDashboardModel --> AlertModel : contains
    ChildRepository --> ChildProfileModel : returns
    ChildRepository --> ChildDashboardModel : returns
    ChildRepository --> ApiClient : uses
    ParentChildrenListResponse --> ChildProfileModel : contains

    %% Screen relationships
    LoginScreen --> AuthNotifier : uses
    ChildLoginScreen --> AuthNotifier : uses
    MainDashboardScreen --> DashboardProvider : uses
    MainDashboardScreen --> AuthNotifier : uses
    ChildProfileSelectorScreen --> ChildSelectionProvider : uses
    ChildProfileSelectorScreen --> ChildRepository : uses
    ChildSavingsDashboardScreen --> ChildDashboardModel : uses
    ChildSavingsDashboardScreen --> ChildRepository : uses
    UserTypeSelectionScreen --> AppRouter : uses
    IntroScreen --> AppRouter : uses

    %% Router relationships
    AppRouter --> RouteNames : uses
    AppRouter --> LoginScreen : contains
    AppRouter --> ChildLoginScreen : contains
    AppRouter --> MainDashboardScreen : contains
    AppRouter --> ChildProfileSelectorScreen : contains
    AppRouter --> ChildSavingsDashboardScreen : contains

    %% Global relationships
    ApiClient --> AppConstants : uses
    AppRouter --> AppTheme : uses
    AppTheme --> AppColors : uses

```

---

## Data Flow Diagrams

### Parent Login Flow
```mermaid
sequenceDiagram
    participant User
    participant LoginScreen
    participant AuthNotifier
    participant AuthRepository
    participant ApiClient
    participant SecureStorage

    User->>LoginScreen: Enter credentials
    LoginScreen->>AuthNotifier: Call login(email, password)
    AuthNotifier->>AuthRepository: login(email, password)
    AuthRepository->>ApiClient: POST /api/login
    ApiClient->>AuthRepository: Response with token & userType
    AuthRepository->>SecureStorage: Save token
    AuthRepository->>AuthNotifier: Return AuthEntity
    AuthNotifier->>LoginScreen: Update AuthState.authenticated
    LoginScreen->>User: Navigate to parent dashboard
```

### Child Login Flow
```mermaid
sequenceDiagram
    participant User
    participant ChildLoginScreen
    participant AuthNotifier
    participant AuthRepository
    participant ApiClient
    participant SecureStorage

    User->>ChildLoginScreen: Enter credentials
    ChildLoginScreen->>AuthNotifier: Call login(email, password)
    AuthNotifier->>AuthRepository: login(email, password)
    AuthRepository->>ApiClient: POST /api/login
    ApiClient->>AuthRepository: Response with userType=CHILD
    AuthRepository->>SecureStorage: Save token
    AuthRepository->>AuthNotifier: Return AuthEntity with isChild=true
    AuthNotifier->>ChildLoginScreen: Update AuthState.authenticated
    ChildLoginScreen->>User: Navigate to /child dashboard
```

### Parent Views Child Dashboard Flow
```mermaid
sequenceDiagram
    participant Parent
    participant ChildSelector
    participant ChildSelectionProvider
    participant ChildRepository
    participant ApiClient
    participant ChildDashboard

    Parent->>ChildSelector: Tap Switch on child
    ChildSelector->>ChildSelectionProvider: selectChild(childModel)
    ChildSelector->>ChildDashboard: Navigate to child dashboard
    ChildDashboard->>ChildSelectionProvider: Get selectedChildDashboardProvider
    ChildSelectionProvider->>ChildRepository: getChildDashboard(childId)
    ChildRepository->>ApiClient: GET /v1/child/dashboard
    ApiClient->>ChildRepository: Response with child data
    ChildRepository->>ChildSelectionProvider: Return ChildDashboardModel
    ChildSelectionProvider->>ChildDashboard: Update UI with live data
    ChildDashboard->>Parent: Display child's financial data
```

---

## Provider Hierarchy

```mermaid
graph TD
    A[authNotifierProvider] --> B[StateNotifier]
    B --> C[AuthState]
    
    D[dashboardFutureProvider] --> E[FutureProvider]
    E --> F[DashboardModel]
    
    G[selectedChildProvider] --> H[StateProvider]
    H --> I[ChildProfileModel?]
    
    J[parentChildrenListProvider] --> K[FutureProvider]
    K --> L[ParentChildrenListResponse]
    
    M[selectedChildDashboardProvider] --> N[FutureProvider]
    N --> O[ChildDashboardModel]
    
    P[pendingCountProvider] --> Q[StateProvider]
    Q --> R[int]
```

---

## File Structure

```mermaid
graph TD
    A["lib/"] --> B["features/"]
    A --> C["app/"]
    
    B --> D["authentication/"]
    B --> E["dashboard/"]
    B --> F["child_literacy/"]
    B --> G["onboarding/"]
    
    D --> D1["domain/"]
    D --> D2["data/"]
    D --> D3["presentation/"]
    
    D1 --> D1A["entities/auth_entity.dart"]
    D2 --> D2A["models/"]
    D2 --> D2B["repositories/"]
    D3 --> D3A["screens/"]
    D3 --> D3B["providers/"]
    
    E --> E1["data/"]
    E --> E2["presentation/"]
    
    F --> F1["data/"]
    F --> F2["presentation/"]
    
    C --> C1["router/"]
    C --> C2["theme/"]
    C --> C3["core/"]
    
    C3 --> C3A["constants/"]
    C3 --> C3B["widgets/"]
```

---

## Authentication State Machine

```mermaid
stateDiagram-v2
    [*] --> Initial: App Start
    
    Initial --> Loading: User taps Login
    Initial --> Initial: User not authenticated
    
    Loading --> Authenticated: Credentials valid
    Loading --> Error: Credentials invalid
    
    Error --> Loading: User retries
    Error --> Initial: User goes back
    
    Authenticated --> Authenticated: Token valid
    Authenticated --> Loading: Refresh token
    Authenticated --> Initial: User logs out
    
    Authenticated --> Dashboard: Parent
    Authenticated --> ChildDashboard: Child
    
    Dashboard --> Dashboard: User navigates
    Dashboard --> Initial: User logs out
    
    ChildDashboard --> ChildDashboard: User navigates
    ChildDashboard --> Initial: User logs out
```

---

## Notes

- All classes follow SOLID principles
- Separation of concerns: Domain, Data, and Presentation layers
- Riverpod for state management and dependency injection
- GoRouter for navigation
- Secure storage for sensitive data (tokens)
- API client with error handling and retry logic

