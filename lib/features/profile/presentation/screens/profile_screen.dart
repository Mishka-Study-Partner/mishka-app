import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/Auth/data/data_sources/auth_remote_data_source.dart';
import 'package:mishka_app/features/Auth/data/models/user_model.dart';
import 'package:mishka_app/features/Auth/view/bloc/auth_bloc.dart';
import 'package:mishka_app/core/widgets/app_settings_scope.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/generated/assets.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/profile_action_button.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_info_row.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/profile_text_field.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthRemoteDataSource _authRemote =
      AuthRemoteDataSource(ApiService());

  static const _genderFemale = 'female';
  static const _genderMale = 'male';
  static const _genderOther = 'other';

  bool _genderBusy = false;

  Future<void> _refreshProfile() async {
    try {
      final user = await _authRemote.getCurrentUser();
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthReplaceUser(user));
    } on ApiException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileLoadFailed)),
      );
    }
  }

  String _displayName(UserModel u, AppLocalizations l10n) {
    final full = u.fullName?.trim();
    if (full != null && full.isNotEmpty) return full;
    final combined = '${u.firstName} ${u.lastName}'.trim();
    if (combined.isNotEmpty) return combined;
    return l10n.profileFieldNotSet;
  }

  String _username(UserModel u, AppLocalizations l10n) {
    final v = u.username?.trim();
    if (v == null || v.isEmpty) return l10n.profileFieldNotSet;
    return v;
  }

  String _email(UserModel u, AppLocalizations l10n) {
    final v = u.email.trim();
    if (v.isEmpty) return l10n.profileFieldNotSet;
    return v;
  }

  String _phone(UserModel u, AppLocalizations l10n) {
    final p = (u.phoneNumber ?? '').trim();
    final c = (u.countryCode ?? '').trim();
    if (p.isEmpty && c.isEmpty) return l10n.profileFieldNotSet;
    if (c.isEmpty) return p;
    if (p.isEmpty) return c;
    return '$c $p';
  }

  bool _isFemale(UserModel u) =>
      (u.gender ?? '').toLowerCase().trim() == _genderFemale;

  bool _isMale(UserModel u) =>
      (u.gender ?? '').toLowerCase().trim() == _genderMale;

  /// Prefer-not / unset / non-binary server values (everything except female & male).
  bool _isPreferNot(UserModel u) => !_isFemale(u) && !_isMale(u);

  String _storedGenderValue(UserModel u) {
    if (_isFemale(u)) return _genderFemale;
    if (_isMale(u)) return _genderMale;
    return _genderOther;
  }

  bool _avatarBusy = false;

  Future<void> _pickAndUploadAvatar() async {
    if (_avatarBusy) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    final path = result?.files.firstOrNull?.path;
    if (path == null || !mounted) return;

    setState(() => _avatarBusy = true);
    try {
      final updated = await _authRemote.uploadAvatar(path);
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthReplaceUser(updated));
    } on ApiException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileLoadFailed)),
      );
    } finally {
      if (mounted) setState(() => _avatarBusy = false);
    }
  }

  Future<void> _deleteAvatar() async {
    if (_avatarBusy) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.removeProfilePhotoConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.remove, style: const TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _avatarBusy = true);
    try {
      final updated = await _authRemote.deleteAvatar();
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthReplaceUser(updated));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileLoadFailed)),
      );
    } finally {
      if (mounted) setState(() => _avatarBusy = false);
    }
  }

  Future<void> _applyGender(UserModel user, String gender) async {
    if (_genderBusy) return;
    if (_storedGenderValue(user) == gender) return;

    setState(() => _genderBusy = true);
    try {
      final updated = await _authRemote.patchCurrentUserProfile(
        gender: gender,
      );
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthReplaceUser(updated));
    } on ApiException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileLoadFailed)),
      );
    } finally {
      if (mounted) setState(() => _genderBusy = false);
    }
  }

  /// Gold accent for profile preference [Switch] / [SegmentedButton] visuals.
  ThemeData _preferenceControlsTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final iconOnGold =
        brightness == Brightness.dark ? AppColors.white : AppColors.mainDark;

    return Theme.of(context).copyWith(
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.mainGold;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.mainGold.withValues(alpha: 0.42);
          }
          return null;
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return iconOnGold;
            return null;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.mainGold;
            return null;
          }),
        ),
      ),
    );
  }

  Widget _languageToggle(
    BuildContext context,
    AppLocalizations l10n,
    AppSettingsScope scope,
  ) {
    final isArabic = scope.locale.languageCode == 'ar';
    final onSurface = Theme.of(context).colorScheme.onSurface;

    const labelFont = 9.0;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerEnd,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.english,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: labelFont.sp,
              fontWeight: isArabic ? FontWeight.w500 : FontWeight.w700,
              color: onSurface.withValues(alpha: isArabic ? 0.55 : 0.92),
            ),
          ),
          Transform.scale(
            scale: .82,
            child: Switch.adaptive(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: isArabic,
              onChanged: (v) {
                scope.onLocaleChanged(Locale(v ? 'ar' : 'en'));
              },
            ),
          ),
          Text(
            l10n.arabic,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: labelFont.sp,
              fontWeight: isArabic ? FontWeight.w700 : FontWeight.w500,
              color: onSurface.withValues(alpha: isArabic ? 0.92 : 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeSegmented(
    BuildContext context,
    AppLocalizations l10n,
    AppSettingsScope scope,
  ) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerEnd,
      child: SegmentedButton<ThemeMode>(
        showSelectedIcon: false,
        multiSelectionEnabled: false,
        emptySelectionAllowed: false,
        segments: [
          ButtonSegment<ThemeMode>(
            value: ThemeMode.light,
            tooltip: l10n.lightMode,
            icon: const Icon(Icons.light_mode_outlined, size: 20),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.dark,
            tooltip: l10n.darkMode,
            icon: const Icon(Icons.dark_mode_outlined, size: 20),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.system,
            tooltip: l10n.themeSystem,
            icon: const Icon(Icons.brightness_auto_outlined, size: 20),
          ),
        ],
        selected: {scope.themeMode},
        onSelectionChanged: (next) {
          if (next.isEmpty) return;
          scope.onThemeModeChanged(next.first);
        },
      ),
    );
  }

  Widget _notificationToggle(
    BuildContext context,
    AppLocalizations l10n,
    AppSettingsScope scope,
  ) {
    final enabled = scope.notificationsEnabled;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    const labelFont = 9.0;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerEnd,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.disabled,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: labelFont.sp,
              fontWeight: enabled ? FontWeight.w500 : FontWeight.w700,
              color: onSurface.withValues(alpha: enabled ? 0.55 : 0.92),
            ),
          ),
          Transform.scale(
            scale: .82,
            child: Switch.adaptive(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: enabled,
              onChanged: (v) => scope.onNotificationsChanged(v),
            ),
          ),
          Text(
            l10n.enabled,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: labelFont.sp,
              fontWeight: enabled ? FontWeight.w700 : FontWeight.w500,
              color: onSurface.withValues(alpha: enabled ? 0.92 : 0.55),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return switch (state) {
          AuthSuccess(:final user) => _buildBody(context, l10n, user),
          AuthLoading() => Scaffold(
              appBar: MishkaAppBar(
                title: l10n.profile,
                showBack: false,
                showBottomBar: false,
              ),
              body: const Center(child: CircularProgressIndicator()),
            ),
          AuthError(:final message) => Scaffold(
              appBar: MishkaAppBar(
                title: l10n.profile,
                showBack: false,
                showBottomBar: false,
              ),
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.paddingLarge),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          fontSize: AppSizes.fontSizeMedium,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(const AuthLoadUserRequested());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainGold,
                        ),
                        child: Text(
                          l10n.retry,
                          style: const TextStyle(
                            fontFamily: 'Pridi',
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          AuthInitial() => Scaffold(
              appBar: MishkaAppBar(
                title: l10n.profile,
                showBack: false,
                showBottomBar: false,
              ),
              body: Center(
                child: Text(
                  l10n.signIn,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppSizes.fontSizeMedium,
                    color:
                        Theme.of(context).colorScheme.onSurface.withValues(
                              alpha: 0.55,
                            ),
                  ),
                ),
              ),
            ),
        };
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    UserModel user,
  ) {
    final female = _isFemale(user);
    final male = _isMale(user);
    final preferNot = _isPreferNot(user);
    final scheme = Theme.of(context).colorScheme;
    final scope = AppSettingsScope.of(context);

    return Scaffold(
      appBar: MishkaAppBar(
        title: l10n.profile,
        showBack: false,
        showBottomBar: false,
        topTrailingAction: IconButton(
          tooltip: l10n.editProfile,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          icon: const Icon(
            Icons.edit_outlined,
            color: AppColors.mainGold,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (ctx) => BlocProvider.value(
                  value: context.read<AuthBloc>(),
                  child: EditProfileScreen(initialUser: user),
                ),
              ),
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 24.h),
              ProfileAvatar(
                networkImageUrl: user.profileImageUrl,
                fallbackAssetPath: Assets.imagesLogoNoName,
                onEdit: _avatarBusy ? null : _pickAndUploadAvatar,
                onDelete: (user.profileImageUrl != null &&
                        user.profileImageUrl!.isNotEmpty &&
                        !_avatarBusy)
                    ? _deleteAvatar
                    : null,
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                  vertical: AppSizes.paddingMedium,
                ),
                child: Column(
                  children: [
                    ProfileSectionCard(
                      icon: Icons.person,
                      title: l10n.accountSetting,
                      child: Column(
                        children: [
                          ProfileTextField(
                            label: l10n.fullName,
                            value: _displayName(user, l10n),
                          ),
                          SizedBox(height: 12.h),
                          ProfileTextField(
                            label: l10n.userName,
                            value: _username(user, l10n),
                          ),
                          SizedBox(height: 12.h),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              l10n.gender,
                              style: TextStyle(
                                fontFamily: 'Pridi',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: scheme.onSurface.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Expanded(
                                child: ProfileActionButton(
                                  text: l10n.female,
                                  selected: female,
                                  expand: true,
                                  onTap: _genderBusy
                                      ? null
                                      : () =>
                                          _applyGender(user, _genderFemale),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: ProfileActionButton(
                                  text: l10n.male,
                                  selected: male,
                                  expand: true,
                                  onTap: _genderBusy
                                      ? null
                                      : () => _applyGender(user, _genderMale),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: ProfileActionButton(
                                  text: l10n.ratherNotToSay,
                                  selected: preferNot,
                                  expand: true,
                                  onTap: _genderBusy
                                      ? null
                                      : () =>
                                          _applyGender(user, _genderOther),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ProfileSectionCard(
                      icon: Icons.mail,
                      title: l10n.contactInfo,
                      child: Column(
                        children: [
                          ProfileTextField(
                            label: l10n.email,
                            value: _email(user, l10n),
                          ),
                          SizedBox(height: 12.h),
                          ProfileTextField(
                            label: l10n.phoneNumber,
                            value: _phone(user, l10n),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ProfileSectionCard(
                      child: Theme(
                        data: _preferenceControlsTheme(context),
                        child: Column(
                          children: [
                            ProfileInfoRow(
                              icon: Icons.language,
                              title: l10n.language,
                              trailing: _languageToggle(
                                context,
                                l10n,
                                scope,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            ProfileInfoRow(
                              icon: Icons.dark_mode,
                              title: l10n.theme,
                              trailing: _themeSegmented(
                                context,
                                l10n,
                                scope,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            ProfileInfoRow(
                              icon: Icons.notifications,
                              title: l10n.notification,
                              trailing: _notificationToggle(
                                context,
                                l10n,
                                scope,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ProfileSectionCard(
                      child: ProfileInfoRow(
                        icon: Icons.shield,
                        title: l10n.privacyPolicy,
                        value: "",
                        onTap: () {
                          showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.privacyPolicy),
                              content: Text(l10n.privacyPolicyComingSoon),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(l10n.ok),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ProfileSectionCard(
                      child: ProfileInfoRow(
                        icon: Icons.contact_support,
                        title: l10n.helpSupport,
                        value: "",
                        onTap: () {
                          showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.helpSupport),
                              content: Text(l10n.helpSupportComingSoon),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(l10n.ok),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ProfileSectionCard(
                      child: ProfileInfoRow(
                        icon: Icons.logout,
                        title: l10n.logOut,
                        value: "",
                        onTap: () {
                          showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.logOut),
                              content: Text(l10n.logoutConfirmationMessage),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context.read<AuthBloc>().add(
                                          const AuthLogoutRequested(),
                                        );
                                  },
                                  child: Text(
                                    l10n.logOut,
                                    style: const TextStyle(
                                      color: AppColors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
