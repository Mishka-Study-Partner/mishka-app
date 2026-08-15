import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';

import '../../../../core/utils/app_colors.dart';

class ProfileSectionCard extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final Widget child;

  const ProfileSectionCard({
    super.key,
    this.icon,
    this.title,
    required this.child,
  });

  bool get _hasHeader => icon != null || title != null;

  @override
  Widget build(BuildContext context) {
    final isTablet = AppBreakpoints.isTablet(context);
    final scheme = Theme.of(context).colorScheme;
    final borderColor = Theme.of(context).dividerColor;
    final padding = isTablet ? AppScale.w(18) : 16.0;
    final titleSize = isTablet ? AppSizes.fontSizeLarge : 16.0;
    final iconSize = isTablet ? AppScale.w(18) : 16.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(isTablet ? 18.r : 16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasHeader) ...[
            Row(
              children: [
                if (icon != null)
                  Icon(icon, size: iconSize, color: AppColors.mainGold),
                if (icon != null && title != null)
                  SizedBox(width: isTablet ? 10.w : 8),
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: titleSize,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: isTablet ? 14.h : 12),
          ],
          child,
        ],
      ),
    );
  }
}
