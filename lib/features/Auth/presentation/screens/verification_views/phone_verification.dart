import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import '../../../../../core/widgets/custom_app_bar.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/otp_input.dart';

class PhoneVerification extends StatelessWidget {
  const PhoneVerification({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const MishkaAppBar(
        title: '',
        showBottomBar: false,
        showBack: true,
      ),
      body: Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSizes.paddingMedium,
          end: AppSizes.paddingMedium,
          bottom: AppSizes.paddingMedium + AppSizes.screenEndPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              l10n.verificationCode,
              style: TextStyle(
                fontSize: AppSizes.fontSizeTitle,
                fontFamily: "Pridi",
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.verifyByPhoneNumber,
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeLarge,
                        fontFamily: "Pridi",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.enter6DigitsCodePhone('+20 1010101010'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeLarge,
                        fontFamily: "Pridi",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    const OtpInput(),
                    SizedBox(height: 24.h),
                    AuthButton(
                      text: l10n.verify,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}