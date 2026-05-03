import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_sizes.dart';

class SocialAuthButton extends StatelessWidget {
  final ImageProvider icon;
  final VoidCallback onTap;

  const SocialAuthButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      child: Container(
        width: 48.w,
        height: 48.w,
        child: Image(image: icon, fit: BoxFit.fill),
      ),
    );
  }
}