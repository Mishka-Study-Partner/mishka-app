import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/app_settings_scope.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/settings/data/data_sources/user_preferences_remote_data_source.dart';
import 'package:mishka_app/features/settings/data/models/report_email_preferences_model.dart';
import 'package:mishka_app/features/settings/data/models/user_preferences_model.dart';
import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/features/settings/presentation/screens/report_email_recipient_screen.dart';
import 'package:mishka_app/features/settings/presentation/widgets/settings_preference_controls.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.userId,
    this.accountEmail,
  });

  final String userId;
  final String? accountEmail;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final UserPreferencesRemoteDataSource _remote =
      UserPreferencesRemoteDataSource(ApiService());

  UserPreferencesModel? _serverPrefs;
  ReportEmailPreferencesModel _reportEmailPrefs =
      const ReportEmailPreferencesModel();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromServer());
  }

  Future<void> _loadFromServer() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final me = await _remote.fetchMe();
      if (!mounted) return;
      if (me != null) {
        if (me.core != null) {
          _serverPrefs = me.core;
          final scope = AppSettingsScope.of(context);
          final remote = me.core!;
          if (scope.locale.languageCode != remote.languageCode) {
            await scope.onLocaleChanged(remote.locale);
          }
          if (scope.themeMode != remote.themeMode) {
            await scope.onThemeModeChanged(remote.themeMode);
          }
          if (scope.notificationsEnabled != remote.notificationsEnabled) {
            await scope.onNotificationsChanged(remote.notificationsEnabled);
          }
        }
        _reportEmailPrefs = me.reportEmail;
        await _syncReportRecipientFromServer(me.reportEmail);
      } else {
        final remote = await _remote.fetchForUser(widget.userId);
        if (!mounted) return;
        if (remote != null) {
          _serverPrefs = remote;
          final scope = AppSettingsScope.of(context);
          if (scope.locale.languageCode != remote.languageCode) {
            await scope.onLocaleChanged(remote.locale);
          }
          if (scope.themeMode != remote.themeMode) {
            await scope.onThemeModeChanged(remote.themeMode);
          }
          if (scope.notificationsEnabled != remote.notificationsEnabled) {
            await scope.onNotificationsChanged(remote.notificationsEnabled);
          }
        } else {
          final scope = AppSettingsScope.of(context);
          final seeded = await _remote.upsertForUser(
            widget.userId,
            _prefsFromScope(scope),
          );
          if (!mounted) return;
          _serverPrefs = seeded;
        }
      }
    } catch (_) {
      // Keep local preferences when offline or endpoint unavailable.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  UserPreferencesModel _prefsFromScope(AppSettingsScope scope) {
    return UserPreferencesModel(
      id: _serverPrefs?.id,
      languageCode: scope.locale.languageCode,
      themeMode: scope.themeMode,
      notificationsEnabled: scope.notificationsEnabled,
    );
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
          accountEmail: widget.accountEmail,
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

  Future<void> _persistToServer() async {
    if (!mounted || _saving) return;
    final scope = AppSettingsScope.of(context);
    final prefs = _prefsFromScope(scope);

    setState(() => _saving = true);
    try {
      final saved = await _remote.upsertForUser(widget.userId, prefs);
      if (!mounted) return;
      setState(() => _serverPrefs = saved);
    } on ApiException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.settingsSyncFailed}\n${e.message}'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsSyncFailed)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _onLocaleChanged(Locale locale) async {
    await AppSettingsScope.of(context).onLocaleChanged(locale);
    await _persistToServer();
  }

  Future<void> _onThemeModeChanged(ThemeMode mode) async {
    await AppSettingsScope.of(context).onThemeModeChanged(mode);
    await _persistToServer();
  }

  Future<void> _onNotificationsChanged(bool enabled) async {
    await AppSettingsScope.of(context).onNotificationsChanged(enabled);
    await _persistToServer();
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: MishkaAppBar(
        title: l10n.settings,
        topTitle: l10n.settings,
        showBack: true,
        showBottomBar: false,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadFromServer,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLarge,
                vertical: 20.h,
              ),
              children: [
                SettingsPreferencesCard(
                  onLocaleChanged: _onLocaleChanged,
                  onThemeModeChanged: _onThemeModeChanged,
                  onNotificationsChanged: _onNotificationsChanged,
                ),
                SizedBox(height: 16.h),
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
      ),
    );
  }
}
