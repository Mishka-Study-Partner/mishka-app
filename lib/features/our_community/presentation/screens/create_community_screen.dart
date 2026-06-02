import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_styles.dart';
import '../../data/community_create_params.dart';
import '../../data/community_current_user.dart';
import '../../data/community_discover_models.dart';
import '../../data/community_error_helpers.dart';
import '../../data/community_locale.dart';
import '../../data/community_repository.dart';
import '../widgets/community_dialogs.dart';
import '../widgets/community_discovery_fields.dart';
import 'community_home_screen.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key, required this.repository});

  final CommunityRepository repository;

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  bool _isPrivate = true;
  bool _submitting = false;
  bool _loadingCategories = false;
  DiscoverCategories? _categories;
  final Set<String> _subjectKeys = {};
  String? _purposeKey;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final locale = communityApiLocale(context);
      final categories =
          await widget.repository.loadDiscoverCategories(locale: locale);
      if (!mounted) return;
      setState(() => _categories = categories);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  String? _profileEducationHint(AppLocalizations l10n) {
    final user = readCachedUser();
    if (user == null) return null;
    final status = user.educationStatus?.trim();
    if (status == null || status.isEmpty) return null;
    if (status.toLowerCase() == 'university' && user.universityYear != null) {
      return l10n.communityCreateEducationHintUniversity(
        user.universityYear.toString(),
      );
    }
    if (status.toLowerCase() == 'school' && user.schoolGrade != null) {
      return l10n.communityCreateEducationHintSchool(
        user.schoolGrade.toString(),
      );
    }
    return l10n.communityCreateEducationHintProfile(status);
  }

  CommunityCreateParams? _discoveryParams() {
    if (_isPrivate) return null;
    final user = readCachedUser();
    final locale = communityApiLocale(context);
    return CommunityCreateParams(
      subjectKeys: _subjectKeys.toList(),
      educationStatus: user?.educationStatus,
      schoolTrack: user?.schoolTrack,
      schoolGrade: user?.schoolGrade,
      universityYear: user?.universityYear,
      purpose: _purposeKey ?? 'general',
      locale: locale,
    );
  }

  Future<void> _createCommunity() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.communityCreateNameRequired,
            style: CommunityStyles.snackBar,
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final community = await widget.repository.createCommunity(
        name: name,
        isPublic: !_isPrivate,
        description: _descController.text.trim(),
        discovery: _discoveryParams(),
      );
      if (!mounted) return;
      await showCommunitySuccessDialog(
        context,
        message: l10n.communityCreateSuccess,
        onDismiss: () {
          Navigator.pop(context, true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (_) => CommunityHomeScreen(
                community: community,
                repository: widget.repository,
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            communityErrorMessage(e),
            style: CommunityStyles.snackBar,
          ),
        ),
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
        title: l10n.communityCreateTitle,
        topTitle: l10n.communityCreateTitle,
        showBack: true,
        showBottomBar: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                l10n.communityCreateTitle,
                style: CommunityStyles.underlinedTitle,
              ),
            ),
            SizedBox(height: 20.h),
            Text(l10n.communityCreateVisibilityLabel, style: CommunityStyles.body),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.mainGold),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  _ToggleButton(
                    label: l10n.communityVisibilityPrivate,
                    selected: _isPrivate,
                    onTap: () => setState(() => _isPrivate = true),
                  ),
                  _ToggleButton(
                    label: l10n.communityVisibilityPublic,
                    selected: !_isPrivate,
                    onTap: () => setState(() => _isPrivate = false),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Center(
              child: CircleAvatar(
                radius: 35.r,
                backgroundColor: AppColors.mainGold,
                child: Icon(Icons.group, color: AppColors.white, size: 32.w),
              ),
            ),
            SizedBox(height: 20.h),
            Text(l10n.communityCreateNameLabel, style: CommunityStyles.sectionLabel),
            SizedBox(height: 6.h),
            TextField(
              controller: _nameController,
              decoration: CommunityStyles.inputDecoration(
                l10n.communityCreateNameHint,
              ),
            ),
            SizedBox(height: 14.h),
            Text(l10n.communityCreateDescLabel, style: CommunityStyles.sectionLabel),
            SizedBox(height: 6.h),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: CommunityStyles.inputDecoration(
                l10n.communityCreateDescHint,
              ),
            ),
            if (!_isPrivate) ...[
              SizedBox(height: 20.h),
              Text(
                l10n.communityCreateDiscoverSection,
                style: CommunityStyles.sectionLabel,
              ),
              SizedBox(height: 6.h),
              Text(
                l10n.communityCreateDiscoverSubtitle,
                style: CommunityStyles.caption,
              ),
              SizedBox(height: 10.h),
              if (_loadingCategories)
                const Center(child: CircularProgressIndicator(strokeWidth: 2))
              else
                CommunityDiscoveryFields(
                  categories: _categories,
                  selectedSubjectKeys: _subjectKeys,
                  selectedPurposeKey: _purposeKey,
                  profileEducationHint: _profileEducationHint(l10n),
                  onSubjectsChanged: (keys) => setState(() {
                    _subjectKeys
                      ..clear()
                      ..addAll(keys);
                  }),
                  onPurposeChanged: (key) => setState(() => _purposeKey = key),
                ),
            ],
            SizedBox(height: 30.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: CommunityStyles.goldButtonStyle(),
                onPressed: _submitting ? null : _createCommunity,
                child: _submitting
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.communityCreateButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.mainGold : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            label,
            style: CommunityStyles.bodySemiBold.copyWith(
              color: selected ? AppColors.white : AppColors.mainDark,
            ),
          ),
        ),
      ),
    );
  }
}
