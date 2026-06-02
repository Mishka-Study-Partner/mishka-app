import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/fa.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/education/education_flow_config.dart';
import 'package:mishka_app/features/education/education_profile_restore.dart';
import 'package:mishka_app/features/education/presentation/education_flow_service.dart';
import 'package:mishka_app/features/education/presentation/widgets/education_next_button.dart';
import 'package:mishka_app/features/education/presentation/widgets/education_option_tile.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Step 2 (university) — academic year 1–5.
class EducationUniversityYearScreen extends StatefulWidget {
  const EducationUniversityYearScreen({super.key, this.config = const EducationFlowConfig()});

  final EducationFlowConfig config;

  @override
  State<EducationUniversityYearScreen> createState() =>
      _EducationUniversityYearScreenState();
}

class _EducationUniversityYearScreenState
    extends State<EducationUniversityYearScreen> {
  int? _selectedYear;
  bool _isLoading = false;
  bool _didRestore = false;

  void _restoreFromProfile() {
    if (_didRestore || !widget.config.isProfileEdit) return;
    _didRestore = true;

    final user = educationUser(context, widget.config);
    if (user == null || user.educationStatus?.toLowerCase() != 'university') {
      return;
    }

    final year = user.universityYear;
    if (year != null && year >= 1 && year <= 5) {
      _selectedYear = year;
    }
  }

  Future<void> _submit() async {
    if (_selectedYear == null || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      await EducationFlowService.submitAndFinish(
        context: context,
        config: widget.config,
        educationStatus: 'university',
        universityYear: _selectedYear,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _restoreFromProfile();

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
                    l10n.universityYearQuestion,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeXLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainDark,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      const EducationGoldIcon(icon: Fa.university),
                      SizedBox(width: 8.w),
                      Text(
                        l10n.universityColon,
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          fontSize: AppSizes.fontSizeLarge,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  ...[
                    for (final entry in <(int, String)>[
                      (1, l10n.firstYear),
                      (2, l10n.secondYear),
                      (3, l10n.thirdYear),
                      (4, l10n.fourthYear),
                      (5, l10n.fifthYear),
                    ])
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: EducationOptionTile(
                          label: entry.$2,
                          selected: _selectedYear == entry.$1,
                          onTap: () => setState(() => _selectedYear = entry.$1),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
          EducationNextButton(
            enabled: _selectedYear != null,
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
