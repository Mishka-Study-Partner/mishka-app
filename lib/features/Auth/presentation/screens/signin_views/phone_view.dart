import 'package:flutter/material.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../widgets/form_text.dart';

class PasswordView extends StatelessWidget {
  const PasswordView({
    super.key,
    required this.phoneController,
    required this.passwordController,
  });

  final TextEditingController phoneController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        SizedBox(height: CustomInputField.spacingBetweenFields),
        CustomInputField(
          label: l10n.phoneNumber,
          hint: '+20 ${l10n.phoneNumber}',
          controller: phoneController,
        ),
        SizedBox(height: CustomInputField.spacingBetweenFields),
        CustomInputField(
          label: l10n.password,
          hint: l10n.examplePassword,
          controller: passwordController,
          isPassword: true,
        ),
      ],
    );
  }
}
