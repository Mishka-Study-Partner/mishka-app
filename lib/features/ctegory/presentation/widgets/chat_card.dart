import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/generated/assets.dart';

import '../../../../main.dart';

class MishkaChatCard extends StatelessWidget {
  final VoidCallback? onNavigate;

  const MishkaChatCard({
    super.key,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      height: 157.h,
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: "Pridi",
                      fontSize: AppSizes.fontSizeXLarge,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mainDark,
                    ),
                    children: [
                      TextSpan(text: "${l10n.chatWithMishkaTitle.split(" ")[0]} ${l10n.chatWithMishkaTitle.split(" ")[1]} "),
                      TextSpan(
                        text: l10n.mishka.toUpperCase(),
                        style: const TextStyle(color: AppColors.mainGold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: onNavigate,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mainGold,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      "${l10n.start}  >",
                      style: TextStyle(
                        fontFamily: "Pridi",
                        fontSize: AppSizes.fontSizeMedium,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            Assets.imagesMishkaHappy,
            width: 111.w,
            height: 151.h,
            fit: BoxFit.fitHeight,
            filterQuality: FilterQuality.high,
          ),
        ],
      ),
    );
  }
}
