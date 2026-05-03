import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/features/Auth/presentation/screens/verification_views/phone_verification.dart';

import '../../widgets/custom_elevated_button.dart';
import '../../widgets/form_text.dart';

class ResetPhoneView extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
  
   ResetPhoneView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        children: [
          SizedBox(height: 48.h),
          Text(
            l10n.forgetPassword,
            style: TextStyle(
              fontSize: AppSizes.fontSizeMedium,
              fontFamily: "Pridi",
              fontWeight: FontWeight.bold,
              color: AppColors.mainDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.writePhoneForCode,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppSizes.fontSizeMedium,
              fontFamily: "Pridi",
              fontWeight: FontWeight.w500,
              color: AppColors.mainDark,
            ),
          ),
          SizedBox(height: 24.h),
          CustomInputField(
            label: l10n.phoneNumber,
            hint: '+20 ${l10n.phoneNumber}',
            controller: phoneController,
          ),
          SizedBox(height: 24.h),
          AuthButton(
            text: l10n.getCode,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PhoneVerification(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
