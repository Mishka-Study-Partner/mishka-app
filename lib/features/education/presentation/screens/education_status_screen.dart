import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/fa.dart';
import 'package:iconify_flutter/icons/fluent_emoji_high_contrast.dart';
import 'package:iconify_flutter/icons/ic.dart';

import 'package:mishka_app/core/layout/form_screen_body.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/education/education_flow_config.dart';
import 'package:mishka_app/features/education/education_profile_restore.dart';
import 'package:mishka_app/features/education/presentation/education_flow_service.dart';
import 'package:mishka_app/features/education/presentation/screens/education_school_stage_screen.dart';
import 'package:mishka_app/features/education/presentation/screens/education_university_year_screen.dart';
import 'package:mishka_app/features/education/presentation/widgets/education_next_button.dart';
import 'package:mishka_app/features/education/presentation/widgets/education_option_tile.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

enum EducationStatusChoice { school, university, other }

/// Step 1 — pick school / university / other (with manual text for other).
class EducationStatusScreen extends StatefulWidget {
  const EducationStatusScreen({super.key, this.config = const EducationFlowConfig()});

  final EducationFlowConfig config;

  @override
  State<EducationStatusScreen> createState() => _EducationStatusScreenState();
}

class _EducationStatusScreenState extends State<EducationStatusScreen> {
  EducationStatusChoice? _choice;
  final _otherDetailController = TextEditingController();
  bool _isLoading = false;

  bool get _canProceed {
    if (_choice == null) return false;
    if (_choice == EducationStatusChoice.other) {
      return _otherDetailController.text.trim().isNotEmpty;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _otherDetailController.addListener(() => setState(() {}));
    _restoreFromProfile();
  }

  void _restoreFromProfile() {
    if (!widget.config.isProfileEdit) return;
    final user = educationUser(context, widget.config);
    if (user == null) return;

    final status = user.educationStatus?.toLowerCase();
    switch (status) {
      case 'school':
        _choice = EducationStatusChoice.school;
      case 'university':
        _choice = EducationStatusChoice.university;
      case 'other':
        _choice = EducationStatusChoice.other;
        final detail = user.educationOtherDetail?.trim();
        if (detail != null && detail.isNotEmpty) {
          _otherDetailController.text = detail;
        }
      default:
        break;
    }
  }

  @override
  void dispose() {
    _otherDetailController.dispose();
    super.dispose();
  }

  Future<void> _submitOther(String detail) async {
    setState(() => _isLoading = true);
    try {
      await EducationFlowService.submitAndFinish(
        context: context,
        config: widget.config,
        educationStatus: 'other',
        educationOtherDetail: detail,
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

  Future<void> _onNext() async {
    if (!_canProceed || _isLoading) return;

    switch (_choice!) {
      case EducationStatusChoice.school:
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => EducationSchoolStageScreen(config: widget.config),
          ),
        );
      case EducationStatusChoice.university:
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => EducationUniversityYearScreen(config: widget.config),
          ),
        );
      case EducationStatusChoice.other:
        await _submitOther(_otherDetailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOther = _choice == EducationStatusChoice.other;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: MishkaAppBar(
        title: '',
        topTitle: l10n.mishka,
        showBack: true,
        showBottomBar: false,
      ),
      body: FormScreenBody.constrain(
        context,
        Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppScrollInsets.page(horizontal: AppSizes.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Text(
                    l10n.educationStatusQuestion,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeXLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainDark,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  EducationOptionTile(
                    label: l10n.school,
                    selected: _choice == EducationStatusChoice.school,
                    onTap: () => setState(
                      () => _choice = EducationStatusChoice.school,
                    ),
                    leadingIcon: const EducationGoldIcon(
                      icon: FluentEmojiHighContrast.school,
                    ),
                    trailing: const EducationMishkaTrailing(),
                  ),
                  SizedBox(height: 12.h),
                  EducationOptionTile(
                    label: l10n.university,
                    selected: _choice == EducationStatusChoice.university,
                    onTap: () => setState(
                      () => _choice = EducationStatusChoice.university,
                    ),
                    leadingIcon: const EducationGoldIcon(icon: Fa.university),
                    trailing: const EducationMishkaTrailing(),
                  ),
                  SizedBox(height: 12.h),
                  EducationOptionTile(
                    label: l10n.otherColon,
                    selected: isOther,
                    onTap: () => setState(
                      () => _choice = EducationStatusChoice.other,
                    ),
                    leadingIcon: const EducationGoldIcon(
                      icon: Ic.round_maps_home_work,
                    ),
                    trailing: const EducationMishkaTrailing(),
                    child: isOther
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.pleaseSpecifyEducationStatus,
                                style: TextStyle(
                                  fontFamily: 'Pridi',
                                  fontSize: AppSizes.fontSizeMedium,
                                  color: AppColors.mainDark,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              TextField(
                                controller: _otherDetailController,
                                textCapitalization: TextCapitalization.sentences,
                                style: TextStyle(
                                  fontFamily: 'Pridi',
                                  fontSize: AppSizes.fontSizeMedium,
                                  color: AppColors.mainDark,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: l10n.educationOtherHint,
                                  hintStyle: TextStyle(
                                    fontFamily: 'Pridi',
                                    color: AppColors.greyText,
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.stroke),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.mainGold,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
          EducationNextButton(
            enabled: _canProceed,
            isLoading: _isLoading,
            onPressed: _onNext,
          ),
        ],
      ),
      ),
    );
  }
}
