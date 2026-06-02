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

class ResetPhoneView extends StatefulWidget {
  const ResetPhoneView({super.key});

  @override
  State<ResetPhoneView> createState() => _ResetPhoneViewState();
}

class _ResetPhoneViewState extends State<ResetPhoneView> {
  final TextEditingController phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final l10n = AppLocalizations.of(context)!;
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.phoneNumber)),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await AuthRemoteDataSource(ApiService()).forgotPassword(phoneNumber: phone);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            title: l10n.verifyByPhoneNumber,
            subtitle: l10n.enter6DigitsCodePhone('+20 $phone'),
            showVerifiedDialog: true,
            onVerify: (_) async {},
            afterVerified: (otpCode) async {
              if (!context.mounted) return;
              await Navigator.pushReplacement<void, void>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => NewPasswordView(
                    resetCode: otpCode,
                    phoneNumber: phone,
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
          SizedBox(height: 16.h),
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
          SizedBox(height: CustomInputField.spacingBetweenFields),
          CustomInputField(
            label: l10n.phoneNumber,
            hint: '+20 ${l10n.phoneNumber}',
            controller: phoneController,
          ),
          SizedBox(height: CustomInputField.spacingBetweenFields),
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
