import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/Auth/data/data_sources/auth_remote_data_source.dart';
import 'package:mishka_app/features/Auth/data/models/user_model.dart';
import 'package:mishka_app/features/Auth/view/bloc/auth_bloc.dart';
import 'package:mishka_app/features/profile/presentation/widgets/profile_action_button.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.initialUser,
  });

  final UserModel initialUser;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _genderFemale = 'female';
  static const _genderMale = 'male';
  static const _genderOther = 'other';

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _countryCodeCtrl;
  late final TextEditingController _phoneCtrl;

  late String _genderValue;
  late final AuthRemoteDataSource _authRemote =
      AuthRemoteDataSource(ApiService());

  bool _saving = false;

  String _storedGender(UserModel u) {
    final g = (u.gender ?? '').toLowerCase().trim();
    if (g == _genderFemale) return _genderFemale;
    if (g == _genderMale) return _genderMale;
    return _genderOther;
  }

  bool get _preferNotGender => _genderValue == _genderOther;

  bool get _isFemaleForForm => _genderValue == _genderFemale;
  bool get _isMaleForForm => _genderValue == _genderMale;

  @override
  void initState() {
    super.initState();
    final u = widget.initialUser;
    _firstNameCtrl = TextEditingController(text: u.firstName.trim());
    _lastNameCtrl = TextEditingController(text: u.lastName.trim());
    _emailCtrl = TextEditingController(text: u.email.trim());
    _countryCodeCtrl = TextEditingController(text: (u.countryCode ?? '').trim());
    _phoneCtrl = TextEditingController(text: (u.phoneNumber ?? '').trim());
    _genderValue = _storedGender(u);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _countryCodeCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final loc = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || !mounted || _saving) return;

    setState(() => _saving = true);
    try {
      final first = _firstNameCtrl.text.trim();
      final last = _lastNameCtrl.text.trim();
      final combined = '$first $last'.trim();

      final phone = _phoneCtrl.text.trim();
      final code = _countryCodeCtrl.text.trim();

      final updated = await _authRemote.patchCurrentUserProfile(
        firstName: first.isEmpty ? null : first,
        lastName: last.isEmpty ? null : last,
        fullName: combined.isEmpty ? null : combined,
        email: _emailCtrl.text.trim(),
        phoneNumber: phone.isEmpty ? null : phone,
        countryCode: code.isEmpty ? null : code,
        gender: _genderValue,
      );

      if (!mounted) return;
      context.read<AuthBloc>().add(AuthReplaceUser(updated));
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.errorPrefix}: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.profileUpdateFailed)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    InputDecoration deco(String hint) => InputDecoration(
          hintText: hint,
          isDense: true,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.outline.withValues(alpha: .4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.mainGold, width: 1.5),
          ),
        );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: MishkaAppBar(
        title: l10n.editProfile,
        topTitle: l10n.editProfile,
        showBack: true,
        showBottomBar: false,
        onBackTap: () {
          if (_saving) return;
          Navigator.of(context).pop();
        },
        topTrailingAction: IconButton(
          tooltip: l10n.save,
          onPressed: _saving ? null : _save,
          icon: _saving
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.mainGold,
                  ),
                )
              : const Icon(Icons.check, color: AppColors.mainGold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLarge,
            vertical: 20.h,
          ),
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              l10n.firstName,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: .9),
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _firstNameCtrl,
              textInputAction: TextInputAction.next,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                color: scheme.onSurface,
              ),
              decoration: deco(l10n.firstName),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                return null;
              },
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.lastName,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: .9),
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _lastNameCtrl,
              textInputAction: TextInputAction.next,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                color: scheme.onSurface,
              ),
              decoration: deco(l10n.lastName),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                return null;
              },
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.email,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: .9),
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                color: scheme.onSurface,
              ),
              decoration: deco(l10n.exampleEmail),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                final t = v.trim();
                final at = t.indexOf('@');
                if (at < 1) return l10n.invalidEmailHint;
                final domain = t.substring(at + 1);
                final dot = domain.lastIndexOf('.');
                final validDomain =
                    dot > 0 && dot < domain.length - 1;
                final hasSpace = t.contains(' ') || t.contains('\t');
                if (!validDomain || hasSpace) {
                  return l10n.invalidEmailHint;
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.phoneNumber,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: .9),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 92.w,
                  child: TextFormField(
                    controller: _countryCodeCtrl,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeMedium,
                      color: scheme.onSurface,
                    ),
                    decoration: deco('+20'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeMedium,
                      color: scheme.onSurface,
                    ),
                    decoration: deco(l10n.phoneNumber),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              l10n.gender,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface.withValues(alpha: .9),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: ProfileActionButton(
                    text: l10n.female,
                    selected: _isFemaleForForm,
                    expand: true,
                    onTap: _saving
                        ? null
                        : () => setState(() => _genderValue = _genderFemale),
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: ProfileActionButton(
                    text: l10n.male,
                    selected: _isMaleForForm,
                    expand: true,
                    onTap: _saving
                        ? null
                        : () => setState(() => _genderValue = _genderMale),
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: ProfileActionButton(
                    text: l10n.ratherNotToSay,
                    selected: _preferNotGender,
                    expand: true,
                    onTap: _saving
                        ? null
                        : () => setState(() => _genderValue = _genderOther),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.mainGold,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  l10n.save,
                  style: const TextStyle(
                    fontFamily: 'Pridi',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
