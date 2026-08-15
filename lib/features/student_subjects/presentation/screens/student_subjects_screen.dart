import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/features/student_subjects/data/data_sources/student_subjects_remote_data_source.dart';
import 'package:mishka_app/features/student_subjects/data/models/student_subject_model.dart';
import 'package:mishka_app/features/student_subjects/utils/subject_color_palette.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class StudentSubjectsScreen extends StatefulWidget {
  const StudentSubjectsScreen({super.key});

  @override
  State<StudentSubjectsScreen> createState() => _StudentSubjectsScreenState();
}

class _StudentSubjectsScreenState extends State<StudentSubjectsScreen> {
  static const _maxSubjects = 20;

  final _remote = StudentSubjectsRemoteDataSource(ApiService());
  List<StudentSubjectModel> _subjects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
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

  Future<void> _openEditor({StudentSubjectModel? existing}) async {
    final l10n = AppLocalizations.of(context)!;
    if (existing == null && _subjects.length >= _maxSubjects) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.studentSubjectsMaxReached(_maxSubjects))),
      );
      return;
    }

    final saved = await showDialog<StudentSubjectModel>(
      context: context,
      builder: (_) => _SubjectEditorDialog(
        existing: existing,
        usedNames: _subjects
            .where((s) => s.id != existing?.id)
            .map((s) => s.name.toLowerCase())
            .toSet(),
      ),
    );
    if (!mounted || saved == null) return;

    try {
      if (existing == null) {
        await _remote.createSubject(name: saved.name, color: saved.color);
      } else {
        await _remote.updateSubject(saved);
      }
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      final message = e.error == 'SUBJECT_NAME_IN_USE'
          ? l10n.studentSubjectsNameInUse
          : e.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.studentSubjectsSaveFailed)),
      );
    }
  }

  Future<void> _deleteSubject(StudentSubjectModel subject) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.studentSubjectsDeleteTitle),
        content: Text(l10n.studentSubjectsDeleteBody(subject.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _remote.deleteSubject(subject.id);
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.studentSubjectsSaveFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.studentSubjectsTitle,
        topTitle: l10n.settings,
        showBack: true,
        showBottomBar: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        backgroundColor: AppColors.mainGold,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 120.h),
                  const Center(child: CircularProgressIndicator()),
                ],
              )
            : ListView(
                padding: AppScrollInsets.page(
                  horizontal: AppSizes.paddingMedium,
                  top: 16.h,
                ),
                children: [
                  Text(
                    l10n.studentSubjectsDescription,
                    style: TextStyle(
                      fontFamily: 'Pridi',
                      fontSize: AppSizes.fontSizeMedium,
                      color: AppColors.lightText,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  if (_subjects.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      child: Text(
                        l10n.studentSubjectsEmpty,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Pridi',
                          fontSize: AppSizes.fontSizeMedium,
                          color: AppColors.lightText,
                        ),
                      ),
                    )
                  else
                    ..._subjects.map(
                      (subject) => _SubjectListTile(
                        subject: subject,
                        onEdit: () => _openEditor(existing: subject),
                        onDelete: () => _deleteSubject(subject),
                      ),
                    ),
                  const ScreenEndSpacer(),
                ],
              ),
      ),
    );
  }
}

class _SubjectListTile extends StatelessWidget {
  const _SubjectListTile({
    required this.subject,
    required this.onEdit,
    required this.onDelete,
  });

  final StudentSubjectModel subject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: AppColors.stroke),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: subject.displayColor,
          radius: 14.r,
        ),
        title: Text(
          subject.name,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontWeight: FontWeight.w600,
            color: AppColors.mainDark,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (ctx) {
            final l10n = AppLocalizations.of(ctx)!;
            return [
              PopupMenuItem(value: 'edit', child: Text(l10n.studentSubjectsEditMenu)),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  l10n.delete,
                  style: const TextStyle(color: AppColors.red),
                ),
              ),
            ];
          },
        ),
      ),
    );
  }
}

class _SubjectEditorDialog extends StatefulWidget {
  const _SubjectEditorDialog({
    this.existing,
    required this.usedNames,
  });

  final StudentSubjectModel? existing;
  final Set<String> usedNames;

  @override
  State<_SubjectEditorDialog> createState() => _SubjectEditorDialogState();
}

class _SubjectEditorDialogState extends State<_SubjectEditorDialog> {
  late final TextEditingController _nameController;
  late String _color;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _color = widget.existing?.color ?? SubjectColorPalette.defaultColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.existing != null;

    return AlertDialog(
      title: Text(
        isEdit ? l10n.studentSubjectsEditTitle : l10n.studentSubjectsAddTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.studentSubjectsNameLabel,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.studentSubjectsColorLabel,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeSmall,
                color: AppColors.lightText,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: SubjectColorPalette.colors.map((hex) {
                final selected = _color == hex;
                final color = StudentSubjectModel(
                  id: '',
                  name: '',
                  color: hex,
                ).displayColor;
                return GestureDetector(
                  onTap: () => setState(() => _color = hex),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColors.mainDark : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? Icon(Icons.check, color: AppColors.white, size: 16.w)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            if (widget.usedNames.contains(name.toLowerCase())) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.studentSubjectsNameInUse)),
              );
              return;
            }
            if (widget.existing != null) {
              Navigator.pop(
                context,
                widget.existing!.copyWith(name: name, color: _color),
              );
            } else {
              Navigator.pop(
                context,
                StudentSubjectModel(id: '', name: name, color: _color),
              );
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
