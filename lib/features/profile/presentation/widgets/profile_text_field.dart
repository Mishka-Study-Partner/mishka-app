import '../../../../core/utils/app_colors.dart';
import 'package:flutter/material.dart';
class ProfileTextField extends StatelessWidget {
  final String label;
  final String value;

  const ProfileTextField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: "Pridi",
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.mainDark,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 24,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: "Pridi",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.mainDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
