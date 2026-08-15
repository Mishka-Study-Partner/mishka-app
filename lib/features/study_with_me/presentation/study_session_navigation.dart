import 'package:flutter/material.dart';

import '../data/study_session_manager.dart';
import 'screens/camera_mode_screen.dart';
import 'screens/timer_session_screen.dart';

/// Opens the in-progress study session screen without resetting the timer.
void openActiveStudySessionScreen(BuildContext context) {
  final manager = StudySessionManager.instance;
  if (!manager.hasActiveSession || manager.isSessionScreenOpen) return;

  final model = manager.controller!.model;
  if (manager.isCallMode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CallStudySessionScreen(
          cameraOn: manager.callCameraOn,
          studentSubjectId: model.studentSubjectId,
          studentSubjectName: model.studentSubjectName,
        ),
      ),
    );
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => const TimerSessionScreen.resume(),
    ),
  );
}
