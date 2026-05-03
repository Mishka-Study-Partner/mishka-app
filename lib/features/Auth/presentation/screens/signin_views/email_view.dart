import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../widgets/form_text.dart';

class EmailView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  EmailView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
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
      ],
    );
  }
}
