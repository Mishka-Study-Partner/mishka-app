import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import '../../community_styles.dart';
import '../../data/community_models.dart';
import '../../data/community_repository.dart';
import '../widgets/community_category_field.dart';
import '../widgets/group_list_item_card.dart';

class EditCommunityScreen extends StatefulWidget {
  const EditCommunityScreen({
    super.key,
    required this.community,
    required this.repository,
    this.onSaved,
  });

  final CommunityModel community;
  final CommunityRepository repository;
  final VoidCallback? onSaved;

  @override
  State<EditCommunityScreen> createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends State<EditCommunityScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  List<CommunityGroupModel> _groups = const [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.community.name);
    _descriptionController = TextEditingController(
      text: widget.community.description ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.community.category ?? '',
    );
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final groups = await widget.repository.loadChannels(widget.community.id);
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<({String? category, String? newCategoryTitle})> _resolveCategoryFields(
    String catText,
  ) async {
    if (catText.isEmpty) return (category: null, newCategoryTitle: null);
    final titles = await widget.repository.loadCategoryTitles(q: catText);
    final known = titles.any(
      (t) => t.title.toLowerCase() == catText.toLowerCase(),
    );
    if (known) {
      return (
        category: titles
            .firstWhere((t) => t.title.toLowerCase() == catText.toLowerCase())
            .title,
        newCategoryTitle: null,
      );
    }
    return (category: null, newCategoryTitle: catText);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final catText = _categoryController.text.trim();
      final resolved = await _resolveCategoryFields(catText);
      await widget.repository.updateCommunity(
        widget.community.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: resolved.category,
        newCategoryTitle: resolved.newCategoryTitle,
      );
      if (!mounted) return;
      widget.onSaved?.call();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      CommunityStyles.showSnackBar(context, '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteGroup(CommunityGroupModel group) async {
    try {
      await widget.repository.deleteChannel(widget.community.id, group.id);
      await _load();
    } catch (e) {
      if (!mounted) return;
      CommunityStyles.showSnackBar(context, '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.communityEditCommunity,
        topTitle: l10n.communityEditCommunity,
        showBack: true,
        showBottomBar: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppScrollInsets.page(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  Text(
                    l10n.communityEditProfileHeader,
                    style: CommunityStyles.dialogTitle,
                  ),
                  SizedBox(height: 16.h),
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 85.w,
                          height: 85.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.mainDark,
                          ),
                          child: Icon(
                            Icons.nightlight_round,
                            color: AppColors.mainGold,
                            size: 45.w,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.mainDark.withValues(alpha: 0.12),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.collections_outlined,
                            color: AppColors.mainDark,
                            size: 18.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    l10n.communityEditNameLabel,
                    style: CommunityStyles.sectionLabel,
                  ),
                  SizedBox(height: 6.h),
                  TextField(
                    controller: _nameController,
                    decoration: CommunityStyles.inputDecoration('').copyWith(
                      suffixIcon: Icon(
                        Icons.edit,
                        color: AppColors.mainGold,
                        size: 20.w,
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Text(
                        l10n.communityAddGroupDescLabel,
                        style: CommunityStyles.sectionLabel,
                      ),
                      Text(
                        l10n.communityLabelOptional,
                        style: CommunityStyles.optionalLabel,
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: CommunityStyles.inputDecoration(
                      l10n.communityEditDescHint,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  CommunityCategoryField(
                    repository: widget.repository,
                    controller: _categoryController,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    l10n.communityEditGroupsLabel,
                    style: CommunityStyles.sectionLabel,
                  ),
                  SizedBox(height: 8.h),
                  ..._groups.map(
                    (group) => EditableGroupCard(
                      group: group,
                      onDelete: () => _deleteGroup(group),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: CommunityStyles.goldButtonStyle(),
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Text(l10n.save),
                    ),
                  ),
                  const ScreenEndSpacer(),
                ],
              ),
            ),
    );
  }
}
