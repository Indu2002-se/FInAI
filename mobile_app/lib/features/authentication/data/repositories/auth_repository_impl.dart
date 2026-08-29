import '../../../../app/core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  UserType _mapUserType(String? userTypeStr) {
    if (userTypeStr?.toUpperCase() == 'CHILD') {
      return UserType.child;
    }
    return UserType.parent;
  }

  @override
  Future<AuthEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await remoteDataSource.login(request);

      // Store tokens securely
      await secureStorage.saveToken(response.token);
      await secureStorage.saveRefreshToken(response.refreshToken);

      final userType = _mapUserType(response.userType);

      return AuthEntity(
        id: response.user.id,
        email: response.user.email,
        firstName: response.user.firstName,
        lastName: response.user.lastName,
        profileComplete: response.user.profileComplete,
        token: response.token,
        userType: userType,
        childProfileId: response.childProfileId,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthEntity> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      final response = await remoteDataSource.register(request);

      // Store tokens securely
      await secureStorage.saveToken(response.token);
      await secureStorage.saveRefreshToken(response.refreshToken);

      final userType = _mapUserType(response.userType);

      return AuthEntity(
        id: response.user.id,
        email: response.user.email,
        firstName: response.user.firstName,
        lastName: response.user.lastName,
        profileComplete: response.user.profileComplete,
        token: response.token,
        userType: userType,
        childProfileId: response.childProfileId,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } finally {
      // Clear tokens regardless of API success
      await secureStorage.clearToken();
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      final token = await secureStorage.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getStoredToken() async {
    try {
      return await secureStorage.getToken();
    } catch (e) {
      return null;
    }
  }
}
