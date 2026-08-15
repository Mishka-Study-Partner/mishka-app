import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local UX preferences; synced via `PUT /users/{id}/preferences` from [SettingsScreen].
class AppPreferences {
  AppPreferences._();

  static const _localeKey = 'mishka_locale_code';
  static const _themeKey = 'mishka_theme_mode';
  static const _notificationsKey = 'mishka_notifications_enabled';
  static const _onboardingIntroKey = 'mishka_onboarding_intro_completed';
  static const _educationSetupKey = 'mishka_education_setup_completed';
  static const _lastStreakPingUtcDateKey = 'mishka_last_streak_ping_utc_date';
  static const _cachedDailyStreakJsonKey = 'mishka_cached_daily_streak_json';
  static const _pendingCommunityInviteKey = 'mishka_pending_community_invite';
  static const _chatBackendSessionIdKey = 'mishka_chat_backend_session_id';
  static const _chatAiSessionIdKey = 'mishka_chat_ai_session_id';
  static const _cachedUserJsonKey = 'mishka_cached_user_json';
  static const _reportEmailRecipientKey = 'mishka_report_email_recipient';

  static SharedPreferences? _prefs;

  static SharedPreferences? get sharedPreferences => _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Call after [init].
  static String get localeCode => _prefs?.getString(_localeKey) ?? 'en';

  static bool get hasStoredLocale =>
      _prefs?.containsKey(_localeKey) ?? false;

  static bool get hasStoredTheme => _prefs?.containsKey(_themeKey) ?? false;

  static bool get hasStoredNotifications =>
      _prefs?.containsKey(_notificationsKey) ?? false;

  static ThemeMode get themeMode => _parseThemeMode(_prefs?.getString(_themeKey));

  static bool get notificationsEnabled =>
      _prefs?.getBool(_notificationsKey) ?? true;

  /// True after the user finishes the one-time Mishka intro onboarding screen.
  static bool get hasCompletedOnboardingIntro =>
      _prefs?.getBool(_onboardingIntroKey) ?? false;

  /// False after sign-up until the user finishes the education profile screens.
  static bool get hasCompletedEducationSetup =>
      _prefs?.getBool(_educationSetupKey) ?? true;

  static Future<void> setEducationSetupCompleted(bool value) async {
    await _prefs?.setBool(_educationSetupKey, value);
  }

  static Future<void> setLocaleCode(String code) async {
    await _prefs?.setString(_localeKey, code);
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs?.setString(_themeKey, _themeModeToStorage(mode));
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    await _prefs?.setBool(_notificationsKey, value);
  }

  static Future<void> setOnboardingIntroCompleted(bool value) async {
    await _prefs?.setBool(_onboardingIntroKey, value);
  }

  /// UTC calendar date (`YYYY-MM-DD`) of the last successful `POST /daily-streaks/ping`.
  static String? get lastDailyStreakPingUtcDate =>
      _prefs?.getString(_lastStreakPingUtcDateKey);

  static Future<void> setLastDailyStreakPingUtcDate(String? utcDate) async {
    if (utcDate == null || utcDate.isEmpty) {
      await _prefs?.remove(_lastStreakPingUtcDateKey);
      return;
    }
    await _prefs?.setString(_lastStreakPingUtcDateKey, utcDate);
  }

  /// Last successful streak payload from `GET /daily-streaks` (or ping/freeze).
  static String? get cachedDailyStreakJson =>
      _prefs?.getString(_cachedDailyStreakJsonKey);

  static Future<void> setCachedDailyStreakJson(String? json) async {
    if (json == null || json.isEmpty) {
      await _prefs?.remove(_cachedDailyStreakJsonKey);
      return;
    }
    await _prefs?.setString(_cachedDailyStreakJsonKey, json);
  }

  /// Queued invite from a universal link before sign-in completes.
  static String? get pendingCommunityInviteJson =>
      _prefs?.getString(_pendingCommunityInviteKey);

  static Future<void> setPendingCommunityInviteLink(String? json) async {
    if (json == null || json.isEmpty) {
      await _prefs?.remove(_pendingCommunityInviteKey);
      return;
    }
    await _prefs?.setString(_pendingCommunityInviteKey, json);
  }

  static Future<void> clearPendingCommunityInviteLink() async {
    await _prefs?.remove(_pendingCommunityInviteKey);
  }

  static String? get chatBackendSessionId =>
      _prefs?.getString(_chatBackendSessionIdKey);

  static String? get chatAiSessionId => _prefs?.getString(_chatAiSessionIdKey);

  static Future<void> setChatBackendSessionId(String backendSessionId) async {
    await _prefs?.setString(_chatBackendSessionIdKey, backendSessionId);
  }

  static Future<void> setActiveChatSession({
    required String backendSessionId,
    required String aiSessionId,
  }) async {
    await _prefs?.setString(_chatBackendSessionIdKey, backendSessionId);
    await _prefs?.setString(_chatAiSessionIdKey, aiSessionId);
  }

  static Future<void> clearActiveChatSession() async {
    await _prefs?.remove(_chatBackendSessionIdKey);
    await _prefs?.remove(_chatAiSessionIdKey);
  }

  /// Last known user profile JSON — used when `/auth/me` is temporarily unavailable.
  static String? get cachedUserJson => _prefs?.getString(_cachedUserJsonKey);

  static Future<void> setCachedUserJson(String? json) async {
    if (json == null || json.isEmpty) {
      await _prefs?.remove(_cachedUserJsonKey);
      return;
    }
    await _prefs?.setString(_cachedUserJsonKey, json);
  }

  /// Report PDF / auto-email recipient; synced from Settings.
  static String? get reportEmailRecipient =>
      _prefs?.getString(_reportEmailRecipientKey);

  static Future<void> setReportEmailRecipient(String? email) async {
    final trimmed = email?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await _prefs?.remove(_reportEmailRecipientKey);
      return;
    }
    await _prefs?.setString(_reportEmailRecipientKey, trimmed);
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
