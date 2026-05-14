import 'dart:async';

import 'package:flutter/foundation.dart';

import 'timer_model.dart';

class SmartTimerController extends ChangeNotifier {
  Timer? _timer;
  TimerMode _currentMode = TimerMode.study;
  late StudyTimerModel _model;
  Duration _remaining = Duration.zero;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;
  int _completedCycles = 0;

  /// Lifecycle callbacks for backend sync.
  VoidCallback? onPause;
  VoidCallback? onResume;
  void Function(TimerMode nextPhase)? onPhaseAdvance;

  SmartTimerController(StudyTimerModel model) : _model = model {
    _remaining = model.durationFor(TimerMode.study);
  }

  TimerMode get currentMode => _currentMode;
  Duration get remaining => _remaining;
  Duration get elapsed => _elapsed;
  bool get isRunning => _isRunning;
  int get completedCycles => _completedCycles;
  StudyTimerModel get model => _model;

  /// Whether the current mode counts up (stopwatch) instead of down.
  bool get isCountUp => _model.durationFor(_currentMode).inSeconds == 0;

  String get formattedTime {
    final duration = isCountUp ? _elapsed : _remaining;
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '${h.toString().padLeft(2, '0')} : $m : $s';
    return '$m : $s';
  }

  double get progress {
    if (isCountUp) {
      // For count-up, show a looping progress every 30 minutes
      final cycleSeconds = 30 * 60;
      return (_elapsed.inSeconds % cycleSeconds) / cycleSeconds;
    }
    final total = _model.durationFor(_currentMode).inSeconds;
    if (total == 0) return 0;
    return 1.0 - (_remaining.inSeconds / total);
  }

  void setMode(TimerMode mode) {
    _timer?.cancel();
    _isRunning = false;
    _wasPausedByUser = false;
    _currentMode = mode;
    _remaining = _model.durationFor(mode);
    _elapsed = Duration.zero;
    onPhaseAdvance?.call(mode);
    notifyListeners();
  }

  bool _wasPausedByUser = false;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isCountUp) {
        _elapsed += const Duration(seconds: 1);
        notifyListeners();
      } else {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
          notifyListeners();
        } else {
          _onTimerComplete();
        }
      }
    });
    if (_wasPausedByUser) {
      onResume?.call();
      _wasPausedByUser = false;
    }
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _isRunning = false;
    _wasPausedByUser = true;
    onPause?.call();
    notifyListeners();
  }

  /// For count-up modes: manually finish the study phase and move to break.
  void finishStudy() {
    if (_currentMode == TimerMode.study && isCountUp) {
      _timer?.cancel();
      _isRunning = false;
      _completedCycles++;
      if (_completedCycles % 4 == 0) {
        setMode(TimerMode.longBreak);
      } else {
        setMode(TimerMode.shortBreak);
      }
    }
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
    _remaining = _model.durationFor(_currentMode);
    _elapsed = Duration.zero;
    notifyListeners();
  }

  void _onTimerComplete() {
    _timer?.cancel();
    _isRunning = false;
    if (_currentMode == TimerMode.study) {
      _completedCycles++;
      if (_completedCycles % 4 == 0) {
        setMode(TimerMode.longBreak);
      } else {
        setMode(TimerMode.shortBreak);
      }
    } else {
      setMode(TimerMode.study);
    }
    // Auto-start the next phase
    start();
  }

  void updateModel(StudyTimerModel newModel) {
    _model = newModel;
    _remaining = newModel.durationFor(_currentMode);
    _elapsed = Duration.zero;
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
