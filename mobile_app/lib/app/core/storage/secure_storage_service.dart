import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(
        key: AppConstants.tokenKey,
        value: token,
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to save token',
        originalException: e,
      );
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: AppConstants.tokenKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve token',
        originalException: e,
      );
    }
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: AppConstants.tokenKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete token',
        originalException: e,
      );
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(
        key: AppConstants.refreshTokenKey,
        value: token,
      );
    } catch (e) {
      throw CacheException(
        message: 'Failed to save refresh token',
        originalException: e,
      );
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: AppConstants.refreshTokenKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve refresh token',
        originalException: e,
      );
    }
  }

  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: AppConstants.refreshTokenKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete refresh token',
        originalException: e,
      );
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear storage',
        originalException: e,
      );
    }
  }

  Future<void> clearToken() async {
    try {
      await deleteToken();
      await deleteRefreshToken();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear tokens',
        originalException: e,
      );
    }
  }
}
