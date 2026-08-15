import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_styles.dart';
import '../../data/community_error_helpers.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';
import '../widgets/community_dialogs.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({
    super.key,
    required this.community,
    required this.repository,
  });

  final CommunityModel community;
  final CommunityRepository repository;

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _nameController.text.trim();
    if (title.isEmpty) return;

    setState(() => _submitting = true);
    try {
      await widget.repository.createChannel(
        widget.community.id,
        title: title,
        description: _descController.text.trim(),
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      await showCommunitySuccessDialog(
        context,
        message: l10n.communityAddGroupSuccess,
        onDismiss: () => Navigator.pop(context, true),
      );
    } catch (e) {
      if (!mounted) return;
      CommunityStyles.showSnackBar(
        context,
        communityErrorMessage(e, l10n: AppLocalizations.of(context)!),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.communityAddGroupTitle,
        topTitle: l10n.communityAddGroupTitle,
        showBack: true,
        showBottomBar: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppScrollInsets.page(horizontal: 20.w, top: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Center(
                      child: Text(
                        l10n.communityAddGroupHeader,
                        textAlign: TextAlign.center,
                        style: CommunityStyles.headline,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    Text(l10n.communityAddGroupProfileLabel, style: CommunityStyles.sectionLabel),
                    SizedBox(height: 16.h),
                    Center(
                      child: Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.mainGold, width: 2),
                          color: AppColors.white,
                        ),
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: AppColors.mainGold,
                          size: 40.w,
                        ),
                      ),
                    ),
                    SizedBox(height: 28.h),
                    Text(l10n.communityAddGroupNameLabel, style: CommunityStyles.sectionLabel),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _nameController,
                      decoration: CommunityStyles.inputDecoration(l10n.communityAddGroupNameHint),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Text(l10n.communityAddGroupDescLabel, style: CommunityStyles.sectionLabel),
                        Text(
                          l10n.communityLabelOptional,
                          style: CommunityStyles.optionalLabel,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: CommunityStyles.inputDecoration(l10n.communityAddGroupDescHint),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: CommunityStyles.goldButtonStyle(),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.communityAddButton),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
