import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/Auth/data/data_sources/auth_remote_data_source.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/features/Auth/presentation/screens/reset_password_views/new_password_view.dart';
import 'package:mishka_app/features/Auth/presentation/screens/verification_views/otp_verification_screen.dart';

import '../../widgets/custom_elevated_button.dart';
import '../../widgets/form_text.dart';

class ResetEmailView extends StatefulWidget {
  const ResetEmailView({super.key});

  @override
  State<ResetEmailView> createState() => _ResetEmailViewState();
}

class _ResetEmailViewState extends State<ResetEmailView> {
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final l10n = AppLocalizations.of(context)!;
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emailAddress)),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await AuthRemoteDataSource(ApiService()).forgotPassword(email: email);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            title: l10n.verifyByEmail,
            subtitle: l10n.enter5DigitsCodeEmail,
            allowEmptyCode: false,
            onVerify: (otpCode) async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewPasswordView(
                    resetCode: otpCode,
                    email: email,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
            l10n.writeEmailForCode,
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
            label: l10n.emailAddress,
            hint: l10n.exampleEmail,
            controller: emailController,
          ),
          SizedBox(height: 24.h),
          AuthButton(
            text: l10n.getCode,
            isLoading: _isLoading,
            onPressed: _sendCode,
          ),
        ],
      ),
    );
  }
}
