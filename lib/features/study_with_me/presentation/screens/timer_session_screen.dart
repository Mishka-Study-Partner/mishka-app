import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/navigation/safe_navigation.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../data/smart_timer_controller.dart';
import '../../data/study_session_manager.dart';
import '../../data/timer_model.dart';
import '../widgets/study_checkin_popups.dart';

class TimerSessionScreen extends StatefulWidget {
  final StudyTimerModel? model;

  const TimerSessionScreen({super.key, required StudyTimerModel model})
      : model = model;

  /// Re-open the global in-progress session without resetting the timer.
  const TimerSessionScreen.resume({super.key}) : model = null;

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

  StudyTimerModel get _displayModel =>
      _sessionRegistered ? _manager.controller!.model : widget.model!;

  @override
  void initState() {
    super.initState();
    _manager.markSessionScreenOpen(true);
    if (_manager.hasActiveSession) {
      _startStudyTick();
    } else {
      final model = widget.model;
      if (model == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) SafeNavigator.popIfPossible(context);
        });
      } else {
        _localController = SmartTimerController(model);
        _localController!.addListener(_onUpdate);
      }
    }
    _manager.addListener(_onUpdate);
  }

  /// Safe check — only create a local pre-start controller when no global session exists.
  void _ensureController() {
    if (_manager.hasActiveSession || widget.model == null) return;
    if (_localController != null) return;
    _localController = SmartTimerController(widget.model!);
    _localController!.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _studyTickTimer?.cancel();
    _localController?.removeListener(_onUpdate);
    _localController?.dispose();
    _manager.removeListener(_onUpdate);
    _manager.markSessionScreenOpen(false);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  /// Called the first time the user presses play.
  /// Registers the session with the global manager so the floating bar appears.
  void _registerAndStart() {
    final model = widget.model;
    if (model == null) return;

    final local = _localController;
    local?.removeListener(_onUpdate);
    _localController = null;

    _manager.startSession(model);
    final registered = _manager.controller!;
    if (local != null) {
      registered.adoptStateFrom(local);
      local.dispose();
    }
    if (!registered.isRunning) {
      registered.start();
    }
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

  bool get _isPreStart => !_sessionRegistered && !_stopped;

  bool get _isStudyRunning =>
      !_stopped &&
      _controller.isRunning &&
      _controller.currentMode == TimerMode.study;

  void _onStart() {
    if (_sessionRegistered) {
      _controller.start();
    } else {
      _registerAndStart();
    }
    setState(() => _stopped = false);
  }

  void _onStop() {
    _controller.pause();
    setState(() => _stopped = true);
  }

  void _onBreak() {
    if (_controller.currentMode != TimerMode.study) return;
    _controller.skipToBreak();
    _controller.start();
    setState(() => _stopped = false);
  }

  void _onContinue() {
    setState(() => _stopped = false);
    _controller.start();
  }

  void _onEndSession() {
    SafeNavigator.popIfPossible(context);
    _manager.endSession(outcome: 'abandoned');
  }

  Widget _buildTimerBarRow(Color accent) {
    final Widget left;
    final Widget right;

    if (_isPreStart) {
      left = _CircleButton(
        icon: Icons.play_arrow,
        color: accent,
        onTap: _onStart,
      );
      right = SizedBox(width: 42.w);
    } else if (_stopped) {
      left = _CircleButton(
        icon: Icons.play_arrow,
        color: AppColors.green,
        onTap: _onContinue,
      );
      right = _CircleButton(
        icon: Icons.close,
        color: AppColors.red,
        onTap: _onEndSession,
      );
    } else if (_isStudyRunning) {
      left = _CircleButton(
        icon: Icons.free_breakfast,
        color: AppColors.blue,
        onTap: _onBreak,
      );
      right = _CircleButton(
        icon: Icons.stop,
        color: accent,
        onTap: _onStop,
      );
    } else {
      left = !_controller.isRunning
          ? _CircleButton(
              icon: Icons.play_arrow,
              color: AppColors.green,
              onTap: _onContinue,
            )
          : SizedBox(width: 42.w);
      right = _CircleButton(
        icon: Icons.close,
        color: AppColors.red,
        onTap: _onEndSession,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        left,
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
        right,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_sessionRegistered && widget.model == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    _ensureController();
    if (_controllerOrNull == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final l10n = AppLocalizations.of(context)!;
    final mode = _controller.currentMode;
    final accent = _modeAccent(mode);

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: _displayModel.title,
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
            padding: EdgeInsets.fromLTRB(
              24.w,
              0,
              24.w,
              24.h + AppSizes.screenEndPadding,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.screenBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: accent.withValues(alpha: 0.5)),
              ),
              child: _buildTimerBarRow(accent),
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
