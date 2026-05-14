import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../data/smart_timer_controller.dart';
import '../../data/study_session_manager.dart';
import '../../data/timer_model.dart';
import '../widgets/study_checkin_popups.dart';

class TimerSessionScreen extends StatefulWidget {
  final StudyTimerModel model;

  const TimerSessionScreen({super.key, required this.model});

  @override
  State<TimerSessionScreen> createState() => _TimerSessionScreenState();
}

class _TimerSessionScreenState extends State<TimerSessionScreen> {
  final _manager = StudySessionManager.instance;
  Timer? _studyTickTimer;
  bool _stopped = false;

  /// Local controller used before user presses start (not yet in manager).
  SmartTimerController? _localController;

  /// Accumulated study seconds (excludes break time).
  int _studySeconds = 0;

  /// Which check-in popup to show next (cycles 0..3).
  int _checkInIndex = 0;

  /// Whether a popup is currently visible.
  bool _popupShowing = false;

  static const _checkInIntervalSeconds = 20 * 60; // 20 minutes

  /// Returns the active controller — either from manager or local pre-start.
  SmartTimerController? get _controllerOrNull =>
      _manager.controller ?? _localController;

  SmartTimerController get _controller => _controllerOrNull!;

  bool get _sessionRegistered => _manager.hasActiveSession;

  @override
  void initState() {
    super.initState();
    if (_manager.hasActiveSession) {
      _startStudyTick();
    } else {
      _localController = SmartTimerController(widget.model);
      _localController!.addListener(_onUpdate);
    }
    _manager.addListener(_onUpdate);
  }

  /// Safe check — if controller is somehow null (e.g., hot reload cleared state),
  /// re-create a local one.
  void _ensureController() {
    if (_controllerOrNull == null) {
      _localController = SmartTimerController(widget.model);
      _localController!.addListener(_onUpdate);
    }
  }

  @override
  void dispose() {
    _studyTickTimer?.cancel();
    _localController?.removeListener(_onUpdate);
    _localController?.dispose();
    _manager.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  /// Called the first time the user presses play.
  /// Registers the session with the global manager so the floating bar appears.
  void _registerAndStart() {
    _localController?.removeListener(_onUpdate);
    _localController?.dispose();
    _localController = null;
    _manager.startSession(widget.model);
    _manager.controller!.start();
    _startStudyTick();
  }

  void _startStudyTick() {
    _studyTickTimer?.cancel();
    _studyTickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_manager.hasActiveSession) return;
      final ctrl = _manager.controller;
      if (ctrl == null) return;

      if (ctrl.isRunning && ctrl.currentMode == TimerMode.study) {
        _studySeconds++;
        if (_studySeconds >= _checkInIntervalSeconds && !_popupShowing) {
          _studySeconds = 0;
          _showNextCheckIn();
        }
      }
    });
  }

  void _showNextCheckIn() {
    if (!mounted) return;
    _popupShowing = true;
    _controller.pause();
    showStudyCheckInPopup(
      context,
      currentIndex: _checkInIndex,
      onResponse: (type, response) {
        _popupShowing = false;
        _checkInIndex = (_checkInIndex + 1) % CheckInType.values.length;
        // Send correct field based on kind
        final isBool =
            type == CheckInType.stillThere || type == CheckInType.goodProgress;
        _manager.submitCheckIn(
          kind: checkInKindString(type),
          responseBool: isBool ? response as bool : null,
          responseInt: !isBool ? response as int : null,
        );
        if (_manager.hasActiveSession) {
          _controller.start();
        }
      },
    );
  }

  String _modeTitle(TimerMode mode, AppLocalizations l10n) {
    switch (mode) {
      case TimerMode.study:
        return l10n.studyTime;
      case TimerMode.shortBreak:
        return 'Your ${l10n.shortBreak}';
      case TimerMode.longBreak:
        return 'Your ${l10n.longBreak}';
    }
  }

  String _modeImage(TimerMode mode) {
    switch (mode) {
      case TimerMode.study:
        return 'assets/images/study_time_mishka.png';
      case TimerMode.shortBreak:
        return 'assets/images/short_break_mishka.png';
      case TimerMode.longBreak:
        return 'assets/images/long_break_mishka.png';
    }
  }

  Color _modeAccent(TimerMode mode) {
    switch (mode) {
      case TimerMode.study:
        return AppColors.mainGold;
      case TimerMode.shortBreak:
        return AppColors.blue;
      case TimerMode.longBreak:
        return AppColors.mainGold;
    }
  }

  Color _modeTitleColor(TimerMode mode) {
    switch (mode) {
      case TimerMode.study:
        return AppColors.mainGold;
      case TimerMode.shortBreak:
        return AppColors.blue;
      case TimerMode.longBreak:
        return AppColors.mainGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureController();
    final l10n = AppLocalizations.of(context)!;
    final mode = _controller.currentMode;
    final accent = _modeAccent(mode);
    final isCountUp = _controller.isCountUp;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: widget.model.title,
        topTitle: l10n.studyWithMe,
        showBack: true,
        showBottomBar: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Text(
                    _modeTitle(mode, l10n),
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: _modeTitleColor(mode),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: Image.asset(
                      _modeImage(mode),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),

          // Timer bar
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.screenBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: accent.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!_stopped) ...[
                    _CircleButton(
                      icon: _controller.isRunning
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: accent,
                      onTap: () {
                        if (_controller.isRunning) {
                          _controller.pause();
                        } else if (!_sessionRegistered) {
                          _registerAndStart();
                        } else {
                          _controller.start();
                        }
                      },
                    ),
                    Text(
                      _controller.formattedTime,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainDark,
                        letterSpacing: 2,
                      ),
                    ),
                    _CircleButton(
                      icon: isCountUp && mode == TimerMode.study
                          ? Icons.check
                          : Icons.stop,
                      color: accent,
                      onTap: () {
                        if (isCountUp && mode == TimerMode.study) {
                          _controller.finishStudy();
                          _controller.start();
                        } else {
                          _controller.pause();
                          setState(() => _stopped = true);
                        }
                      },
                    ),
                  ] else ...[
                    _CircleButton(
                      icon: Icons.play_arrow,
                      color: AppColors.green,
                      onTap: () {
                        setState(() => _stopped = false);
                        _controller.start();
                      },
                    ),
                    Text(
                      _controller.formattedTime,
                      style: TextStyle(
                        fontFamily: 'Pridi',
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainDark,
                        letterSpacing: 2,
                      ),
                    ),
                    _CircleButton(
                      icon: Icons.close,
                      color: AppColors.red,
                      onTap: () {
                        _manager.endSession(outcome: 'abandoned');
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Icon(icon, color: AppColors.white, size: 22.w),
      ),
    );
  }
}
