import 'package:shared_preferences/shared_preferences.dart';

/// Persists JWT for [Authorization: Bearer] (via [DioClient]).
class TokenStorage {
  TokenStorage._();

  static const _key = 'mishka_access_token';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String? get token => _prefs?.getString(_key);

  static Future<void> saveToken(String value) async {
    await _prefs?.setString(_key, value);
  }

  static Future<void> clearToken() async {
    await _prefs?.remove(_key);
  }
}
