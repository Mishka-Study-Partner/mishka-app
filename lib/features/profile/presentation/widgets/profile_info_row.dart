import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget row = Row(
      children: [
        Icon(icon, size: 14, color: AppColors.mainGold),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: "Pridi",
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: "Pridi",
            color: AppColors.lightText,
          ),
        ),
      ],
    );
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: row,
      );
    }
    
    return row;
  }
}
