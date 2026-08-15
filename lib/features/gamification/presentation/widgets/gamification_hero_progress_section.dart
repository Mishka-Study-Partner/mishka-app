import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/gamification/data/gamification_dashboard_model.dart';
import 'package:mishka_app/features/gamification/presentation/widgets/gamification_progress_bar.dart';
import 'package:mishka_app/features/gamification/presentation/widgets/gamification_section_card.dart';
import 'package:mishka_app/features/gamification/utils/gamification_badge_assets.dart';

class GamificationHeroProgressSection extends StatelessWidget {
  const GamificationHeroProgressSection({
    super.key,
    required this.goalText,
    required this.primaryStat,
    required this.secondaryStat,
    required this.progressLabel,
    required this.monthlyBadgeText,
    required this.section,
    required this.data,
  });

  final String goalText;
  final String primaryStat;
  final String secondaryStat;
  final String progressLabel;
  final String monthlyBadgeText;
  final GamificationSectionHero section;
  final GamificationProgressSection data;

  @override
  Widget build(BuildContext context) {
    return GamificationSectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goalText,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainGold,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  primaryStat,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mainDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  secondaryStat,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainDark,
                  ),
                ),
                SizedBox(height: 10.h),
                GamificationProgressBar(
                  progress: data.computedProgress,
                  label: progressLabel,
                ),
                SizedBox(height: 8.h),
                Text(
                  monthlyBadgeText,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E9E5B),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 96.w,
            child: Center(
              child: Image.asset(
                GamificationBadgeAssets.sectionHeroAsset(section),
                width: 96.w,
                height: 96.w,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Iconify(
                  Mdi.trophy,
                  size: 72.sp,
                  color: AppColors.mainGold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
