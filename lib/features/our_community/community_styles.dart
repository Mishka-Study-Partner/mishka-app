import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

/// Shared typography and input styles for the Community feature.
abstract final class CommunityStyles {
  static const _fontFamily = 'Pridi';

  static TextStyle get titleGold => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeLarge,
        fontWeight: FontWeight.w600,
        color: AppColors.mainGold,
      );

  static TextStyle get sectionLabel => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeMedium,
        fontWeight: FontWeight.w600,
        color: AppColors.mainDark,
      );

  static TextStyle get body => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeMedium,
        color: AppColors.mainDark,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeLarge,
        color: AppColors.mainDark,
      );

  static TextStyle get headline => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeXXLarge,
        fontWeight: FontWeight.bold,
        color: AppColors.mainDark,
      );

  static TextStyle get communityName => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeTitle,
        fontWeight: FontWeight.bold,
        color: AppColors.mainDark,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeSmall,
        color: AppColors.lightText,
      );

  static TextStyle get optionalLabel => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeSmall,
        fontWeight: FontWeight.bold,
        color: AppColors.mainGold,
      );

  static TextStyle get error => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeSmall,
        color: AppColors.red,
      );

  static TextStyle get link => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeSmall,
        color: AppColors.blue,
        decoration: TextDecoration.underline,
      );

  static TextStyle get roleLabel => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeSmall,
        color: AppColors.blue,
      );

  static TextStyle get menuTitle => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeXLarge,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      );

  static TextStyle get menuItem => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeLarge,
        fontWeight: FontWeight.w600,
        color: AppColors.lightText,
      );

  static TextStyle get successMessage => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeXLarge,
        fontWeight: FontWeight.w600,
        color: AppColors.mainDark,
      );

  static TextStyle get bodySemiBold => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeMedium,
        fontWeight: FontWeight.w600,
        color: AppColors.mainDark,
      );

  static TextStyle get bodyBold => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeMedium,
        fontWeight: FontWeight.bold,
        color: AppColors.mainDark,
      );

  static TextStyle get dialogTitle => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeLarge,
        fontWeight: FontWeight.bold,
        color: AppColors.mainDark,
      );

  static TextStyle get underlinedTitle => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeLarge,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
        color: AppColors.mainDark,
      );

  static TextStyle get appBarAction => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeMedium,
        fontWeight: FontWeight.w600,
        color: AppColors.mainGold,
      );

  static TextStyle get destructiveAction => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeMedium,
        color: AppColors.red,
      );

  static TextStyle outlineAction(Color color) => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeMedium,
        color: color,
      );

  /// Text on [showSnackBar] — dark on gold for readable contrast in all themes.
  static TextStyle get snackBar => TextStyle(
        fontFamily: _fontFamily,
        fontSize: AppSizes.fontSizeMedium,
        fontWeight: FontWeight.w500,
        color: AppColors.mainDark,
      );

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: snackBar),
        backgroundColor: AppColors.mainGold,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static InputDecoration inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: AppSizes.fontSizeMedium,
          color: AppColors.greyText,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          borderSide: const BorderSide(color: AppColors.mainGold, width: 1.5),
        ),
      );

  static ButtonStyle goldButtonStyle({double? verticalPadding}) =>
      ElevatedButton.styleFrom(
        backgroundColor: AppColors.mainGold,
        foregroundColor: AppColors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: verticalPadding ?? 14.h,
        ),
        minimumSize: Size(0, AppSizes.buttonHeightSmall),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        ),
        elevation: 0,
        textStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: AppSizes.fontSizeLarge,
          fontWeight: FontWeight.w600,
          height: 1.2,
          leadingDistribution: TextLeadingDistribution.even,
        ),
      );

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.stroke),
      );

  static BoxDecoration get goldBorderCardDecoration => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.mainGold),
      );
}
