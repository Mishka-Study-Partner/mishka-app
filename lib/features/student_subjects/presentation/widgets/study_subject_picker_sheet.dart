import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/student_subjects/data/data_sources/student_subjects_remote_data_source.dart';
import 'package:mishka_app/features/student_subjects/data/models/student_subject_model.dart';
import 'package:mishka_app/features/student_subjects/presentation/screens/student_subjects_screen.dart';
import 'package:mishka_app/features/student_subjects/study_subject_launch.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Bottom sheet: optional subject before starting a study session.
class StudySubjectPickerSheet extends StatefulWidget {
  const StudySubjectPickerSheet({super.key});

  static Future<StudySubjectPickerResult?> show(BuildContext context) {
    return showModalBottomSheet<StudySubjectPickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => const StudySubjectPickerSheet(),
    );
  }

  @override
  State<StudySubjectPickerSheet> createState() => _StudySubjectPickerSheetState();
}

class _StudySubjectPickerSheetState extends State<StudySubjectPickerSheet> {
  final _remote = StudentSubjectsRemoteDataSource(ApiService());

  List<StudentSubjectModel> _subjects = [];
  bool _loading = true;
  String? _selectedId;
  String? _selectedName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _remote.listSubjects();
      if (!mounted) return;
      setState(() {
        _subjects = list;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _select(String? id, {String? name}) {
    setState(() {
      _selectedId = id;
      _selectedName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.stroke,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.studySubjectPickerTitle,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeLarge,
                fontWeight: FontWeight.w700,
                color: AppColors.mainDark,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              l10n.studySubjectPickerSubtitle,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeSmall,
                color: AppColors.lightText,
              ),
            ),
            SizedBox(height: 16.h),
            if (_loading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: const Center(child: CircularProgressIndicator()),
              )
            else ...[
              _SubjectOptionTile(
                label: l10n.studySubjectNone,
                color: AppColors.greyText,
                selected: _selectedId == null,
                onTap: () => _select(null),
              ),
              ..._subjects.map(
                (subject) => _SubjectOptionTile(
                  label: subject.name,
                  color: subject.displayColor,
                  selected: _selectedId == subject.id,
                  onTap: () => _select(subject.id, name: subject.name),
                ),
              ),
            ],
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StudentSubjectsScreen(),
                  ),
                );
                if (!mounted) return;
                await _load();
              },
              child: Text(
                l10n.studySubjectManage,
                style: TextStyle(
                  fontFamily: 'Pridi',
                  fontSize: AppSizes.fontSizeMedium,
                  color: AppColors.mainGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 48.h,
              child: ElevatedButton(
                onPressed: _loading
                    ? null
                    : () => Navigator.of(context).pop(
                          StudySubjectPickerResult(
                            subjectId: _selectedId,
                            subjectName: _selectedName,
                          ),
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  l10n.studySubjectStartSession,
                  style: TextStyle(
                    fontFamily: 'Pridi',
                    fontSize: AppSizes.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectOptionTile extends StatelessWidget {
  const _SubjectOptionTile({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: selected
            ? AppColors.mainGold.withValues(alpha: 0.08)
            : AppColors.lightFrameBackground,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeMedium,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: AppColors.mainDark,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: AppColors.mainGold, size: 20.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
