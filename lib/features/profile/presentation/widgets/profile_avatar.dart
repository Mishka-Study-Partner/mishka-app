import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.networkImageUrl,
    required this.fallbackAssetPath,
    this.onEdit,
    this.onDelete,
  });

  /// Remote profile photo from `/auth/me` when present.
  final String? networkImageUrl;
  final String fallbackAssetPath;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final h = R.h(context, 150);
    final w = R.w(context, 150);
    final url = networkImageUrl?.trim();
    final hasUrl = url != null && url.isNotEmpty;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: hasUrl
              ? Image.network(
                  url,
                  height: h,
                  width: w,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: h,
                      width: w,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      fallbackAssetPath,
                      height: h,
                      width: w,
                      fit: BoxFit.cover,
                    );
                  },
                )
              : Image.asset(
                  fallbackAssetPath,
                  height: h,
                  width: w,
                  fit: BoxFit.cover,
                ),
        ),
        if (onEdit != null || onDelete != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onEdit != null) _iconButton(Icons.edit, AppColors.blue, onEdit),
              if (onEdit != null && onDelete != null) const SizedBox(width: 8),
              if (onDelete != null) _iconButton(Icons.delete, AppColors.red, onDelete),
            ],
          ),
        ],
      ],
    );
  }

  Widget _iconButton(IconData icon, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
