import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

/// Selectable row used on education onboarding screens.
class EducationOptionTile extends StatelessWidget {
  const EducationOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leadingIcon,
    this.trailing,
    this.subtitle,
    this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leadingIcon;
  final Widget? trailing;
  final String? subtitle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.educationSelected : AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(
              color: selected ? AppColors.mainGold : AppColors.stroke,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (leadingIcon != null) ...[
                    leadingIcon!,
                    SizedBox(width: 12.w),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: AppSizes.fontSizeLarge,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mainDark,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              if (subtitle != null) ...[
                SizedBox(height: 8.h),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppSizes.fontSizeMedium,
                    color: AppColors.mainDark,
                  ),
                ),
              ],
              if (child != null) ...[
                SizedBox(height: 8.h),
                child!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EducationGoldIcon extends StatelessWidget {
  const EducationGoldIcon({super.key, required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    return Iconify(
      icon,
      size: 28.w,
      color: AppColors.mainGold,
    );
  }
}

class EducationMishkaTrailing extends StatelessWidget {
  const EducationMishkaTrailing({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/mishka_school.png',
      width: 36.w,
      height: 36.w,
      fit: BoxFit.contain,
    );
  }
}
