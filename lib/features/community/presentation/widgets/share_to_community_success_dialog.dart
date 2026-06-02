import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

enum ShareToCommunitySuccessAction { continueFlow, openGroup }

/// Success popup after sharing material to community groups.
Future<ShareToCommunitySuccessAction?> showShareToCommunitySuccessDialog({
  required BuildContext context,
}) {
  final l10n = AppLocalizations.of(context)!;

  return showDialog<ShareToCommunitySuccessAction>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          elevation: 8,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _ShareSuccessBadge(),
                SizedBox(height: 18.h),
                Text(
                  l10n.shareSuccessTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppSizes.fontSizeXLarge,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainDark,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: _ShareSuccessOutlinedButton(
                        label: l10n.shareSuccessContinue,
                        onPressed: () => Navigator.pop(
                          dialogContext,
                          ShareToCommunitySuccessAction.continueFlow,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _ShareSuccessOutlinedButton(
                        label: l10n.shareOpenGroup,
                        onPressed: () => Navigator.pop(
                          dialogContext,
                          ShareToCommunitySuccessAction.openGroup,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _ShareSuccessBadge extends StatelessWidget {
  const _ShareSuccessBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: BoxDecoration(
        color: AppColors.green,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.check_rounded,
        color: AppColors.white,
        size: 40.w,
      ),
    );
  }
}

class _ShareSuccessOutlinedButton extends StatelessWidget {
  const _ShareSuccessOutlinedButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mainGold,
          side: const BorderSide(color: AppColors.mainGold, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8.w),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: AppSizes.fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
