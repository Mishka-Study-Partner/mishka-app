import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local UX preferences (not synced to backend yet).
class AppPreferences {
  AppPreferences._();

  static const _localeKey = 'mishka_locale_code';
  static const _themeKey = 'mishka_theme_mode';
  static const _notificationsKey = 'mishka_notifications_enabled';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Call after [init].
  static String get localeCode => _prefs?.getString(_localeKey) ?? 'en';

  static ThemeMode get themeMode => _parseThemeMode(_prefs?.getString(_themeKey));

  static bool get notificationsEnabled =>
      _prefs?.getBool(_notificationsKey) ?? true;

  static Future<void> setLocaleCode(String code) async {
    await _prefs?.setString(_localeKey, code);
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs?.setString(_themeKey, _themeModeToStorage(mode));
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    await _prefs?.setBool(_notificationsKey, value);
  }

  static ThemeMode _parseThemeMode(String? raw) {
    switch (raw) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  static String _themeModeToStorage(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
  }
}
