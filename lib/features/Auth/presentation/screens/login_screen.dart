import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/features/Auth/presentation/screens/reset_password.dart';
import 'package:mishka_app/features/Auth/presentation/screens/signin_views/email_view.dart';
import 'package:mishka_app/features/Auth/presentation/screens/signin_views/phone_view.dart';
import 'package:mishka_app/features/Auth/presentation/screens/sign_up_screen.dart';
import 'package:mishka_app/features/Auth/view/bloc/auth_bloc.dart';

import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/custom_segmanted_button.dart';
import '../widgets/social_media_total_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key,});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    final TextEditingController emailController =TextEditingController();
    final TextEditingController phoneController =TextEditingController();
    final TextEditingController passwordController =TextEditingController();
    bool isChecked1 = false;
    bool isChecked2 = false;
    int selectedIndex = 0;
    @override
    void dispose() {
      emailController.dispose();
      phoneController.dispose();
      passwordController.dispose();
      super.dispose();
    }

    void _submitLogin() {
      final l10n = AppLocalizations.of(context)!;
      final password = passwordController.text.trim();
      final email = emailController.text.trim();
      final phone = phoneController.text.trim();

      if (password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.password)),
        );
        return;
      }

      if (selectedIndex == 0 && email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.emailAddress)),
        );
        return;
      }

      if (selectedIndex == 1 && phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.phoneNumber)),
        );
        return;
      }

      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: selectedIndex == 0 ? email : null,
          phoneNumber: selectedIndex == 1 ? phone : null,
          password: password,
          rememberMe: isChecked1,
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context)!;

      return BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
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
                  l10n.signIn,
                  style: TextStyle(
                    fontSize: AppSizes.fontSizeTitle,
                    fontFamily: "Pridi",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.welcomeBackToMishka,
                  style: TextStyle(
                    fontSize: AppSizes.fontSizeMedium,
                    fontFamily: "Pridi",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 24.h),
                CustomSegmentedButton(
                  selectedIndex: selectedIndex,
                  onChanged: (i) => setState(() => selectedIndex = i),
                  segments: [l10n.email, l10n.phoneNumber],
                ),
                if (selectedIndex == 0)
                  EmailView(
                    emailController: emailController,
                    passwordController: passwordController,
                  )
                else
                  PasswordView(
                    phoneController: phoneController,
                    passwordController: passwordController,
                  ),

                SizedBox(height: 16.h),
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
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ResetPassword(),
                          ),
                        );
                      },
                      child: Text(
                        l10n.forgetPassword,
                        style: TextStyle(
                          fontSize: AppSizes.fontSizeSmall,
                          fontFamily: "Pridi",
                          fontWeight: FontWeight.w500,
                          color: AppColors.mainDark,
                        ),
                      ),
                    ),
                  ],
                ),
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
                    Expanded(
                      child: Text(
                        l10n.agreeToTerms,
                        style: TextStyle(
                          fontSize: AppSizes.fontSizeSmall,
                          fontFamily: "Pridi",
                          fontWeight: FontWeight.w500,
                          color: AppColors.mainDark,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                AuthButton(
                  text: l10n.signIn,
                  isLoading: isLoading,
                  onPressed: _submitLogin,
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      l10n.dontHaveAccount,
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
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        l10n.createAccount,
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
        },
      );
  }

}