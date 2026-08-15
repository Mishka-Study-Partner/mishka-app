import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/layout/app_breakpoints.dart';
import 'package:mishka_app/core/layout/app_scale.dart';

import '../../../../core/utils/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.networkImageUrl,
    required this.fallbackAssetPath,
    this.onEdit,
    this.onDelete,
  });

  final String? networkImageUrl;
  final String fallbackAssetPath;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  double _avatarSize(BuildContext context) =>
      AppBreakpoints.isTablet(context) ? AppScale.w(130) : 150.w;

  @override
  Widget build(BuildContext context) {
    final size = _avatarSize(context);
    final url = networkImageUrl?.trim();
    final hasUrl = url != null && url.isNotEmpty;
    final radius = AppBreakpoints.isTablet(context) ? 20.r : 24.0;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: hasUrl
              ? Image.network(
                  url,
                  height: size,
                  width: size,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: size,
                      width: size,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      fallbackAssetPath,
                      height: size,
                      width: size,
                      fit: BoxFit.cover,
                    );
                  },
                )
              : Image.asset(
                  fallbackAssetPath,
                  height: size,
                  width: size,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
        ),
        if (onEdit != null || onDelete != null) ...[
          SizedBox(height: AppBreakpoints.isTablet(context) ? 10.h : 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onEdit != null) _iconButton(context, Icons.edit, AppColors.blue, onEdit),
              if (onEdit != null && onDelete != null) SizedBox(width: 8.w),
              if (onDelete != null)
                  _iconButton(context, Icons.delete, AppColors.red, onDelete),
            ],
          ),
        ],
      ],
    );
  }

  Widget _iconButton(
    BuildContext context,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    final isTablet = AppBreakpoints.isTablet(context);
    final box = isTablet ? AppScale.w(36) : 32.0;
    final iconSize = isTablet ? AppScale.w(18) : 16.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: box,
        width: box,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .15),
          borderRadius: BorderRadius.circular(isTablet ? 10.r : 8),
        ),
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}
