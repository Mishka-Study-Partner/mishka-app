import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/utils/app_colors.dart';
import '../../core/utils/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../l10n/app_localizations.dart';

class OurCommunity extends StatelessWidget {
  final VoidCallback? onBack;

  const OurCommunity({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.ourCommunity,
        showBack: true,
        showBottomBar: false,
        onBackTap: onBack,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            Text(
              l10n.mishkasCommunity,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeXXLarge,
                fontWeight: FontWeight.w600,
                color: AppColors.mainDark,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              l10n.ourCommunitySubtitle,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                color: AppColors.greyText,
              ),
            ),
            SizedBox(height: 24.h),
            _CommunityOptionCard(
              icon: Icons.menu_book_rounded,
              title: l10n.mentorLibrary,
              onTap: () => _showComingSoon(context, l10n),
            ),
            SizedBox(height: 12.h),
            _CommunityOptionCard(
              icon: Icons.event,
              title: l10n.communityEvents,
              onTap: () => _showComingSoon(context, l10n),
            ),
            SizedBox(height: 12.h),
            _CommunityOptionCard(
              icon: Icons.history,
              title: l10n.mentorshipHistory,
              onTap: () => _showComingSoon(context, l10n),
            ),
            const Spacer(),
            _buildBottomActions(context, l10n),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showComingSoon(context, l10n),
            icon: const Icon(Icons.add, color: AppColors.white),
            label: Text(
              l10n.joinNewCommunity,
              style: const TextStyle(fontFamily: 'Pridi', color: AppColors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainGold,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showComingSoon(context, l10n),
            icon: const Icon(Icons.refresh, color: AppColors.mainGold),
            label: Text(
              l10n.rejoinSavedCommunity,
              style: const TextStyle(fontFamily: 'Pridi', color: AppColors.mainGold),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              side: const BorderSide(color: AppColors.mainGold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.comingSoonFeature, style: const TextStyle(fontFamily: 'Pridi')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _CommunityOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _CommunityOptionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: AppColors.stroke),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.mainGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: AppColors.mainGold, size: 22.w),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppSizes.fontSizeMedium,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainDark,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14.w, color: AppColors.greyText),
            ],
          ),
        ),
      ),
    );
  }
}
