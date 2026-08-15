import 'package:flutter/material.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/gamification/presentation/widgets/gamification_period_toggle.dart';

class GamificationSectionHeader extends StatelessWidget {
  const GamificationSectionHeader({
    super.key,
    required this.title,
    this.showPeriodToggle = true,
    this.monthlyOnly = false,
    this.selectedPeriod = GamificationPeriod.weekly,
    this.weeklyLabel = 'weekly',
    this.monthlyLabel = 'monthly',
    this.onWeeklyTap,
    this.onMonthlyTap,
  });

  final String title;
  final bool showPeriodToggle;
  final bool monthlyOnly;
  final GamificationPeriod selectedPeriod;
  final String weeklyLabel;
  final String monthlyLabel;
  final VoidCallback? onWeeklyTap;
  final VoidCallback? onMonthlyTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: AppSizes.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: AppColors.mainDark,
            ),
          ),
        ),
        if (monthlyOnly)
          GamificationPeriodToggle(
            selected: GamificationPeriod.monthly,
            weeklyLabel: weeklyLabel,
            monthlyLabel: monthlyLabel,
            showWeekly: false,
            onWeeklyTap: () {},
            onMonthlyTap: onMonthlyTap ?? () {},
          )
        else if (showPeriodToggle)
          GamificationPeriodToggle(
            selected: selectedPeriod,
            weeklyLabel: weeklyLabel,
            monthlyLabel: monthlyLabel,
            onWeeklyTap: onWeeklyTap ?? () {},
            onMonthlyTap: onMonthlyTap ?? () {},
          ),
      ],
    );
  }
}
