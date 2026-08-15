import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/widgets/custom_app_bar.dart';
import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import 'package:mishka_app/features/chat_with_mishka/data/quiz_progress_cache.dart';
import 'package:mishka_app/features/chat_with_mishka/data/quiz_progress_metadata.dart';
import 'package:mishka_app/features/chat_with_mishka/data/tool_data_normalizer.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/screens/quiz_result_screen.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import '../widgets/tool_preview_renderer.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.toolData,
    this.storageMessageId,
    this.onToolDataUpdated,
  });

  final Map<String, dynamic> toolData;
  final String? storageMessageId;
  final ValueChanged<Map<String, dynamic>>? onToolDataUpdated;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Map<String, dynamic> _toolData;
  var _openedCompletedResult = false;

  @override
  void initState() {
    super.initState();
    _toolData = QuizProgressCache.mergeStoredProgress(
      normalizeToolData(Map<String, dynamic>.from(widget.toolData)),
      widget.storageMessageId,
    );
    _toolData.putIfAbsent('tool_type', () => 'quizzes');
    _maybeOpenCompletedResult();
  }

  void _maybeOpenCompletedResult() {
    final progress = readQuizProgress(_toolData);
    if (progress == null || !progress.completed || progress.percent == null) {
      return;
    }
    final completed = progress;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _openedCompletedResult) return;
      _openedCompletedResult = true;
      final total = (_toolData['questions'] as List?)?.length ?? 0;
      final correct =
          completed.questionCorrect.values.where((ok) => ok).length;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => QuizResultScreen(
            percent: completed.percent!,
            correctCount: correct,
            totalCount: total,
            sourceId: widget.storageMessageId ?? '',
          ),
        ),
      );
    });
  }

  void _handleToolDataUpdated(Map<String, dynamic> updated) {
    setState(() => _toolData = updated);
    widget.onToolDataUpdated?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.quizzes,
        showBack: true,
        showBottomBar: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppScrollInsets.page(horizontal: 16.w, top: 16.h, bottom: 24.h),
          child: ToolPreviewRenderer(
            toolData: _toolData,
            layout: ToolPreviewLayout.expanded,
            storageMessageId: widget.storageMessageId,
            onToolDataUpdated: _handleToolDataUpdated,
          ),
        ),
      ),
    );
  }
}
