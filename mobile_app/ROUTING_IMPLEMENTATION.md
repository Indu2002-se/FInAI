# FinAI Mobile App - Routing Implementation

## ✅ Signup → Wizard Routing Complete!

### Flow Overview

```
Register → Check profileComplete → Route accordingly
   |
   ├─→ profileComplete = false → Onboarding Wizard (4 steps)
   |      ↓
   |   Welcome → Personal → Household → Employment → Financial → Dashboard
   |
   └─→ profileComplete = true → Dashboard (direct)
```

### Implementation Details

#### 1. **Backend Response** (`AuthenticationResponse`)
```java
{
  "token": "jwt_token_here",
  "type": "Bearer",
  "user": {
    "id": 1,
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "profileComplete": false,  // ← Key field for routing
    ...
  }
}
```

#### 2. **Registration Flow** (`register_screen.dart`)
```dart
ref.listen<AuthState>(authNotifierProvider, (previous, next) {
  next.whenOrNull(
    authenticated: (user) {
      if (user.profileComplete) {
        // Direct to dashboard
        context.go('/dashboard');
      } else {
        // Start onboarding wizard
        context.go('/onboarding/welcome');
      }
    },
    error: (message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    },
  );
});
```

#### 3. **Onboarding Wizard Steps**

**Step 0: Welcome Screen** (`/onboarding/welcome`)
- Welcome message
- Start button → Personal Information

**Step 1: Personal Information** (`/onboarding/personal`)
- Fields: Name, Age, Gender, Location
- Continue → Household Information

**Step 2: Household Information** (`/onboarding/household`)
- Fields: Household Size, Dependents, Family Info
- Continue → Employment Information

**Step 3: Employment & Income** (`/onboarding/employment`)
- Fields: Employment Status, Monthly Income, Income Source
- Continue → Financial Profile

**Step 4: Financial Profile** (`/onboarding/financial`)
- Fields: Savings, Debt, Goals, Risk Tolerance
- Finish Setup → Dashboard

#### 4. **Route Names** (`route_names.dart`)
All routes defined as constants:
```dart
class RouteNames {
  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  
  // Onboarding
  static const String onboardingWelcome = '/onboarding/welcome';
  static const String onboardingPersonal = '/onboarding/personal';
  static const String onboardingHousehold = '/onboarding/household';
  static const String onboardingEmployment = '/onboarding/employment';
  static const String onboardingFinancial = '/onboarding/financial';
  
  // Main app
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  ...
}
```

#### 5. **Router Configuration** (`app_router.dart`)
```dart
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      // Auth routes
      GoRoute(path: RouteNames.splash, ...),
      GoRoute(path: RouteNames.login, ...),
      GoRoute(path: RouteNames.register, ...),
      
      // Onboarding routes
      GoRoute(path: RouteNames.onboardingWelcome, ...),
      GoRoute(path: RouteNames.onboardingPersonal, ...),
      GoRoute(path: RouteNames.onboardingHousehold, ...),
      GoRoute(path: RouteNames.onboardingEmployment, ...),
      GoRoute(path: RouteNames.onboardingFinancial, ...),
      
      // Main routes
      GoRoute(path: RouteNames.dashboard, ...),
      GoRoute(path: RouteNames.profile, ...),
      ...
    ],
  );
});
```

### Backend Integration Points

#### Register Endpoint
```
POST /api/auth/register
Request:
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john@example.com",
  "password": "password123"
}

Response:
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "token": "jwt_token",
    "user": {
      "profileComplete": false  // New users = false
    }
  }
}
```

#### Save Wizard Profile Endpoint
```
POST /api/wizard
Headers: Authorization: Bearer {jwt_token}
Request:
{
  "personalInfo": {...},
  "householdInfo": {...},
  "employmentInfo": {...},
  "financialInfo": {...}
}

Response:
{
  "success": true,
  "message": "Wizard profile created successfully",
  "data": {
    "profileComplete": true  // Set to true after wizard
  }
}
```

### Key Features

✅ **Automatic Routing**: Based on `profileComplete` field
✅ **Sequential Wizard**: 4 steps with validation
✅ **Back Navigation**: Users can go back through steps
✅ **Form Validation**: Each step validates before continue
✅ **Loading States**: Shows progress during submission
✅ **Error Handling**: Displays errors to user

### User Experience

**New User Journey:**
1. Register → See welcome screen
2. Complete 4-step wizard
3. Land on dashboard with complete profile

**Returning User Journey:**
1. Login → Check profileComplete
2. If incomplete → Resume wizard
3. If complete → Direct to dashboard

### Testing Checklist

- [ ] Register new user → Should go to wizard
- [ ] Complete wizard → Should go to dashboard
- [ ] Login existing user with complete profile → Direct to dashboard
- [ ] Login user with incomplete profile → Resume wizard
- [ ] Back navigation works in wizard
- [ ] Form validation works at each step
- [ ] Error messages display correctly
- [ ] Loading states show properly

### Next Steps (Optional)

1. **Backend Wizard Service**: Implement actual save to database
2. **State Persistence**: Store wizard progress locally
3. **Skip Option**: Allow users to complete later
4. **Progress Indicator**: Visual progress bar across steps
5. **Edit Profile**: Allow updating wizard info later

## 🎉 Summary

Signup → Wizard routing fully implemented! Users get seamless onboarding experience with proper routing based on profile completion status.
