import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ✅ HEADER (only if needed)
          if (_hasHeader) ...[
            Row(
              children: [
                if (icon != null)
                  Icon(icon, size: 16, color: AppColors.mainGold),

                if (icon != null && title != null)
                  const SizedBox(width: 8),

                if (title != null)
                  Text(
                    title!,
                    style: const TextStyle(
                      fontFamily: "Pridi",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // ✅ CONTENT
          child,
        ],
      ),
    );
  }
}
