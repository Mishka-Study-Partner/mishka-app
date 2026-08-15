import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/network/api_service.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../l10n/app_localizations.dart';
import 'data/study_remote_data_source.dart';
import 'data/timer_model.dart';
import 'presentation/screens/camera_mode_screen.dart';
import 'presentation/screens/custom_timer_screen.dart';
import 'presentation/screens/timer_session_screen.dart';
import 'package:mishka_app/features/student_subjects/study_subject_launch.dart';

class StudyWithMishka extends StatefulWidget {
  final VoidCallback? onBack;

  const StudyWithMishka({
    super.key,
    this.onBack,
  });

  @override
  State<StudyWithMishka> createState() => _StudyWithMishkaState();
}

class _StudyWithMishkaState extends State<StudyWithMishka> {
  bool _concentrationExpanded = false;
  final StudyRemoteDataSource _remote = StudyRemoteDataSource(ApiService());
  StudyCatalog? _catalog;
  bool _catalogLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      final catalog = await _remote.getCatalog();
      if (!mounted) return;
      setState(() => _catalog = catalog);
    } catch (e) {
      debugPrint('📚 StudyWithMishka: catalog fetch failed ($e)');
    } finally {
      if (mounted) setState(() => _catalogLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.studyWithMe,
        showBack: true,
        showBottomBar: false,
        onBackTap: widget.onBack,
      ),
      body: SingleChildScrollView(
        padding: AppScrollInsets.page(horizontal: AppSizes.paddingMedium, top: AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            Center(
              child: Text(
                l10n.chooseYourStudyMode,
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
            _buildCameraModeTile(l10n),
            SizedBox(height: 12.h),
            _buildConcentrationModeTile(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraModeTile(AppLocalizations l10n) {
    return _StudyOptionTile(
      title: l10n.cameraMode,
      trailing: Icon(Icons.arrow_forward_ios, size: 16.w, color: AppColors.mainGold),
      onTap: () {
        StudySubjectLaunch.pickSubjectAndStart(
          context,
          onStart: (subjectId, subjectName) async {
            if (!context.mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CameraModeScreen(
                  studentSubjectId: subjectId,
                  studentSubjectName: subjectName,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildConcentrationModeTile(AppLocalizations l10n) {
    final hasBackendPresets =
        _catalog != null && _catalog!.concentrationPresets.isNotEmpty;

    final regularPresets = hasBackendPresets
        ? _catalog!.concentrationPresets.where((p) => !p.isCustom).toList()
        : <ConcentrationPreset>[];

    // Fallback local presets when catalog fails
    final displayPresets = regularPresets.isNotEmpty
        ? regularPresets
            .map((p) => _PresetDisplay(
                  title: p.label,
                  modeId: p.id,
                  studyMinutes: p.id == 'flowtime' ? 0 : p.studyMinutes,
                  shortBreakMinutes: p.shortBreakMinutes,
                  longBreakMinutes: p.longBreakMinutes,
                  tagline: p.tagline,
                  onTap: () => _startPresetTimer(p.toTimerModel()),
                ))
            .toList()
        : StudyTimerModel.presets
            .map((p) => _PresetDisplay(
                  title: p.title,
                  modeId: p.modeId,
                  studyMinutes: p.studyMinutes,
                  shortBreakMinutes: p.shortBreakMinutes,
                  longBreakMinutes: p.longBreakMinutes,
                  onTap: () => _startPresetTimer(p),
                ))
            .toList();

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _concentrationExpanded = !_concentrationExpanded;
            });
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.mainGold,
              borderRadius: _concentrationExpanded
                  ? BorderRadius.vertical(top: Radius.circular(AppSizes.radiusSmall))
                  : BorderRadius.circular(AppSizes.radiusSmall),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.concentrationMode,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
                if (_catalogLoading)
                  SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                else
                  Icon(
                    _concentrationExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: AppColors.white,
                  ),
              ],
            ),
          ),
        ),
        if (_concentrationExpanded)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.stroke),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppSizes.radiusSmall),
              ),
              color: AppColors.white,
            ),
            child: Column(
              children: [
                ...displayPresets.map((preset) {
                  return _PresetTile(preset: preset, l10n: l10n);
                }),
                const Divider(height: 1),
                ListTile(
                  title: Text(
                    l10n.customTimer,
                    style: const TextStyle(
                        fontFamily: 'Pridi', color: AppColors.mainDark),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 14.w, color: AppColors.greyText),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CustomTimerScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _startPresetTimer(StudyTimerModel model) {
    StudySubjectLaunch.pickSubjectAndStart(
      context,
      onStart: (subjectId, subjectName) async {
        if (!context.mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TimerSessionScreen(
              model: model.withStudentSubject(subjectId, name: subjectName),
            ),
          ),
        );
      },
    );
  }
}

class _PresetDisplay {
  final String title;
  final String? modeId;
  final int studyMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final String? tagline;
  final VoidCallback onTap;

  const _PresetDisplay({
    required this.title,
    this.modeId,
    required this.studyMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    this.tagline,
    required this.onTap,
  });

  bool get isCountUp => studyMinutes == 0 || modeId == 'flowtime';
}

class _PresetTile extends StatelessWidget {
  final _PresetDisplay preset;
  final AppLocalizations l10n;

  const _PresetTile({required this.preset, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: preset.onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preset.title,
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          fontWeight: FontWeight.w600,
                          fontSize: AppSizes.fontSizeMedium,
                          color: AppColors.mainDark,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      _timerRow(
                        l10n.studyTime,
                        preset.isCountUp ? '∞' : '${preset.studyMinutes} ${l10n.mins}',
                      ),
                      _timerRow(l10n.shortBreak, '${preset.shortBreakMinutes} ${l10n.mins}'),
                      _timerRow(l10n.longBreak, '${preset.longBreakMinutes} ${l10n.mins}'),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Icon(Icons.arrow_forward_ios,
                      size: 14.w, color: AppColors.greyText),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _timerRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeSmall,
                color: AppColors.mainDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeSmall,
                color: AppColors.greyText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyOptionTile extends StatelessWidget {
  final String title;
  final Widget trailing;
  final VoidCallback onTap;

  const _StudyOptionTile({
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            border: Border.all(color: AppColors.mainGold, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppSizes.fontSizeMedium,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mainGold,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
