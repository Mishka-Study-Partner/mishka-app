import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final fieldBg = Theme.of(context).brightness == Brightness.dark
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.35)
        : AppColors.white;
    final borderColor = Theme.of(context).dividerColor;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: "Pridi",
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 24,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontFamily: "Pridi",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
