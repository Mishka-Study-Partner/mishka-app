import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mishka_app/core/network/token_storage.dart';
import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/features/Auth/view/bloc/auth_bloc.dart';
import 'package:mishka_app/app/main_shell.dart';
import 'package:mishka_app/features/education/presentation/screens/education_status_screen.dart';
import 'package:mishka_app/features/onboarding/presentation/screens/onboarding_intro_screen.dart';
import 'package:mishka_app/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:mishka_app/features/onboarding/presentation/screens/welcome_screen.dart';

/// Splash on every cold start, then route by auth + onboarding state.
class AppLaunchGate extends StatefulWidget {
  const AppLaunchGate({super.key});

  @override
  State<AppLaunchGate> createState() => _AppLaunchGateState();
}

class _AppLaunchGateState extends State<AppLaunchGate> {
  static const _splashDuration = Duration(milliseconds: 2200);

  bool _splashDone = false;
  bool _splashTimerStarted = false;

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  void _startSplashTimer() {
    if (_splashTimerStarted) return;
    _splashTimerStarted = true;
    Future<void>.delayed(_splashDuration, () {
      if (!mounted) return;
      setState(() => _splashDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_splashDone) {
      return const SplashScreen();
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          if (!AppPreferences.hasCompletedEducationSetup) {
            return const EducationStatusScreen();
          }
          return const MainScreen();
        }

        if (state is AuthLoading) {
          final hasToken =
              TokenStorage.token != null && TokenStorage.token!.isNotEmpty;
          if (hasToken) {
            return const SplashScreen();
          }
          return _unauthenticatedDestination();
        }

        return _unauthenticatedDestination();
      },
    );
  }

  Widget _unauthenticatedDestination() {
    if (!AppPreferences.hasCompletedOnboardingIntro) {
      return const OnboardingIntroScreen();
    }
    return const WelcomeScreen();
  }
}
