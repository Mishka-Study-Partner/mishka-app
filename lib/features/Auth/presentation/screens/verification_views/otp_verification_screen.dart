import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/layout/form_screen_body.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/Auth/presentation/widgets/auth_success_dialog.dart';
import 'package:mishka_app/features/Auth/presentation/widgets/custom_elevated_button.dart';
import 'package:mishka_app/features/Auth/presentation/widgets/otp_input.dart';
import 'package:mishka_app/features/Auth/utils/auth_error_messages.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.subtitle,
    required this.onVerify,
    this.title,
    this.allowEmptyCode = false,
    this.otpLength = 6,
    this.showVerifiedDialog = false,
    this.afterVerified,
  });

  final String? title;
  final String subtitle;
  final bool allowEmptyCode;
  final int otpLength;
  final bool showVerifiedDialog;
  final Future<void> Function(String code) onVerify;
  final Future<void> Function(String code)? afterVerified;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _otpCode = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _otpCode.trim();

    if (code.isEmpty && !widget.allowEmptyCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterVerificationCode)),
      );
      return;
    }
    if (!widget.allowEmptyCode && code.length != widget.otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterVerificationCode)),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.onVerify(code);
      if (!mounted) return;

      if (widget.showVerifiedDialog) {
        await AuthSuccessDialog.showVerified(context);
      }
      if (!mounted) return;

      if (widget.afterVerified != null) {
        await widget.afterVerified!(code);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthErrorMessages.from(e, l10n))),
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
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const MishkaAppBar(
        title: '',
        showBottomBar: false,
        showBack: true,
      ),
      body: FormScreenBody(
        padding: EdgeInsetsDirectional.only(
          start: AppSizes.paddingMedium,
          end: AppSizes.paddingMedium,
          bottom: AppSizes.paddingMedium + AppSizes.screenEndPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8.h),
            Text(
              l10n.verificationCode,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.fontSizeTitle,
                fontFamily: 'Pridi',
                fontWeight: FontWeight.w600,
                color: AppColors.mainDark,
              ),
            ),
            SizedBox(height: 32.h),
            if (widget.title != null)
              Text(
                widget.title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.fontSizeLarge,
                  fontFamily: 'Pridi',
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                ),
              ),
            if (widget.title != null) SizedBox(height: 12.h),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.fontSizeMedium,
                fontFamily: 'Pridi',
                fontWeight: FontWeight.w500,
                color: AppColors.mainDark,
                height: 1.35,
              ),
            ),
            SizedBox(height: 32.h),
            OtpInput(
              length: widget.otpLength,
              onChanged: (code) => _otpCode = code,
              onCompleted: (code) => _otpCode = code,
            ),
            SizedBox(height: 48.h),
            AuthButton(
              text: l10n.verify,
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}
