import 'package:mishka_app/features/gamification/data/gamification_badge_type.dart';
import 'package:mishka_app/generated/assets.dart';

class GamificationBadgeAssets {
  GamificationBadgeAssets._();

  static String assetFor(GamificationBadgeType type) {
    return switch (type) {
      GamificationBadgeType.quizPerfect => Assets.imagesPerfectScore,
      GamificationBadgeType.quizScore80 => Assets.imagesScore80,
      GamificationBadgeType.quizKeepLearning => Assets.imagesKeepLearning,
      GamificationBadgeType.flashcardsComplete => Assets.imagesFlashcardsReviewed,
      GamificationBadgeType.summaryComplete => Assets.imagesSummaryReviewed,
      GamificationBadgeType.mindMapComplete => Assets.imagesSummaryReviewed,
      GamificationBadgeType.chatPoints => Assets.imagesChatWithMishkaBadge,
    };
  }

  static String sectionHeroAsset(GamificationSectionHero hero) {
    return switch (hero) {
      GamificationSectionHero.tasks => Assets.imagesFinishingAllYourTasks,
      GamificationSectionHero.study => Assets.imagesMiskaSupport1,
      GamificationSectionHero.community => Assets.imagesMishkaSupport2,
    };
  }
}

enum GamificationSectionHero { tasks, study, community }
