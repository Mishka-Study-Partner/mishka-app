import 'package:flutter/material.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/button_label.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? height;
  final double? borderRadius;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height,
    this.borderRadius,
  });

  static TextStyle _labelStyle() => TextStyle(
        fontSize: AppSizes.fontSizeLarge,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        fontFamily: 'Pridi',
        height: 1.25,
        leadingDistribution: TextLeadingDistribution.even,
      );

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? AppSizes.buttonHeight;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainGold,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: AppScale.w(16),
            vertical: AppScale.h(12),
          ),
          minimumSize: Size(double.infinity, buttonHeight),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppScale.r(6),
            ),
          ),
          textStyle: _labelStyle(),
        ),
        child: isLoading
            ? SizedBox(
                height: AppScale.h(22),
                width: AppScale.w(22),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : ButtonLabel(
                text,
                style: _labelStyle(),
              ),
      ),
    );
  }
}
