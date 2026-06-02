import 'package:flutter/material.dart';

/// Server-backed user preferences per OpenAPI (`language`, `theme`, `notificationsEnabled`).
class UserPreferencesModel {
  const UserPreferencesModel({
    this.id,
    this.userId,
    required this.languageCode,
    required this.themeMode,
    required this.notificationsEnabled,
    this.updatedAt,
  });

  final String? id;
  final String? userId;

  /// App locale code: `en` or `ar`.
  final String languageCode;
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final String? updatedAt;

  Locale get locale => Locale(languageCode);

  /// PUT `/users/{id}/preferences` body (see OpenAPI `JsonRecord` description).
  Map<String, dynamic> toUpsertJson() => {
        'language': languageToApi(languageCode),
        'theme': themeToApi(themeMode),
        'notificationsEnabled': notificationsEnabled,
      };

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    final lang = _readString(json, const ['language']);
    final theme = _readString(json, const ['theme', 'themeMode']);
    final notifications = _readBool(json, const [
      'notificationsEnabled',
      'notifications',
      'pushNotifications',
    ]);

    return UserPreferencesModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString(),
      languageCode: languageFromApi(lang),
      themeMode: themeFromApi(theme),
      notificationsEnabled: notifications ?? true,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  static UserPreferencesModel? tryParseEnvelopeData(Object? raw) {
    if (raw == null) return null;
    if (raw is Map) {
      return UserPreferencesModel.fromJson(Map<String, dynamic>.from(raw));
    }
    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is Map) {
        return UserPreferencesModel.fromJson(Map<String, dynamic>.from(first));
      }
    }
    return null;
  }

  /// API stores display names (`Arabic`, `English`), not ISO codes.
  static String languageToApi(String code) {
    return code == 'ar' ? 'Arabic' : 'English';
  }

  static String languageFromApi(String? raw) {
    final v = (raw ?? 'English').trim().toLowerCase();
    if (v == 'ar' || v == 'arabic' || v.startsWith('ar')) return 'ar';
    return 'en';
  }

  static String themeToApi(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
  }

  static ThemeMode themeFromApi(String? raw) {
    switch ((raw ?? 'light').trim().toLowerCase()) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  static String? _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final v = json[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  static bool? _readBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final v = json[key];
      if (v is bool) return v;
    }
    return null;
  }
}
