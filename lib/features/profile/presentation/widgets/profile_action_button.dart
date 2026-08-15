import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/profile/presentation/widgets/profile_field_metrics.dart';

import '../../../../core/utils/app_colors.dart';

class ProfileActionButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  final bool expand;
  final double? width;

  const ProfileActionButton({
    super.key,
    required this.text,
    this.selected = false,
    this.onTap,
    this.expand = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = AppBreakpoints.isTablet(context);
    final scheme = Theme.of(context).colorScheme;
    final idleBg = Theme.of(context).brightness == Brightness.dark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.45)
        : AppColors.white;
    final borderColor = ProfileFieldMetrics.fieldBorder(context);
    final radius = BorderRadius.circular(isTablet ? 10.r : 8);
    final height = ProfileFieldMetrics.fieldHeight(context);

    final child = Container(
      height: height,
      width: expand ? double.infinity : (width ?? 118.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.mainGold : idleBg,
        borderRadius: radius,
        border: Border.all(color: borderColor),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: isTablet ? AppSizes.fontSizeSmall : 11.sp,
              fontWeight: FontWeight.w500,
              color: selected ? AppColors.white : scheme.onSurface,
            ),
          ),
        ),
      ),
    );

    if (onTap == null) {
      return child;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: child,
      ),
    );
  }
}
