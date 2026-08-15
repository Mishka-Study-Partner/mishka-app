import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/report/data/models/report_models.dart';

class ReportVerticalBarChart extends StatelessWidget {
  const ReportVerticalBarChart({
    super.key,
    required this.buckets,
    this.maxValue = 60,
    this.valueSuffix = 'm',
    this.barColor = AppColors.blue,
  });

  final List<ReportBucket> buckets;
  final double maxValue;
  final String valueSuffix;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) return const SizedBox.shrink();
    final peak = math.max(
      maxValue,
      buckets.map((b) => b.value).fold<double>(0, math.max),
    );

    return SizedBox(
      height: 180.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: buckets.map((bucket) {
          final ratio = peak <= 0 ? 0.0 : (bucket.value / peak).clamp(0.0, 1.0);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (bucket.value > 0)
                    Text(
                      '${bucket.value.toStringAsFixed(0)}$valueSuffix',
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: 9.sp,
                        color: AppColors.lightText,
                      ),
                    ),
                  SizedBox(height: 4.h),
                  Container(
                    height: (120.h * ratio).clamp(4.h, 120.h),
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    bucket.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: 10.sp,
                      color: AppColors.mainDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ReportProgressRing extends StatelessWidget {
  const ReportProgressRing({
    super.key,
    required this.percent,
    required this.label,
  });

  final int percent;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            width: 72.w,
            height: 72.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 7,
                    backgroundColor: AppColors.stroke,
                    color: AppColors.green,
                  ),
                ),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppSizes.fontSizeMedium,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mainDark,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: 10.sp,
              color: AppColors.mainDark,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class ReportStudyBySubjectChart extends StatelessWidget {
  const ReportStudyBySubjectChart({
    super.key,
    required this.rows,
    required this.minutesSuffix,
  });

  final List<StudySubjectReportRow> rows;
  final String minutesSuffix;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    final peak = math.max(
      1.0,
      rows.map((r) => r.studyMinutes).fold<double>(0, math.max),
    );

    return Column(
      children: rows.map((row) {
        final ratio = (row.studyMinutes / peak).clamp(0.0, 1.0);
        final barColor = row.displayColor ?? AppColors.blue;
        final minutesLabel = '${row.studyMinutes.toStringAsFixed(0)}$minutesSuffix';
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      row.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainDark,
                      ),
                    ),
                  ),
                  Text(
                    '$minutesLabel · ${row.percentOfTotal}%',
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: 10.sp,
                      color: AppColors.lightText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 22.h,
                    decoration: BoxDecoration(
                      color: AppColors.lightFrameBackground,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: ratio,
                    child: Container(
                      height: 22.h,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class ReportHorizontalBars extends StatelessWidget {
  const ReportHorizontalBars({
    super.key,
    required this.buckets,
    this.valueAsPercent = true,
  });

  final List<ReportBucket> buckets;
  final bool valueAsPercent;

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) return const SizedBox.shrink();

    final peak = valueAsPercent
        ? 100.0
        : math.max(
            1.0,
            buckets.map((b) => b.value).fold<double>(0, math.max),
          );

    return Column(
      children: buckets.map((bucket) {
        final ratio = valueAsPercent
            ? (bucket.value / 100).clamp(0.0, 1.0)
            : (bucket.value / peak).clamp(0.0, 1.0);
        final valueLabel = valueAsPercent
            ? '${bucket.value.toStringAsFixed(0)}%'
            : bucket.value.toStringAsFixed(0);
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Row(
            children: [
              SizedBox(
                width: 36.w,
                child: Text(
                  bucket.label,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: 11.sp,
                    color: AppColors.mainDark,
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 22.h,
                      decoration: BoxDecoration(
                        color: AppColors.lightFrameBackground,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: ratio,
                      child: Container(
                        height: 22.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: ratio > 0.18
                            ? Text(
                                valueLabel,
                                style: TextStyle(
                                  fontFamily: 'Pridi',
                                  fontSize: 10.sp,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class ReportTaskBarChart extends StatelessWidget {
  const ReportTaskBarChart({super.key, required this.buckets});

  final List<TaskReportBucket> buckets;

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 190.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: buckets.map((bucket) {
          final ratio = bucket.ratio.clamp(0.0, 1.0);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${bucket.completed} / ${bucket.total}',
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: 9.sp,
                      color: AppColors.lightText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 110.h,
                        decoration: BoxDecoration(
                          color: AppColors.lightFrameBackground,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(4.r),
                          ),
                        ),
                      ),
                      Container(
                        height: (110.h * ratio).clamp(4.h, 110.h),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(4.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    bucket.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: 10.sp,
                      color: AppColors.mainDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ReportStreakSummary extends StatelessWidget {
  const ReportStreakSummary({
    super.key,
    required this.current,
    required this.longest,
    required this.freezes,
    required this.currentLabel,
    required this.longestLabel,
    required this.freezesLabel,
  });

  final int current;
  final int longest;
  final int freezes;
  final String currentLabel;
  final String longestLabel;
  final String freezesLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StreakStat(label: currentLabel, value: '$current')),
        Expanded(child: _StreakStat(label: longestLabel, value: '$longest')),
        Expanded(child: _StreakStat(label: freezesLabel, value: '$freezes')),
      ],
    );
  }
}

class _StreakStat extends StatelessWidget {
  const _StreakStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: AppSizes.fontSizeXXLarge,
            fontWeight: FontWeight.w700,
            color: AppColors.mainGold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: AppSizes.fontSizeSmall,
            color: AppColors.lightText,
          ),
        ),
      ],
    );
  }
}

class ReportEmptyHint extends StatelessWidget {
  const ReportEmptyHint({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        message,
        style: TextStyle(
          fontFamily: 'Pridi',
          fontSize: AppSizes.fontSizeMedium,
          color: AppColors.lightText,
        ),
      ),
    );
  }
}

class ReportSectionCard extends StatelessWidget {
  const ReportSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: AppSizes.fontSizeLarge,
              fontWeight: FontWeight.w700,
              color: AppColors.mainDark,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.mainDark,
            ),
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

class ReportCommunitySummary extends StatelessWidget {
  const ReportCommunitySummary({
    super.key,
    required this.stats,
    required this.messagesLabel,
    required this.sharesLabel,
    required this.joinsLabel,
  });

  final CommunityReportStats stats;
  final String messagesLabel;
  final String sharesLabel;
  final String joinsLabel;

  @override
  Widget build(BuildContext context) {
    return ReportStreakSummary(
      current: stats.messagesPosted,
      longest: stats.materialShares,
      freezes: stats.channelJoins,
      currentLabel: messagesLabel,
      longestLabel: sharesLabel,
      freezesLabel: joinsLabel,
    );
  }
}
