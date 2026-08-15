import 'package:flutter/material.dart';
import 'package:mishka_app/core/layout/app_scale.dart';
import 'package:mishka_app/core/layout/form_screen_body.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/features/Auth/presentation/screens/reset_password_views/email_view.dart';
import 'package:mishka_app/features/Auth/presentation/screens/reset_password_views/reset_phone_view.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/custom_segmanted_button.dart';


class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key,});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController emailController =TextEditingController();
  TextEditingController phoneController =TextEditingController();
  TextEditingController passwordController =TextEditingController();
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const MishkaAppBar(
        title: '',
        showBottomBar: false,
      ),
      body: FormScreenBody(
          child: Column(
            children: [
              Text(
                l10n.resetPassword,
                style: TextStyle(
                  fontSize: AppSizes.fontSizeTitle,
                  fontFamily: "Pridi",
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppScale.h(24)),
              CustomSegmentedButton(
                selectedIndex: selectedIndex,
                onChanged: (i) => setState(() => selectedIndex = i),
                segments: [l10n.email, l10n.phoneNumber],
              ),
              if (selectedIndex == 0)
                 ResetEmailView()
              else
                 ResetPhoneView(),
            ],
          ),
      ),
    );
  }

}