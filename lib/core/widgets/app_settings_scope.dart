import 'package:flutter/material.dart';

/// Holds app-wide UI settings callbacks and mirrors of current values so
/// profile (and similar) can persist + update locale, theme, etc.
class AppSettingsScope extends InheritedWidget {
  const AppSettingsScope({
    super.key,
    required this.locale,
    required this.themeMode,
    required this.notificationsEnabled,
    required this.onLocaleChanged,
    required this.onThemeModeChanged,
    required this.onNotificationsChanged,
    required super.child,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final bool notificationsEnabled;

  /// Persists preference and notifies root to rebuild [MaterialApp].
  final Future<void> Function(Locale locale) onLocaleChanged;
  final Future<void> Function(ThemeMode themeMode) onThemeModeChanged;
  final Future<void> Function(bool enabled) onNotificationsChanged;

  static AppSettingsScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
  }

  static AppSettingsScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'AppSettingsScope missing above context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppSettingsScope oldWidget) {
    return locale != oldWidget.locale ||
        themeMode != oldWidget.themeMode ||
        notificationsEnabled != oldWidget.notificationsEnabled;
  }
}
