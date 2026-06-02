import 'package:flutter/material.dart';

import 'package:mishka_app/core/preferences/app_preferences.dart';

import 'models/user_preferences_model.dart';

/// Applies server preference values to local storage (and optional UI callbacks).
class UserPreferencesApplier {
  UserPreferencesApplier._();

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
