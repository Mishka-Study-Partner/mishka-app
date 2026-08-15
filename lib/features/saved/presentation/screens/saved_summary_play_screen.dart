import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/saved/data/models/saved_detail_model.dart';
import 'package:mishka_app/features/saved/data/repositories/saved_repository.dart';
import 'package:mishka_app/features/saved/data/saved_detail_cache.dart';
import 'package:mishka_app/features/saved/data/saved_tutor_detail_helpers.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/formatted_study_text.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_focus_metrics.dart';
import 'package:mishka_app/features/saved/presentation/screens/summary_result_screen.dart';
import 'package:mishka_app/features/saved/presentation/widgets/saved_tool_footer.dart';
import 'package:mishka_app/features/saved/presentation/widgets/saved_tutor_play_header.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class SavedSummaryPlayScreen extends StatefulWidget {
  const SavedSummaryPlayScreen({
    super.key,
    required this.savedListItemId,
    required this.title,
    this.sourceFileName,
    this.createdAt,
  });

  final String savedListItemId;
  final String title;
  final String? sourceFileName;
  final DateTime? createdAt;

  @override
  State<SavedSummaryPlayScreen> createState() => _SavedSummaryPlayScreenState();
}

class _SavedSummaryPlayScreenState extends State<SavedSummaryPlayScreen> {
  final SavedRepository _repository = SavedRepository();

  bool _loading = true;
  Object? _error;
  String? _displayTitle;
  String? _sourceFileName;
  String? _summaryText;
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    _displayTitle = widget.title;
    _sourceFileName = widget.sourceFileName;
    _createdAt = widget.createdAt;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _error = null);

    SavedLibraryDetail? cached;
    if (widget.savedListItemId.isNotEmpty) {
      cached = await SavedDetailCache.read(
        SavedContentKind.summary,
        widget.savedListItemId,
      );
    }

    if (!mounted) return;

    final hasUsefulCache = cached != null && cached.raw.isNotEmpty;
    if (hasUsefulCache) {
      await _applyDetail(cached);
      setState(() => _loading = false);
    } else {
      setState(() => _loading = true);
    }

    try {
      if (widget.savedListItemId.isEmpty) {
        throw ApiException(
          message: l10n.savedDetailMissingListId,
          error: 'MISSING_SAVED_LIST_ID',
        );
      }

      final detail =
          await _repository.getSavedSummaryDetail(widget.savedListItemId);
      await SavedDetailCache.write(
        SavedContentKind.summary,
        widget.savedListItemId,
        detail.raw,
      );

      if (!mounted) return;
      await _applyDetail(detail);
      setState(() {
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (hasUsefulCache) {
        setState(() {
          _loading = false;
          _error = null;
        });
        return;
      }
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _applyDetail(SavedLibraryDetail detail) async {
    _displayTitle = detail.resolvedTitle(widget.title);
    _sourceFileName ??=
        await _repository.resolveUploadFilename(detail.raw) ??
        widget.sourceFileName;
    _createdAt ??= readSavedCreatedAt(
      detail.raw,
      nestedKey: 'summary',
    ) ??
        widget.createdAt;
    _summaryText = extractSummaryTextFromRaw(detail.raw);
  }

  Future<void> _finishSummary() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SummaryResultScreen(sourceId: widget.savedListItemId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _displayTitle ?? widget.title;
    final fileName = _sourceFileName?.trim() ?? '';
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.savedSummaryTitle,
        topTitle: l10n.saved,
        showBack: true,
        showBottomBar: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(l10n)
              : (_summaryText == null || _summaryText!.isEmpty)
                  ? _buildEmpty(l10n)
                  : Padding(
                      padding: ToolFocusMetrics.playScreenPadding(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SavedTutorPlayHeader(
                            title: title,
                            sourceFileName: fileName,
                          ),
                          SizedBox(height: ToolFocusMetrics.sectionGap(context)),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(
                                  10.w,
                                  10.h,
                                  10.w,
                                  10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border(
                                    left: BorderSide(
                                      color: AppColors.mainDark,
                                      width: 4.w,
                                    ),
                                  ),
                                ),
                                child: FormattedStudyText(
                                  text: _summaryText!,
                                  textAlign: TextAlign.justify,
                                  baseStyle: TextStyle(
                                    fontFamily: 'Pridi',
                                    fontSize: ToolFocusMetrics.chromeBodySize(context) + 2.sp,
                                    height: 1.5,
                                    color: AppColors.mainDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: ToolFocusMetrics.sectionGap(context)),
                          SavedToolFooter(
                            onDone: _finishSummary,
                            createdAt: _createdAt,
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.savedDetailNotFound,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pridi',
                fontSize: AppSizes.fontSizeMedium,
                color: AppColors.greyText,
              ),
            ),
            SizedBox(height: 16.h),
            IconButton(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              color: AppColors.mainGold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          l10n.savedDetailPlaceholder,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Pridi',
            fontSize: AppSizes.fontSizeMedium,
            color: AppColors.greyText,
          ),
        ),
      ),
    );
  }
}
