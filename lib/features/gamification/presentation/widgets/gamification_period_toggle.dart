import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';

enum GamificationPeriod { weekly, monthly }

class GamificationPeriodToggle extends StatelessWidget {
  const GamificationPeriodToggle({
    super.key,
    required this.selected,
    required this.weeklyLabel,
    required this.monthlyLabel,
    required this.onWeeklyTap,
    required this.onMonthlyTap,
    this.showWeekly = true,
  });

  final GamificationPeriod selected;
  final String weeklyLabel;
  final String monthlyLabel;
  final VoidCallback onWeeklyTap;
  final VoidCallback onMonthlyTap;
  final bool showWeekly;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showWeekly) ...[
          _Pill(
            label: weeklyLabel,
            selected: selected == GamificationPeriod.weekly,
            onTap: onWeeklyTap,
          ),
          SizedBox(width: 8.w),
        ],
        GestureDetector(
          onTap: onMonthlyTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                monthlyLabel,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: selected == GamificationPeriod.monthly
                      ? AppColors.mainGold
                      : AppColors.mainDark,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16.sp,
                color: selected == GamificationPeriod.monthly
                    ? AppColors.mainGold
                    : AppColors.mainDark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.mainGold : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.mainGold : AppColors.stroke,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.mainDark,
          ),
        ),
      ),
    );
  }
}
