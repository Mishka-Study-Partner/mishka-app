import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_styles.dart';
import '../../data/community_create_params.dart';
import '../../data/community_current_user.dart';
import '../../data/community_discover_models.dart';
import '../../data/community_error_helpers.dart';
import '../../data/community_locale.dart';
import '../../data/community_repository.dart';
import '../widgets/community_category_field.dart';
import '../widgets/community_dialogs.dart';
import '../widgets/community_public_discovery_section.dart';
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
  bool _loadingDiscover = false;
  DiscoverCategories? _categories;
  final Set<String> _subjectKeys = {};
  String? _purposeKey;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();
  List<CommunityCategoryTitle> _categoryTitles = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadDiscoverData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadDiscoverData() async {
    setState(() => _loadingDiscover = true);
    try {
      final locale = communityApiLocale(context);
      final categories =
          await widget.repository.loadDiscoverCategories(locale: locale);
      var titles = categories.categoryTitles;
      if (titles.isEmpty) {
        titles = await widget.repository.loadCategoryTitles();
      }
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _categoryTitles = titles;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingDiscover = false);
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

  (String? category, String? newCategoryTitle) _resolveCategoryFields() {
    final catText = _categoryController.text.trim();
    if (catText.isEmpty) return (null, null);
    final known = _categoryTitles.any(
      (t) => t.title.toLowerCase() == catText.toLowerCase(),
    );
    if (known) {
      final title = _categoryTitles
          .firstWhere((t) => t.title.toLowerCase() == catText.toLowerCase())
          .title;
      return (title, null);
    }
    return (null, catText);
  }

  CommunityCreateParams _createParams() {
    final (category, newCategoryTitle) = _resolveCategoryFields();
    if (_isPrivate) {
      return CommunityCreateParams(
        category: category,
        newCategoryTitle: newCategoryTitle,
      );
    }
    final user = readCachedUser();
    final locale = communityApiLocale(context);
    return CommunityCreateParams(
      subjectKeys: _subjectKeys.toList(),
      educationStatus: user?.educationStatus,
      schoolTrack: user?.schoolTrack,
      schoolGrade: user?.schoolGrade,
      universityYear: user?.universityYear,
      purpose: _purposeKey,
      locale: locale,
      category: category,
      newCategoryTitle: newCategoryTitle,
    );
  }

  Future<void> _createCommunity() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      CommunityStyles.showSnackBar(context, l10n.communityCreateNameRequired);
      return;
    }

    setState(() => _submitting = true);
    try {
      final community = await widget.repository.createCommunity(
        name: name,
        isPublic: !_isPrivate,
        description: _descController.text.trim(),
        discovery: _createParams(),
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
        title: l10n.communityCreateTitle,
        topTitle: l10n.communityCreateTitle,
        showBack: true,
        showBottomBar: false,
      ),
      body: SingleChildScrollView(
        padding: AppScrollInsets.page(horizontal: 16.w, top: 16.h),
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
            SizedBox(height: 20.h),
            if (_isPrivate)
              CommunityCategoryField(
                repository: widget.repository,
                controller: _categoryController,
                initialTitles: _categoryTitles,
              )
            else
              CommunityPublicDiscoverySection(
                repository: widget.repository,
                categoryController: _categoryController,
                categoryTitles: _categoryTitles,
                categories: _categories,
                loadingDiscover: _loadingDiscover,
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
