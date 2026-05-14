import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../data/smart_timer_controller.dart';
import '../../data/study_session_manager.dart';
import '../../data/timer_model.dart';

class CameraModeScreen extends StatelessWidget {
  const CameraModeScreen({super.key});

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
                l10n.cameraOn,
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
              title: l10n.videoCallWithMishka,
              subtitle: l10n.cameraIsOn,
              icon: Icons.videocam,
              onTap: () => _startCallSession(context, cameraOn: true),
            ),
            SizedBox(height: 12.h),
            _CameraOptionCard(
              title: l10n.videoCallWithMishka,
              subtitle: l10n.cameraIsOff,
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
        builder: (_) => _CallStudySession(cameraOn: cameraOn),
      ),
    );
  }
}

class _CameraOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _CameraOptionCard({
    required this.title,
    required this.subtitle,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mainGold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: 11.sp,
                      color: AppColors.lightText,
                    ),
                  ),
                ],
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

class _CallStudySession extends StatefulWidget {
  final bool cameraOn;

  const _CallStudySession({required this.cameraOn});

  @override
  State<_CallStudySession> createState() => _CallStudySessionState();
}

class _CallStudySessionState extends State<_CallStudySession> {
  static const _model = StudyTimerModel('Call With Mishka', 25, 5, 15,
      modeId: 'call_with_mishka');

  final _manager = StudySessionManager.instance;
  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _isOnBreak = false;

  SmartTimerController get _controller => _manager.controller!;

  @override
  void initState() {
    super.initState();
    // Start session immediately — no waiting for user to press play
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _manager.startSession(_model);
      _manager.controller!.start();
    });
    _manager.addListener(_onTimerUpdate);

    if (widget.cameraOn) {
      _initCamera();
    }
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
      _cameraController = CameraController(front, ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (_) {
      if (mounted) setState(() => _cameraFailed = true);
    }
  }

  void _onTimerUpdate() {
    if (!mounted) return;
    if (!_manager.hasActiveSession) return;
    final onBreak = _controller.currentMode != TimerMode.study;
    if (onBreak != _isOnBreak) {
      setState(() => _isOnBreak = onBreak);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _manager.removeListener(_onTimerUpdate);
    _cameraController?.dispose();
    super.dispose();
  }

  DateTime? _breakStartedAt;

  void _takeBreak() {
    if (!_manager.hasActiveSession) return;
    _controller.pause();
    _controller.setMode(
      _controller.completedCycles % 4 == 3
          ? TimerMode.longBreak
          : TimerMode.shortBreak,
    );
    _controller.start();
    _breakStartedAt = DateTime.now();
    _manager.startCallBreak();
  }

  void _backToCall() {
    if (!_manager.hasActiveSession) return;
    // Report break duration to backend
    if (_breakStartedAt != null) {
      final seconds = DateTime.now().difference(_breakStartedAt!).inSeconds;
      _manager.endCallBreak(durationSeconds: seconds);
      _breakStartedAt = null;
    }
    _controller.pause();
    _controller.setMode(TimerMode.study);
    _controller.start();
  }

  void _endCall() {
    if (_breakStartedAt != null) {
      final seconds = DateTime.now().difference(_breakStartedAt!).inSeconds;
      _manager.endCallBreak(durationSeconds: seconds);
    }
    _manager.endSession(outcome: 'abandoned');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!_manager.hasActiveSession) {
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

    final isStudy = _controller.currentMode == TimerMode.study;
    final showCamera = widget.cameraOn && isStudy;

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
                        '${_controller.formattedTime} mins',
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
              ],
            ),
          ),
        ),
        // Buttons
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
          child: Column(
            children: [
              _CallActionButton(
                text: l10n.takeBreak,
                color: AppColors.blue,
                onTap: _takeBreak,
              ),
              SizedBox(height: 10.h),
              _CallActionButton(
                text: l10n.endCall,
                color: AppColors.red,
                onTap: _endCall,
              ),
            ],
          ),
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
              : '${l10n.timer}: ${_controller.formattedTime} mins',
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
          child: Column(
            children: [
              if (isBreak)
                _CallActionButton(
                  text: l10n.backToCall,
                  color: AppColors.blue,
                  onTap: _backToCall,
                )
              else
                _CallActionButton(
                  text: l10n.takeBreak,
                  color: AppColors.blue,
                  onTap: _takeBreak,
                ),
              SizedBox(height: 10.h),
              _CallActionButton(
                text: l10n.endCall,
                color: AppColors.red,
                onTap: _endCall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
