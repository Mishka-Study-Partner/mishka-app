import 'package:flutter/widgets.dart';

/// Synced from [MaterialApp] via [syncFromContext] so [Accept-Language] matches UI.
class AppNetworkConfig {
  AppNetworkConfig._();

  /// Values sent as `Accept-Language`: `ar` or `en` (backend expects these).
  static String acceptLanguage = 'en';

  static void syncFromContext(BuildContext context) {
    final locale = Localizations.localeOf(context);
    acceptLanguage = locale.languageCode == 'ar' ? 'ar' : 'en';
  }
}
