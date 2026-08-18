import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../errors/app_exception.dart';

final preferencesServiceProvider = FutureProvider<PreferencesService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return PreferencesService(prefs);
});

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  Future<void> setBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save boolean preference',
        originalException: e,
      );
    }
  }

  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve boolean preference',
        originalException: e,
      );
    }
  }

  Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save string preference',
        originalException: e,
      );
    }
  }

  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve string preference',
        originalException: e,
      );
    }
  }

  Future<void> setInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save integer preference',
        originalException: e,
      );
    }
  }

  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve integer preference',
        originalException: e,
      );
    }
  }

  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to remove preference',
        originalException: e,
      );
    }
  }

  Future<void> clear() async {
    try {
      await _prefs.clear();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear preferences',
        originalException: e,
      );
    }
  }
}
