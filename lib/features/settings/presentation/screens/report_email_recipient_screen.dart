import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/Auth/presentation/widgets/custom_elevated_button.dart';
import 'package:mishka_app/features/Auth/utils/auth_validators.dart';
import 'package:mishka_app/features/settings/data/data_sources/user_preferences_remote_data_source.dart';
import 'package:mishka_app/features/settings/data/models/report_email_preferences_model.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class ReportEmailRecipientScreen extends StatefulWidget {
  const ReportEmailRecipientScreen({
    super.key,
    required this.initialEmail,
    this.accountEmail,
  });

  final String? initialEmail;
  final String? accountEmail;

  @override
  State<ReportEmailRecipientScreen> createState() =>
      _ReportEmailRecipientScreenState();
}

class _ReportEmailRecipientScreenState extends State<ReportEmailRecipientScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialEmail ?? widget.accountEmail ?? '',
  );
  late final UserPreferencesRemoteDataSource _remote =
      UserPreferencesRemoteDataSource(ApiService());

  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final email = _controller.text.trim();
    setState(() => _saving = true);

    try {
      await AppPreferences.setReportEmailRecipient(email);
      var syncedToServer = false;
      try {
        await _remote.patchMe(
          ReportEmailPreferencesModel.patchRecipientOnly(email),
        );
        syncedToServer = true;
      } on ApiException {
        // Saved locally until backend accepts reportEmailRecipient.
      }
      if (!mounted) return;
      Navigator.of(context).pop(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            syncedToServer
                ? l10n.settingsReportRecipientSaved
                : l10n.settingsReportRecipientSavedLocal,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsSyncFailed)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _useAccountEmail() async {
    final account = widget.accountEmail?.trim();
    if (account == null || account.isEmpty) return;
    _controller.text = account;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final account = widget.accountEmail?.trim();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: MishkaAppBar(
        title: l10n.settingsReportRecipientTitle,
        topTitle: l10n.settingsReportRecipientTitle,
        showBack: true,
        showBottomBar: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLarge,
            vertical: 20.h,
          ),
          children: [
            Text(
              l10n.settingsReportRecipientBody,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                height: 1.5,
                color: scheme.onSurface.withValues(alpha: 0.88),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              l10n.settingsReportRecipientLabel,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              autofillHints: const [AutofillHints.email],
              validator: (v) => AuthValidators.validateEmail(v, l10n),
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                color: scheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: account ?? 'you@example.com',
                hintStyle: TextStyle(
                  fontFamily: 'Pridi',
                  color: scheme.onSurface.withValues(alpha: 0.45),
                ),
                filled: true,
                fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  borderSide: const BorderSide(color: AppColors.mainGold),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 14.h,
                ),
              ),
            ),
            if (account != null && account.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: _useAccountEmail,
                  child: Text(
                    l10n.settingsReportRecipientUseAccount(account),
                    style: const TextStyle(
                      fontFamily: 'Pridi',
                      color: AppColors.mainGold,
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: 28.h),
            AuthButton(
              text: l10n.save,
              onPressed: _save,
              isLoading: _saving,
            ),
          ],
        ),
      ),
    );
  }
}
