import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:mishka_app/features/gamification/presentation/widgets/gamification_section_card.dart';
import 'package:mishka_app/features/gamification/presentation/widgets/gamification_section_header.dart';
import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';
import 'package:mishka_app/features/home/presentation/widgets/daily_streak_week_row.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class GamificationStreakSection extends StatelessWidget {
  const GamificationStreakSection({
    super.key,
    required this.streakDays,
    required this.streakWeek,
    required this.freezesRemaining,
    this.onFreezeTap,
    this.onMonthlyTap,
  });

  final int streakDays;
  final List<DailyStreakDayModel> streakWeek;
  final int freezesRemaining;
  final ValueChanged<DailyStreakDayModel>? onFreezeTap;
  final VoidCallback? onMonthlyTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GamificationSectionHeader(
          title: l10n.dailyStreaks,
          showPeriodToggle: false,
          monthlyOnly: onMonthlyTap != null,
          weeklyLabel: l10n.gamificationWeekly,
          monthlyLabel: l10n.gamificationMonthly,
          onMonthlyTap: onMonthlyTap,
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Iconify(
              Mdi.fire,
              size: 16.sp,
              color: const Color(0xFF2E9E5B),
            ),
            SizedBox(width: 4.w),
            Text(
              l10n.gamificationStreakDaysPerWeek(streakDays),
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E9E5B),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        GamificationSectionCard(
          child: DailyStreakWeekRow(
            week: streakWeek,
            freezesRemaining: freezesRemaining,
            onFreezeTap: onFreezeTap,
          ),
        ),
      ],
    );
  }
}
