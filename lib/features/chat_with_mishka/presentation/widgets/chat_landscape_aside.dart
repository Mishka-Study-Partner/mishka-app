import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/generated/assets.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Left panel for tablet landscape chat — Mishka branding beside the conversation.
class ChatLandscapeAside extends StatelessWidget {
  const ChatLandscapeAside({
    super.key,
    required this.onOpenHistory,
  });

  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = (MediaQuery.sizeOf(context).width * 0.28)
        .clamp(AppScale.w(240), AppScale.w(320));

    return SizedBox(
      width: width,
      child: ColoredBox(
        color: AppColors.white,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppScale.w(20),
              vertical: AppScale.h(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(
                    Assets.imagesMishkaHappy,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.chatWithMishka,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppScale.sp(22),
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainDark,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.askMishka,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppScale.sp(14),
                    color: AppColors.lightText,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: onOpenHistory,
                  icon: const Icon(Icons.history_rounded, size: 20),
                  label: Text(l10n.yourHistory),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.mainGold,
                    side: const BorderSide(color: AppColors.mainGold),
                    minimumSize: Size(double.infinity, 44.h),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
