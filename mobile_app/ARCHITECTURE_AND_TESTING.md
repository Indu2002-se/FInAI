# FinAI Mobile App - Architecture & Testing Documentation

**Version**: 1.0  
**Date**: August 25, 2026

---

## Quick Links

- **📐 Class Diagram**: [CLASS_DIAGRAM.md](CLASS_DIAGRAM.md) - Complete architecture and data flow
- **🧪 Test Cases**: [TEST_CASES.md](TEST_CASES.md) - 37 comprehensive test cases

---

## Overview

This document summarizes the architecture and testing strategy for the FinAI Mobile App, which implements a parent-child finance management system with separate authentication flows and live data integration.

---

## Architecture Highlights

### Layered Architecture

The app follows a clean three-layer architecture:

```
┌─────────────────────────────────────────┐
│      Presentation Layer (UI)            │
│  Screens, Widgets, Navigation           │
└─────────────────────────────────────────┘
            ↓         ↑
┌─────────────────────────────────────────┐
│     Application Layer (State Mgmt)      │
│  Riverpod Providers, Notifiers          │
└─────────────────────────────────────────┘
            ↓         ↑
┌─────────────────────────────────────────┐
│    Domain & Data Layer (Business)       │
│  Entities, Repositories, Models         │
└─────────────────────────────────────────┘
            ↓         ↑
┌─────────────────────────────────────────┐
│      Infrastructure Layer (API)         │
│  HTTP Client, API Calls, Storage        │
└─────────────────────────────────────────┘
```

### Key Components

| Component | Purpose | Technology |
|-----------|---------|-----------|
| **Authentication** | User login/logout and token management | Dart/Flutter + Riverpod |
| **State Management** | App state and data flow | Riverpod (Functional Reactive) |
| **Navigation** | Screen routing and deep linking | GoRouter (Router v7) |
| **API Communication** | Backend integration | Dio + HTTP |
| **Data Storage** | Secure local storage | Flutter Secure Storage |
| **UI Framework** | User interface | Flutter Material Design |

---

## Class Diagram

### Key Classes

**See [CLASS_DIAGRAM.md](CLASS_DIAGRAM.md) for:**

1. **Authentication Classes**
   - `AuthEntity` - User model with UserType enum
   - `LoginResponse` - API response model
   - `AuthRepositoryImpl` - Authentication business logic
   - `AuthNotifier` - State notifier for auth state
   - `SecureStorageService` - Secure token storage

2. **Dashboard Classes**
   - `DashboardModel` - Parent dashboard data
   - `DashboardProvider` - Fetch dashboard data
   - `DashboardRepository` - Dashboard API calls

3. **Child Management Classes**
   - `ChildProfileModel` - Child profile data
   - `ChildDashboardModel` - Child's financial data
   - `ChildSelectionProvider` - Manage selected child
   - `ChildRepository` - Child-related API calls

4. **UI Components**
   - `LoginScreen` - Parent login
   - `ChildLoginScreen` - Child login
   - `MainDashboardScreen` - Parent dashboard
   - `ChildProfileSelectorScreen` - Child selector
   - `ChildSavingsDashboardScreen` - Child dashboard

5. **Navigation**
   - `AppRouter` - Router configuration
   - `RouteNames` - Route constants

---

## Data Flow

### Complete User Flow Diagrams

**See [CLASS_DIAGRAM.md](CLASS_DIAGRAM.md) for Mermaid sequence diagrams:**

1. **Parent Login Flow** - Shows authentication, token storage, dashboard navigation
2. **Child Login Flow** - Shows separate auth path, role detection, child dashboard
3. **Parent Views Child Dashboard** - Shows child selection, API calls, live data fetch

### API Endpoints Used

| Endpoint | Method | Purpose | Auth |
|----------|--------|---------|------|
| `/api/login` | POST | User authentication | No |
| `/api/register` | POST | User registration | No |
| `/v1/child/dashboard` | GET | Child financial data | Yes |
| `/api/parent/children` | GET | Parent's children list | Yes |

---

## Testing Strategy

### Test Coverage

**Total Test Cases**: 37

| Category | Count | Focus |
|----------|-------|-------|
| Authentication | 8 | Login validation, error handling |
| Parent Dashboard | 4 | UI display, data accuracy |
| Child Management | 4 | Child selection, switching |
| Child Dashboard | 3 | Live data, UI elements |
| Navigation | 4 | Screen routing, back button |
| Error Handling | 5 | Network, API, validation |
| Performance | 4 | Load times, memory usage |
| Security | 5 | Token storage, encryption |

### Test Types

- **Functional Tests** - Feature functionality and behavior
- **Validation Tests** - Input validation and error messages
- **Navigation Tests** - Screen routing and navigation
- **Error Handling Tests** - Network failures, API errors
- **Performance Tests** - Load times, memory usage
- **Security Tests** - Token storage, encryption, HTTPS

### Test Execution

**See [TEST_CASES.md](TEST_CASES.md) for:**

- Detailed test steps for each test case
- Expected vs actual results
- Pre-conditions and assumptions
- Priority levels (Critical, High, Medium, Low)
- Pass/Fail tracking

---

## Key Features Tested

### ✅ Parent-Child Separation
- [ ] Parent can only see parent dashboard
- [ ] Child can only see child dashboard
- [ ] Different login screens for each role
- [ ] Role-based routing works correctly

### ✅ Live Data Integration
- [ ] Child dashboard fetches real API data
- [ ] Data updates on pull-to-refresh
- [ ] Loading states show during fetch
- [ ] Error states handle API failures

### ✅ Child Management
- [ ] Parents can view all children
- [ ] Can switch between children
- [ ] Each child's data displays correctly
- [ ] No data corruption on switch

### ✅ Navigation
- [ ] All routes configured correctly
- [ ] Back buttons work at each step
- [ ] Navigation is smooth and responsive
- [ ] State preserved during navigation

### ✅ Error Handling
- [ ] Network errors handled gracefully
- [ ] API errors show user-friendly messages
- [ ] Retry functionality works
- [ ] No app crashes on errors

### ✅ Security
- [ ] Tokens stored securely
- [ ] HTTPS enforced for API calls
- [ ] Session expiration handled
- [ ] No sensitive data logged

---

## Test Environment Setup

### Device Requirements
- Android API Level 21+ (minimum)
- 2GB RAM minimum (4GB recommended)
- Stable internet connection for API tests

### Network Configuration
- Backend URL: `http://140.238.242.80/api`
- Connection timeout: 10 seconds
- Read timeout: 10 seconds

### Test Accounts

For manual testing, request test credentials from QA team:
- Parent test account
- Child test account
- Multiple children setup (if available)

---

## Automation Recommendations

### Automatable Tests (Priority)

1. **Authentication Tests** (High Priority)
   - Valid/invalid login
   - Form validation
   - Error message verification
   - Token storage

2. **Navigation Tests** (High Priority)
   - Route transitions
   - Back button functionality
   - Deep linking

3. **Data Display Tests** (Medium Priority)
   - Dashboard elements present
   - Data formatting correct
   - No missing fields

4. **Error Handling** (Medium Priority)
   - Timeout handling
   - API error responses
   - Retry logic

### Manual-Only Tests

- UI/UX subjective assessment
- Performance on real devices
- Memory leak detection
- Security penetration testing

---

## Performance Benchmarks

| Metric | Target | Current |
|--------|--------|---------|
| Login Response | < 5 sec | |
| Dashboard Load | < 2 sec | |
| Child Dashboard Load | < 2 sec | |
| Pull-to-Refresh | < 1 sec | |
| Memory Usage | < 100 MB | |
| App Startup | < 3 sec | |

---

## Security Checklist

- [ ] Tokens stored in Keystore (Android) / Keychain (iOS)
- [ ] HTTPS enforced for all API calls
- [ ] Certificate pinning implemented
- [ ] No sensitive data in logs
- [ ] Password not stored locally
- [ ] Refresh token rotation implemented
- [ ] Session timeout on app background
- [ ] Input validation on all forms

---

## Known Limitations

1. **Offline Mode** - App requires internet for full functionality
2. **Demo Credentials** - Removed from production (was: parent@finai.com)
3. **iOS Support** - Currently Android-only (iOS pending)
4. **Sync** - Real-time sync not implemented (refresh-based)

---

## Future Enhancements

1. **Real-time Sync** - WebSocket for live updates
2. **Offline Support** - Cache data locally
3. **iOS Deployment** - Extend to Apple devices
4. **Notifications** - Push notifications for financial alerts
5. **Advanced Analytics** - More detailed financial insights
6. **Parent Controls** - Edit child data and goals
7. **Multi-language** - i18n support

---

## Documentation Map

```
mobile_app/
├── CLASS_DIAGRAM.md           ← Architecture & Class Diagrams
├── TEST_CASES.md              ← All 37 Test Cases
├── ARCHITECTURE_AND_TESTING.md ← This file
├── README.md                  ← Quick start
└── pubspec.yaml              ← Dependencies
```

---

## Quick Test Execution Guide

### Running All Tests

```bash
# Run all unit tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/authentication_test.dart
```

### Manual Testing

1. **Prepare Environment**
   - Ensure backend running at http://140.238.242.80
   - Have test accounts ready
   - Device/emulator setup

2. **Run Test Scenarios**
   - Follow test steps in TEST_CASES.md
   - Record pass/fail results
   - Note any issues found

3. **Report Results**
   - Complete test summary table
   - Document defects found
   - Sign off test execution

---

## Contact & Support

For questions about:
- **Architecture**: See CLASS_DIAGRAM.md or code comments
- **Tests**: See TEST_CASES.md with detailed steps
- **API**: Contact backend team at [backend-contact]
- **Issues**: File in project issue tracker

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Aug 25, 2026 | Initial documentation |
| | | 37 test cases |
| | | Complete class diagram |
| | | Architecture overview |

---

*FinAI Mobile App - Architecture & Testing*  
*Last Updated: August 25, 2026*

**Status**: ✅ Documentation Complete
