import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class ProfileAvatar extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProfileAvatar({
    super.key,
    required this.imagePath,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return  Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              imagePath,
              height: R.h(context, 150),
              width: R.w(context, 150),
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _iconButton(Icons.edit, AppColors.blue, onEdit),
              const SizedBox(width: 8),
              _iconButton(Icons.delete, AppColors.red, onDelete),
            ],
          )
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
          color: color.withOpacity(.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
