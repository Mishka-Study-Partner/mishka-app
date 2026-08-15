import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:mishka_app/core/network/api_service.dart';

import 'smart_timer_controller.dart';
import 'study_remote_data_source.dart';
import 'timer_model.dart';

/// Global singleton that keeps the study timer alive across navigation.
class StudySessionManager extends ChangeNotifier {
  StudySessionManager._();
  static final instance = StudySessionManager._();

  final StudyRemoteDataSource _remote = StudyRemoteDataSource(ApiService());

  SmartTimerController? _controller;
  String? _backendSessionId;
  bool _isCallMode = false;
  bool _callCameraOn = true;
  bool _sessionScreenOpen = false;

  SmartTimerController? get controller => _controller;
  String? get backendSessionId => _backendSessionId;
  bool get hasActiveSession => _controller != null;
  bool get isRunning => _controller?.isRunning ?? false;
  bool get isCallMode => _isCallMode;
  bool get callCameraOn => _callCameraOn;
  bool get isSessionScreenOpen => _sessionScreenOpen;

  /// Tracks whether a session screen route is on the stack (navigation guard only).
  /// Does not notify — avoids rebuild-during-build errors on [FloatingTimerBar].
  void markSessionScreenOpen(bool open) {
    _sessionScreenOpen = open;
  }

  void startSession(StudyTimerModel model, {bool callCameraOn = true}) {
    final previousId = _backendSessionId;
    if (previousId != null) {
      _remote.endSession(previousId, outcome: 'abandoned');
      _backendSessionId = null;
    }
    _controller?.dispose();
    _isCallMode = model.modeId == 'call_with_mishka';
    if (_isCallMode) {
      _callCameraOn = callCameraOn;
    }
    _controller = SmartTimerController(model);
    _controller!.addListener(_onUpdate);
    // Call mode uses call-break/* only; concentration uses pause/resume/advance-phase.
    if (_isCallMode) {
      _controller!.onPause = null;
      _controller!.onResume = null;
      _controller!.onPhaseAdvance = null;
    } else {
      _controller!.onPause = notifyPause;
      _controller!.onResume = notifyResume;
      _controller!.onPhaseAdvance = notifyAdvancePhase;
    }
    notifyListeners();
    _startBackendSession(model);
  }

  Future<void> _startBackendSession(StudyTimerModel model) async {
    final isCall = model.modeId == 'call_with_mishka';
    String? concentrationPreset;
    if (!isCall) {
      concentrationPreset = _normalizeConcentrationPreset(model.modeId);
    }
    _backendSessionId = await _remote.startSession(
      topLevelMode: isCall ? 'call_with_mishka' : 'concentration',
      concentrationPreset: concentrationPreset,
      customPresetId: model.customPresetId,
      studentSubjectId: model.studentSubjectId,
      focusMinutes: model.studyMinutes > 0 ? model.studyMinutes : null,
      shortBreakMinutes: model.shortBreakMinutes,
      longBreakMinutes: model.longBreakMinutes,
    );
    if (kDebugMode && _backendSessionId != null && model.studentSubjectId != null) {
      debugPrint(
        '📚 StudySession backend id=$_backendSessionId subject=${model.studentSubjectName ?? model.studentSubjectId}',
      );
    }
  }

  String _normalizeConcentrationPreset(String? modeId) {
    if (modeId == null || modeId.isEmpty) return 'custom';
    if (modeId == 'custom_timer') return 'custom';
    return modeId;
  }

  void endSession({String outcome = 'completed'}) {
    _controller?.removeListener(_onUpdate);
    _controller?.stop();
    final model = _controller?.model;
    _controller?.dispose();
    _controller = null;
    _isCallMode = false;
    _callCameraOn = true;
    _sessionScreenOpen = false;
    if (_backendSessionId != null) {
      final sessionId = _backendSessionId!;
      final subjectId = model?.studentSubjectId;
      _backendSessionId = null;
      unawaited(_finalizeBackendSession(sessionId, subjectId, outcome));
    }
    notifyListeners();
  }

  Future<void> _finalizeBackendSession(
    String sessionId,
    String? subjectId,
    String outcome,
  ) async {
    if (subjectId != null && subjectId.isNotEmpty) {
      await _remote.patchStudentSubject(sessionId, studentSubjectId: subjectId);
    }
    await _remote.endSession(sessionId, outcome: outcome);
  }

  /// Submit a check-in response to the backend.
  Future<void> submitCheckIn({
    required String kind,
    bool? responseBool,
    int? responseInt,
  }) async {
    if (_backendSessionId == null) return;
    await _remote.submitCheckIn(
      sessionId: _backendSessionId!,
      kind: kind,
      responseBool: responseBool,
      responseInt: responseInt,
    );
  }

  /// Notify backend of pause.
  void notifyPause() {
    if (_backendSessionId != null) {
      _remote.pauseSession(_backendSessionId!);
    }
  }

  /// Notify backend of resume.
  void notifyResume() {
    if (_backendSessionId != null) {
      _remote.resumeSession(_backendSessionId!);
    }
  }

  /// Notify backend of phase advance.
  void notifyAdvancePhase(
    TimerMode nextMode, {
    int? actualFocusMinutes,
    bool? completedFocusCycle,
  }) {
    if (_backendSessionId == null) return;
    final String phase;
    switch (nextMode) {
      case TimerMode.study:
        phase = 'focus';
      case TimerMode.shortBreak:
        phase = 'short_break';
      case TimerMode.longBreak:
        phase = 'long_break';
    }
    _remote.advancePhase(
      _backendSessionId!,
      nextPhase: phase,
      actualFocusMinutes: actualFocusMinutes,
      completedFocusCycle: completedFocusCycle,
    );
  }

  /// Start a call break (call_with_mishka only).
  Future<void> startCallBreak() async {
    if (_backendSessionId == null) return;
    await _remote.startCallBreak(_backendSessionId!);
  }

  /// End a call break.
  Future<void> endCallBreak({int? durationSeconds}) async {
    if (_backendSessionId == null) return;
    await _remote.endCallBreak(_backendSessionId!, durationSeconds: durationSeconds);
  }

  /// Upload aggregated ML posture stats (Camera With Mishka).
  Future<void> submitMlReportSummary(Map<String, dynamic> payload) async {
    final id = _backendSessionId;
    if (id == null) return;
    await _remote.submitMlReport(sessionId: id, payload: payload);
  }

  void _onUpdate() => notifyListeners();

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
