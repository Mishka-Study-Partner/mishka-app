import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/settings/data/app_public_settings_cache.dart';
import 'package:mishka_app/features/settings/data/data_sources/app_public_settings_remote_data_source.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final AppPublicSettingsRemoteDataSource _remote =
      AppPublicSettingsRemoteDataSource(ApiService());

  String? _body;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load({bool refresh = false}) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      final settings =
          await AppPublicSettingsCache.load(_remote, refresh: refresh);
      if (!mounted) return;
      final fromApi = settings?.privacyPolicyText.trim();
      _body = (fromApi != null && fromApi.isNotEmpty)
          ? fromApi
          : l10n.privacyPolicyBody;
    } catch (_) {
      if (!mounted) return;
      _body = l10n.privacyPolicyBody;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: MishkaAppBar(
        title: l10n.privacyPolicy,
        topTitle: l10n.privacyPolicy,
        showBack: true,
        showBottomBar: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _load(refresh: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingLarge,
                  vertical: 20.h,
                ),
                child: Text(
                  _body ?? l10n.privacyPolicyBody,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppSizes.fontSizeMedium,
                    height: 1.55,
                    color: scheme.onSurface.withValues(alpha: 0.88),
                  ),
                ),
              ),
            ),
    );
  }
}
