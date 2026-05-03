import 'package:flutter/material.dart';

import '../widgets/calender.dart';
class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskDates = [
      DateTime(2025, 12, 3),
      DateTime(2025, 12, 7),
      DateTime(2025, 12, 18),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomCalendar(
          taskDates: taskDates,
        ),
      ),
    );
  }
}
