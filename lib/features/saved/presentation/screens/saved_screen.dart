import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishka_app/core/utils/app_colors.dart';
import 'package:mishka_app/core/utils/app_sizes.dart';
import 'package:mishka_app/l10n/app_localizations.dart';
import 'package:mishka_app/generated/assets.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../features/Auth/presentation/widgets/custom_segmanted_button.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  int selectedIndex = 0; // 0 = Flash Cards, 1 = Quizzes, 2 = Summary

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: const MishkaAppBar(
        title: "Saved",
        showBack: false,
        showBottomBar: false,
        topTitle: "Saved",
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          children: [
            SizedBox(height: 16.h),
            CustomSegmentedButton(
              selectedIndex: selectedIndex,
              onChanged: (i) => setState(() => selectedIndex = i),
              segments: [
                l10n.flashCards,
                l10n.quizzes,
                l10n.summarize,
              ],
            ),
            SizedBox(height: 24.h),
            Expanded(
              child: _buildContent(context, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    switch (selectedIndex) {
      case 0:
        return _buildFlashCardsTab(context, l10n);
      case 1:
        return _buildQuizzesTab(context, l10n);
      case 2:
        return _buildSummaryTab(context, l10n);
      default:
        return const SizedBox();
    }
  }

  Widget _buildFlashCardsTab(BuildContext context, AppLocalizations l10n) {
    return ListView(
      children: [
        _buildSavedCard(
          context,
          Assets.imagesSavedCard1,
          l10n.savedFlashCards,
          l10n.view,
        ),
        SizedBox(height: 12.h),
        _buildSavedCard(
          context,
          Assets.imagesSavedCard2,
          l10n.savedFlashCards,
          l10n.view,
        ),
        SizedBox(height: 12.h),
        _buildSavedCard(
          context,
          Assets.imagesSavedCard3,
          l10n.savedFlashCards,
          l10n.view,
        ),
      ],
    );
  }

  Widget _buildQuizzesTab(BuildContext context, AppLocalizations l10n) {
    return ListView(
      children: [
        _buildSavedCard(
          context,
          Assets.imagesSavedCard1,
          l10n.savedQuizes,
          l10n.view,
        ),
        SizedBox(height: 12.h),
        _buildSavedCard(
          context,
          Assets.imagesSavedCard2,
          l10n.savedQuizes,
          l10n.view,
        ),
      ],
    );
  }

  Widget _buildSummaryTab(BuildContext context, AppLocalizations l10n) {
    return ListView(
      children: [
        _buildSavedCard(
          context,
          Assets.imagesSavedCard1,
          l10n.savedSummary,
          l10n.view,
        ),
        SizedBox(height: 12.h),
        _buildSavedCard(
          context,
          Assets.imagesSavedCard2,
          l10n.savedSummary,
          l10n.view,
        ),
        SizedBox(height: 12.h),
        _buildSavedCard(
          context,
          Assets.imagesSavedCard3,
          l10n.savedSummary,
          l10n.view,
        ),
      ],
    );
  }

  Widget _buildSavedCard(
    BuildContext context,
    String imagePath,
    String title,
    String actionText,
  ) {
    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusMedium),
              bottomLeft: Radius.circular(AppSizes.radiusMedium),
            ),
            child: Image.asset(
              imagePath,
              width: 120.w,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "Pridi",
                      fontSize: AppSizes.fontSizeXLarge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainDark,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Navigate to detail screen when implemented
                        // This will show the full flashcard/quiz/summary content
                        // For now, this is a placeholder
                      },
                      child: Text(
                        actionText,
                        style: TextStyle(
                          fontFamily: "Pridi",
                          fontSize: AppSizes.fontSizeMedium,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainGold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

