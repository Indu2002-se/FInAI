# FinAI Flutter Architecture

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Flutter Mobile App                       │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                   PRESENTATION LAYER                      │   │
│  │                   (UI & State Management)                 │   │
│  │                                                            │   │
│  │  ┌─────────────────────────────────────────────────────┐ │   │
│  │  │              SCREENS / WIDGETS                       │ │   │
│  │  │  • LoginScreen      • RegisterScreen               │ │   │
│  │  │  • DashboardScreen  • ExpenseScreen                │ │   │
│  │  │  • ... (Feature Screens)                           │ │   │
│  │  └─────────────────────────────────────────────────────┘ │   │
│  │                            ▲                               │   │
│  │                            │ (uses)                        │   │
│  │  ┌─────────────────────────────────────────────────────┐ │   │
│  │  │         RIVERPOD PROVIDERS & NOTIFIERS             │ │   │
│  │  │  • authNotifierProvider    • dashboardProvider     │ │   │
│  │  │  • expenseNotifierProvider • incomeNotifierProvider│ │   │
│  │  │  • Freezed State Classes                           │ │   │
│  │  └─────────────────────────────────────────────────────┘ │   │
│  │                            ▲                               │   │
│  │                            │ (injects)                     │   │
│  └────────────────────────────┼───────────────────────────────┘   │
│                               │                                    │
│  ┌────────────────────────────┼───────────────────────────────┐   │
│  │                    DOMAIN LAYER                            │   │
│  │            (Business Logic & Interfaces)                  │   │
│  │                                                            │   │
│  │  ┌─────────────────────────────────────────────────────┐ │   │
│  │  │             USE CASES / Interactors                │ │   │
│  │  │  • LoginUseCase         • RegisterUseCase          │ │   │
│  │  │  • GetDashboardUseCase  • AddExpenseUseCase        │ │   │
│  │  │  • ... (Feature UseCases)                          │ │   │
│  │  └─────────────────────────────────────────────────────┘ │   │
│  │                            ▲                               │   │
│  │                            │ (implements)                  │   │
│  │  ┌─────────────────────────────────────────────────────┐ │   │
│  │  │         REPOSITORY INTERFACES (Abstractions)       │ │   │
│  │  │  • AuthRepository       • DashboardRepository      │ │   │
│  │  │  • ExpenseRepository    • IncomeRepository         │ │   │
│  │  │  • ... (Feature Repositories)                      │ │   │
│  │  └─────────────────────────────────────────────────────┘ │   │
│  │                            ▲                               │   │
│  │  ┌─────────────────────────────────────────────────────┐ │   │
│  │  │                   ENTITIES (Models)                 │ │   │
│  │  │  • AuthEntity          • DashboardEntity           │ │   │
│  │  │  • ExpenseEntity       • IncomeEntity              │ │   │
│  │  │  • ... (Feature Entities)                          │ │   │
│  │  └─────────────────────────────────────────────────────┘ │   │
│  │                                                            │   │
│  └────────────────────────────────────────────────────────────┘   │
│                               │                                    │
│  ┌────────────────────────────┼───────────────────────────────┐   │
│  │                    DATA LAYER                             │   │
│  │            (Implementation & Persistence)                │   │
│  │                                                            │   │
│  │  ┌─────────────────────────────────────────────────────┐ │   │
│  │  │         REPOSITORY IMPLEMENTATIONS                  │ │   │
│  │  │  • AuthRepositoryImpl       • DashboardRepositoryImpl│ │   │
│  │  │  • ExpenseRepositoryImpl    • IncomeRepositoryImpl   │ │   │
│  │  │  • ... (Feature Repositories)                       │ │   │
│  │  └─────────────────────────────────────────────────────┘ │   │
│  │                            ▲                               │   │
│  │                            │ (uses)                        │   │
│  │  ┌─────────────────────────────────────────────────────┐ │   │
│  │  │            REMOTE DATA SOURCES                      │ │   │
│  │  │  • AuthRemoteDataSource       • DashboardDataSource │ │   │
│  │  │  • ExpenseRemoteDataSource    • IncomeDataSource    │ │   │
│  │  │  • ... (Feature DataSources)                        │ │   │
│  │  └─────────────────────────────────────────────────────┘ │   │
│  │                            ▲                               │   │
│  │                            │ (calls)                       │   │
│  │  ┌─────────────────────────────────────────────────────┐ │   │
│  │  │                  DATA MODELS                        │ │   │
│  │  │  • LoginRequest/Response      • DashboardModel     │ │   │
│  │  │  • ExpenseModel               • IncomeModel        │ │   │
│  │  │  • ... (Feature Models)                            │ │   │
│  │  └─────────────────────────────────────────────────────┘ │   │
│  │                                                            │   │
│  └────────────────────────────────────────────────────────────┘   │
│                               │                                    │
│  ┌────────────────────────────┼───────────────────────────────┐   │
│  │                 CORE INFRASTRUCTURE                        │   │
│  │                                                            │   │
│  │  ┌──────────────────┐  ┌──────────────────┐  ┌─────────┐ │   │
│  │  │   NETWORKING     │  │    STORAGE       │  │ THEME   │ │   │
│  │  │  • DioClient     │  │ • SecureStorage  │  │ • Colors│ │   │
│  │  │  • Interceptors  │  │ • Preferences    │  │ • Fonts │ │   │
│  │  │  • Error Mapping │  │                  │  │         │ │   │
│  │  └──────────────────┘  └──────────────────┘  └─────────┘ │   │
│  │                                                            │   │
│  │  ┌──────────────────┐  ┌──────────────────┐              │   │
│  │  │   VALIDATION     │  │   EXTENSIONS     │              │   │
│  │  │  • Validators    │  │ • String         │              │   │
│  │  │  • Formatters    │  │ • Number         │              │   │
│  │  │                  │  │ • DateTime       │              │   │
│  │  └──────────────────┘  └──────────────────┘              │   │
│  │                                                            │   │
│  │  ┌──────────────────┐  ┌──────────────────┐              │   │
│  │  │   COMPONENTS     │  │   ERROR HANDLING │              │   │
│  │  │  • Forms         │  │  • Exceptions    │              │   │
│  │  │  • Cards         │  │  • Messages      │              │   │
│  │  │  • Loading       │  │                  │              │   │
│  │  └──────────────────┘  └──────────────────┘              │   │
│  │                                                            │   │
│  └────────────────────────────────────────────────────────────┘   │
│                               │                                    │
└───────────────────────────────┼────────────────────────────────────┘
                                │
                    ┌───────────▼────────────┐
                    │  EXTERNAL SERVICES    │
                    │                       │
                    │ ┌─────────────────┐   │
                    │ │  Spring Boot    │   │
                    │ │  Backend API    │   │
                    │ │  (REST)         │   │
                    │ └─────────────────┘   │
                    │         │             │
                    │         ▼             │
                    │ ┌─────────────────┐   │
                    │ │  FastAPI       │   │
                    │ │  AI/ML Service │   │
                    │ │  (Predictions) │   │
                    │ └─────────────────┘   │
                    │                       │
                    └───────────────────────┘
```

## Data Flow (Example: Login)

```
User Enters Credentials
    ▼
LoginScreen
    ▼ (calls)
authNotifierProvider.notifier.login()
    ▼ (calls)
LoginUseCase.call()
    ▼ (calls)
AuthRepository.login() [Interface]
    ▼ (calls)
AuthRepositoryImpl.login()
    ▼ (calls)
AuthRemoteDataSource.login()
    ▼ (calls)
DioClient.post()
    ▼ (HTTP POST)
Spring Boot API: /auth/login
    ▼ (returns)
LoginResponse { token, refreshToken, user }
    ▼ (stores)
SecureStorageService.saveToken()
    ▼ (returns)
AuthEntity
    ▼ (updates)
AuthState.authenticated(user)
    ▼ (triggers)
authNotifierProvider listeners
    ▼ (rebuilds)
UI shows authenticated state
```

## State Management Pattern

```
        Screen Widget
            │
            │ watches
            ▼
    StateNotifierProvider<AuthState>
            │
        ┌───┴───┐
        │       │
    read()  listen()
        │       │
        ▼       ▼
AuthNotifier  Updates
    │           │
    ├─ state    └─▶ Trigger UI rebuilds
    │
    └─ methods
        ├─ login()
        ├─ register()
        └─ logout()
```

## Riverpod Dependency Injection

```
Providers Hierarchy:

Core (Bottom)
  ├─ dioClientProvider (Dio HTTP client)
  ├─ secureStorageServiceProvider (Token storage)
  └─ preferencesServiceProvider (App preferences)
      │
      ├─ authRemoteDataSourceProvider (API calls)
      │   │
      │   └─ authRepositoryProvider (Business logic)
      │       │
      │       ├─ loginUseCaseProvider (UseCase)
      │       ├─ registerUseCaseProvider
      │       └─ logoutUseCaseProvider
      │           │
      │           └─ authNotifierProvider (State management)
      │               │
      │               └─ Screens (UI)
      │
      └─ Similar patterns for other features
```

## Feature Folder Structure (Per Feature)

```
features/feature_name/
├── data/
│   ├── datasources/
│   │   ├── feature_remote_datasource.dart
│   │   └── feature_local_datasource.dart (if needed)
│   │
│   ├── models/
│   │   ├── feature_model.dart
│   │   └── feature_request.dart
│   │
│   └── repositories/
│       └── feature_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── feature_entity.dart
│   │
│   ├── repositories/
│   │   └── feature_repository.dart
│   │
│   └── usecases/
│       ├── get_feature_usecase.dart
│       ├── create_feature_usecase.dart
│       └── delete_feature_usecase.dart
│
└── presentation/
    ├── providers/
    │   ├── feature_providers.dart
    │   ├── feature_notifier.dart
    │   └── feature_state.dart (Freezed)
    │
    ├── screens/
    │   ├── feature_list_screen.dart
    │   ├── feature_detail_screen.dart
    │   └── feature_form_screen.dart
    │
    └── widgets/
        ├── feature_card.dart
        └── feature_item.dart
```

## Error Handling Flow

```
API Request
    ▼
Dio HTTP Error
    ▼
_handleException() method
    ▼
    ├─ ConnectionTimeout ──▶ TimeoutException
    ├─ ReceiveTimeout   ──▶ TimeoutException
    ├─ BadResponse
    │   ├─ 400 ──▶ BadRequestException
    │   ├─ 401 ──▶ UnauthorizedException
    │   ├─ 403 ──▶ ForbiddenException
    │   ├─ 404 ──▶ NotFoundException
    │   ├─ 5xx ──▶ ServerException
    │   └─ other ──▶ UnknownException
    │
    ├─ Cancel ──▶ NetworkException
    └─ Unknown ──▶ UnknownException
        ▼
   Thrown to caller
        ▼
   Caught in UseCase
        ▼
   Converted to AuthState.error()
        ▼
   UI displays error message
```

## Authentication Flow Diagram

```
┌─────────────────┐
│   Splash Page   │
└────────┬────────┘
         │
    Check Token
         │
    ┌────┴────────────────────────┐
    │                             │
    No Token                   Token Valid
    │                             │
    ▼                             ▼
┌──────────────┐           ┌────────────────┐
│ Login Page   │           │ Check Profile  │
└──────┬───────┘           └────┬───────────┘
       │                        │
       ├─ Enter Credentials     ├─ Complete
       │                        │    │
       ▼                        │    ▼
       │                        │ ┌──────────────┐
       │                        └─▶ Dashboard    │
       │                        │ └──────────────┘
       │                        │
       │                   Incomplete
       │                        │
       │                        ▼
       │                   ┌──────────────┐
       │                   │ Onboarding   │
       │                   └──────────────┘
       │
    ┌──┴────────────────┐
    │                   │
    Success         Fail
    │                   │
    ▼                   ▼
Store Token      Error Message
    │                   │
    ▼                   ▼
Check Profile   User Retries
    │
    ├─ Complete ──▶ Dashboard
    │
    └─ Incomplete ──▶ Onboarding
```

## Color System

```
Material 3 Semantic Colors:

Primary (Brand Color)
├─ darkTeal (#0D6B63)
│  └─ Used for: Main buttons, headlines, key interactions
│
├─ tealAccent (#1B8A7E)
│  └─ Used for: Secondary buttons, hover states, accents
│
└─ Related (Computed)
   ├─ onPrimary (White)
   ├─ primaryContainer (tealAccent)
   └─ onPrimaryContainer (White)

Surface (Backgrounds)
├─ white (#FFFFFF)
│  └─ Used for: Cards, surfaces, input backgrounds
│
├─ offWhite (#F8FAFB)
│  └─ Used for: Screen background, safe areas
│
└─ lightGrey (#F3F4F6)
   └─ Used for: Borders, dividers, disabled states

Status Colors
├─ success (Green #10B981)
├─ warning (Amber #F59E0B)
├─ error (Red #EF4444)
└─ info (Blue #3B82F6)

Text Colors
├─ darkGrey (#1F2937) - Primary text
├─ mediumGrey (#6B7280) - Secondary text
└─ lightGrey (#F3F4F6) - Disabled/borders
```

## Responsive Design

```
Mobile (< 600dp)
├─ Single column layout
├─ Full-width buttons
└─ Bottom navigation

Tablet (600dp - 900dp)
├─ Two column layout
├─ Side navigation drawer
└─ Adaptive cards

Desktop (> 900dp)
├─ Three column layout
├─ Rail navigation
└─ Larger cards with max width
```

## Performance Considerations

1. **Riverpod Caching**: Providers cache results automatically
2. **Lazy Loading**: Use `.future` for async data loading
3. **Image Optimization**: Consider caching with `cached_network_image`
4. **State Scope**: Keep provider scope minimal to avoid unnecessary rebuilds
5. **Build Methods**: Keep build methods pure and fast

---

**This architecture ensures:**
- ✅ Clean separation of concerns
- ✅ Easy testing
- ✅ Reusable components
- ✅ Maintainable code
- ✅ Scalable to many features
- ✅ Type-safe throughout
- ✅ Efficient state management
