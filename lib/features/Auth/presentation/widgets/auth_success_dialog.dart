import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Centered success card used after OTP verify / password reset (design frames).
class AuthSuccessDialog extends StatelessWidget {
  const AuthSuccessDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.showSpeechTail = false,
  });

  final String title;
  final String? subtitle;
  final bool showSpeechTail;

  static Future<void> showVerified(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AuthSuccessDialog(
        title: l10n.successfullyVerified,
        subtitle: l10n.letsStartSettingAccount,
        showSpeechTail: true,
      ),
    );
  }

  static Future<void> showPasswordSet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AuthSuccessDialog(
        title: l10n.passwordSuccessfullySet,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        elevation: 8,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SuccessIcon(showSpeechTail: showSpeechTail),
              SizedBox(height: 20.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: AppSizes.fontSizeXLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 12.h),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppSizes.fontSizeMedium,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainDark,
                    height: 1.35,
                  ),
                ),
              ],
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainGold,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.yesContinue,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon({required this.showSpeechTail});

  final bool showSpeechTail;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: 72.w,
      height: 72.w,
      decoration: const BoxDecoration(
        color: AppColors.mainGold,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.check,
        color: AppColors.white,
        size: 40.w,
      ),
    );

    if (!showSpeechTail) return circle;

    return SizedBox(
      width: 88.w,
      height: 88.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          circle,
          Positioned(
            right: 4.w,
            bottom: 8.h,
            child: Container(
              width: 14.w,
              height: 14.w,
              decoration: const BoxDecoration(
                color: AppColors.mainGold,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
