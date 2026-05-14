import 'package:flutter/foundation.dart';
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

  SmartTimerController? get controller => _controller;
  String? get backendSessionId => _backendSessionId;
  bool get hasActiveSession => _controller != null;
  bool get isRunning => _controller?.isRunning ?? false;

  void startSession(StudyTimerModel model) {
    _controller?.dispose();
    _controller = SmartTimerController(model);
    _controller!.addListener(_onUpdate);
    _controller!.onPause = notifyPause;
    _controller!.onResume = notifyResume;
    _controller!.onPhaseAdvance = notifyAdvancePhase;
    notifyListeners();
    _startBackendSession(model);
  }

  Future<void> _startBackendSession(StudyTimerModel model) async {
    final isCall = model.modeId == 'call_with_mishka';
    String? concentrationPreset;
    if (!isCall) {
      // Map modeId to the backend concentrationPreset enum value
      concentrationPreset = model.modeId ?? 'custom';
    }
    _backendSessionId = await _remote.startSession(
      topLevelMode: isCall ? 'call_with_mishka' : 'concentration',
      concentrationPreset: concentrationPreset,
      focusMinutes: model.studyMinutes > 0 ? model.studyMinutes : null,
      shortBreakMinutes: model.shortBreakMinutes,
      longBreakMinutes: model.longBreakMinutes,
    );
  }

  void endSession({String outcome = 'completed'}) {
    _controller?.removeListener(_onUpdate);
    _controller?.stop();
    _controller?.dispose();
    _controller = null;
    if (_backendSessionId != null) {
      _remote.endSession(_backendSessionId!, outcome: outcome);
      _backendSessionId = null;
    }
    notifyListeners();
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
  void notifyAdvancePhase(TimerMode nextMode) {
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
    _remote.advancePhase(_backendSessionId!, nextPhase: phase);
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

  void _onUpdate() => notifyListeners();

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
