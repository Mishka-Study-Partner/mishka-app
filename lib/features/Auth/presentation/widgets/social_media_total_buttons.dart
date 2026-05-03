import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
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
          icon: const AssetImage('assets/image/flat-color-icons_google.png'),
          onTap: onGoogle,
        ),
        SizedBox(width: 16.w),

        SocialAuthButton(
          icon: const AssetImage('assets/image/logos_facebook.png'),
          onTap: onApple,
        ),
        SizedBox(width: 16.w),

        SocialAuthButton(
          icon: const AssetImage('assets/image/icon-park-solid_apple.png'),
          onTap: onFacebook,
        ),
      ],
    );
  }
}