import 'package:flutter/material.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../widgets/form_text.dart';

class EmailView extends StatelessWidget {
  const EmailView({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        SizedBox(height: CustomInputField.spacingBetweenFields),
        CustomInputField(
          label: l10n.emailAddress,
          hint: l10n.exampleEmail,
          controller: emailController,
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
