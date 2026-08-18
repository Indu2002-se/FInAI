# FinAI Flutter Frontend - Developer Guide

## Quick Start

### Setup
```bash
cd FInAI/mobile_app
flutter pub get
flutter pub run build_runner build
flutter run
```

## Architecture Overview

### Clean Architecture Pattern
```
Presentation (Screens/Providers)
    ↓ (uses)
Domain (Entities/Repositories/UseCases)
    ↓ (implements)
Data (Models/DataSources)
    ↓ (calls)
External (Dio/SecureStorage)
```

### State Flow Example (Authentication)
```
LoginScreen
    ↓ (calls)
authNotifierProvider.notifier.login()
    ↓ (calls)
LoginUseCase.call()
    ↓ (calls)
AuthRepository.login()
    ↓ (calls)
AuthRemoteDataSource.login()
    ↓ (calls)
DioClient.post()
    ↓ (receives)
API Response
    ↓ (stores)
SecureStorageService.saveToken()
    ↓ (returns)
AuthEntity
    ↓ (updates)
AuthState (Freezed)
    ↓ (rebuilds)
UI with new state
```

## Color Usage

### Theme Colors
```dart
// Import
import 'app/core/theme/app_theme.dart';

// Use primary colors
AppColors.darkTeal      // #0D6B63 - Primary color
AppColors.tealAccent    // #1B8A7E - Secondary/accent
AppColors.white         // #FFFFFF - Background
AppColors.offWhite      // #F8FAFB - Light background

// Use status colors
AppColors.success       // Green
AppColors.warning       // Amber
AppColors.error         // Red
AppColors.info          // Blue

// Use text colors
AppColors.darkGrey      // Primary text
AppColors.mediumGrey    // Secondary text
AppColors.lightGrey     // Borders/dividers
```

## Common Patterns

### Creating a New Feature

1. **Create directory structure**
```
lib/features/new_feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

2. **Create entity (domain)**
```dart
class MyEntity {
  final String id;
  final String name;
  
  MyEntity({required this.id, required this.name});
}
```

3. **Create models (data)**
```dart
class MyModel {
  final String id;
  final String name;
  
  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(id: json['id'], name: json['name']);
  }
  
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
```

4. **Create repository interface (domain)**
```dart
abstract class MyRepository {
  Future<MyEntity> getItem(String id);
}
```

5. **Create repository impl (data)**
```dart
class MyRepositoryImpl implements MyRepository {
  final MyRemoteDataSource remoteDataSource;
  
  MyRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<MyEntity> getItem(String id) async {
    final model = await remoteDataSource.getItem(id);
    return MyEntity(id: model.id, name: model.name);
  }
}
```

6. **Create providers**
```dart
final myRepositoryProvider = Provider<MyRepository>((ref) {
  final dataSource = ref.watch(myRemoteDataSourceProvider);
  return MyRepositoryImpl(remoteDataSource: dataSource);
});
```

7. **Create state (using Freezed)**
```dart
@freezed
class MyState with _$MyState {
  const factory MyState.initial() = _Initial;
  const factory MyState.loading() = _Loading;
  const factory MyState.success(MyEntity data) = _Success;
  const factory MyState.error(String message) = _Error;
}
```

8. **Create notifier**
```dart
class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(const MyState.initial());
  
  Future<void> loadItem(String id) async {
    state = const MyState.loading();
    try {
      final item = await repository.getItem(id);
      state = MyState.success(item);
    } catch (e) {
      state = MyState.error(e.toString());
    }
  }
}

final myNotifierProvider = StateNotifierProvider<MyNotifier, MyState>((ref) {
  return MyNotifier();
});
```

9. **Create screen**
```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<MyState>(myNotifierProvider, (prev, next) {
      next.whenOrNull(
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      );
    });
    
    final state = ref.watch(myNotifierProvider);
    
    return state.when(
      initial: () => SizedBox.shrink(),
      loading: () => AppLoading(),
      success: (data) => MyContent(data: data),
      error: (message) => AppError(message: message),
    );
  }
}
```

## Form Validation Example

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      AppEmailField(
        label: 'Email',
        controller: _emailController,
        validator: (value) => AppValidators.validateEmail(value),
        required: true,
      ),
      AppPasswordField(
        label: 'Password',
        controller: _passwordController,
        validator: (value) => AppValidators.validatePassword(value),
        required: true,
      ),
    ],
  ),
)

if (_formKey.currentState?.validate() ?? false) {
  // Form is valid
}
```

## Extension Usage Examples

### String Extensions
```dart
String email = "  test@example.com  ";
email.trim()                    // "test@example.com"
email.isValidEmail              // true
email.truncate(maxLength: 10)  // "test@ex..."
```

### Number Extensions
```dart
double salary = 5000.0;
salary.toCurrency()             // "$5,000.00"
salary.toFormattedString()      // "5,000.00"
salary.toPercentage(decimalPlaces: 1)  // "5000.0%"
salary.toShortFormat()          // "5.0K"

int views = 1500000;
views.toShortFormat()           // "1.5M"
```

### DateTime Extensions
```dart
DateTime now = DateTime.now();
now.toFormattedDate()           // "Jan 15, 2024"
now.toFormattedTime()           // "02:30 PM"
now.toRelativeTime()            // "just now"
now.isToday                     // true
now.startOfDay                  // Start of today
now.startOfMonth                // Start of this month
```

## HTTP Requests with DioClient

```dart
// GET request
final data = await dioClient.get<MyModel>(
  endpoint: '/api/item',
  queryParameters: {'id': '123'},
);

// POST request
final response = await dioClient.post<MyModel>(
  endpoint: '/api/item',
  data: {'name': 'Test'},
);

// PUT request
await dioClient.put<void>(
  endpoint: '/api/item/123',
  data: {'name': 'Updated'},
);

// DELETE request
await dioClient.delete<void>(
  endpoint: '/api/item/123',
);
```

## Storage Usage

### Secure Storage (for tokens)
```dart
final secureStorage = ref.watch(secureStorageServiceProvider);

// Save token
await secureStorage.saveToken('token_value');

// Get token
final token = await secureStorage.getToken();

// Clear all tokens
await secureStorage.clearToken();
```

### Preferences (for non-sensitive data)
```dart
final prefs = await ref.watch(preferencesServiceProvider.future);

// Save
await prefs.setBool('key', true);
await prefs.setString('name', 'John');
await prefs.setInt('age', 25);

// Get
final value = prefs.getBool('key');

// Remove
await prefs.remove('key');
```

## Loading States in UI

```dart
// Simple loading
if (state.isLoading) {
  return AppLoading(message: 'Loading data...');
}

// Error state
if (state.hasError) {
  return AppError(
    message: state.error,
    onRetry: () => ref.refresh(myNotifierProvider),
  );
}

// Empty state
if (state.data?.isEmpty ?? true) {
  return AppEmptyState(
    title: 'No items found',
    description: 'Start by adding your first item',
    actionLabel: 'Add Item',
    onAction: () => _showAddDialog(),
  );
}

// Success state
return ListView.builder(
  itemCount: state.data.length,
  itemBuilder: (context, index) {
    return MyItemCard(item: state.data[index]);
  },
);
```

## Testing Example

```dart
test('login should store token', () async {
  // Arrange
  final mockDataSource = MockAuthRemoteDataSource();
  final mockStorage = MockSecureStorageService();
  
  when(mockDataSource.login(any)).thenAnswer(
    (_) async => mockLoginResponse,
  );
  
  final repository = AuthRepositoryImpl(
    remoteDataSource: mockDataSource,
    secureStorage: mockStorage,
  );
  
  // Act
  await repository.login(email: 'test@test.com', password: 'password');
  
  // Assert
  verify(mockStorage.saveToken(any)).called(1);
});
```

## Common Issues & Solutions

### Issue: Token not being sent in requests
**Solution:** Ensure `SecureStorageService` is properly injected into `DioClient` and token exists in storage.

### Issue: Form validation not working
**Solution:** Ensure `validator` parameter is provided and form key's `validate()` is called.

### Issue: State not updating
**Solution:** Check that provider is using StateNotifier pattern and state is being reassigned, not mutated.

### Issue: Import conflicts
**Solution:** Use aliases or specific imports:
```dart
import 'package:flutter/material.dart' as material;
import 'package:my_package/widgets.dart' as my_widgets;
```

## Best Practices

1. **Never call Dio directly from UI** - Always use repositories through use cases
2. **Keep state immutable** - Use Freezed or manual final fields
3. **Use providers for dependencies** - Never pass dependencies through constructors in screens
4. **Validate user input** - Always validate forms before submission
5. **Handle errors gracefully** - Show user-friendly error messages
6. **Store tokens securely** - Never use SharedPreferences for tokens
7. **Use loading states** - Always show feedback during async operations
8. **Test your code** - Write unit tests for logic, widget tests for UI
9. **Follow naming conventions** - Use descriptive names for variables and functions
10. **Document complex logic** - Add comments for non-obvious code

## Useful Commands

```bash
# Generate code (Freezed, build_runner)
flutter pub run build_runner build

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/

# Check security issues
flutter pub global run security_linter

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Go Router Documentation](https://pub.dev/packages/go_router)
- [Dio Documentation](https://pub.dev/packages/dio)
- [Freezed Documentation](https://pub.dev/packages/freezed)
- [Material 3 Guidelines](https://m3.material.io/)

## Support

For issues or questions:
1. Check the implementation plan: `FinAI_Flutter_Frontend_Implementation_Plan.md`
2. Review this guide: `DEVELOPER_GUIDE.md`
3. Check the progress: `IMPLEMENTATION_PROGRESS.md`
4. Review similar implemented features
