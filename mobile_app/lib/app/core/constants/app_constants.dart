import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static String? _overrideBaseUrl;

  /// Set base URL dynamically at runtime if needed
  static void setBaseUrl(String url) {
    _overrideBaseUrl = url;
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
    // This is the deployed backend base path. Override it only at build time,
    // e.g. --dart-define=API_BASE_URL=https://your-domain.example/api.
    const productionUrl = 'http://140.238.242.80/api';

    // A production build must never silently fall back to a local server.  That
    // can make an account appear to be created while its data is only written
    // to the developer machine instead of the hosted MySQL database.
    if (!kDebugMode) {
      return [productionUrl];
    }

    if (kIsWeb) {
      return [productionUrl, 'http://localhost:8080/api', 'http://127.0.0.1:8080/api'];
    }

    try {
      if (Platform.isAndroid) {
        return [
          // Production backend (primary)
          productionUrl,
          // Android Emulator uses this alias for the development machine.
          'http://10.0.2.2:8080/api',
          // Physical Android devices use localhost when started through
          // tool/run_android_debug.ps1, which creates an ADB port tunnel.
          'http://127.0.0.1:8080/api',
        ];
      }
      if (Platform.isIOS) {
        return [
          // Production backend (primary)
          productionUrl,
          'http://localhost:8080/api',
          'http://10.233.96.79:8080/api'
        ];
      }
    } catch (_) {}

    // Default to production backend
    return [productionUrl];
  }

  static String get baseUrl => candidateBaseUrls.first;

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
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
