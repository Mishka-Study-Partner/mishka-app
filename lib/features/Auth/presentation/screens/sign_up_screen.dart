import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/layout/form_screen_body.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/Auth/data/data_sources/auth_remote_data_source.dart';
import 'package:mishka_app/features/Auth/utils/auth_navigation.dart';
import 'package:mishka_app/features/Auth/utils/auth_validators.dart';
import 'package:mishka_app/features/Auth/utils/auth_error_messages.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/features/Auth/view/bloc/auth_bloc.dart';

import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/auth_checkbox_row.dart';
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
  final _formKey = GlobalKey<FormState>();
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
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
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
          SnackBar(content: Text(AuthErrorMessages.from(e, l10n))),
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
          allowEmptyCode: _signupOtpOptional,
          showVerifiedDialog: true,
          onVerify: (otpCode) async {
            final trimmedOtp = otpCode.trim();
            if (trimmedOtp.isNotEmpty) {
              await AuthRemoteDataSource(ApiService()).verifySignupOtp(
                email: email,
                otpCode: trimmedOtp,
              );
            }
          },
          afterVerified: (otpCode) async {
            final bloc = context.read<AuthBloc>();
            final trimmedOtp = otpCode.trim();
            bloc.add(
              AuthRegisterRequested(
                firstName: firstNameController.text.trim(),
                lastName: lastNameController.text.trim(),
                email: email,
                password: passwordController.text,
                agreeTerms: isChecked2,
                phoneNumber: phoneController.text.trim(),
                signupOtp: trimmedOtp.isEmpty ? null : trimmedOtp,
              ),
            );
            final result = await bloc.stream.firstWhere(
              (s) => s is AuthSuccess || s is AuthError,
            );
            if (result is AuthError) {
              throw ApiException(
                message: result.message,
                error: result.errorCode,
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthSuccess) {
          await AuthNavigation.goAfterAuthentication(context, state.user);
          return;
        }
        if (state is AuthError) {
          final message = state.errorCode == 'UNIQUE_VIOLATION'
              ? l10n.accountAlreadyExists
              : state.message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const MishkaAppBar(title: '', showBottomBar: false),
      body: FormScreenBody(
          child: Form(
            key: _formKey,
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
              SizedBox(height: CustomInputField.spacingBetweenFields),
              CustomInputField(
                label: l10n.firstName,
                hint: l10n.firstName,
                controller: firstNameController,
                validator: (v) => AuthValidators.validateFirstName(v, l10n),
              ),
              SizedBox(height: CustomInputField.spacingBetweenFields),
              CustomInputField(
                label: l10n.lastName,
                hint: l10n.lastName,
                controller: lastNameController,
                validator: (v) => AuthValidators.validateLastName(v, l10n),
              ),
              SizedBox(height: CustomInputField.spacingBetweenFields),
              CustomInputField(
                label: l10n.phoneNumber,
                hint: '+20 ${l10n.phoneNumber}',
                controller: phoneController,
                validator: (v) => AuthValidators.validatePhone(v, l10n),
              ),
              SizedBox(height: CustomInputField.spacingBetweenFields),
              CustomInputField(
                label: l10n.emailAddress,
                hint: l10n.exampleEmail,
                controller: emailController,
                validator: (v) => AuthValidators.validateEmail(v, l10n),
              ),
              SizedBox(height: CustomInputField.spacingBetweenFields),
              CustomInputField(
                label: l10n.password,
                hint: l10n.examplePassword,
                controller: passwordController,
                isPassword: true,
                validator: (v) => AuthValidators.validatePassword(v, l10n),
              ),
              SizedBox(height: 16.h),
              AuthCheckboxRow(
                value: isChecked1,
                onChanged: (value) {
                  setState(() => isChecked1 = value ?? false);
                },
                label: l10n.rememberMe,
              ),
              SizedBox(height: 8.h),
              AuthCheckboxRow(
                value: isChecked2,
                onChanged: (value) {
                  setState(() => isChecked2 = value ?? false);
                },
                label: l10n.agreeToTerms,
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
            ],
            ),
          ),
        ),
      );
      },
    );
  }

}