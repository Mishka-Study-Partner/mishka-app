import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

void showFocusCheckPopup(
  BuildContext context, {
  required VoidCallback onYes,
  required VoidCallback onNo,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _FocusCheckPopup(onYes: onYes, onNo: onNo),
  );
}

class _FocusCheckPopup extends StatelessWidget {
  final VoidCallback onYes;
  final VoidCallback onNo;

  const _FocusCheckPopup({required this.onYes, required this.onNo});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: AppColors.screenBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.mainGold, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.h),
            Text(
              l10n.areYouStillThere,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppColors.mainDark,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.howIsYourMoodWhileStudying,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                color: AppColors.greyText,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PopupButton(
                  text: l10n.yesContinue,
                  color: AppColors.green,
                  onTap: () {
                    Navigator.pop(context);
                    onYes();
                  },
                ),
                SizedBox(width: 12.w),
                _PopupButton(
                  text: l10n.noStop,
                  color: AppColors.red,
                  onTap: () {
                    Navigator.pop(context);
                    onNo();
                  },
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}

class _PopupButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _PopupButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Pridi',
          color: AppColors.white,
          fontSize: AppSizes.fontSizeMedium,
          height: 1.0,
        ),
        strutStyle: StrutStyle(
          fontFamily: 'Pridi',
          fontSize: AppSizes.fontSizeMedium,
          height: 1.4,
          forceStrutHeight: true,
        ),
      ),
    );
  }
}
