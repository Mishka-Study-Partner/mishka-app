import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/app_settings_scope.dart';
import 'package:mishka_app/features/profile/presentation/widgets/profile_info_row.dart';
import 'package:mishka_app/features/profile/presentation/widgets/profile_section_card.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Gold-accent theme for language / theme / notification controls on settings.
ThemeData preferenceControlsTheme(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  final iconOnGold =
      brightness == Brightness.dark ? AppColors.white : AppColors.mainDark;

  return Theme.of(context).copyWith(
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.mainGold;
        return null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.mainGold.withValues(alpha: 0.42);
        }
        return null;
      }),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return iconOnGold;
          return null;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.mainGold;
          return null;
        }),
      ),
    ),
  );
}

class SettingsPreferencesCard extends StatelessWidget {
  const SettingsPreferencesCard({
    super.key,
    required this.onLocaleChanged,
    required this.onThemeModeChanged,
    required this.onNotificationsChanged,
  });

  final Future<void> Function(Locale locale) onLocaleChanged;
  final Future<void> Function(ThemeMode themeMode) onThemeModeChanged;
  final Future<void> Function(bool enabled) onNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scope = AppSettingsScope.of(context);

    return ProfileSectionCard(
      child: Theme(
        data: preferenceControlsTheme(context),
        child: Column(
          children: [
            ProfileInfoRow(
              icon: Icons.language,
              title: l10n.language,
              trailing: _LanguageToggle(
                isArabic: scope.locale.languageCode == 'ar',
                onChanged: (isArabic) =>
                    onLocaleChanged(Locale(isArabic ? 'ar' : 'en')),
              ),
            ),
            SizedBox(height: 12.h),
            ProfileInfoRow(
              icon: Icons.dark_mode,
              title: l10n.theme,
              trailing: _ThemeSegmented(
                selected: scope.themeMode,
                onChanged: onThemeModeChanged,
              ),
            ),
            SizedBox(height: 12.h),
            ProfileInfoRow(
              icon: Icons.notifications,
              title: l10n.notification,
              trailing: _NotificationToggle(
                enabled: scope.notificationsEnabled,
                onChanged: onNotificationsChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsReportEmailCard extends StatelessWidget {
  const SettingsReportEmailCard({
    super.key,
    required this.autoEnabled,
    required this.frequency,
    required this.recipientEmail,
    required this.recipientNotSetLabel,
    required this.onAutoEnabledChanged,
    required this.onFrequencyChanged,
    required this.onRecipientTap,
  });

  final bool autoEnabled;
  final String frequency;
  final String? recipientEmail;
  final String recipientNotSetLabel;
  final Future<void> Function(bool enabled) onAutoEnabledChanged;
  final Future<void> Function(String frequency) onFrequencyChanged;
  final VoidCallback onRecipientTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return ProfileSectionCard(
      child: Theme(
        data: preferenceControlsTheme(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileInfoRow(
              icon: Icons.mail_outline,
              title: l10n.settingsReportAutoEmail,
              trailing: Transform.scale(
                scale: .82,
                child: Switch.adaptive(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: autoEnabled,
                  onChanged: (v) => onAutoEnabledChanged(v),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            ProfileInfoRow(
              icon: Icons.alternate_email,
              title: l10n.settingsReportRecipientRow,
              value: (recipientEmail != null && recipientEmail!.trim().isNotEmpty)
                  ? recipientEmail!.trim()
                  : recipientNotSetLabel,
              onTap: onRecipientTap,
            ),
            if (autoEnabled) ...[
              SizedBox(height: 8.h),
              Text(
                l10n.settingsReportAutoEmailHint,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: 12.sp,
                  color: onSurface.withValues(alpha: 0.65),
                ),
              ),
              SizedBox(height: 12.h),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: 'weekly',
                    label: Text(l10n.reportEmailWeekly),
                  ),
                  ButtonSegment(
                    value: 'monthly',
                    label: Text(l10n.reportEmailMonthly),
                  ),
                ],
                selected: {frequency},
                onSelectionChanged: (next) {
                  if (next.isEmpty) return;
                  onFrequencyChanged(next.first);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({
    required this.isArabic,
    required this.onChanged,
  });

  final bool isArabic;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    const labelFont = 9.0;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerEnd,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.english,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: labelFont.sp,
              fontWeight: isArabic ? FontWeight.w500 : FontWeight.w700,
              color: onSurface.withValues(alpha: isArabic ? 0.55 : 0.92),
            ),
          ),
          Transform.scale(
            scale: .82,
            child: Switch.adaptive(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: isArabic,
              onChanged: onChanged,
            ),
          ),
          Text(
            l10n.arabic,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: labelFont.sp,
              fontWeight: isArabic ? FontWeight.w700 : FontWeight.w500,
              color: onSurface.withValues(alpha: isArabic ? 0.92 : 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSegmented extends StatelessWidget {
  const _ThemeSegmented({
    required this.selected,
    required this.onChanged,
  });

  final ThemeMode selected;
  final Future<void> Function(ThemeMode themeMode) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerEnd,
      child: SegmentedButton<ThemeMode>(
        showSelectedIcon: false,
        multiSelectionEnabled: false,
        emptySelectionAllowed: false,
        segments: [
          ButtonSegment<ThemeMode>(
            value: ThemeMode.light,
            tooltip: l10n.lightMode,
            icon: const Icon(Icons.light_mode_outlined, size: 20),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.dark,
            tooltip: l10n.darkMode,
            icon: const Icon(Icons.dark_mode_outlined, size: 20),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.system,
            tooltip: l10n.themeSystem,
            icon: const Icon(Icons.brightness_auto_outlined, size: 20),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (next) {
          if (next.isEmpty) return;
          onChanged(next.first);
        },
      ),
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final Future<void> Function(bool enabled) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    const labelFont = 9.0;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerEnd,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.disabled,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: labelFont.sp,
              fontWeight: enabled ? FontWeight.w500 : FontWeight.w700,
              color: onSurface.withValues(alpha: enabled ? 0.55 : 0.92),
            ),
          ),
          Transform.scale(
            scale: .82,
            child: Switch.adaptive(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: enabled,
              onChanged: (v) => onChanged(v),
            ),
          ),
          Text(
            l10n.enabled,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: labelFont.sp,
              fontWeight: enabled ? FontWeight.w700 : FontWeight.w500,
              color: onSurface.withValues(alpha: enabled ? 0.92 : 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
