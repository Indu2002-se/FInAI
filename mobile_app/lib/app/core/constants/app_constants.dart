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
  static String get baseUrl {
    if (_overrideBaseUrl != null && _overrideBaseUrl!.isNotEmpty) {
      return _overrideBaseUrl!;
    }

    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }
    try {
      if (Platform.isAndroid) {
        // Current host IP on local Wi-Fi: 10.138.201.79
        // For standard Android emulator, use 10.0.2.2:8080/api
        return 'http://10.138.201.79:8080/api';
      }
    } catch (_) {}
    return 'http://localhost:8080/api';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
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
