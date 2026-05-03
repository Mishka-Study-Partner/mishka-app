import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/form_text.dart';
import '../widgets/social_media_total_buttons.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key,});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailController =TextEditingController();
  TextEditingController firstNameController =TextEditingController();
  TextEditingController lastNameController =TextEditingController();
  TextEditingController phoneController =TextEditingController();
  TextEditingController passwordController =TextEditingController();
  bool isChecked1 = false;
  bool isChecked2 = false;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const MishkaAppBar(title: '', showBottomBar: false),
      body: Padding(
        padding: EdgeInsetsDirectional.only(
          start: AppSizes.paddingMedium,
          end: AppSizes.paddingMedium,
          bottom: AppSizes.paddingMedium,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                l10n.createAccount,
                style: TextStyle(
                  fontSize: AppSizes.fontSizeTitle,
                  fontFamily: "Pridi",
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                l10n.createAccountAtMishka,
                style: TextStyle(
                  fontSize: AppSizes.fontSizeMedium,
                  fontFamily: "Pridi",
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 24.h),
              CustomInputField(
                label: l10n.firstName,
                hint: l10n.firstName,
                controller: firstNameController,
              ),
              SizedBox(height: 24.h),
              CustomInputField(
                label: l10n.lastName,
                hint: l10n.lastName,
                controller: lastNameController,
              ),
              SizedBox(height: 24.h),
              CustomInputField(
                label: l10n.phoneNumber,
                hint: '+20 ${l10n.phoneNumber}',
                controller: phoneController,
              ),
              SizedBox(height: 24.h),
              CustomInputField(
                label: l10n.emailAddress,
                hint: l10n.exampleEmail,
                controller: emailController,
              ),
              SizedBox(height: 24.h),
              CustomInputField(
                label: l10n.password,
                hint: l10n.examplePassword,
                controller: passwordController,
                isPassword: true,
              ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
          Checkbox(
            value: isChecked1,
            activeColor: AppColors.mainGold,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (value) {
              setState(() {
                isChecked1 = value!;
              });
            },
          ),
          Text(
            l10n.rememberMe,
            style: TextStyle(
              fontSize: AppSizes.fontSizeSmall,
              fontFamily: "Pridi",
              fontWeight: FontWeight.w500,
              color: AppColors.mainDark,
            ),
          ),
                ],
              ),

          ],),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isChecked2,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: AppColors.mainGold,
                    onChanged: (value) {
                      setState(() {
                        isChecked2 = value!;
                      });
                    },
                  ),
                  Text(
                    l10n.agreeToTerms,
                    style: TextStyle(
                      fontSize: AppSizes.fontSizeSmall,
                      fontFamily: "Pridi",
                      fontWeight: FontWeight.w500,
                      color: AppColors.mainDark,
                    ),
                  )
                ],
              ),
              SizedBox(height: 24.h),
              AuthButton(
                text: l10n.createAccount,
                onPressed: () {},
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    l10n.alreadyHaveAccount,
                    style: TextStyle(
                      fontSize: AppSizes.fontSizeSmall,
                      fontFamily: "Pridi",
                      fontWeight: FontWeight.w500,
                      color: AppColors.mainDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      l10n.signIn,
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeSmall,
                        fontFamily: "Pridi",
                        fontWeight: FontWeight.w500,
                        color: AppColors.mainGold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1.h,
                      color: AppColors.mainDark,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Text(
                      l10n.orSignUpWith,
                      style: TextStyle(
                        color: AppColors.mainDark,
                        fontSize: AppSizes.fontSizeSmall,
                        fontFamily: "Pridi",
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1.h,
                      color: AppColors.mainDark,
                    ),
                  ),
                ],
              ),
              SocialAuthRow(onGoogle: () {  }, onApple: () {  }, onFacebook: () {  },),
          ],),
        ),
      ),

    );
  }

}