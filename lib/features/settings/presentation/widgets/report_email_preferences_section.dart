import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/features/Auth/data/models/user_model.dart';
import 'package:mishka_app/features/settings/data/data_sources/user_preferences_remote_data_source.dart';
import 'package:mishka_app/features/settings/data/models/report_email_preferences_model.dart';
import 'package:mishka_app/features/settings/presentation/screens/report_email_recipient_screen.dart';
import 'package:mishka_app/features/settings/presentation/widgets/settings_preference_controls.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Report auto-email + recipient controls (moved from general Settings).
class ReportEmailPreferencesSection extends StatefulWidget {
  const ReportEmailPreferencesSection({
    super.key,
    this.accountEmail,
  });

  final String? accountEmail;

  @override
  State<ReportEmailPreferencesSection> createState() =>
      _ReportEmailPreferencesSectionState();
}

class _ReportEmailPreferencesSectionState
    extends State<ReportEmailPreferencesSection> {
  late final UserPreferencesRemoteDataSource _remote =
      UserPreferencesRemoteDataSource(ApiService());

  ReportEmailPreferencesModel _reportEmailPrefs =
      const ReportEmailPreferencesModel();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromServer());
  }

  String? get _accountEmail {
    final direct = widget.accountEmail?.trim();
    if (direct != null && direct.isNotEmpty) return direct;
    final raw = AppPreferences.cachedUserJson;
    if (raw == null || raw.isEmpty) return null;
    try {
      final user =
          UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      final email = user.email.trim();
      return email.isEmpty ? null : email;
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadFromServer() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final me = await _remote.fetchMe();
      if (!mounted) return;
      if (me != null) {
        _reportEmailPrefs = me.reportEmail;
        await _syncReportRecipientFromServer(me.reportEmail);
      }
    } catch (_) {
      // Keep local preferences when offline.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _syncReportRecipientFromServer(
    ReportEmailPreferencesModel prefs,
  ) async {
    final effective = prefs.displayRecipientEmail;
    if (effective != null && effective.isNotEmpty) {
      await AppPreferences.setReportEmailRecipient(
        prefs.usingCustomRecipient ? effective : null,
      );
      if (prefs.usingCustomRecipient) {
        _reportEmailPrefs = prefs;
      } else {
        _reportEmailPrefs = prefs.copyWith(recipientEmail: null);
      }
      return;
    }
    if (prefs.hasRecipientEmail) {
      await AppPreferences.setReportEmailRecipient(prefs.recipientEmail);
      return;
    }
    final local = AppPreferences.reportEmailRecipient;
    if (local != null && local.isNotEmpty) {
      _reportEmailPrefs = prefs.copyWith(recipientEmail: local);
    }
  }

  String? get _effectiveRecipientEmail =>
      _reportEmailPrefs.displayRecipientEmail ??
      AppPreferences.reportEmailRecipient;

  Future<void> _openRecipientScreen() async {
    final saved = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ReportEmailRecipientScreen(
          initialEmail: _effectiveRecipientEmail,
          accountEmail: _accountEmail,
        ),
      ),
    );
    if (!mounted || saved == null) return;
    setState(
      () => _reportEmailPrefs = _reportEmailPrefs.copyWith(
        recipientEmail: saved,
      ),
    );
  }

  Future<void> _onReportAutoEmailChanged(bool enabled) async {
    if (!mounted || _saving) return;
    final locale = Localizations.localeOf(context).languageCode;
    setState(() => _saving = true);
    try {
      final saved = await _remote.patchMe(
        _reportEmailPrefs.toPatchJson(
          autoEnabled: enabled,
          locale: locale,
        ),
      );
      if (!mounted) return;
      setState(() => _reportEmailPrefs = saved.reportEmail);
    } on ApiException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.settingsSyncFailed}\n${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onReportFrequencyChanged(String frequency) async {
    if (!mounted || _saving || !_reportEmailPrefs.autoEnabled) return;
    final locale = Localizations.localeOf(context).languageCode;
    setState(() => _saving = true);
    try {
      final saved = await _remote.patchMe(
        _reportEmailPrefs.toPatchJson(
          autoEnabled: true,
          frequency: frequency,
          locale: locale,
        ),
      );
      if (!mounted) return;
      setState(() => _reportEmailPrefs = saved.reportEmail);
    } on ApiException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.settingsSyncFailed}\n${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadFromServer,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: AppScrollInsets.page(
              horizontal: AppSizes.paddingLarge,
              top: 20.h,
            ),
            children: [
              SettingsReportEmailCard(
                autoEnabled: _reportEmailPrefs.autoEnabled,
                frequency: _reportEmailPrefs.frequency,
                recipientEmail: _effectiveRecipientEmail,
                recipientNotSetLabel: l10n.settingsReportRecipientNotSet,
                onAutoEnabledChanged: _onReportAutoEmailChanged,
                onFrequencyChanged: _onReportFrequencyChanged,
                onRecipientTap: _openRecipientScreen,
              ),
            ],
          ),
        ),
        if (_loading || _saving)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 2,
              color: Color(0xFFC9A227),
              backgroundColor: Colors.transparent,
            ),
          ),
      ],
    );
  }
}
