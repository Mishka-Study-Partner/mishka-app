import 'package:iconify_flutter/icons/lucide.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class MainNavDestination {
  const MainNavDestination({
    required this.label,
    required this.icon,
  });

  final String label;
  final String icon;
}

List<MainNavDestination> mainNavDestinations(AppLocalizations l10n) {
  return [
    MainNavDestination(label: l10n.home, icon: Mdi.home_outline),
    MainNavDestination(label: l10n.toDo, icon: Lucide.layout_list),
    MainNavDestination(label: l10n.category, icon: Mdi.category_outline),
    MainNavDestination(label: l10n.saved, icon: Mdi.content_save_check),
    MainNavDestination(label: l10n.profile, icon: Mdi.account_circle_outline),
  ];
}
