import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/profile/presentation/widgets/profile_field_metrics.dart';

import '../../../../core/utils/app_colors.dart';

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// When true, uses the same bordered field height as [ProfileTextField].
  final bool matchFieldStyle;

  /// When true, shows [value] on its own row below the title (full width).
  final bool stackValueBelow;

  /// Max lines for [value]; defaults to 2, or 1 when [stackValueBelow] is true.
  final int? valueMaxLines;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.title,
    this.value = '',
    this.trailing,
    this.onTap,
    this.matchFieldStyle = false,
    this.stackValueBelow = false,
    this.valueMaxLines,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = AppBreakpoints.isTablet(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final titleSize = isTablet ? AppSizes.fontSizeMedium : 14.0;
    final valueSize = isTablet ? AppSizes.fontSizeSmall : 12.0;
    final iconSize = isTablet ? AppSizes.iconSmall : 14.0;
    final resolvedValueMaxLines =
        valueMaxLines ?? (stackValueBelow ? 1 : 2);

    Text valueText(String text) => Text(
          text,
          maxLines: resolvedValueMaxLines,
          overflow: TextOverflow.ellipsis,
          softWrap: resolvedValueMaxLines == 1 ? false : true,
          textAlign: stackValueBelow ? TextAlign.start : TextAlign.end,
          style: TextStyle(
            fontSize: matchFieldStyle
                ? ProfileFieldMetrics.valueFontSize(context)
                : valueSize,
            fontWeight: FontWeight.w500,
            fontFamily: 'Pridi',
            color: onTap != null
                ? AppColors.mainGold
                : onSurface.withValues(alpha: 0.72),
          ),
        );

    Widget? rightChild;
    if (trailing != null) {
      rightChild = trailing;
    } else if (value.isNotEmpty || onTap != null) {
      rightChild = value.isNotEmpty ? valueText(value) : null;
    }

    if (stackValueBelow) {
      Widget column = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: iconSize, color: AppColors.mainGold),
              SizedBox(width: isTablet ? 10.w : 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: matchFieldStyle
                        ? ProfileFieldMetrics.valueFontSize(context)
                        : titleSize,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Pridi',
                    color: onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (value.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.only(left: iconSize + (isTablet ? 10.w : 8)),
              child: SizedBox(
                width: double.infinity,
                child: valueText(value),
              ),
            ),
          ],
        ],
      );

      if (matchFieldStyle) {
        column = Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: ProfileFieldMetrics.horizontalPad(context),
            vertical: ProfileFieldMetrics.horizontalPad(context) * 0.65,
          ),
          decoration: BoxDecoration(
            color: ProfileFieldMetrics.fieldBackground(context),
            borderRadius: BorderRadius.circular(
              ProfileFieldMetrics.fieldRadius(context),
            ),
            border: Border.all(color: ProfileFieldMetrics.fieldBorder(context)),
          ),
          child: column,
        );
      }

      if (onTap != null && trailing == null) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: column,
        );
      }
      return column;
    }

    Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: iconSize, color: AppColors.mainGold),
        SizedBox(width: isTablet ? 10.w : 8),
        Expanded(
          flex: 2,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: matchFieldStyle
                  ? ProfileFieldMetrics.valueFontSize(context)
                  : titleSize,
              fontWeight: FontWeight.w500,
              fontFamily: 'Pridi',
              color: onSurface,
            ),
          ),
        ),
        if (rightChild != null) ...[
          SizedBox(width: isTablet ? 10.w : 8),
          Expanded(
            flex: 3,
            child: rightChild,
          ),
        ],
      ],
    );

    if (matchFieldStyle) {
      row = Container(
        width: double.infinity,
        height: ProfileFieldMetrics.fieldHeight(context),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(
          horizontal: ProfileFieldMetrics.horizontalPad(context),
        ),
        decoration: BoxDecoration(
          color: ProfileFieldMetrics.fieldBackground(context),
          borderRadius: BorderRadius.circular(
            ProfileFieldMetrics.fieldRadius(context),
          ),
          border: Border.all(color: ProfileFieldMetrics.fieldBorder(context)),
        ),
        child: row,
      );
    }

    final tappableWholeRow = onTap != null && trailing == null;

    if (tappableWholeRow) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: row,
      );
    }
    return row;
  }
}
