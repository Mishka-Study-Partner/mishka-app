import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/network/app_network_config.dart';
import 'package:mishka_app/core/network/dio_client.dart';
import 'package:mishka_app/core/network/token_storage.dart';
import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/core/utils/app_theme.dart';
import 'package:mishka_app/core/widgets/app_settings_scope.dart';
import 'package:mishka_app/features/Auth/data/data_sources/auth_remote_data_source.dart';
import 'package:mishka_app/features/Auth/view/bloc/auth_bloc.dart';
import 'package:mishka_app/features/onboarding/presentation/app_launch_gate.dart';
// Deep links disabled — re-enable with CommunityInviteDeepLinkCoordinator + entitlements.
// import 'package:mishka_app/features/our_community/data/community_invite_deep_link_coordinator.dart';
import 'package:mishka_app/features/settings/data/models/user_preferences_model.dart';
import 'package:mishka_app/features/settings/data/user_preferences_applier.dart';

import 'l10n/app_localizations.dart';

export 'app/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🚀 Mishka: main() start');
  await TokenStorage.init();
  debugPrint('🚀 Mishka: TokenStorage ready, token=${TokenStorage.token != null ? "present" : "null"}');
  await AppPreferences.init();
  debugPrint('🚀 Mishka: AppPreferences ready');
  DioClient.instance.init();
  debugPrint('🚀 Mishka: DioClient ready — launching app');
  // await CommunityInviteDeepLinkCoordinator.instance.init();
  runApp(const MishkaApp());
}

class MishkaApp extends StatefulWidget {
  const MishkaApp({super.key});

  @override
  State<MishkaApp> createState() => _MishkaAppState();
}

class _MishkaAppState extends State<MishkaApp> {
  late Locale _locale = Locale(AppPreferences.localeCode);
  late ThemeMode _themeMode = AppPreferences.themeMode;
  late bool _notificationsEnabled = AppPreferences.notificationsEnabled;

  Future<void> _onLocaleChanged(Locale value) async {
    await AppPreferences.setLocaleCode(value.languageCode);
    if (!mounted) return;
    setState(() => _locale = value);
  }

  Future<void> _onThemeModeChanged(ThemeMode mode) async {
    await AppPreferences.setThemeMode(mode);
    if (!mounted) return;
    setState(() => _themeMode = mode);
  }

  Future<void> _onNotificationsChanged(bool enabled) async {
    await AppPreferences.setNotificationsEnabled(enabled);
    if (!mounted) return;
    setState(() => _notificationsEnabled = enabled);
  }

  Future<void> _applyServerPreferences(UserPreferencesModel? server) async {
    final effective = UserPreferencesApplier.resolve(server);
    await UserPreferencesApplier.apply(effective);
    if (!mounted) return;
    setState(() {
      _locale = effective.locale;
      _themeMode = effective.themeMode;
      _notificationsEnabled = effective.notificationsEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(
        AuthRemoteDataSource(ApiService()),
      )..add(const AuthLoadUserRequested()),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) {
          if (current is! AuthSuccess || current.preference == null) {
            return false;
          }
          if (previous is AuthSuccess) {
            final prev = previous.preference;
            final curr = current.preference;
            if (prev != null &&
                prev.languageCode == curr!.languageCode &&
                prev.themeMode == curr.themeMode &&
                prev.notificationsEnabled == curr.notificationsEnabled) {
              return false;
            }
          }
          return true;
        },
        listener: (context, state) {
          if (state is AuthSuccess && state.preference != null) {
            _applyServerPreferences(state.preference!);
          }
        },
        child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Mishka',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _themeMode,
            locale: _locale,
            builder: (context, child) {
              AppNetworkConfig.syncFromContext(context);
              return AppSettingsScope(
                locale: _locale,
                themeMode: _themeMode,
                notificationsEnabled: _notificationsEnabled,
                onLocaleChanged: _onLocaleChanged,
                onThemeModeChanged: _onThemeModeChanged,
                onNotificationsChanged: _onNotificationsChanged,
                child: child ?? const SizedBox.shrink(),
              );
            },
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            home: const AppLaunchGate(),
          );
        },
      ),
      ),
    );
  }
}
