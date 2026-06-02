import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconify_flutter/icons/fa.dart';
import 'package:iconify_flutter/icons/fluent_emoji_high_contrast.dart';
import 'package:iconify_flutter/icons/ic.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/education/education_flow_config.dart';
import 'package:mishka_app/features/education/presentation/education_flow_service.dart';
import 'package:mishka_app/features/education/presentation/widgets/education_next_button.dart';
import 'package:mishka_app/features/education/presentation/widgets/education_option_tile.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Step 2 (other) — specify current status in free text.
class EducationOtherScreen extends StatefulWidget {
  const EducationOtherScreen({super.key, this.config = const EducationFlowConfig()});

  final EducationFlowConfig config;

  @override
  State<EducationOtherScreen> createState() => _EducationOtherScreenState();
}

class _EducationOtherScreenState extends State<EducationOtherScreen> {
  final _detailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _detailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final detail = _detailController.text.trim();
    if (detail.isEmpty || _isLoading) return;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                  Opacity(
                    opacity: 0.45,
                    child: IgnorePointer(
                      child: EducationOptionTile(
                        label: l10n.school,
                        selected: false,
                        onTap: () {},
                        leadingIcon: const EducationGoldIcon(
                          icon: FluentEmojiHighContrast.school,
                        ),
                        trailing: const EducationMishkaTrailing(),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Opacity(
                    opacity: 0.45,
                    child: IgnorePointer(
                      child: EducationOptionTile(
                        label: l10n.university,
                        selected: false,
                        onTap: () {},
                        leadingIcon:
                            const EducationGoldIcon(icon: Fa.university),
                        trailing: const EducationMishkaTrailing(),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  EducationOptionTile(
                    label: l10n.otherColon,
                    selected: true,
                    onTap: () {},
                    leadingIcon: const EducationGoldIcon(
                      icon: Ic.round_maps_home_work,
                    ),
                    trailing: const EducationMishkaTrailing(),
                    child: Column(
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
                          controller: _detailController,
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          EducationNextButton(
            enabled: _detailController.text.trim().isNotEmpty,
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
