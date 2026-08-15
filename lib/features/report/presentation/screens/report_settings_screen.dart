import 'package:flutter/material.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/settings/presentation/widgets/report_email_preferences_section.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class ReportSettingsScreen extends StatelessWidget {
  const ReportSettingsScreen({
    super.key,
    this.accountEmail,
  });

  final String? accountEmail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: MishkaAppBar(
        title: l10n.reportSettingsTitle,
        topTitle: l10n.yourReport,
        showBack: true,
        showBottomBar: false,
      ),
      body: ReportEmailPreferencesSection(accountEmail: accountEmail),
    );
  }
}
