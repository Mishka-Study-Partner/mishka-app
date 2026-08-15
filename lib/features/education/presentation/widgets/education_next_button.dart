import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/button_label.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class EducationNextButton extends StatelessWidget {
  const EducationNextButton({
    super.key,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingLarge,
        8.h,
        AppSizes.paddingLarge,
        24.h,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: enabled && !isLoading ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mainGold,
            disabledBackgroundColor: AppColors.mainGold.withValues(alpha: 0.45),
            foregroundColor: AppColors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            minimumSize: Size(double.infinity, AppSizes.buttonHeightSmall),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : ButtonLabel(
                  l10n.next,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppSizes.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    height: 1.2,
                  ),
                ),
        ),
      ),
    );
  }
}
