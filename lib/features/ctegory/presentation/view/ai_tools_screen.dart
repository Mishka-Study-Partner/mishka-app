import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/features/ctegory/utils/ai_tool_ui_helper.dart';
import 'package:mishka_app/features/chat_with_mishka/presentation/screens/direct_tool_generator_screen.dart';
import 'package:mishka_app/features/ctegory/data/models/ai_tool_api_model.dart';
import 'package:mishka_app/features/ctegory/data/repositories/category_repository.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

import 'package:mishka_app/core/widgets/screen_end_spacer.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/ai_tools_cards.dart';
import '../widgets/chat_card.dart';
import '../widgets/search_bar.dart';
import '../../../../main.dart';

class AiToolsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(CategoryScreenType)? onNavigate;

  const AiToolsScreen({
    super.key,
    required this.onBack,
    this.onNavigate,
  });

  @override
  State<AiToolsScreen> createState() => _AiToolsScreenState();
}

class _AiToolsScreenState extends State<AiToolsScreen> {
  final CategoryRepository _repository = CategoryRepository();
  List<AiToolApiModel> _aiTools = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    AiToolUiHelper.evictHomeCardImages();
    _loadAiTools();
  }

  Future<void> _loadAiTools() async {
    setState(() => _isLoading = true);
    try {
      final tools = await _repository.getAiTools();
      if (!mounted) return;
      setState(() => _aiTools = tools);
    } catch (_) {
      // Keep static fallback cards if API fails.
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _imageForTool(String text) => AiToolUiHelper.imageForTitle(text);

  void _openDirectTool(DirectToolKind kind, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DirectToolGeneratorScreen(
          kind: kind,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.aiTools,
        showBack: true,
        showBottomBar: false,
        onBackTap: widget.onBack,
      ),
      body: SingleChildScrollView(
        padding: AppScrollInsets.page(
          horizontal: AppSizes.paddingMedium,
          top: AppSizes.paddingMedium,
        ),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            MishkaSearchBar(hintText: l10n.search),
            SizedBox(height: 8.h),
            MishkaChatCard(
              onNavigate: widget.onNavigate != null
                  ? () => widget.onNavigate!(CategoryScreenType.chatWithMishka)
                  : null,
            ),
            SizedBox(height: 8.h),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_aiTools.isEmpty) ...[
              for (final entry in [
                (DirectToolKind.flashcards, l10n.flashCards),
                (DirectToolKind.quiz, l10n.quizzes),
                (DirectToolKind.summarize, l10n.summarize),
                (DirectToolKind.mindmap, l10n.mindMap),
              ])
                FeatureAiSectionCard(
                  imagePath: AiToolUiHelper.imageForTitle(entry.$2),
                  title: entry.$2,
                  subtitle: '',
                  onTap: () => _openDirectTool(entry.$1, entry.$2),
                ),
            ] else
              ..._aiTools.map((tool) {
                final kind = AiToolUiHelper.directKindForTitle(tool.title);
                return FeatureAiSectionCard(
                  imagePath: _imageForTool(tool.title),
                  title: tool.title,
                  subtitle: tool.subtitle ?? '',
                  onTap: kind == null
                      ? (widget.onNavigate != null
                          ? () => widget.onNavigate!(CategoryScreenType.chatWithMishka)
                          : null)
                      : () => _openDirectTool(kind, tool.title),
                );
              }),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
