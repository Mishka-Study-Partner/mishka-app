import 'package:flutter/material.dart';

import 'package:mishka_app/core/preferences/app_preferences.dart';

import 'models/user_preferences_model.dart';

/// Applies server preference values to local storage (and optional UI callbacks).
class UserPreferencesApplier {
  UserPreferencesApplier._();

  /// Device-stored choices win when the user has changed them locally.
  /// Otherwise fall back to [server] (e.g. first login on a new device).
  static UserPreferencesModel resolve(UserPreferencesModel? server) {
    final localLocale = AppPreferences.localeCode;
    final localTheme = AppPreferences.themeMode;
    final localNotifications = AppPreferences.notificationsEnabled;

    if (server == null) {
      return UserPreferencesModel(
        languageCode: localLocale,
        themeMode: localTheme,
        notificationsEnabled: localNotifications,
      );
    }

    return UserPreferencesModel(
      id: server.id,
      userId: server.userId,
      languageCode:
          AppPreferences.hasStoredLocale ? localLocale : server.languageCode,
      themeMode: AppPreferences.hasStoredTheme ? localTheme : server.themeMode,
      notificationsEnabled: AppPreferences.hasStoredNotifications
          ? localNotifications
          : server.notificationsEnabled,
      updatedAt: server.updatedAt,
    );
  }

  static Future<void> apply(UserPreferencesModel prefs) async {
    await AppPreferences.setLocaleCode(prefs.languageCode);
    await AppPreferences.setThemeMode(prefs.themeMode);
    await AppPreferences.setNotificationsEnabled(prefs.notificationsEnabled);
  }

  static void applyToMaterialAppState({
    required UserPreferencesModel prefs,
    required void Function(Locale locale) setLocale,
    required void Function(ThemeMode themeMode) setThemeMode,
    required void Function(bool enabled) setNotificationsEnabled,
  }) {
    setLocale(prefs.locale);
    setThemeMode(prefs.themeMode);
    setNotificationsEnabled(prefs.notificationsEnabled);
  }
}
