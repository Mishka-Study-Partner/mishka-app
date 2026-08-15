import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_focus_metrics.dart';
import 'package:mishka_app/features/saved/presentation/widgets/saved_tutor_play_header.dart';
import 'package:mishka_app/features/chat_with_mishka/data/quiz_progress_cache.dart';
import 'package:mishka_app/features/chat_with_mishka/data/quiz_progress_metadata.dart';
import 'package:mishka_app/features/chat_with_mishka/data/tool_data_normalizer.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/tool_preview_renderer.dart';
import 'package:mishka_app/features/saved/data/models/quiz_submit_outcome.dart';
import 'package:mishka_app/features/saved/data/models/saved_detail_model.dart';
import 'package:mishka_app/features/saved/data/repositories/saved_repository.dart';
import 'package:mishka_app/features/saved/data/saved_detail_cache.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

class SavedQuizPlayScreen extends StatefulWidget {
  const SavedQuizPlayScreen({
    super.key,
    required this.savedListItemId,
    required this.title,
    this.sourceFileName,
  });

  final String savedListItemId;
  final String title;
  final String? sourceFileName;

  @override
  State<SavedQuizPlayScreen> createState() => _SavedQuizPlayScreenState();
}

class _SavedQuizPlayScreenState extends State<SavedQuizPlayScreen> {
  final SavedRepository _repository = SavedRepository();

  bool _loading = true;
  Object? _error;
  Map<String, dynamic>? _toolData;
  String? _displayTitle;
  String? _sourceFileName;
  String? _quizId;
  int? _previousScorePercent;

  @override
  void initState() {
    super.initState();
    _displayTitle = widget.title;
    _sourceFileName = widget.sourceFileName;
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
        SavedContentKind.quiz,
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
          await _repository.getSavedQuizDetail(widget.savedListItemId);
      await SavedDetailCache.write(
        SavedContentKind.quiz,
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
    _quizId = detail.tutorEntityId(SavedContentKind.quiz);

    var toolData = buildQuizToolDataFromSavedDetail(
      detail.raw,
      fallbackTitle: widget.title,
    );

    if (toolData != null && _quizId != null && _quizId!.isNotEmpty) {
      toolData['quizId'] = _quizId;
    }

    toolData = QuizProgressCache.mergeStoredProgress(
      toolData ?? const {},
      widget.savedListItemId,
    );

    var previousScore = readQuizProgress(toolData)?.percent;
    if (_quizId != null && _quizId!.isNotEmpty) {
      final best = await _repository.getQuizBestScorePercent(_quizId!);
      if (best != null) {
        previousScore = previousScore == null
            ? best
            : (best > previousScore ? best : previousScore);
      }
    }

    if (!mounted) return;
    setState(() {
      _toolData = toolData;
      _previousScorePercent = previousScore;
    });
  }

  Future<QuizSubmitOutcome?> _submitSavedQuiz({
    required List<Map<String, dynamic>> questions,
    required Map<int, int> selectedAnswers,
  }) async {
    final quizId = _quizId;
    if (quizId == null || quizId.isEmpty) return null;
    return _repository.submitQuizAttempt(
      quizId: quizId,
      questions: questions,
      selectedAnswers: selectedAnswers,
    );
  }

  void _onToolDataUpdated(Map<String, dynamic> updated) {
    setState(() {
      _toolData = updated;
      final progress = readQuizProgress(updated);
      if (progress?.completed == true && progress?.percent != null) {
        _previousScorePercent = progress!.percent;
      }
    });
  }

  void _onPreviousScoreChanged(int? percent) {
    if (percent == null) {
      setState(() => _previousScorePercent = null);
      return;
    }
    setState(() {
      _previousScorePercent =
          _previousScorePercent == null || percent > _previousScorePercent!
              ? percent
              : _previousScorePercent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fileName = _sourceFileName ?? widget.sourceFileName ?? '';
    final title = _displayTitle ?? widget.title;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.savedQuizTitle,
        topTitle: l10n.saved,
        showBack: true,
        showBottomBar: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(l10n)
              : _toolData == null
                  ? _buildEmpty(l10n)
                  : Padding(
                      padding: ToolFocusMetrics.playScreenPadding(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SavedTutorPlayHeader(
                            title: title,
                            sourceFileName: fileName,
                            trailingIcon: Icons.quiz_outlined,
                          ),
                          SizedBox(height: ToolFocusMetrics.sectionGap(context)),
                          Expanded(
                            child: ToolPreviewRenderer(
                              toolData: _toolData!,
                              layout: ToolPreviewLayout.saved,
                              storageMessageId: widget.savedListItemId,
                              previousScorePercent: _previousScorePercent,
                              onToolDataUpdated: _onToolDataUpdated,
                              onPreviousScoreChanged: _onPreviousScoreChanged,
                              onSubmitSavedQuiz: _submitSavedQuiz,
                            ),
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

String formatSavedQuizCreatedAt(DateTime? date, String locale) {
  if (date == null) return '—';
  return DateFormat("d MMM yyyy 'at' hh:mm a", locale).format(date.toLocal());
}
