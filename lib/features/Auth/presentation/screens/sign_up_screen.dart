import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/Auth/data/data_sources/auth_remote_data_source.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/features/Auth/view/bloc/auth_bloc.dart';

import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/form_text.dart';
import '../widgets/social_media_total_buttons.dart';
import 'login_screen.dart';
import 'verification_views/otp_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key,});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const bool _signupOtpOptional = false;
  final TextEditingController emailController =TextEditingController();
  final TextEditingController firstNameController =TextEditingController();
  final TextEditingController lastNameController =TextEditingController();
  final TextEditingController phoneController =TextEditingController();
  final TextEditingController passwordController =TextEditingController();
  bool isChecked1 = false;
  bool isChecked2 = false;
  bool _isOtpLoading = false;
  @override
  void dispose() {
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitSignUp() async {
    final l10n = AppLocalizations.of(context)!;
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseFillAllRequiredFields)),
      );
      return;
    }
    if (!isChecked2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.agreeToTerms)),
      );
      return;
    }

    setState(() => _isOtpLoading = true);
    final email = emailController.text.trim();
    try {
      await AuthRemoteDataSource(ApiService()).sendSignupOtp(
        email: email,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage(e))),
        );
      }
      return;
    } finally {
      if (mounted) {
        setState(() => _isOtpLoading = false);
      }
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          title: l10n.verifyByEmail,
          subtitle: l10n.enter6DigitsCodeEmail(email),
          // Keep optional until final signup OTP UX is locked.
          allowEmptyCode: _signupOtpOptional,
          onVerify: (otpCode) async {
            final dataSource = AuthRemoteDataSource(ApiService());
            final trimmedOtp = otpCode.trim();
            if (trimmedOtp.isNotEmpty) {
              await dataSource.verifySignupOtp(
                email: email,
                otpCode: trimmedOtp,
              );
            }
            context.read<AuthBloc>().add(
              AuthRegisterRequested(
                firstName: firstNameController.text.trim(),
                lastName: lastNameController.text.trim(),
                email: email,
                password: passwordController.text,
                agreeTerms: isChecked2,
                phoneNumber: phoneController.text.trim(),
                // Temporary fallback until education status selector is implemented.
                educationStatus: 'other',
                signupOtp: trimmedOtp.isEmpty ? null : trimmedOtp,
              ),
            );
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  String _errorMessage(Object error) {
    if (error is ApiException) {
      final buffer = StringBuffer();
      if (error.statusCode != null) {
        buffer.write('[${error.statusCode}] ');
      }
      if (error.error != null && error.error!.isNotEmpty) {
        buffer.write('[${error.error}] ');
      }
      buffer.write(error.message);
      if (error.details != null) {
        buffer.write('\n${error.details}');
      }
      return buffer.toString();
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          return;
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
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
                isLoading: state is AuthLoading || _isOtpLoading,
                onPressed: _submitSignUp,
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
      },
    );
  }

}