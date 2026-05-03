import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/generated/assets.dart';

import '../../../../core/widgets/custom_app_bar.dart';
import '../widgets/ai_tools_cards.dart';
import '../widgets/chat_card.dart';
import '../widgets/search_bar.dart';
import '../../../../main.dart';

class AiToolsScreen extends StatelessWidget {
  final VoidCallback onBack;
  final void Function(CategoryScreenType)? onNavigate;

  const AiToolsScreen({
    super.key,
    required this.onBack,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: MishkaAppBar(
        title: l10n.aiTools,
        showBack: true,
        showBottomBar: false,
        onBackTap: onBack,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            MishkaSearchBar(hintText: l10n.search),
            SizedBox(height: 16.h),
            MishkaChatCard(
              onNavigate: onNavigate != null
                  ? () => onNavigate!(CategoryScreenType.chatWithMishka)
                  : null,
            ),
            SizedBox(height: 16.h),
            FeatureAiSectionCard(
              imagePath: Assets.imagesHomeFlashcardsCard,
              title: l10n.flashCards,
              subtitle: '',
              // TODO: Navigate to Flash Cards screen when implemented
              // For now, navigates to Chat with Mishka where flashcards can be created
              onTap: onNavigate != null
                  ? () => onNavigate!(CategoryScreenType.chatWithMishka)
                  : null,
            ),
            SizedBox(height: 12.h),
            FeatureAiSectionCard(
              imagePath: Assets.imagesHomeSumaryQuizzesCard,
              title: l10n.quizzes,
              subtitle: '',
              // TODO: Navigate to Quizzes screen when implemented
              // For now, navigates to Chat with Mishka where quizzes can be created
              onTap: onNavigate != null
                  ? () => onNavigate!(CategoryScreenType.chatWithMishka)
                  : null,
            ),
            SizedBox(height: 12.h),
            FeatureAiSectionCard(
              imagePath: Assets.imagesHomeSumaryQuizzesCard,
              title: l10n.summarize,
              subtitle: '',
              // TODO: Navigate to Summarize screen when implemented
              // For now, navigates to Chat with Mishka where summaries can be created
              onTap: onNavigate != null
                  ? () => onNavigate!(CategoryScreenType.chatWithMishka)
                  : null,
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
