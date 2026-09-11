import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static String? _overrideBaseUrl;

  /// Set base URL dynamically at runtime if needed.
  /// Local emulator URLs are never sticky — they caused "server not running"
  /// errors after the real EC2 backend was already up.
  static void setBaseUrl(String url) {
    if (_isLocalDevUrl(url)) return;
    _overrideBaseUrl = url;
  }

  static void clearBaseUrlOverride() {
    _overrideBaseUrl = null;
  }

  static bool _isLocalDevUrl(String url) {
    final u = url.toLowerCase();
    return u.contains('10.0.2.2') ||
        u.contains('127.0.0.1') ||
        u.contains('localhost');
  }

  // API Configuration
  static List<String> get candidateBaseUrls {
    if (_overrideBaseUrl != null && _overrideBaseUrl!.isNotEmpty) {
      return [_overrideBaseUrl!];
    }

    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return [envUrl];
    }

    // Production backend - FinAI Backend Server
    const productionUrl = 'http://18.142.90.168/api';

    // Local fallbacks only when explicitly requested:
    // flutter run --dart-define=USE_LOCAL_API=true
    const useLocal = bool.fromEnvironment('USE_LOCAL_API', defaultValue: false);
    if (!useLocal || !kDebugMode) {
      return [productionUrl];
    }

    return [
      productionUrl,
      'http://10.0.2.2:8080/api',
      'http://127.0.0.1:8080/api',
      'http://localhost:8080/api',
    ];
  }

  static String get baseUrl => candidateBaseUrls.first;

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const String contentType = 'application/json';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String userProfileKey = 'user_profile';
  static const String onboardingCompleteKey = 'onboarding_complete';

  // Validation
  static const int minPasswordLength = 8;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Pagination
  static const int defaultPageSize = 20;
  static const int defaultInitialPage = 0;

  // General
  static const String appName = 'FinAI';
  static const String appVersion = '1.0.0';
}
