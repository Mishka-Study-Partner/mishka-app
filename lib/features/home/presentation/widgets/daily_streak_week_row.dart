import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
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
    final compact = AppBreakpoints.isTablet(context);
    final dayLabels = [
      l10n.sat,
      l10n.sun,
      l10n.mon,
      l10n.tue,
      l10n.wed,
      l10n.thu,
      l10n.fri,
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (i) {
            final weekDay = _dayAt(i);
            final completed =
                (weekDay?.isCompleted ?? false) || (weekDay?.isFrozen ?? false);
            final missed = weekDay?.isMissed ?? false;
            final isToday = weekDay?.isToday ?? false;
            final canFreeze = onFreezeTap != null &&
                missed &&
                freezesRemaining > 0 &&
                weekDay != null &&
                weekDay.date.isNotEmpty;

            return _DayItem(
              dayLabel: dayLabels[i],
              completed: completed,
              missed: missed,
              isToday: isToday,
              compact: compact,
              onTap: canFreeze ? () => onFreezeTap!(weekDay) : null,
            );
          }),
        ),
        if (showLegend) ...[
          SizedBox(height: compact ? 10.h : 16.h),
          Divider(color: AppColors.stroke, height: 1.h),
          SizedBox(height: compact ? 10.h : 16.h),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: compact ? 12.w : 16.w,
            runSpacing: compact ? 6.h : 8.h,
            children: [
              _LegendItem(color: AppColors.mainGold, text: l10n.completed),
              _LegendItem(color: AppColors.white, text: l10n.today),
              _LegendItem(
                color: AppColors.lightFrameBackground,
                text: l10n.upcoming,
              ),
              _LegendItem(
                color: AppColors.lightFrameBackground,
                text: l10n.streakMissed,
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
    required this.dayLabel,
    required this.completed,
    required this.missed,
    required this.isToday,
    this.compact = false,
    this.onTap,
  });

  final String dayLabel;
  final bool completed;
  final bool missed;
  final bool isToday;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tileSize = compact ? AppScale.w(32) : 40.w;
    final iconSize = compact ? AppScale.w(14) : 18.w;
    final todayImageW = compact ? AppScale.w(16) : 20.w;
    final todayImageH = compact ? AppScale.w(20) : 26.w;
    final labelSize = compact ? AppScale.sp(10) : 11.sp;

    final Color bgColor;
    final Widget statusIcon;
    Border? border;

    if (completed) {
      bgColor = AppColors.mainGold;
      statusIcon = Iconify(
        Mdi.check,
        size: iconSize,
        color: AppColors.white,
      );
    } else if (missed) {
      bgColor = AppColors.lightFrameBackground;
      statusIcon = Iconify(
        Mdi.close,
        size: iconSize,
        color: AppColors.lightText,
      );
    } else if (isToday) {
      bgColor = AppColors.white;
      statusIcon = Image.asset(
        Assets.imagesStreakToday,
        width: todayImageW,
        height: todayImageH,
        fit: BoxFit.contain,
      );
      border = Border.all(color: AppColors.mainGold, width: compact ? 1.5 : 2);
    } else {
      bgColor = AppColors.lightFrameBackground;
      statusIcon = const SizedBox.shrink();
    }

    final tile = SizedBox(
      width: tileSize,
      child: Column(
        children: [
          Container(
            width: tileSize,
            height: tileSize,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(compact ? 6.r : 8.r),
              border: border,
            ),
            child: Center(child: statusIcon),
          ),
          SizedBox(height: compact ? 4.h : 6.h),
          Text(
            dayLabel,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: labelSize,
              fontWeight: FontWeight.w600,
              color: isToday ? AppColors.mainGold : AppColors.mainDark,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: tile);
    }
    return tile;
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.text,
    this.borderColor,
  });

  final Color color;
  final String text;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: borderColor != null || color == AppColors.white
                ? Border.all(color: borderColor ?? AppColors.stroke)
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
