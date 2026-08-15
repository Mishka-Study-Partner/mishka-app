import 'package:flutter/material.dart';

import 'package:mishka_app/features/gamification/presentation/screens/gamification_hub_screen.dart';

/// Badges, rewards, points, and challenges hub.
class Gamification extends StatelessWidget {
  const Gamification({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return GamificationHubScreen(onBack: onBack);
  }
}
