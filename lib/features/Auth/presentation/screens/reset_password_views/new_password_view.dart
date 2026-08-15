import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/layout/form_screen_body.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/Auth/data/data_sources/auth_remote_data_source.dart';
import 'package:mishka_app/features/Auth/presentation/widgets/auth_success_dialog.dart';
import 'package:mishka_app/features/Auth/presentation/widgets/custom_elevated_button.dart';
import 'package:mishka_app/features/Auth/presentation/widgets/form_text.dart';
import 'package:mishka_app/features/Auth/presentation/widgets/password_requirements_card.dart';
import 'package:mishka_app/features/Auth/utils/auth_validators.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class NewPasswordView extends StatefulWidget {
  const NewPasswordView({
    super.key,
    required this.resetCode,
    this.userId,
    this.email,
    this.phoneNumber,
  });

  final String resetCode;
  final String? userId;
  final String? email;
  final String? phoneNumber;

  @override
  State<NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<NewPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final newPassword = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;
    if (newPassword != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.passwordsDoNotMatch)),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await AuthRemoteDataSource(ApiService()).resetPassword(
        userId: widget.userId,
        email: widget.email,
        phoneNumber: widget.phoneNumber,
        resetCode: widget.resetCode,
        newPassword: newPassword,
      );
      if (!mounted) return;
      await AuthSuccessDialog.showPasswordSet(context);
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8.h),
                Text(
                  l10n.enterNewPassword,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppSizes.fontSizeTitle,
                    fontFamily: 'Pridi',
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainDark,
                  ),
                ),
                SizedBox(height: CustomInputField.spacingBetweenFields),
                CustomInputField(
                  label: l10n.newPassword,
                  hint: l10n.newPassword,
                  isPassword: true,
                  controller: _newPasswordController,
                  validator: (v) => AuthValidators.validatePassword(v, l10n),
                ),
                SizedBox(height: CustomInputField.spacingBetweenFields),
                CustomInputField(
                  label: l10n.confirmNewPassword,
                  hint: l10n.confirmNewPassword,
                  isPassword: true,
                  controller: _confirmPasswordController,
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.fieldRequired;
                    if (v != _newPasswordController.text) {
                      return l10n.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                ListenableBuilder(
                  listenable: _newPasswordController,
                  builder: (context, _) {
                    return PasswordRequirementsCard(
                      password: _newPasswordController.text,
                    );
                  },
                ),
                SizedBox(height: 24.h),
                AuthButton(
                  text: l10n.setPassword,
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
      ),
    );
  }
}
