import 'package:flutter/material.dart';

import 'package:mishka_app/features/report/presentation/screens/your_report_screen.dart';

/// Progress report screen (replaces gamification placeholder).
class Gamification extends StatelessWidget {
  const Gamification({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return YourReportScreen(onBack: onBack);
  }
}
