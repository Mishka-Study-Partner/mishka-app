import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  /// When set, shown on the right instead of [value].
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.title,
    this.value = '',
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    Widget? rightChild;
    if (trailing != null) {
      rightChild = trailing;
    } else if (value.isNotEmpty || onTap != null) {
      rightChild = value.isNotEmpty
          ? Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Pridi',
                color: onTap != null
                    ? AppColors.mainGold
                    : onSurface.withValues(alpha: 0.72),
              ),
            )
          : null;
    }

    Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: AppColors.mainGold),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: "Pridi",
              color: onSurface,
            ),
          ),
        ),
        if (rightChild != null) ...[
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: rightChild,
          ),
        ],
      ],
    );

    // Avoid stealing taps from [trailing] controls (Switch, SegmentedButton).
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
