import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

/// Checkbox + label on one visual line (login / sign-up).
class AuthCheckboxRow extends StatelessWidget {
  const AuthCheckboxRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;

  static const double _lineHeightFactor = 1.25;

  @override
  Widget build(BuildContext context) {
    final fontSize = AppSizes.fontSizeSmall;
    final lineHeight = fontSize * _lineHeightFactor;
    final boxSize = 20.w;
    final rowHeight = lineHeight > boxSize ? lineHeight : boxSize;

    final labelStyle = TextStyle(
      fontSize: fontSize,
      fontFamily: 'Pridi',
      fontWeight: FontWeight.w500,
      color: AppColors.mainDark,
      height: _lineHeightFactor,
    );

    final strutStyle = StrutStyle(
      fontSize: fontSize,
      height: _lineHeightFactor,
      fontFamily: 'Pridi',
      fontWeight: FontWeight.w500,
      forceStrutHeight: true,
    );

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: rowHeight,
              width: boxSize + 2.w,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _AuthCheckBox(
                  value: value,
                  size: boxSize,
                  onChanged: onChanged,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                style: labelStyle,
                strutStyle: strutStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthCheckBox extends StatelessWidget {
  const _AuthCheckBox({
    required this.value,
    required this.size,
    required this.onChanged,
  });

  final bool value;
  final double size;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: value ? AppColors.mainGold : AppColors.white,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(
              color: value ? AppColors.mainGold : AppColors.stroke,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: value
              ? Icon(
                  Icons.check,
                  size: size * 0.7,
                  color: AppColors.white,
                )
              : null,
        ),
      ),
    );
  }
}
