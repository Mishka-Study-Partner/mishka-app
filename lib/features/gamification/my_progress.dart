import 'package:flutter/material.dart';

import 'package:mishka_app/features/report/presentation/screens/your_report_screen.dart';

/// Category entry for study progress and weekly/monthly reports.
class MyProgress extends StatelessWidget {
  const MyProgress({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return YourReportScreen(onBack: onBack);
  }
}
