import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/core/widgets/app_settings_scope.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/settings/data/data_sources/user_preferences_remote_data_source.dart';
import 'package:mishka_app/features/settings/data/models/user_preferences_model.dart';
import 'package:mishka_app/features/student_subjects/presentation/screens/student_subjects_screen.dart';
import 'package:mishka_app/features/settings/presentation/widgets/settings_preference_controls.dart';
import 'package:mishka_app/features/settings/data/user_preferences_applier.dart';
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
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromServer());
  }

  Future<void> _applyResolvedPreferences(UserPreferencesModel? server) async {
    final effective = UserPreferencesApplier.resolve(server);
    final scope = AppSettingsScope.of(context);

    if (scope.locale.languageCode != effective.languageCode) {
      await scope.onLocaleChanged(effective.locale);
    }
    if (scope.themeMode != effective.themeMode) {
      await scope.onThemeModeChanged(effective.themeMode);
    }
    if (scope.notificationsEnabled != effective.notificationsEnabled) {
      await scope.onNotificationsChanged(effective.notificationsEnabled);
    }

    if (server != null &&
        (server.languageCode != effective.languageCode ||
            server.themeMode != effective.themeMode ||
            server.notificationsEnabled != effective.notificationsEnabled)) {
      unawaited(_syncDevicePreferencesToServer(effective));
    }
  }

  Future<void> _syncDevicePreferencesToServer(UserPreferencesModel prefs) async {
    try {
      final saved = await _remote.upsertForUser(widget.userId, prefs);
      if (!mounted) return;
      setState(() => _serverPrefs = saved);
    } catch (_) {
      // Local device prefs remain authoritative; retry on next settings visit.
    }
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
          await _applyResolvedPreferences(me.core);
        }
      } else {
        final remote = await _remote.fetchForUser(widget.userId);
        if (!mounted) return;
        if (remote != null) {
          _serverPrefs = remote;
          await _applyResolvedPreferences(remote);
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
              padding: AppScrollInsets.page(
                horizontal: AppSizes.paddingLarge,
                top: 20.h,
              ),
              children: [
                SettingsPreferencesCard(
                  onLocaleChanged: _onLocaleChanged,
                  onThemeModeChanged: _onThemeModeChanged,
                  onNotificationsChanged: _onNotificationsChanged,
                ),
                SizedBox(height: 16.h),
                _SettingsLinkTile(
                  icon: Icons.menu_book_outlined,
                  title: l10n.studentSubjectsTitle,
                  subtitle: l10n.studentSubjectsSettingsHint,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StudentSubjectsScreen(),
                      ),
                    );
                  },
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

class _SettingsLinkTile extends StatelessWidget {
  const _SettingsLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFC9A227), size: 24.w),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: 12.sp,
                        color: AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.greyText, size: 22.w),
            ],
          ),
        ),
      ),
    );
  }
}
