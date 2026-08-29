import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> login({
    required String email,
    required String password,
  });

  Future<AuthEntity> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  /// Returns null when the user dismisses the Google account picker.
  Future<AuthEntity?> signInWithGoogle();

  Future<void> logout();

  Future<bool> isUserLoggedIn();

  Future<String?> getStoredToken();
}
