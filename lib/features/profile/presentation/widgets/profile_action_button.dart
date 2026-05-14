import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';

class ProfileActionButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  /// When true, expands to fill [Row]/[Expanded] width (omit fixed [width]).
  final bool expand;

  /// Fixed width when [expand] is false; defaults to `118.w`.
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
    final scheme = Theme.of(context).colorScheme;
    final idleBg = Theme.of(context).brightness == Brightness.dark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.45)
        : AppColors.white;
    final borderColor = Theme.of(context).dividerColor;
    final radius = BorderRadius.circular(8);

    final child = Container(
      height: 28.h,
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
              fontFamily: "Pridi",
              fontSize: 11.sp,
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
