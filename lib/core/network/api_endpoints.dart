/// Backend base URL and path constants (match Express routes).
class ApiEndpoints {
  ApiEndpoints._();

  /// Override with `--dart-define=API_BASE_URL=http://10.0.2.2:3000` for Android emulator.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );

  // --- Auth (public) ---
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';

  // --- Users & app resources (JWT required) ---
  static const String users = '/users';
  static String userById(String id) => '/users/$id';

  static const String passwordResetTokens = '/password-reset-tokens';
  static const String userPreferences = '/user-preferences';
  static const String userSessions = '/user-sessions';
  static const String tips = '/tips';
  static const String userStreaks = '/user-streaks';
  static const String aiTools = '/ai-tools';
  static const String studySessions = '/study-sessions';
  static const String communities = '/communities';
  static const String userCommunities = '/user-communities';
  static const String categories = '/categories';
  static const String userSavedCategories = '/user-saved-categories';
  static const String userAiActivity = '/user-ai-activity';
  static const String chatSessions = '/chat-sessions';
  static const String chatMessages = '/chat-messages';
  static const String aiRequests = '/ai-requests';
  static const String flashcardSets = '/flashcard-sets';
  static const String flashcards = '/flashcards';
  static const String quizzes = '/quizzes';
  static const String quizQuestions = '/quiz-questions';
  static const String summaries = '/summaries';
  static const String historyItems = '/history-items';
  static const String todoLists = '/todo-lists';
  static const String icons = '/icons';
  static const String tasks = '/tasks';

  // --- AI (JWT required; multipart / JSON) ---
  static const String upload = '/upload';
  static const String chat = '/chat';
  static const String generateTools = '/generate-tools';
}
