import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/features/Auth/presentation/widgets/social_media_button.dart';

class SocialAuthRow extends StatelessWidget {
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final VoidCallback onFacebook;

  const SocialAuthRow({
    super.key,
    required this.onGoogle,
    required this.onApple,
    required this.onFacebook,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialAuthButton(
          icon: Iconify(
            Mdi.google,
            size: AppSizes.iconMedium,
            color: AppColors.mainDark,
          ),
          onTap: onGoogle,
        ),
        SizedBox(width: 16.w),

        SocialAuthButton(
          icon: Iconify(
            Mdi.facebook,
            size: AppSizes.iconMedium,
            color: AppColors.mainDark,
          ),
          onTap: onFacebook,
        ),
        SizedBox(width: 16.w),

        SocialAuthButton(
          icon: Iconify(
            Mdi.apple,
            size: AppSizes.iconMedium,
            color: AppColors.mainDark,
          ),
          onTap: onApple,
        ),
      ],
    );
  }
}