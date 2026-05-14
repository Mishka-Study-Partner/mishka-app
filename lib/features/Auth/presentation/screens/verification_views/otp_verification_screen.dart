import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/Auth/presentation/widgets/custom_elevated_button.dart';
import 'package:mishka_app/features/Auth/presentation/widgets/otp_input.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.subtitle,
    required this.onVerify,
    this.title,
    this.allowEmptyCode = false,
  });

  final String? title;
  final String subtitle;
  final bool allowEmptyCode;
  final Future<void> Function(String code) onVerify;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _otpCode = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_otpCode.trim().isEmpty && !widget.allowEmptyCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterVerificationCode)),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await widget.onVerify(_otpCode.trim());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
          bottom: AppSizes.paddingMedium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              l10n.verificationCode,
              style: TextStyle(
                fontSize: AppSizes.fontSizeTitle,
                fontFamily: 'Pridi',
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.title != null)
                      Text(
                        widget.title!,
                        style: TextStyle(
                          fontSize: AppSizes.fontSizeLarge,
                          fontFamily: 'Pridi',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (widget.title != null) SizedBox(height: 8.h),
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeLarge,
                        fontFamily: 'Pridi',
                        fontWeight: FontWeight.w500,
                        color: AppColors.mainDark,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    OtpInput(
                      onCompleted: (code) {
                        _otpCode = code;
                      },
                    ),
                    SizedBox(height: 24.h),
                    AuthButton(
                      text: l10n.verify,
                      isLoading: _isLoading,
                      onPressed: _submit,
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
