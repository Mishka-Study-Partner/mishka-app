import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/utils/link_launcher.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/profile/presentation/widgets/profile_info_row.dart';
import 'package:mishka_app/features/profile/presentation/widgets/profile_section_card.dart';
import 'package:mishka_app/features/settings/data/app_public_settings_cache.dart';
import 'package:mishka_app/features/settings/data/data_sources/app_public_settings_remote_data_source.dart';
import 'package:mishka_app/features/settings/data/models/app_public_settings_model.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  late final AppPublicSettingsRemoteDataSource _remote =
      AppPublicSettingsRemoteDataSource(ApiService());

  AppPublicSettingsModel? _settings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load({bool refresh = false}) async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      _settings = await AppPublicSettingsCache.load(_remote, refresh: refresh);
    } catch (_) {
      _settings = null;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _launch(
    Future<bool> Function() action,
    AppLocalizations l10n, {
    String? copyFallback,
  }) async {
    final ok = await action();
    if (!ok && mounted) {
      if (copyFallback != null && copyFallback.trim().isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: copyFallback.trim()));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.linkOpenFailedCopied)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.linkOpenFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final settings = _settings;
    final hasContacts = settings?.hasSupportContacts ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: MishkaAppBar(
        title: l10n.helpSupport,
        topTitle: l10n.helpSupport,
        showBack: true,
        showBottomBar: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _load(refresh: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                  vertical: 20.h,
                ),
                children: [
                  if (!hasContacts) ...[
                    Text(
                      l10n.helpSupportBody,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: AppSizes.fontSizeMedium,
                        height: 1.55,
                        color: scheme.onSurface.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                  if (hasContacts && settings != null) ...[
                    ProfileSectionCard(
                      child: Column(
                        children: [
                          if (_nonEmpty(settings.supportEmail))
                            ProfileInfoRow(
                              icon: Icons.mail_outline,
                              title: l10n.email,
                              value: settings.supportEmail!.trim(),
                              onTap: () => _launch(
                                () => LinkLauncher.openEmail(
                                  settings.supportEmail!.trim(),
                                ),
                                l10n,
                                copyFallback: settings.supportEmail!.trim(),
                              ),
                            ),
                          if (_nonEmpty(settings.supportEmail) &&
                              _nonEmpty(settings.supportPhone))
                            SizedBox(height: 12.h),
                          if (_nonEmpty(settings.supportPhone))
                            ProfileInfoRow(
                              icon: Icons.chat_outlined,
                              title: l10n.supportWhatsApp,
                              value: settings.supportPhone!.trim(),
                              onTap: () => _launch(
                                () => LinkLauncher.openWhatsApp(
                                  settings.supportPhone!.trim(),
                                ),
                                l10n,
                                copyFallback: settings.supportPhone!.trim(),
                              ),
                            ),
                          if ((_nonEmpty(settings.supportEmail) ||
                                  _nonEmpty(settings.supportPhone)) &&
                              _nonEmpty(settings.supportFacebookUrl))
                            SizedBox(height: 12.h),
                          if (_nonEmpty(settings.supportFacebookUrl))
                            ProfileInfoRow(
                              icon: Icons.facebook,
                              title: l10n.supportFacebook,
                              value: LinkLauncher.displayLabelForUrl(
                                settings.supportFacebookUrl!.trim(),
                              ),
                              onTap: () => _launch(
                                () => LinkLauncher.openUrl(
                                  settings.supportFacebookUrl!.trim(),
                                ),
                                l10n,
                              ),
                            ),
                          if (_nonEmpty(settings.supportFacebookUrl) &&
                              _nonEmpty(settings.supportInstagramUrl))
                            SizedBox(height: 12.h),
                          if (_nonEmpty(settings.supportInstagramUrl))
                            ProfileInfoRow(
                              icon: Icons.camera_alt_outlined,
                              title: l10n.supportInstagram,
                              value: LinkLauncher.displayLabelForUrl(
                                settings.supportInstagramUrl!.trim(),
                              ),
                              onTap: () => _launch(
                                () => LinkLauncher.openUrl(
                                  settings.supportInstagramUrl!.trim(),
                                ),
                                l10n,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  bool _nonEmpty(String? v) => v != null && v.trim().isNotEmpty;
}
