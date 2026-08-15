import 'dart:async';
import 'dart:io' show Platform;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/navigation/safe_navigation.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../data/ml_service_config.dart';
import '../../data/smart_timer_controller.dart';
import '../../data/study_monitor_response.dart';
import '../../data/study_posture_alert_sound.dart';
import '../../data/study_posture_monitor.dart';
import '../../data/study_session_manager.dart';
import '../../data/timer_model.dart';

class CameraModeScreen extends StatelessWidget {
  const CameraModeScreen({
    super.key,
    this.studentSubjectId,
    this.studentSubjectName,
  });

  final String? studentSubjectId;
  final String? studentSubjectName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.cameraMode,
        topTitle: l10n.studyWithMe,
        showBack: true,
        showBottomBar: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Center(
              child: Text(
                l10n.callMishka,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: AppSizes.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  color: AppColors.mainDark,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            _CameraOptionCard(
              title: l10n.cameraIsOn,
              icon: Icons.videocam,
              onTap: () => _startCallSession(context, cameraOn: true),
            ),
            SizedBox(height: 12.h),
            _CameraOptionCard(
              title: l10n.cameraIsOff,
              icon: Icons.videocam_off,
              onTap: () => _startCallSession(context, cameraOn: false),
            ),
          ],
        ),
      ),
    );
  }

  void _startCallSession(BuildContext context, {required bool cameraOn}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CallStudySessionScreen(
          cameraOn: cameraOn,
          studentSubjectId: studentSubjectId,
          studentSubjectName: studentSubjectName,
        ),
      ),
    );
  }
}

class _CameraOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _CameraOptionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.mainGold.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.mainGold),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.mainGold, size: 24.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mainGold,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14.w, color: AppColors.mainGold),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Call Study Session — the actual video-call-style study screen
// ---------------------------------------------------------------------------

class CallStudySessionScreen extends StatefulWidget {
  final bool cameraOn;
  final String? studentSubjectId;
  final String? studentSubjectName;

  const CallStudySessionScreen({
    super.key,
    required this.cameraOn,
    this.studentSubjectId,
    this.studentSubjectName,
  });

  @override
  State<CallStudySessionScreen> createState() => _CallStudySessionState();
}

enum _MlAvailability { unknown, checking, available, unavailable }

class _CallStudySessionState extends State<CallStudySessionScreen> {
  late final StudyTimerModel _model;
  bool _sessionInitialized = false;

  final _manager = StudySessionManager.instance;
  final _postureMonitor = StudyPostureMonitor();
  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _isOnBreak = false;
  bool _isCalibrating = false;
  bool _awaitingStart = true;
  bool _sessionPaused = false;
  _MlAvailability _mlAvailability = _MlAvailability.unknown;
  Timer? _calibrationTimer;
  StudyPostureKind? _previousPostureKind;
  DateTime? _lastPostureAlertAt;
  static const _postureAlertCooldown = Duration(seconds: 4);

  SmartTimerController? _localController;

  SmartTimerController? get _controllerOrNull =>
      _manager.controller ?? _localController;

  void _ensureLocalController() {
    if (_manager.hasActiveSession || _localController != null) return;
    _localController = SmartTimerController(_model);
    _localController!.addListener(_onTimerUpdate);
    _awaitingStart = true;
    _sessionPaused = false;
    _isOnBreak = false;
  }

  SmartTimerController get _controller {
    final existing = _controllerOrNull;
    if (existing != null) return existing;
    _ensureLocalController();
    return _localController!;
  }

  String _timerDisplayText() {
    final time = _controller.formattedTime;
    final onOpenEndedStudy =
        _controller.currentMode == TimerMode.study && _controller.isCountUp;
    return onOpenEndedStudy ? time : '$time mins';
  }

  @override
  void initState() {
    super.initState();
    _manager.markSessionScreenOpen(true);
    _postureMonitor.addListener(_onPostureUpdate);
    _manager.addListener(_onTimerUpdate);

    if (widget.cameraOn) {
      _initCamera();
      unawaited(_checkMlAvailability());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sessionInitialized) return;
    _sessionInitialized = true;

    final l10n = AppLocalizations.of(context)!;
    _model = StudyTimerModel(
      l10n.callMishka,
      0,
      5,
      15,
      modeId: 'call_with_mishka',
      studentSubjectId: widget.studentSubjectId,
      studentSubjectName: widget.studentSubjectName,
    );

    if (_manager.hasActiveSession && _manager.isCallMode) {
      _awaitingStart = false;
      _sessionPaused = !_manager.controller!.isRunning;
      _isOnBreak = _manager.controller!.currentMode != TimerMode.study;
    } else {
      _localController = SmartTimerController(_model);
      _localController!.addListener(_onTimerUpdate);
      _awaitingStart = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_manager.hasActiveSession && _manager.isCallMode) {
        if (!_isOnBreak &&
            !_sessionPaused &&
            widget.cameraOn &&
            _cameraReady) {
          _beginPostureCalibration();
        }
      }
    });
  }

  Future<void> _checkMlAvailability() async {
    if (!widget.cameraOn || !_awaitingStart) return;
    setState(() => _mlAvailability = _MlAvailability.checking);
    final available = await StudyPostureMonitor.checkAvailability();
    if (!mounted || !_awaitingStart) return;
    setState(
      () => _mlAvailability =
          available ? _MlAvailability.available : _MlAvailability.unavailable,
    );
  }

  bool _cameraFailed = false;

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _cameraFailed = true);
        return;
      }
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.jpeg
            : ImageFormatGroup.bgra8888,
      );
      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(FlashMode.off);
      if (!mounted) return;
      setState(() => _cameraReady = true);
      if (!_awaitingStart && !_sessionPaused && !_isOnBreak) {
        _beginPostureCalibration();
      }
    } catch (_) {
      if (mounted) setState(() => _cameraFailed = true);
    }
  }

  void _beginPostureCalibration() {
    if (!widget.cameraOn ||
        _isOnBreak ||
        _cameraController == null ||
        !_cameraReady) {
      return;
    }
    _calibrationTimer?.cancel();
    unawaited(_stopPostureMonitor());
    _previousPostureKind = null;
    _lastPostureAlertAt = null;
    setState(() => _isCalibrating = true);
    _calibrationTimer = Timer(MlServiceConfig.calibrationDuration, () {
      if (!mounted) return;
      setState(() => _isCalibrating = false);
      unawaited(_startPostureMonitorIfNeeded());
    });
  }

  void _cancelCalibration() {
    _calibrationTimer?.cancel();
    _calibrationTimer = null;
    if (_isCalibrating && mounted) {
      setState(() => _isCalibrating = false);
    }
  }

  Future<void> _startPostureMonitorIfNeeded() async {
    if (!widget.cameraOn ||
        _isOnBreak ||
        _cameraController == null ||
        !_cameraReady) {
      return;
    }
    await _postureMonitor.start(_cameraController!);
  }

  Future<void> _stopPostureMonitor() async {
    await _postureMonitor.stop();
  }

  void _onPostureUpdate() {
    if (!mounted) return;
    _maybePlayPostureAlert();
    setState(() {});
  }

  void _maybePlayPostureAlert() {
    if (!widget.cameraOn || _isOnBreak || _isCalibrating) return;

    final kind = _postureMonitor.postureKind;
    final previous = _previousPostureKind;
    _previousPostureKind = kind;

    final level = kind.alertLevel;
    if (level == null) return;

    final previousLevel = previous?.alertLevel;
    final enteredAlert = previousLevel == null;
    final escalated = previousLevel == StudyPostureAlertLevel.warning &&
        level == StudyPostureAlertLevel.critical;
    if (!enteredAlert && !escalated) return;

    final now = DateTime.now();
    if (_lastPostureAlertAt != null &&
        now.difference(_lastPostureAlertAt!) < _postureAlertCooldown) {
      return;
    }
    _lastPostureAlertAt = now;
    unawaited(StudyPostureAlertSound.play(level));
  }

  void _onTimerUpdate() {
    if (!mounted) return;
    if (_manager.hasActiveSession) {
      final ctrl = _manager.controller;
      if (ctrl == null) {
        setState(() {});
        return;
      }
      final onBreak = ctrl.currentMode != TimerMode.study;
      if (onBreak != _isOnBreak) {
        setState(() {
          _isOnBreak = onBreak;
          if (!onBreak) _sessionPaused = false;
        });
        if (onBreak) {
          _cancelCalibration();
          unawaited(_stopPostureMonitor());
        } else if (widget.cameraOn && _cameraReady && !_sessionPaused) {
          _beginPostureCalibration();
        }
      } else {
        setState(() {});
      }
    } else if (_localController == null) {
      _ensureLocalController();
      setState(() {});
    } else {
      setState(() {});
    }
  }

  void _startCall() {
    if (!_awaitingStart) return;

    final local = _localController;
    local?.removeListener(_onTimerUpdate);

    _manager.startSession(_model, callCameraOn: widget.cameraOn);
    final registered = _manager.controller!;
    if (local != null) {
      registered.adoptStateFrom(local);
      local.dispose();
    }
    _localController = null;
    if (!registered.isRunning) {
      registered.start();
    }

    setState(() {
      _awaitingStart = false;
      _sessionPaused = false;
    });

    if (widget.cameraOn && _cameraReady) {
      _beginPostureCalibration();
    }
  }

  void _stopCall() {
    _controller.pause();
    _cancelCalibration();
    unawaited(_stopPostureMonitor());
    setState(() => _sessionPaused = true);
  }

  void _continueCall() {
    setState(() => _sessionPaused = false);
    _controller.start();
    if (!_isOnBreak && widget.cameraOn && _cameraReady) {
      _beginPostureCalibration();
    }
  }

  Widget _buildCallIconControls() {
    if (_awaitingStart) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CircleIconButton(
            icon: Icons.play_arrow,
            color: AppColors.mainGold,
            onTap: _startCall,
          ),
        ],
      );
    }

    if (_sessionPaused) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CircleIconButton(
            icon: Icons.play_arrow,
            color: AppColors.green,
            onTap: _continueCall,
          ),
          _CircleIconButton(
            icon: Icons.close,
            color: AppColors.red,
            onTap: _endCall,
          ),
        ],
      );
    }

    if (_isOnBreak) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CircleIconButton(
            icon: Icons.videocam,
            color: AppColors.blue,
            onTap: _backToCall,
          ),
          _CircleIconButton(
            icon: Icons.close,
            color: AppColors.red,
            onTap: _endCall,
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CircleIconButton(
          icon: Icons.free_breakfast,
          color: AppColors.blue,
          onTap: _takeBreak,
        ),
        _CircleIconButton(
          icon: Icons.stop,
          color: AppColors.mainGold,
          onTap: _stopCall,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _manager.removeListener(_onTimerUpdate);
    _manager.markSessionScreenOpen(false);
    _localController?.removeListener(_onTimerUpdate);
    _localController?.dispose();
    _postureMonitor.removeListener(_onPostureUpdate);
    _cancelCalibration();
    _previousPostureKind = null;
    _lastPostureAlertAt = null;
    unawaited(StudyPostureAlertSound.dispose());
    _postureMonitor.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  DateTime? _breakStartedAt;

  void _takeBreak() {
    if (_awaitingStart || _sessionPaused) return;
    if (!_manager.hasActiveSession || _isOnBreak) return;
    _cancelCalibration();
    unawaited(_stopPostureMonitor());
    _breakStartedAt = DateTime.now();
    _manager.startCallBreak();
    _controller.setMode(
      _controller.completedCycles % 4 == 3
          ? TimerMode.longBreak
          : TimerMode.shortBreak,
    );
    _controller.start();
    setState(() => _isOnBreak = true);
  }

  void _backToCall() {
    if (!_manager.hasActiveSession || !_isOnBreak) return;
    if (_breakStartedAt != null) {
      final seconds = DateTime.now().difference(_breakStartedAt!).inSeconds;
      _manager.endCallBreak(durationSeconds: seconds.clamp(0, 86400));
      _breakStartedAt = null;
    }
    _controller.setMode(TimerMode.study);
    _controller.start();
    setState(() {
      _isOnBreak = false;
      _sessionPaused = false;
    });
    if (widget.cameraOn && _cameraReady) {
      _beginPostureCalibration();
    }
  }

  Future<void> _endCall() async {
    _cancelCalibration();
    if (_breakStartedAt != null) {
      final seconds = DateTime.now().difference(_breakStartedAt!).inSeconds;
      _manager.endCallBreak(durationSeconds: seconds);
    }
    await _stopPostureMonitor();
    if (widget.cameraOn && _postureMonitor.sampleCount > 0) {
      await _manager.submitMlReportSummary(
        _postureMonitor.buildMlReportPayload(),
      );
    }
    if (!mounted) return;
    SafeNavigator.popIfPossible(context);
    _manager.endSession(outcome: 'abandoned');
  }

  String _focusStatusLabel(AppLocalizations l10n) {
    if (_awaitingStart && widget.cameraOn) {
      return switch (_mlAvailability) {
        _MlAvailability.checking => l10n.studyFocusConnecting,
        _MlAvailability.unavailable => l10n.studyFocusOffline,
        _ => l10n.startCallWithMishka,
      };
    }
    if (!_postureMonitor.isConnected && !_postureMonitor.isConnecting) {
      return l10n.studyFocusOffline;
    }
    if (_postureMonitor.isConnecting) {
      return l10n.studyFocusConnecting;
    }
    return switch (_postureMonitor.postureKind) {
      StudyPostureKind.calibrating => l10n.studyMlCalibrating,
      StudyPostureKind.focusing => l10n.studyMlFocusing,
      StudyPostureKind.badPosture => l10n.studyMlBadPosture,
      StudyPostureKind.lookingAway => l10n.studyMlLookingAway,
      StudyPostureKind.noUser => l10n.studyMlNoUser,
      StudyPostureKind.error => l10n.studyMlError,
      StudyPostureKind.unknown => l10n.studyFocusUnknown,
    };
  }

  Color _focusStatusColor() {
    if (_awaitingStart && widget.cameraOn) {
      return switch (_mlAvailability) {
        _MlAvailability.unavailable => AppColors.greyText,
        _MlAvailability.checking => AppColors.mainGold,
        _ => AppColors.mainGold,
      };
    }
    if (!_postureMonitor.isConnected && !_postureMonitor.isConnecting) {
      return AppColors.greyText;
    }
    final mlColor = _postureMonitor.indicatorColor;
    if (mlColor != null) return mlColor;
    return switch (_postureMonitor.postureKind) {
      StudyPostureKind.calibrating => AppColors.mainGold,
      StudyPostureKind.focusing => AppColors.green,
      StudyPostureKind.badPosture => AppColors.mainGold,
      StudyPostureKind.lookingAway => AppColors.mainGold,
      StudyPostureKind.noUser => AppColors.red,
      StudyPostureKind.error => AppColors.red,
      StudyPostureKind.unknown => AppColors.greyText,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _ensureLocalController();
    final ctrl = _controllerOrNull;
    if (ctrl == null) {
      return Scaffold(
        backgroundColor: AppColors.screenBackground,
        appBar: MishkaAppBar(
          title: l10n.cameraMode,
          topTitle: l10n.studyWithMe,
          showBack: true,
          showBottomBar: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isStudy = ctrl.currentMode == TimerMode.study;
    final showCamera = widget.cameraOn && isStudy && !_sessionPaused;

    return Scaffold(
      backgroundColor: showCamera ? AppColors.screenBackground : AppColors.mainDark,
      appBar: MishkaAppBar(
        title: l10n.cameraMode,
        topTitle: l10n.studyWithMe,
        showBack: true,
        showBottomBar: false,
      ),
      body: showCamera ? _buildCameraOnStudy(l10n) : _buildSingleImage(l10n),
    );
  }

  /// Camera ON + Study mode: two images — Mishka top-left + camera below
  Widget _buildCameraOnStudy(AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Stack(
              children: [
                // Full-area camera preview or fallback
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: _cameraReady && _cameraController != null
                        ? CameraPreview(_cameraController!)
                        : _cameraFailed
                            ? Image.asset(
                                'assets/images/study_call_mode.png',
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.mainDark.withValues(alpha: 0.1),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                  ),
                ),
                // Mishka image — top left with green border
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    width: 100.w,
                    height: 130.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.green, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: Image.asset(
                        'assets/images/study_call_mode.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Timer — top right
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${l10n.timer}:',
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainGold,
                        ),
                      ),
                      Text(
                        _timerDisplayText(),
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainGold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Posture calibration or ML focus status — bottom center
                if (_isCalibrating)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: _PostureCalibrationOverlay(
                        message: l10n.studyPostureCalibration,
                      ),
                    ),
                  )
                else
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    bottom: 12.h,
                    child: _FocusStatusChip(
                      label: _focusStatusLabel(l10n),
                      color: _focusStatusColor(),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Buttons
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
          child: _buildCallIconControls(),
        ),
      ],
    );
  }

  /// Camera OFF or Break mode: single Mishka image full screen
  Widget _buildSingleImage(AppLocalizations l10n) {
    final isBreak = _controller.currentMode != TimerMode.study;
    return Column(
      children: [
        SizedBox(height: 12.h),
        // Timer text
        Text(
          isBreak
              ? '${l10n.breakTime}: ${_controller.formattedTime} mins'
              : '${l10n.timer}: ${_timerDisplayText()}',
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        SizedBox(height: 12.h),
        // Mishka image
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.asset(
                'assets/images/study_call_mode.png',
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        // Buttons
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
          child: _buildCallIconControls(),
        ),
      ],
    );
  }
}

class _PostureCalibrationOverlay extends StatelessWidget {
  const _PostureCalibrationOverlay({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mainDark.withValues(alpha: 0.55),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.mainGold, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36.w,
                height: 36.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.mainGold,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: 15.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mainDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusStatusChip extends StatelessWidget {
  const _FocusStatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.visibility, color: color, size: 18.w),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                label,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52.w,
        height: 52.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Icon(icon, color: AppColors.white, size: 26.w),
      ),
    );
  }
}
