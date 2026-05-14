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
import 'package:mishka_app/features/study_with_me/presentation/widgets/floating_timer_bar.dart';
import 'package:mishka_app/features/study_with_me/study_with.dart';
import 'package:mishka_app/core/widgets/custom_nav_bar.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/screens/chat_with_mishka_screen.dart';
import 'package:mishka_app/features/ctegory/presentation/view/ai_tools_screen.dart';
import 'package:mishka_app/features/ctegory/presentation/view/category_screen.dart';
import 'package:mishka_app/features/gamification/gamification.dart';
import 'package:mishka_app/features/our_community/our_community.dart';
import 'package:mishka_app/features/Auth/presentation/screens/login_screen.dart';
import 'package:mishka_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:mishka_app/features/home/presentation/screens/home_screen.dart';
import 'package:mishka_app/features/saved/presentation/screens/saved_screen.dart';
import 'package:mishka_app/features/todo_lists/presentation/view/todo_lists_screen.dart';

import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenStorage.init();
  await AppPreferences.init();
  DioClient.instance.init();
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(
        AuthRemoteDataSource(ApiService()),
      )..add(const AuthLoadUserRequested()),
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
            // Scope must wrap the navigator subtree — an [InheritedWidget] above
            // [MaterialApp] is not visible to route widgets on all Flutter versions.
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
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          return const MainScreen();
        }
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const LoginScreen();
      },
    );
  }
}

enum MainTab {
  home,
  todo,
  category,
  saved,
  profile,
}

enum CategoryScreenType {
  main,
  aiTools,
  studyWithMe,
  ourCommunity,
  gamefaction,
  chatWithMishka,
}
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  MainTab currentTab = MainTab.home;

  CategoryScreenType categoryScreen = CategoryScreenType.main;

  void switchTab(MainTab tab) {
    setState(() {
      currentTab = tab;
      if (tab != MainTab.category) {
        categoryScreen = CategoryScreenType.main;
      }
    });
  }


  void openCategoryScreen(CategoryScreenType screen) {
    setState(() {
      currentTab = MainTab.category;
      categoryScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (currentTab) {
      case MainTab.home:
        body = HomeScreen(
          onTabSwitch: switchTab,
          onCategoryNavigate: openCategoryScreen,
        );
        break;
      case MainTab.todo:
        body = const TodoScreen();
        break;
      case MainTab.category:
        body = CategoryContainer(
          screen: categoryScreen,
          onNavigate: openCategoryScreen,
          onTabSwitch: switchTab,
        );
        break;
      case MainTab.saved:
        body = const SavedScreen();
        break;
      case MainTab.profile:
        body = const ProfileScreen();
        break;
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: body),
          const FloatingTimerBar(),
        ],
      ),
      bottomNavigationBar: MishkaBottomNav(
        currentIndex: currentTab.index,
        onTap: (i) => switchTab(MainTab.values[i]),
      ),
    );
  }
}
class CategoryContainer extends StatelessWidget {
  final CategoryScreenType screen;
  final void Function(CategoryScreenType) onNavigate;
  final void Function(MainTab)? onTabSwitch;

  const CategoryContainer({
    super.key,
    required this.screen,
    required this.onNavigate,
    this.onTabSwitch,
  });

  @override
  Widget build(BuildContext context) {
    switch (screen) {
      case CategoryScreenType.main:
        return CategoryScreen(
          onNavigate: onNavigate,
          onTabSwitch: onTabSwitch,
        );

      case CategoryScreenType.aiTools:
        return AiToolsScreen(
          onBack: () => onNavigate(CategoryScreenType.main),
          onNavigate: onNavigate,
        );

      case CategoryScreenType.studyWithMe:
        return StudyWithMishka(
          onBack: () => onNavigate(CategoryScreenType.main),
        );

      case CategoryScreenType.ourCommunity:
        return OurCommunity(
          onBack: () => onNavigate(CategoryScreenType.main),
        );

      case CategoryScreenType.gamefaction:
        return Gamification(
          onBack: () => onNavigate(CategoryScreenType.main),
        );

      case CategoryScreenType.chatWithMishka:
        return ChatWithMishkaScreen(
          onBack: () => onNavigate(CategoryScreenType.main),
        );


    }
  }
}
