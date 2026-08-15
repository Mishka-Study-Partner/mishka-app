import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../data/study_remote_data_source.dart';
import '../../data/timer_model.dart';
import 'timer_session_screen.dart';
import 'package:mishka_app/features/student_subjects/study_subject_launch.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  final StudyRemoteDataSource _remote = StudyRemoteDataSource(ApiService());
  int _selectedIndex = 0;
  List<StudyTimerModel> _timers = StudyTimerModel.presets;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      final catalog = await _remote.getCatalog();
      if (!mounted) return;
      if (catalog.concentrationPresets.isNotEmpty) {
        setState(() {
          _timers = catalog.concentrationPresets
              .map((p) => p.toTimerModel())
              .toList();
        });
      }
    } catch (e) {
      debugPrint('⏱ PomodoroScreen: catalog fetch failed ($e), using local presets');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.concentrationMode,
        topTitle: l10n.studyWithMe,
        showBack: true,
        showBottomBar: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            Center(
              child: Text(
                l10n.concentrationMode,
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: AppScrollInsets.list(),
                      itemCount: _timers.length,
                      itemBuilder: (context, index) {
                        return _TimerTile(
                          model: _timers[index],
                          isSelected: _selectedIndex == index,
                          onTap: () => setState(() => _selectedIndex = index),
                        );
                      },
                    ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _timers.isEmpty
                    ? null
                    : () {
                        final model = _timers[_selectedIndex];
                        StudySubjectLaunch.pickSubjectAndStart(
                          context,
                          onStart: (subjectId, subjectName) async {
                            if (!context.mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TimerSessionScreen(
                                  model: model.withStudentSubject(
                                    subjectId,
                                    name: subjectName,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.startTimer,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppSizes.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    height: 1.0,
                  ),
                  strutStyle: StrutStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppSizes.fontSizeMedium,
                    height: 1.4,
                    forceStrutHeight: true,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}

class _TimerTile extends StatelessWidget {
  final StudyTimerModel model;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimerTile({
    required this.model,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.mainGold : AppColors.stroke,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              margin: EdgeInsets.only(top: 4.h),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.mainGold, width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.mainGold,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.title,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontWeight: FontWeight.w600,
                      fontSize: AppSizes.fontSizeMedium,
                      color: AppColors.mainDark,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  _TimerRow('${model.studyMinutes} ${l10n.mins}', l10n.studyTime),
                  _TimerRow('${model.shortBreakMinutes} ${l10n.mins}', l10n.shortBreak),
                  _TimerRow('${model.longBreakMinutes} ${l10n.mins}', l10n.longBreak),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerRow extends StatelessWidget {
  final String time;
  final String label;

  const _TimerRow(this.time, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          SizedBox(
            width: 70.w,
            child: Text(
              time,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeSmall,
                color: AppColors.mainDark,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Pridi',
              fontSize: AppSizes.fontSizeSmall,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }
}
