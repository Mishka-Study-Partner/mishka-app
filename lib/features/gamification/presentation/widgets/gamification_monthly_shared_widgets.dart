import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/gamification/data/gamification_monthly_model.dart';

class GamificationWeekStatusIcon extends StatelessWidget {
  const GamificationWeekStatusIcon({super.key, required this.goalMet});

  final bool goalMet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        color: goalMet ? const Color(0xFF2E9E5B) : const Color(0xFFE04B4B),
        shape: BoxShape.circle,
        border: Border.all(
          color: goalMet ? const Color(0xFF2E9E5B) : const Color(0xFFE04B4B),
          width: 2,
        ),
      ),
      child: Center(
        child: Iconify(
          goalMet ? Mdi.check : Mdi.close,
          size: 12.sp,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class GamificationMonthlyWeekRow extends StatelessWidget {
  const GamificationMonthlyWeekRow({
    super.key,
    required this.weekLabel,
    required this.rangeLabel,
    required this.goalMet,
  });

  final String weekLabel;
  final String rangeLabel;
  final bool goalMet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          GamificationWeekStatusIcon(goalMet: goalMet),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: 11.sp,
                  color: AppColors.mainDark,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: weekLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' [$rangeLabel]'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GamificationMonthlySummaryCard extends StatelessWidget {
  const GamificationMonthlySummaryCard({
    super.key,
    required this.badgeAssetPath,
    required this.weeks,
    required this.weekLabelBuilder,
    required this.rangeLabelBuilder,
  });

  final String badgeAssetPath;
  final List<GamificationMonthWeekStat> weeks;
  final String Function(GamificationMonthWeekStat week) weekLabelBuilder;
  final String Function(GamificationMonthWeekStat week) rangeLabelBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96.w,
            child: Image.asset(
              badgeAssetPath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.emoji_events_outlined,
                size: 64.sp,
                color: AppColors.mainGold,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              children: [
                for (final week in weeks)
                  GamificationMonthlyWeekRow(
                    weekLabel: weekLabelBuilder(week),
                    rangeLabel: rangeLabelBuilder(week),
                    goalMet: week.goalMet,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GamificationMonthlyWeekDetailCard extends StatelessWidget {
  const GamificationMonthlyWeekDetailCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressLabel,
    required this.goalMet,
  });

  final String title;
  final String subtitle;
  final double progress;
  final String progressLabel;
  final bool goalMet;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.mainDark,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.mainGold,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10.h,
              backgroundColor: AppColors.lightFrameBackground,
              color: goalMet ? const Color(0xFF2E9E5B) : const Color(0xFFE04B4B),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            progressLabel,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
}

class GamificationMonthlyAiWeekDetailCard extends StatelessWidget {
  const GamificationMonthlyAiWeekDetailCard({
    super.key,
    required this.week,
    required this.weekLabel,
    required this.rangeLabel,
  });

  final GamificationMonthWeekStat week;
  final String weekLabel;
  final String rangeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148.w,
      margin: EdgeInsets.only(right: 10.w),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.mainGold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            weekLabel,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.mainDark,
            ),
          ),
          SizedBox(height: 4.h),
          if (week.detailSubtitle != null)
            Text(
              week.detailSubtitle!,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.lightText,
                height: 1.25,
              ),
            ),
          SizedBox(height: 6.h),
          Text(
            week.progressLabel,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.mainGold,
            ),
          ),
        ],
      ),
    );
  }
}
