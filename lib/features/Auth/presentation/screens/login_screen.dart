import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishka_app/core/layout/form_screen_body.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/features/Auth/presentation/screens/reset_password.dart';
import 'package:mishka_app/features/Auth/presentation/screens/signin_views/email_view.dart';
import 'package:mishka_app/features/Auth/presentation/screens/signin_views/phone_view.dart';
import 'package:mishka_app/features/Auth/presentation/screens/sign_up_screen.dart';
import 'package:mishka_app/features/Auth/utils/auth_navigation.dart';
import 'package:mishka_app/features/Auth/view/bloc/auth_bloc.dart';

import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/auth_checkbox_row.dart';
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
        listener: (context, state) async {
          if (state is AuthSuccess) {
            await AuthNavigation.goAfterAuthentication(context, state.user);
            return;
          }
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
        body: FormScreenBody(
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
                SizedBox(height: AppScale.h(4)),
                Text(
                  l10n.welcomeBackToMishka,
                  style: TextStyle(
                    fontSize: AppSizes.fontSizeMedium,
                    fontFamily: "Pridi",
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppScale.h(24)),
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

                SizedBox(height: AppScale.h(16)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AuthCheckboxRow(
                        value: isChecked1,
                        onChanged: (value) {
                          setState(() => isChecked1 = value ?? false);
                        },
                        label: l10n.rememberMe,
                      ),
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
                AuthCheckboxRow(
                  value: isChecked2,
                  onChanged: (value) {
                    setState(() => isChecked2 = value ?? false);
                  },
                  label: l10n.agreeToTerms,
                ),
                SizedBox(height: AppScale.h(24)),
                AuthButton(
                  text: l10n.signIn,
                  isLoading: isLoading,
                  onPressed: _submitLogin,
                ),
                SizedBox(height: AppScale.h(16)),
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
                SizedBox(height: AppScale.h(16)),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: AppScale.h(1),
                        color: AppColors.mainDark,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(AppScale.w(8)),
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
                        height: AppScale.h(1),
                        color: AppColors.mainDark,
                      ),
                    ),
                  ],
                ),
                SocialAuthRow(onGoogle: () {  }, onApple: () {  }, onFacebook: () {  },),
              ],
            ),
        ),
    );
        },
      );
  }

}