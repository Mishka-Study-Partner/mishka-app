import 'package:flutter/widgets.dart';

/// API locale (`en` | `ar`) safe to call from [State.initState] (no [BuildContext]).
String communityApiLocale([BuildContext? context]) {
  if (context != null) {
    final locale = Localizations.maybeLocaleOf(context);
    if (locale != null) {
      return locale.languageCode == 'ar' ? 'ar' : 'en';
    }
  }
  final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return code == 'ar' ? 'ar' : 'en';
}
