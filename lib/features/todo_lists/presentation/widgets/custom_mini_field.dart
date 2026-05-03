import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';


class CustomMiniField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final bool readOnly;

  const CustomMiniField({
    super.key,
    required this.label,
    this.controller,
    this.onTap,
    this.readOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: "Pridi",
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.mainDark,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(
            fontFamily: "Pridi",
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.lightText,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          filled: true,
          fillColor: AppColors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: AppColors.stroke),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: AppColors.mainGold),
          ),
        ),
      ),
    );
  }
}
