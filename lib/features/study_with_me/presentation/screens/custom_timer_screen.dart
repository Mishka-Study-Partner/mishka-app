import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/study_remote_data_source.dart';
import '../../data/timer_model.dart';
import 'timer_session_screen.dart';
import 'package:mishka_app/features/student_subjects/study_subject_launch.dart';

const _kLocalTimersKey = 'custom_timers_local';

class CustomTimerScreen extends StatefulWidget {
  const CustomTimerScreen({super.key});

  @override
  State<CustomTimerScreen> createState() => _CustomTimerScreenState();
}

class _CustomTimerScreenState extends State<CustomTimerScreen> {
  final StudyRemoteDataSource _remote = StudyRemoteDataSource(ApiService());
  final TextEditingController _studyController = TextEditingController();
  final TextEditingController _shortController = TextEditingController();
  final TextEditingController _longController = TextEditingController();

  int _selectedIndex = -1;
  List<CustomTimerPreset> _recentTimers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomTimers();
  }

  Future<void> _loadCustomTimers() async {
    try {
      final timers = await _remote.getCustomTimers();
      if (!mounted) return;
      setState(() => _recentTimers = timers);
      _saveTimersLocally(timers);
    } catch (e) {
      debugPrint('⏱ CustomTimerScreen: failed to load from backend ($e), loading local');
      final local = await _loadTimersLocally();
      if (!mounted) return;
      if (local.isNotEmpty) {
        setState(() => _recentTimers = local);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveTimersLocally(List<CustomTimerPreset> timers) async {
    final prefs = await SharedPreferences.getInstance();
    final json = timers.map((t) => {
      'id': t.id,
      'studyMinutes': t.studyMinutes,
      'shortBreakMinutes': t.shortBreakMinutes,
      'longBreakMinutes': t.longBreakMinutes,
      'label': t.label,
    }).toList();
    await prefs.setString(_kLocalTimersKey, jsonEncode(json));
  }

  Future<List<CustomTimerPreset>> _loadTimersLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLocalTimersKey);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List?) ?? [];
    return list
        .whereType<Map>()
        .map((e) => CustomTimerPreset.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  void dispose() {
    _studyController.dispose();
    _shortController.dispose();
    _longController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomTimer() async {
    final l10n = AppLocalizations.of(context)!;
    final study = int.tryParse(_studyController.text.trim());
    final short = int.tryParse(_shortController.text.trim());
    final long = int.tryParse(_longController.text.trim());

    if (study == null || short == null || long == null ||
        study <= 0 || short <= 0 || long <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseFillAllRequiredFields)),
      );
      return;
    }

    try {
      await _remote.createCustomTimer(
        studyMinutes: study,
        shortBreakMinutes: short,
        longBreakMinutes: long,
      );
      _studyController.clear();
      _shortController.clear();
      _longController.clear();
      await _loadCustomTimers();
      if (mounted) {
        setState(() => _selectedIndex = 0);
      }
    } catch (e) {
      debugPrint('⏱ CustomTimerScreen: backend save failed ($e), saving locally');
      if (!mounted) return;
      setState(() {
        _recentTimers.insert(
          0,
          CustomTimerPreset(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            studyMinutes: study,
            shortBreakMinutes: short,
            longBreakMinutes: long,
          ),
        );
        _selectedIndex = 0;
      });
      _saveTimersLocally(_recentTimers);
      _studyController.clear();
      _shortController.clear();
      _longController.clear();
    }
  }

  void _startTimer() {
    StudyTimerModel timer;

    if (_selectedIndex >= 0 && _selectedIndex < _recentTimers.length) {
      timer = _recentTimers[_selectedIndex].toTimerModel();
    } else {
      final study = int.tryParse(_studyController.text.trim()) ?? 25;
      final short = int.tryParse(_shortController.text.trim()) ?? 5;
      final long = int.tryParse(_longController.text.trim()) ?? 15;
      timer = StudyTimerModel(
        'Custom',
        study,
        short,
        long,
        modeId: 'custom',
      );
    }

    StudySubjectLaunch.pickSubjectAndStart(
      context,
      onStart: (subjectId, subjectName) async {
        if (!context.mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TimerSessionScreen(
              model: timer.withStudentSubject(subjectId, name: subjectName),
            ),
          ),
        );
      },
    );
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
      body: SingleChildScrollView(
        padding: AppScrollInsets.page(horizontal: AppSizes.paddingMedium, top: AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                l10n.concentrationMode,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: AppSizes.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainDark,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              l10n.customYourOwnTimer,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontSizeMedium,
                color: AppColors.mainDark,
              ),
            ),
            SizedBox(height: 12.h),

            _buildInputRow(l10n.studyTime, _studyController, l10n),
            _buildInputRow(l10n.shortBreak, _shortController, l10n),
            _buildInputRow(l10n.longBreak, _longController, l10n),

            SizedBox(height: 10.h),
            Center(
              child: ElevatedButton(
                onPressed: _saveCustomTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainGold,
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.save,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    color: AppColors.white,
                    fontSize: AppSizes.fontSizeMedium,
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

            SizedBox(height: 20.h),

            Text(
              l10n.recentlyCustomizedTimers,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontSizeMedium,
                color: AppColors.mainDark,
              ),
            ),
            SizedBox(height: 10.h),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_recentTimers.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Text(
                    l10n.noPreviousCustomTimers,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeMedium,
                      color: AppColors.greyText,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentTimers.length,
                itemBuilder: (context, index) {
                  final item = _recentTimers[index];
                  final isSelected = _selectedIndex == index;
                  return _RecentTimerCard(
                    preset: item,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedIndex = index),
                  );
                },
              ),

            SizedBox(height: 20.h),

            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _startTimer,
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
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.fontSizeMedium,
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

  Widget _buildInputRow(
    String label,
    TextEditingController controller,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                color: AppColors.mainDark,
              ),
            ),
          ),
          SizedBox(
            width: 70.w,
            height: 38.h,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Pridi', fontSize: 13.sp),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: const BorderSide(color: AppColors.stroke),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.r),
                  borderSide: const BorderSide(color: AppColors.mainGold),
                ),
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            l10n.mins,
            style: TextStyle(
              fontFamily: 'Pridi',
              color: AppColors.mainGold,
              fontSize: AppSizes.fontSizeMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTimerCard extends StatelessWidget {
  final CustomTimerPreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecentTimerCard({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.mainGold.withValues(alpha: 0.08)
              : AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? AppColors.mainGold : AppColors.stroke,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9.r),
          child: IntrinsicHeight(
            child: Row(
              children: [
                SizedBox(width: 10.w),
                Container(
                  width: 4.w,
                  margin: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.mainGold,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: _timerColumn(l10n.studyTime, '${preset.studyMinutes} ${l10n.mins}'),
                        ),
                        Expanded(
                          child: _timerColumn(l10n.shortBreak, '${preset.shortBreakMinutes} ${l10n.mins}'),
                        ),
                        Expanded(
                          child: _timerColumn(l10n.longBreak, '${preset.longBreakMinutes} ${l10n.mins}'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _timerColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.mainDark,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: 11.sp,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }
}
