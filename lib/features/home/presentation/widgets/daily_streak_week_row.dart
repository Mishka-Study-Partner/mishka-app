import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';
import 'package:mishka_app/generated/assets.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class DailyStreakWeekRow extends StatelessWidget {
  const DailyStreakWeekRow({
    super.key,
    required this.week,
    this.freezesRemaining = 0,
    this.onFreezeTap,
    this.showLegend = true,
  });

  final List<DailyStreakDayModel> week;
  final int freezesRemaining;
  final ValueChanged<DailyStreakDayModel>? onFreezeTap;
  final bool showLegend;

  DailyStreakDayModel? _dayAt(int index) {
    if (week.length != 7 || index < 0 || index >= 7) return null;
    return week[index];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dayLabels = [
      l10n.mon,
      l10n.tue,
      l10n.wed,
      l10n.thu,
      l10n.fri,
      l10n.sat,
      l10n.sun,
    ];
    final weekCompleted = week.length == 7
        ? week.map((day) => day.isCompleted).toList()
        : List<bool>.filled(7, false);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (i) {
            final weekDay = _dayAt(i);
            final isToday =
                weekDay?.isToday ?? (i == DateTime.now().weekday - 1);
            final completed = weekCompleted[i];
            final missed = weekDay?.isMissed ?? false;
            final canFreeze = onFreezeTap != null &&
                missed &&
                freezesRemaining > 0 &&
                weekDay != null &&
                weekDay.date.isNotEmpty;

            return _DayItem(
              day: dayLabels[i],
              completed: completed || (weekDay?.isFrozen ?? false),
              isToday: isToday,
              onTap: canFreeze ? () => onFreezeTap!(weekDay) : null,
            );
          }),
        ),
        if (showLegend) ...[
          SizedBox(height: 16.h),
          Divider(color: AppColors.stroke, height: 1.h),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: AppColors.mainGold, text: l10n.completed),
              SizedBox(width: 16.w),
              _LegendItem(color: AppColors.white, text: l10n.today),
              SizedBox(width: 16.w),
              _LegendItem(
                color: AppColors.lightFrameBackground,
                text: l10n.upcoming,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DayItem extends StatelessWidget {
  const _DayItem({
    required this.day,
    required this.completed,
    required this.isToday,
    this.onTap,
  });

  final String day;
  final bool completed;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Widget? icon;

    if (completed) {
      bgColor = AppColors.mainGold;
      icon = Iconify(
        Mdi.check,
        size: 20.w,
        color: AppColors.white,
      );
    } else if (isToday) {
      bgColor = AppColors.white;
      icon = Image.asset(
        Assets.imagesStreakToday,
        width: 22.w,
        height: 30.w,
        fit: BoxFit.contain,
      );
    } else {
      bgColor = AppColors.lightFrameBackground;
      icon = null;
    }

    final dayCircle = Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
        border:
            isToday ? Border.all(color: AppColors.mainGold, width: 2) : null,
      ),
      child: Center(
        child: icon ??
            Text(
              day,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.lightText,
              ),
            ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: dayCircle);
    }
    return dayCircle;
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: color == AppColors.white
                ? Border.all(color: AppColors.stroke)
                : null,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: 10.sp,
            color: AppColors.lightText,
          ),
        ),
      ],
    );
  }
}
