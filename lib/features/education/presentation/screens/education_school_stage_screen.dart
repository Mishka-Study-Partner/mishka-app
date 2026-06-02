import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/fluent_emoji_high_contrast.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/education/education_flow_config.dart';
import 'package:mishka_app/features/education/education_profile_restore.dart';
import 'package:mishka_app/features/education/presentation/education_flow_service.dart';
import 'package:mishka_app/features/education/presentation/widgets/education_next_button.dart';
import 'package:mishka_app/features/education/presentation/widgets/education_option_tile.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class _SchoolOption {
  const _SchoolOption({
    required this.label,
    required this.track,
    required this.grade,
  });

  final String label;
  final String track;
  final int grade;
}

/// Step 2 (school) — middle / high school year.
class EducationSchoolStageScreen extends StatefulWidget {
  const EducationSchoolStageScreen({super.key, this.config = const EducationFlowConfig()});

  final EducationFlowConfig config;

  @override
  State<EducationSchoolStageScreen> createState() =>
      _EducationSchoolStageScreenState();
}

class _EducationSchoolStageScreenState extends State<EducationSchoolStageScreen> {
  _SchoolOption? _selected;
  bool _isLoading = false;
  bool _didRestore = false;

  List<_SchoolOption> _middleOptions(AppLocalizations l10n) => [
        _SchoolOption(
          label: l10n.firstPreparatory,
          track: 'middle_school',
          grade: 1,
        ),
        _SchoolOption(
          label: l10n.secondPreparatory,
          track: 'middle_school',
          grade: 2,
        ),
        _SchoolOption(
          label: l10n.thirdPreparatory,
          track: 'middle_school',
          grade: 3,
        ),
      ];

  List<_SchoolOption> _highOptions(AppLocalizations l10n) => [
        _SchoolOption(
          label: l10n.firstSecondary,
          track: 'high_school',
          grade: 1,
        ),
        _SchoolOption(
          label: l10n.secondSecondary,
          track: 'high_school',
          grade: 2,
        ),
        _SchoolOption(
          label: l10n.thirdSecondary,
          track: 'high_school',
          grade: 3,
        ),
      ];

  Future<void> _submit() async {
    if (_selected == null || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      await EducationFlowService.submitAndFinish(
        context: context,
        config: widget.config,
        educationStatus: 'school',
        schoolTrack: _selected!.track,
        schoolGrade: _selected!.grade,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(EducationFlowService.errorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _restoreFromProfile(AppLocalizations l10n) {
    if (_didRestore || !widget.config.isProfileEdit) return;
    _didRestore = true;

    final user = educationUser(context, widget.config);
    if (user == null || user.educationStatus?.toLowerCase() != 'school') return;

    final track = user.schoolTrack?.toLowerCase();
    final grade = user.schoolGrade;
    if (track == null || grade == null) return;

    final all = [..._middleOptions(l10n), ..._highOptions(l10n)];
    for (final option in all) {
      if (option.track == track && option.grade == grade) {
        _selected = option;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _restoreFromProfile(l10n);
    final middle = _middleOptions(l10n);
    final high = _highOptions(l10n);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: MishkaAppBar(
        title: '',
        topTitle: l10n.mishka,
        showBack: true,
        showBottomBar: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Text(
                    l10n.schoolStageQuestion,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeXLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainDark,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _SectionHeader(
                    icon: FluentEmojiHighContrast.school,
                    title: l10n.middleSchoolColon,
                  ),
                  SizedBox(height: 10.h),
                  ...middle.map((o) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: EducationOptionTile(
                          label: o.label,
                          selected: _selected == o,
                          onTap: () => setState(() => _selected = o),
                        ),
                      )),
                  SizedBox(height: 16.h),
                  _SectionHeader(
                    icon: FluentEmojiHighContrast.school,
                    title: l10n.highSchoolColon,
                  ),
                  SizedBox(height: 10.h),
                  ...high.map((o) => Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: EducationOptionTile(
                          label: o.label,
                          selected: _selected == o,
                          onTap: () => setState(() => _selected = o),
                        ),
                      )),
                ],
              ),
            ),
          ),
          EducationNextButton(
            enabled: _selected != null,
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        EducationGoldIcon(icon: icon),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: AppSizes.fontSizeLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.mainDark,
          ),
        ),
      ],
    );
  }
}
