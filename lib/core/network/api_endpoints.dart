/// Backend base URL and path constants (match Express routes).
class ApiEndpoints {
  ApiEndpoints._();

  /// Override with `--dart-define=API_BASE_URL=https://...` when needed.
  /// Production: `https://mishka-backend-production.up.railway.app`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://fleshy-lemon-persevere.ngrok-free.dev',
  );

  // --- Public (no JWT) ---
  static const String publicAppSettings = '/public/app-settings';

  // --- Auth (public + JWT) ---
  static const String authRegister = '/auth/register';
  static const String authSendSignupOtp = '/auth/send-signup-otp';
  static const String authVerifySignupOtp = '/auth/verify-signup-otp';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authMeAvatar = '/auth/me/avatar';
  static const String authLogout = '/auth/logout';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';

  // --- Users & app resources (JWT required) ---
  static const String users = '/users';
  static String userById(String id) => '/users/$id';

  static const String passwordResetTokens = '/password-reset-tokens';
  static const String userPreferences = '/user-preferences';
  static String userPreferenceById(String id) => '/user-preferences/$id';

  /// Canonical upsert for the signed-in user (`language`, `theme`, `notificationsEnabled`).
  static String userPreferencesForUser(String userId) =>
      '/users/$userId/preferences';
  static const String userSessions = '/user-sessions';
  static const String tips = '/tips';
  static const String userStreaks = '/user-streaks';
  static const String dailyStreaks = '/daily-streaks';
  static const String dailyStreaksPing = '/daily-streaks/ping';
  static const String dailyStreaksFreeze = '/daily-streaks/freeze';
  static const String aiTools = '/ai-tools';
  static const String studySessions = '/study-sessions';
  static const String communities = '/communities';
  static const String communitiesRecommended = '/communities/recommended';
  static const String communitiesDiscover = '/communities/discover';
  static const String communitiesDiscoverCategories =
      '/communities/discover/categories';
  static const String communitiesJoin = '/communities/join';
  static const String userCommunities = '/user-communities';
  static String communityById(String id) => '/communities/$id';
  static String communityLeave(String id) => '/communities/$id/leave';
  static String communityPin(String id) => '/communities/$id/pin';
  static String communityInvite(String id) => '/communities/$id/invite';
  static String communityInviteRegenerate(String id) =>
      '/communities/$id/invite/regenerate';
  static String communityMembers(String id) => '/communities/$id/members';
  static String communityMemberByUserId(String communityId, String userId) =>
      '/communities/$communityId/members/$userId';
  static String communityChannels(String communityId) =>
      '/communities/$communityId/channels';
  static String communityChannelById(String communityId, String channelId) =>
      '/communities/$communityId/channels/$channelId';
  static String communityChannelJoin(String communityId, String channelId) =>
      '/communities/$communityId/channels/$channelId/join';
  static String communityChannelDuplicate(String communityId, String channelId) =>
      '/communities/$communityId/channels/$channelId/duplicate';
  static String communityChannelMessages(String communityId, String channelId) =>
      '/communities/$communityId/channels/$channelId/messages';
  static const String categories = '/categories';
  static const String userSavedCategories = '/user-saved-categories';
  static String userSavedCategoryById(String id) =>
      '/user-saved-categories/$id';
  static const String userAiActivity = '/user-ai-activity';
  static const String chatSessions = '/chat-sessions';
  static String chatSessionById(String id) => '/chat-sessions/$id';
  static String chatSessionMessages(String id) => '/chat-sessions/$id/messages';
  static String chatSessionTimeline(String id) => '/chat-sessions/$id/timeline';
  static const String chatMessages = '/chat-messages';
  static const String aiRequests = '/ai-requests';
  static const String flashcardSets = '/flashcard-sets';
  static const String flashcards = '/flashcards';
  static const String quizzes = '/quizzes';
  static const String quizQuestions = '/quiz-questions';
  static const String summaries = '/summaries';
  static const String mindMaps = '/mind-maps';
  static const String savedQuizzes = '/saved-quizzes';
  static const String savedFlashcardSets = '/saved-flashcard-sets';
  static const String savedSummaries = '/saved-summaries';
  static const String savedMindMaps = '/saved-mind-maps';
  static String quizShareById(String id) => '/quizzes/$id/share';
  static String flashcardSetShareById(String id) => '/flashcard-sets/$id/share';
  static String summaryShareById(String id) => '/summaries/$id/share';
  static String mindMapShareById(String id) => '/mind-maps/$id/share';
  static String savedQuizShareById(String id) => '/saved-quizzes/$id/share';
  static String savedFlashcardSetShareById(String id) =>
      '/saved-flashcard-sets/$id/share';
  static String savedSummaryShareById(String id) =>
      '/saved-summaries/$id/share';
  static String savedMindMapShareById(String id) =>
      '/saved-mind-maps/$id/share';

  /// Saved-library detail (`{id}` = list row `id` from GET `/saved-*`).
  static String savedQuizDetailById(String id) => '/saved-quizzes/$id';
  static String savedFlashcardSetDetailById(String id) =>
      '/saved-flashcard-sets/$id';
  static String savedSummaryDetailById(String id) => '/saved-summaries/$id';
  static String savedMindMapDetailById(String id) => '/saved-mind-maps/$id';

  /// Direct tutor entity URLs (outside saved-library wrappers).
  static String quizById(String id) => '/quizzes/$id';
  static String flashcardSetById(String id) => '/flashcard-sets/$id';
  static String summaryById(String id) => '/summaries/$id';
  static String mindMapById(String id) => '/mind-maps/$id';
  static const String historyItems = '/history-items';
  static const String todoLists = '/todo-lists';
  static String todoListById(String id) => '/todo-lists/$id';
  static const String icons = '/icons';
  static const String tasks = '/tasks';
  static String taskById(String id) => '/tasks/$id';

  // --- Study With Mishka ---
  static const String studyWithMishkaCatalog = '/study-with-mishka/catalog';
  static const String studyWithMishkaCustomTimers = '/study-with-mishka/custom-timers';
  static String studyWithMishkaCustomTimerById(String id) => '/study-with-mishka/custom-timers/$id';
  static const String studyWithMishkaSessionStart = '/study-with-mishka/sessions/start';
  static const String studyWithMishkaSessions = '/study-with-mishka/sessions';
  static String studyWithMishkaSessionById(String id) => '/study-with-mishka/sessions/$id';
  static String studyWithMishkaSessionPause(String id) => '/study-with-mishka/sessions/$id/pause';
  static String studyWithMishkaSessionResume(String id) => '/study-with-mishka/sessions/$id/resume';
  static String studyWithMishkaSessionEnd(String id) => '/study-with-mishka/sessions/$id/end';
  static String studyWithMishkaSessionAdvancePhase(String id) => '/study-with-mishka/sessions/$id/advance-phase';
  static String studyWithMishkaSessionCheckIns(String id) => '/study-with-mishka/sessions/$id/check-ins';
  static String studyWithMishkaCallBreakStart(String id) => '/study-with-mishka/sessions/$id/call-break/start';
  static String studyWithMishkaCallBreakEnd(String id) => '/study-with-mishka/sessions/$id/call-break/end';
  static const String studyWithMishkaStatsSummary = '/study-with-mishka/stats/summary';
  static const String studyWithMishkaReportsDay = '/study-with-mishka/reports/day';
  static const String studyWithMishkaReportsWeek = '/study-with-mishka/reports/week';
  static const String studyWithMishkaReportsMonth = '/study-with-mishka/reports/month';
  static const String studyWithMishkaReportsYear = '/study-with-mishka/reports/year';

  // --- Your Report (unified bundle + PDF export) ---
  static const String yourReport = '/reports/your-report';
  static const String yourReportExport = '/reports/your-report/export';
  static String yourReportExportDownload(String reportId) =>
      '/reports/your-report/export/$reportId';

  // --- User preferences (report auto-email) ---
  static const String userPreferencesMe = '/user-preferences/me';
  static const String userAiActivityReport = '/user-ai-activity/report';
  static const String tasksReportCompletions = '/tasks/report/completions';
  static const String dailyStreaksHistory = '/daily-streaks/history';
  static const String communitiesActivityReport = '/communities/activity/report';

  // --- AI (JWT required; multipart / JSON) ---
  static const String upload = '/upload';
  static const String chat = '/chat';
  static const String generateTools = '/generate-tools';
}
