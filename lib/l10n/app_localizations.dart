import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Mishka'**
  String get appTitle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createAccountAtMishka.
  ///
  /// In en, this message translates to:
  /// **'Create your account at MISHKA'**
  String get createAccountAtMishka;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @exampleEmail.
  ///
  /// In en, this message translates to:
  /// **'Example1234@gmail.com'**
  String get exampleEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @examplePassword.
  ///
  /// In en, this message translates to:
  /// **'Pass123#!\\\$'**
  String get examplePassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget Password?'**
  String get forgetPassword;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'Agree to terms and conditions & privacy policy'**
  String get agreeToTerms;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have account? Sign In'**
  String get alreadyHaveAccount;

  /// No description provided for @orSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'or sign up with'**
  String get orSignUpWith;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @welcomeBackToMishka.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to MISHKA'**
  String get welcomeBackToMishka;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have account? create account'**
  String get dontHaveAccount;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordUsing.
  ///
  /// In en, this message translates to:
  /// **'Reset your password using:'**
  String get resetPasswordUsing;

  /// No description provided for @writeEmailForCode.
  ///
  /// In en, this message translates to:
  /// **'write your email to receive your confirmation code to create your new password'**
  String get writeEmailForCode;

  /// No description provided for @getCode.
  ///
  /// In en, this message translates to:
  /// **'Get Code'**
  String get getCode;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @verifyByEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify by Email Address'**
  String get verifyByEmail;

  /// No description provided for @enter5DigitsCodeEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the 5 digits code you received at your gmail: {email}'**
  String enter5DigitsCodeEmail(String email);

  /// No description provided for @enter6DigitsCodeEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6 digits code you received at your gmail: {email}'**
  String enter6DigitsCodeEmail(String email);

  /// No description provided for @enter6DigitsCodePhone.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6 digits code you received (SMS) at {phone}'**
  String enter6DigitsCodePhone(String phone);

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @successfullyVerified.
  ///
  /// In en, this message translates to:
  /// **'Successfully Verified'**
  String get successfullyVerified;

  /// No description provided for @letsStartSettingAccount.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start setting your account so you can start using the app'**
  String get letsStartSettingAccount;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterNewPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New password'**
  String get confirmNewPassword;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'your password must contain:'**
  String get passwordRequirements;

  /// No description provided for @passwordRequirement1.
  ///
  /// In en, this message translates to:
  /// **'Between 8 and 20 characters'**
  String get passwordRequirement1;

  /// No description provided for @passwordRequirement2.
  ///
  /// In en, this message translates to:
  /// **'1 upper case letter'**
  String get passwordRequirement2;

  /// No description provided for @passwordRequirement3.
  ///
  /// In en, this message translates to:
  /// **'1 or more numbers'**
  String get passwordRequirement3;

  /// No description provided for @passwordRequirement4.
  ///
  /// In en, this message translates to:
  /// **'1 or more special character'**
  String get passwordRequirement4;

  /// No description provided for @setPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get setPassword;

  /// No description provided for @passwordSuccessfullySet.
  ///
  /// In en, this message translates to:
  /// **'Password Is Successfully Set'**
  String get passwordSuccessfullySet;

  /// No description provided for @writePhoneForCode.
  ///
  /// In en, this message translates to:
  /// **'write your PHONE NUMBER to receive your confirmation code to create your new password'**
  String get writePhoneForCode;

  /// No description provided for @verifyByPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify by phone number'**
  String get verifyByPhoneNumber;

  /// No description provided for @enter5DigitsCodePhone.
  ///
  /// In en, this message translates to:
  /// **'Enter the 5 digits code you received (SMS) at {phone}'**
  String enter5DigitsCodePhone(String phone);

  /// No description provided for @welcomeBackSara.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Back Ziad!'**
  String get welcomeBackSara;

  /// No description provided for @sundayJan26.
  ///
  /// In en, this message translates to:
  /// **'Sunday, Jan 26, 2026'**
  String get sundayJan26;

  /// No description provided for @dailyStreaks.
  ///
  /// In en, this message translates to:
  /// **'Daily Streaks:'**
  String get dailyStreaks;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String days(int count);

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get completed;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @streakStats.
  ///
  /// In en, this message translates to:
  /// **'Best: {longest} · {freezes} freezes left'**
  String streakStats(int longest, int freezes);

  /// No description provided for @streakMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed (tap to freeze)'**
  String get streakMissed;

  /// No description provided for @streakFreezeTitle.
  ///
  /// In en, this message translates to:
  /// **'Use streak freeze?'**
  String get streakFreezeTitle;

  /// No description provided for @streakFreezeMessage.
  ///
  /// In en, this message translates to:
  /// **'Protect your streak for {date}?'**
  String streakFreezeMessage(String date);

  /// No description provided for @streakFreezeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Use freeze'**
  String get streakFreezeConfirm;

  /// No description provided for @streakFreezeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Streak freeze applied'**
  String get streakFreezeSuccess;

  /// No description provided for @streakFreezeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not apply streak freeze'**
  String get streakFreezeFailed;

  /// No description provided for @tipOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Tip Of The Day'**
  String get tipOfTheDay;

  /// No description provided for @tipQuote.
  ///
  /// In en, this message translates to:
  /// **'I am more impressed by your effort and your process than by the final grade.'**
  String get tipQuote;

  /// No description provided for @upComingDeadlines.
  ///
  /// In en, this message translates to:
  /// **'Up Coming Deadlines:'**
  String get upComingDeadlines;

  /// No description provided for @viewYourToDoList.
  ///
  /// In en, this message translates to:
  /// **'View your To Do List'**
  String get viewYourToDoList;

  /// No description provided for @task.
  ///
  /// In en, this message translates to:
  /// **'Task:'**
  String get task;

  /// No description provided for @plcSheet2Offline.
  ///
  /// In en, this message translates to:
  /// **'PLC sheet 2 (offline)'**
  String get plcSheet2Offline;

  /// No description provided for @meetingForGraduationProject.
  ///
  /// In en, this message translates to:
  /// **'Meating for Graduation project'**
  String get meetingForGraduationProject;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List:'**
  String get list;

  /// No description provided for @collegeTasksList.
  ///
  /// In en, this message translates to:
  /// **'College Tasks List.'**
  String get collegeTasksList;

  /// No description provided for @workTasksList.
  ///
  /// In en, this message translates to:
  /// **'Work Tasks List.'**
  String get workTasksList;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline:'**
  String get deadline;

  /// No description provided for @sunJan262025.
  ///
  /// In en, this message translates to:
  /// **'Sun, Jan 26, 2025'**
  String get sunJan262025;

  /// No description provided for @pm700.
  ///
  /// In en, this message translates to:
  /// **'07:00 pm'**
  String get pm700;

  /// No description provided for @pm900.
  ///
  /// In en, this message translates to:
  /// **'09:00 pm'**
  String get pm900;

  /// No description provided for @pm200.
  ///
  /// In en, this message translates to:
  /// **'02:00 pm'**
  String get pm200;

  /// No description provided for @mishkasAiTools.
  ///
  /// In en, this message translates to:
  /// **'Mishka\'s AI Tools:'**
  String get mishkasAiTools;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get viewMore;

  /// No description provided for @chatWithMishka.
  ///
  /// In en, this message translates to:
  /// **'Chat with Mishka'**
  String get chatWithMishka;

  /// No description provided for @yourHistory.
  ///
  /// In en, this message translates to:
  /// **'Your History'**
  String get yourHistory;

  /// No description provided for @searchYourHistory.
  ///
  /// In en, this message translates to:
  /// **'Search your history...'**
  String get searchYourHistory;

  /// No description provided for @historyChats.
  ///
  /// In en, this message translates to:
  /// **'chats:'**
  String get historyChats;

  /// No description provided for @historyQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes:'**
  String get historyQuizzes;

  /// No description provided for @historyFlashCards.
  ///
  /// In en, this message translates to:
  /// **'FlashCards:'**
  String get historyFlashCards;

  /// No description provided for @historySummarization.
  ///
  /// In en, this message translates to:
  /// **'Summarization :'**
  String get historySummarization;

  /// No description provided for @historyMindMaps.
  ///
  /// In en, this message translates to:
  /// **'Mind Maps:'**
  String get historyMindMaps;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No history found'**
  String get historyEmpty;

  /// No description provided for @historyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this chat session'**
  String get historyLoadFailed;

  /// No description provided for @chatGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, please upload your material to start our journey'**
  String get chatGreeting;

  /// No description provided for @chatAnalyzingPdf.
  ///
  /// In en, this message translates to:
  /// **'Analyzing PDF...'**
  String get chatAnalyzingPdf;

  /// No description provided for @chatWhichTool.
  ///
  /// In en, this message translates to:
  /// **'Which tool would you like to use?'**
  String get chatWhichTool;

  /// No description provided for @chatWaitForExplanation.
  ///
  /// In en, this message translates to:
  /// **'Please wait for the explanation to complete first.'**
  String get chatWaitForExplanation;

  /// No description provided for @chatUploadPdfHint.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF to start'**
  String get chatUploadPdfHint;

  /// No description provided for @chatChooseDifficultyHint.
  ///
  /// In en, this message translates to:
  /// **'Choose difficulty above'**
  String get chatChooseDifficultyHint;

  /// No description provided for @chatDifficultySimple.
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get chatDifficultySimple;

  /// No description provided for @chatDifficultyIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get chatDifficultyIntermediate;

  /// No description provided for @chatDifficultyAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get chatDifficultyAdvanced;

  /// No description provided for @chatToolQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get chatToolQuiz;

  /// No description provided for @chatToolFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get chatToolFlashcards;

  /// No description provided for @chatToolMindMap.
  ///
  /// In en, this message translates to:
  /// **'Mind Map'**
  String get chatToolMindMap;

  /// No description provided for @chatToolSummarize.
  ///
  /// In en, this message translates to:
  /// **'Summarize'**
  String get chatToolSummarize;

  /// No description provided for @chatRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get chatRegenerate;

  /// No description provided for @chatAnotherTool.
  ///
  /// In en, this message translates to:
  /// **'Another Tool'**
  String get chatAnotherTool;

  /// No description provided for @chatToolSelected.
  ///
  /// In en, this message translates to:
  /// **'Great! You selected: {tool}. Generating it for you...'**
  String chatToolSelected(String tool);

  /// No description provided for @chatRegenerating.
  ///
  /// In en, this message translates to:
  /// **'Regenerating {tool}...'**
  String chatRegenerating(String tool);

  /// No description provided for @chatRegenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Regeneration failed.\n{error}'**
  String chatRegenerationFailed(String error);

  /// No description provided for @chatAnalyzePdfFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze PDF.\n{error}'**
  String chatAnalyzePdfFailed(String error);

  /// No description provided for @chatToolGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Tool generation failed.\n{error}'**
  String chatToolGenerationFailed(String error);

  /// No description provided for @chatMessageFailed.
  ///
  /// In en, this message translates to:
  /// **'Chat failed.\n{error}'**
  String chatMessageFailed(String error);

  /// No description provided for @chatSessionStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start chat session.\n{error}'**
  String chatSessionStartFailed(String error);

  /// No description provided for @chatNewChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new chat?'**
  String get chatNewChatTitle;

  /// No description provided for @chatNewChatMessage.
  ///
  /// In en, this message translates to:
  /// **'Your current conversation stays in history. You can reopen it from the menu.'**
  String get chatNewChatMessage;

  /// No description provided for @chatNewChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get chatNewChatConfirm;

  /// No description provided for @chatNewChatAction.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get chatNewChatAction;

  /// No description provided for @renameSavedItem.
  ///
  /// In en, this message translates to:
  /// **'Rename item'**
  String get renameSavedItem;

  /// No description provided for @savedItemRenamed.
  ///
  /// In en, this message translates to:
  /// **'Item renamed'**
  String get savedItemRenamed;

  /// No description provided for @savedRenameUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This item cannot be renamed'**
  String get savedRenameUnavailable;

  /// No description provided for @savedItemTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get savedItemTitleHint;

  /// No description provided for @summarizeWithMishka.
  ///
  /// In en, this message translates to:
  /// **'Summarize with Mishka'**
  String get summarizeWithMishka;

  /// No description provided for @makeFlashcardsWithMishka.
  ///
  /// In en, this message translates to:
  /// **'Make Flashcards with Mishka'**
  String get makeFlashcardsWithMishka;

  /// No description provided for @makeQuizzesWithMishka.
  ///
  /// In en, this message translates to:
  /// **'Make Quizes with Mishka'**
  String get makeQuizzesWithMishka;

  /// No description provided for @studyWithMishka.
  ///
  /// In en, this message translates to:
  /// **'Study With Mishka:'**
  String get studyWithMishka;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @mishkasCommunity.
  ///
  /// In en, this message translates to:
  /// **'Mishka\'s Community:'**
  String get mishkasCommunity;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @youCanAddNewCommunity.
  ///
  /// In en, this message translates to:
  /// **'You can add new Community'**
  String get youCanAddNewCommunity;

  /// No description provided for @youCanRejoinSavedCommunity.
  ///
  /// In en, this message translates to:
  /// **'You can rejoin your saved Community'**
  String get youCanRejoinSavedCommunity;

  /// No description provided for @exploreCommunitiesByMajor.
  ///
  /// In en, this message translates to:
  /// **'Explore Our communities based on your major'**
  String get exploreCommunitiesByMajor;

  /// No description provided for @mishkasSupport.
  ///
  /// In en, this message translates to:
  /// **'Mishka\'s Support:'**
  String get mishkasSupport;

  /// No description provided for @exploreMore.
  ///
  /// In en, this message translates to:
  /// **'Explore more'**
  String get exploreMore;

  /// No description provided for @countDailyStudyHours.
  ///
  /// In en, this message translates to:
  /// **'Count Your daily study hours with Mishka'**
  String get countDailyStudyHours;

  /// No description provided for @winMishkasChallenges.
  ///
  /// In en, this message translates to:
  /// **'Win Mishka\'s Challenges and get your Prize'**
  String get winMishkasChallenges;

  /// No description provided for @getPointsByChatting.
  ///
  /// In en, this message translates to:
  /// **'Get Points by chatting with Mishka everyday'**
  String get getPointsByChatting;

  /// No description provided for @viewAllBadgesMonthly.
  ///
  /// In en, this message translates to:
  /// **'View all your Badges monthly with Mishka'**
  String get viewAllBadgesMonthly;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @toDo.
  ///
  /// In en, this message translates to:
  /// **'To-Do'**
  String get toDo;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileFieldNotSet.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get profileFieldNotSet;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh profile.'**
  String get profileLoadFailed;

  /// No description provided for @removeProfilePhotoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove your profile photo?'**
  String get removeProfilePhotoConfirm;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile.'**
  String get profileUpdateFailed;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get fieldRequired;

  /// No description provided for @invalidEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmailHint;

  /// No description provided for @invalidPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number.'**
  String get invalidPhoneHint;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name must be 50 characters or fewer.'**
  String get nameTooLong;

  /// No description provided for @accountAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email or phone number already exists.'**
  String get accountAlreadyExists;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @aiTools.
  ///
  /// In en, this message translates to:
  /// **'Ai tools'**
  String get aiTools;

  /// No description provided for @aiToolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chat with Mishka, Quizzes, Flash Cards, Summary.'**
  String get aiToolsSubtitle;

  /// No description provided for @toDoList.
  ///
  /// In en, this message translates to:
  /// **'To Do List'**
  String get toDoList;

  /// No description provided for @yourToDoList.
  ///
  /// In en, this message translates to:
  /// **'Your To do list.'**
  String get yourToDoList;

  /// No description provided for @studyWithMe.
  ///
  /// In en, this message translates to:
  /// **'Study with Me'**
  String get studyWithMe;

  /// No description provided for @studyWithMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'solo mode, group mode, Mishka partner.'**
  String get studyWithMeSubtitle;

  /// No description provided for @ourCommunity.
  ///
  /// In en, this message translates to:
  /// **'Our Community'**
  String get ourCommunity;

  /// No description provided for @ourCommunitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mentor Library, Events community, Mentorship History.'**
  String get ourCommunitySubtitle;

  /// No description provided for @gamification.
  ///
  /// In en, this message translates to:
  /// **'Gamification'**
  String get gamification;

  /// No description provided for @gamificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'points, streaks, Badges, Challenges.'**
  String get gamificationSubtitle;

  /// No description provided for @accountSetting.
  ///
  /// In en, this message translates to:
  /// **'Account Setting:'**
  String get accountSetting;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name:'**
  String get fullName;

  /// No description provided for @yourFullName.
  ///
  /// In en, this message translates to:
  /// **'Your Full Name'**
  String get yourFullName;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name:'**
  String get userName;

  /// No description provided for @yourUserName.
  ///
  /// In en, this message translates to:
  /// **'Your user Name'**
  String get yourUserName;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender:'**
  String get gender;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @ratherNotToSay.
  ///
  /// In en, this message translates to:
  /// **'rather not to say'**
  String get ratherNotToSay;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Info:'**
  String get contactInfo;

  /// No description provided for @exampleEmailContact.
  ///
  /// In en, this message translates to:
  /// **'example123@gmail.com'**
  String get exampleEmailContact;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language:'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme:'**
  String get theme;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification:'**
  String get notification;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @chooseAppearance.
  ///
  /// In en, this message translates to:
  /// **'Choose appearance'**
  String get chooseAppearance;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language, theme, notifications'**
  String get settingsSubtitle;

  /// No description provided for @settingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how Mishka looks and how we reach you. Changes apply on this device and sync to your account when you are signed in.'**
  String get settingsDescription;

  /// No description provided for @settingsPreferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferencesSection;

  /// No description provided for @settingsSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sync settings to your account. Your choice is saved on this device.'**
  String get settingsSyncFailed;

  /// No description provided for @privacyPolicyBody.
  ///
  /// In en, this message translates to:
  /// **'Mishka respects your privacy. We collect only the information needed to run your account, personalize study features, and improve the app.\n\nWe use your email and profile details to authenticate you and to communicate about your account. Study activity, tasks, and AI interactions are stored to provide history, streaks, and tutoring features you use.\n\nWe do not sell your personal data. We may share limited data with service providers that host our infrastructure and deliver notifications, under strict confidentiality.\n\nYou can update your profile, education details, and preferences in the app. Contact support if you need access, correction, or deletion of your data.\n\nThis summary is provided for convenience. A full legal policy may be published separately on our website.'**
  String get privacyPolicyBody;

  /// No description provided for @helpSupportIntro.
  ///
  /// In en, this message translates to:
  /// **'Need help with Mishka? Reach us using the contacts below, or read the quick tips in this screen when contacts are not configured yet.'**
  String get helpSupportIntro;

  /// No description provided for @helpSupportContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get helpSupportContactsTitle;

  /// No description provided for @helpSupportTapToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap a row to open Gmail, WhatsApp, or the link in its app.'**
  String get helpSupportTapToOpen;

  /// No description provided for @linkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open this link on your device.'**
  String get linkOpenFailed;

  /// No description provided for @linkOpenFailedCopied.
  ///
  /// In en, this message translates to:
  /// **'Could not open the app — copied to clipboard instead.'**
  String get linkOpenFailedCopied;

  /// No description provided for @supportFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get supportFacebook;

  /// No description provided for @supportInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get supportInstagram;

  /// No description provided for @supportWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get supportWhatsApp;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @helpSupportBody.
  ///
  /// In en, this message translates to:
  /// **'Need help with Mishka? Here is how to get unstuck.\n\nAccount & sign-in: Use Forgot password on the login screen if you cannot sign in. Make sure your email or phone matches what you registered with.\n\nStudy With Mishka: Start a session from Home, pick a timer, and stay on the session screen until you finish or end early. If a session fails to start, check your connection and try again.\n\nTasks & lists: Create lists from the To-Do area, then add tasks with deadlines. Pull to refresh on Home to see upcoming tasks.\n\nProfile & education: Open Profile to edit your name, contact info, gender, and education level. Use Settings for language, theme, and notifications.\n\nStill stuck? Email our team at support@mishka.app with a short description and screenshots if possible. We typically reply within a few business days.'**
  String get helpSupportBody;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search ...'**
  String get search;

  /// No description provided for @chatWithMishkaTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat with MISHKA'**
  String get chatWithMishkaTitle;

  /// No description provided for @flashCards.
  ///
  /// In en, this message translates to:
  /// **'Flash Cards'**
  String get flashCards;

  /// No description provided for @quizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzes;

  /// No description provided for @summarize.
  ///
  /// In en, this message translates to:
  /// **'Summarize'**
  String get summarize;

  /// No description provided for @mishka.
  ///
  /// In en, this message translates to:
  /// **'Mishka'**
  String get mishka;

  /// No description provided for @helloSara.
  ///
  /// In en, this message translates to:
  /// **'Hello, Sara!'**
  String get helloSara;

  /// No description provided for @askMishka.
  ///
  /// In en, this message translates to:
  /// **'Ask MISHKA ....'**
  String get askMishka;

  /// No description provided for @apologizeNotUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I apologize, but I did not understand this input'**
  String get apologizeNotUnderstand;

  /// No description provided for @pleaseClarify.
  ///
  /// In en, this message translates to:
  /// **'Could you please clarify your request .'**
  String get pleaseClarify;

  /// No description provided for @tellMeMoreAboutMishkaApp.
  ///
  /// In en, this message translates to:
  /// **'tell me more about MISHKA app?'**
  String get tellMeMoreAboutMishkaApp;

  /// No description provided for @mishkaDescription.
  ///
  /// In en, this message translates to:
  /// **'Mishka is an AI-powered interactive study companion, designed to address the major obstacles faced by students in modern education: difficulty understanding complex material, distraction, lack of motivation, and limited collaboration opportunities. By combining artificial intelligence, gamification, and inclusive design into one integrated platform, Mishka transforms studying from an isolating and stressful activity into an engaging, structured, and rewarding experience.'**
  String get mishkaDescription;

  /// No description provided for @whatMakesMishkaBetter.
  ///
  /// In en, this message translates to:
  /// **'But What makes MISHKA better than other applications?'**
  String get whatMakesMishkaBetter;

  /// No description provided for @mishkaBetterDescription.
  ///
  /// In en, this message translates to:
  /// **'Mishka stands out from other study apps by integrating AI, gamification, and inclusive design into a single platform, moving beyond basic tutoring to tackle the major student obstacles of complex material, distraction, and lack of motivation, transforming studying into an engaging, structured, and rewarding experience for all.'**
  String get mishkaBetterDescription;

  /// No description provided for @uploadFiles.
  ///
  /// In en, this message translates to:
  /// **'Upload Files'**
  String get uploadFiles;

  /// No description provided for @uploadPDF.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF'**
  String get uploadPDF;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @uploadVideo.
  ///
  /// In en, this message translates to:
  /// **'Upload Video'**
  String get uploadVideo;

  /// No description provided for @uploadArticle.
  ///
  /// In en, this message translates to:
  /// **'Upload Article'**
  String get uploadArticle;

  /// No description provided for @pdfsName.
  ///
  /// In en, this message translates to:
  /// **'pdf\'s name'**
  String get pdfsName;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @pdf.
  ///
  /// In en, this message translates to:
  /// **'pdf'**
  String get pdf;

  /// No description provided for @fileLower.
  ///
  /// In en, this message translates to:
  /// **'file'**
  String get fileLower;

  /// No description provided for @pngJpeg.
  ///
  /// In en, this message translates to:
  /// **'png/jpeg'**
  String get pngJpeg;

  /// No description provided for @article.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get article;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'text'**
  String get text;

  /// No description provided for @mp3.
  ///
  /// In en, this message translates to:
  /// **'mp3'**
  String get mp3;

  /// No description provided for @pleaseEnterMaterialFlashcards.
  ///
  /// In en, this message translates to:
  /// **'please enter your material so I can create flashcards for you.'**
  String get pleaseEnterMaterialFlashcards;

  /// No description provided for @pleaseEnterMaterialQuizzes.
  ///
  /// In en, this message translates to:
  /// **'please enter your material so I can turn them to mcq Quizzes.'**
  String get pleaseEnterMaterialQuizzes;

  /// No description provided for @pleaseEnterMaterialSummarize.
  ///
  /// In en, this message translates to:
  /// **'please enter your material so I can Summarize them for you.'**
  String get pleaseEnterMaterialSummarize;

  /// No description provided for @thisIsYourFlashcards.
  ///
  /// In en, this message translates to:
  /// **'This is your flashcards:'**
  String get thisIsYourFlashcards;

  /// No description provided for @successfullyReviewedFlashcards.
  ///
  /// In en, this message translates to:
  /// **'You successfully reviewed all our flashcards great job!'**
  String get successfullyReviewedFlashcards;

  /// No description provided for @eyeOfHorus.
  ///
  /// In en, this message translates to:
  /// **'the eye of Horus'**
  String get eyeOfHorus;

  /// No description provided for @wedjitEye.
  ///
  /// In en, this message translates to:
  /// **'(wedjit eye)'**
  String get wedjitEye;

  /// No description provided for @ancientEgyptian.
  ///
  /// In en, this message translates to:
  /// **'Ancient Egyptian'**
  String get ancientEgyptian;

  /// No description provided for @goldCollar.
  ///
  /// In en, this message translates to:
  /// **'Gold collar'**
  String get goldCollar;

  /// No description provided for @lifeKey.
  ///
  /// In en, this message translates to:
  /// **'Life Key'**
  String get lifeKey;

  /// No description provided for @hieroglyphs.
  ///
  /// In en, this message translates to:
  /// **'Hieroglyphs'**
  String get hieroglyphs;

  /// No description provided for @okThankYouMishka.
  ///
  /// In en, this message translates to:
  /// **'Ok, Thank You Mishka'**
  String get okThankYouMishka;

  /// No description provided for @hereIsYourQuiz.
  ///
  /// In en, this message translates to:
  /// **'Here is your quiz:'**
  String get hereIsYourQuiz;

  /// No description provided for @whatIsMishkaApp.
  ///
  /// In en, this message translates to:
  /// **'What is Mishka app?'**
  String get whatIsMishkaApp;

  /// No description provided for @quizProgress.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total}'**
  String quizProgress(int current, int total);

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer.'**
  String get correctAnswer;

  /// No description provided for @wrongAnswer.
  ///
  /// In en, this message translates to:
  /// **'Wrong Answer'**
  String get wrongAnswer;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @hereIsYourSummarizedArticle.
  ///
  /// In en, this message translates to:
  /// **'Here is your Summarized article:'**
  String get hereIsYourSummarizedArticle;

  /// No description provided for @toDoListTitle.
  ///
  /// In en, this message translates to:
  /// **'To Do list'**
  String get toDoListTitle;

  /// No description provided for @yourList.
  ///
  /// In en, this message translates to:
  /// **'Your List:'**
  String get yourList;

  /// No description provided for @searchList.
  ///
  /// In en, this message translates to:
  /// **'Search list ...'**
  String get searchList;

  /// No description provided for @calender.
  ///
  /// In en, this message translates to:
  /// **'Calender'**
  String get calender;

  /// No description provided for @allTasks.
  ///
  /// In en, this message translates to:
  /// **'All Tasks'**
  String get allTasks;

  /// No description provided for @collegeTasks.
  ///
  /// In en, this message translates to:
  /// **'College Tasks'**
  String get collegeTasks;

  /// No description provided for @workTasks.
  ///
  /// In en, this message translates to:
  /// **'Work Tasks'**
  String get workTasks;

  /// No description provided for @personalTasks.
  ///
  /// In en, this message translates to:
  /// **'Personal Tasks'**
  String get personalTasks;

  /// No description provided for @addNewTask.
  ///
  /// In en, this message translates to:
  /// **'Add New Task'**
  String get addNewTask;

  /// No description provided for @addNewList.
  ///
  /// In en, this message translates to:
  /// **'Add New List'**
  String get addNewList;

  /// No description provided for @selectList.
  ///
  /// In en, this message translates to:
  /// **'Select List'**
  String get selectList;

  /// No description provided for @chooseListIcon.
  ///
  /// In en, this message translates to:
  /// **'Choose your list\'s icon'**
  String get chooseListIcon;

  /// No description provided for @listName.
  ///
  /// In en, this message translates to:
  /// **'List Name:'**
  String get listName;

  /// No description provided for @typeListName.
  ///
  /// In en, this message translates to:
  /// **'Type your list\'s name here'**
  String get typeListName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// No description provided for @areYouSureDeleteTask.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this task??'**
  String get areYouSureDeleteTask;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @savedFlashCards.
  ///
  /// In en, this message translates to:
  /// **'Saved Flash Cards'**
  String get savedFlashCards;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @savedQuizes.
  ///
  /// In en, this message translates to:
  /// **'Saved Quizes'**
  String get savedQuizes;

  /// No description provided for @savedSummary.
  ///
  /// In en, this message translates to:
  /// **'Saved Summary'**
  String get savedSummary;

  /// No description provided for @savedSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search saved items...'**
  String get savedSearchHint;

  /// No description provided for @savedDetailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your saved content will load here when the library is connected.'**
  String get savedDetailPlaceholder;

  /// No description provided for @savedNoSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No saved items match your search.'**
  String get savedNoSearchResults;

  /// No description provided for @savedLibraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet. Create content from AI tools and tap Save.'**
  String get savedLibraryEmpty;

  /// No description provided for @savedDetailItemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This item is no longer available.'**
  String get savedDetailItemUnavailable;

  /// No description provided for @savedDetailNotInLibraryAnymore.
  ///
  /// In en, this message translates to:
  /// **'This is not in your saved library anymore. Pull to refresh the list.'**
  String get savedDetailNotInLibraryAnymore;

  /// No description provided for @savedDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'We could not find this item.'**
  String get savedDetailNotFound;

  /// No description provided for @savedDetailMissingListId.
  ///
  /// In en, this message translates to:
  /// **'This item has no id. Try refreshing the list.'**
  String get savedDetailMissingListId;

  /// No description provided for @savedLibraryRemoveQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove this from your saved library?'**
  String get savedLibraryRemoveQuestion;

  /// No description provided for @savedLibraryRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved library.'**
  String get savedLibraryRemoved;

  /// No description provided for @savedLibraryShared.
  ///
  /// In en, this message translates to:
  /// **'Shared to your channels.'**
  String get savedLibraryShared;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @congratulation.
  ///
  /// In en, this message translates to:
  /// **'Congratulation!'**
  String get congratulation;

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep it up'**
  String get keepItUp;

  /// No description provided for @collectBadge.
  ///
  /// In en, this message translates to:
  /// **'Collect Badge'**
  String get collectBadge;

  /// No description provided for @answered100Percent.
  ///
  /// In en, this message translates to:
  /// **'you have answered 100% correct answers'**
  String get answered100Percent;

  /// No description provided for @answered80Percent.
  ///
  /// In en, this message translates to:
  /// **'you have answered 80% correct answers'**
  String get answered80Percent;

  /// No description provided for @answered40Percent.
  ///
  /// In en, this message translates to:
  /// **'you have answered 40% correct answers'**
  String get answered40Percent;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepGoing;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @deleteThisListQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete this list?'**
  String get deleteThisListQuestion;

  /// No description provided for @listDeleted.
  ///
  /// In en, this message translates to:
  /// **'List deleted'**
  String get listDeleted;

  /// No description provided for @renameList.
  ///
  /// In en, this message translates to:
  /// **'Rename List'**
  String get renameList;

  /// No description provided for @listRenamed.
  ///
  /// In en, this message translates to:
  /// **'List renamed'**
  String get listRenamed;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorPrefix;

  /// No description provided for @pleaseFillAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get pleaseFillAllRequiredFields;

  /// No description provided for @pleaseEnterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter verification code'**
  String get pleaseEnterVerificationCode;

  /// No description provided for @pleaseEnterBothPasswordFields.
  ///
  /// In en, this message translates to:
  /// **'Please enter both password fields'**
  String get pleaseEnterBothPasswordFields;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @noUpcomingDeadlinesYet.
  ///
  /// In en, this message translates to:
  /// **'No upcoming deadlines yet.'**
  String get noUpcomingDeadlinesYet;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @privacyPolicyComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy screen coming soon.'**
  String get privacyPolicyComingSoon;

  /// No description provided for @helpSupportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Help & Support screen coming soon.'**
  String get helpSupportComingSoon;

  /// No description provided for @taskActionsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Task edit, delete, and complete will be available in a future update.'**
  String get taskActionsComingSoon;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this task?'**
  String get deleteTaskConfirm;

  /// No description provided for @taskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted.'**
  String get taskDeleted;

  /// No description provided for @taskMarkedComplete.
  ///
  /// In en, this message translates to:
  /// **'Task marked as completed.'**
  String get taskMarkedComplete;

  /// No description provided for @taskMarkedPending.
  ///
  /// In en, this message translates to:
  /// **'Task marked as pending.'**
  String get taskMarkedPending;

  /// No description provided for @createListBeforeAddingTasks.
  ///
  /// In en, this message translates to:
  /// **'Create a list first, then add tasks inside it.'**
  String get createListBeforeAddingTasks;

  /// No description provided for @chooseListForNewTask.
  ///
  /// In en, this message translates to:
  /// **'Which list should this task go in?'**
  String get chooseListForNewTask;

  /// No description provided for @logoutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmationMessage;

  /// No description provided for @couldNotReadFilePath.
  ///
  /// In en, this message translates to:
  /// **'Could not read file path'**
  String get couldNotReadFilePath;

  /// No description provided for @mindMap.
  ///
  /// In en, this message translates to:
  /// **'Mind Map'**
  String get mindMap;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareToCommunityChannels.
  ///
  /// In en, this message translates to:
  /// **'Share to community channels'**
  String get shareToCommunityChannels;

  /// No description provided for @shareCommunitiesYouJoined.
  ///
  /// In en, this message translates to:
  /// **'Communities You Joined'**
  String get shareCommunitiesYouJoined;

  /// No description provided for @shareToSelectedGroups.
  ///
  /// In en, this message translates to:
  /// **'Share to selected groups'**
  String get shareToSelectedGroups;

  /// No description provided for @shareMembersGroupsCount.
  ///
  /// In en, this message translates to:
  /// **'{members} members {groups} groups'**
  String shareMembersGroupsCount(int members, int groups);

  /// No description provided for @shareGroupMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String shareGroupMembersCount(int count);

  /// No description provided for @shareSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Successfully Shared to the group'**
  String get shareSuccessTitle;

  /// No description provided for @shareSuccessContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get shareSuccessContinue;

  /// No description provided for @shareOpenGroup.
  ///
  /// In en, this message translates to:
  /// **'Open group'**
  String get shareOpenGroup;

  /// No description provided for @noCommunityChannelsFound.
  ///
  /// In en, this message translates to:
  /// **'No community channels found'**
  String get noCommunityChannelsFound;

  /// No description provided for @failedToLoadChannels.
  ///
  /// In en, this message translates to:
  /// **'Failed to load channels: {error}'**
  String failedToLoadChannels(String error);

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Share failed: {error}'**
  String shareFailed(String error);

  /// No description provided for @sharedToChannelsCount.
  ///
  /// In en, this message translates to:
  /// **'Shared to {count} channel(s)'**
  String sharedToChannelsCount(int count);

  /// No description provided for @uploadMaterialToGenerateSummary.
  ///
  /// In en, this message translates to:
  /// **'Upload your material to generate summary'**
  String get uploadMaterialToGenerateSummary;

  /// No description provided for @uploadMaterialToGenerateQuiz.
  ///
  /// In en, this message translates to:
  /// **'Upload your material to generate quiz'**
  String get uploadMaterialToGenerateQuiz;

  /// No description provided for @uploadMaterialToGenerateFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Upload your material to generate flashcards'**
  String get uploadMaterialToGenerateFlashcards;

  /// No description provided for @uploadMaterialToGenerateMindMap.
  ///
  /// In en, this message translates to:
  /// **'Upload your material to generate mind map'**
  String get uploadMaterialToGenerateMindMap;

  /// No description provided for @generationFailed.
  ///
  /// In en, this message translates to:
  /// **'Generation failed: {error}'**
  String generationFailed(String error);

  /// No description provided for @savedToYourLibrary.
  ///
  /// In en, this message translates to:
  /// **'Saved to your library'**
  String get savedToYourLibrary;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String saveFailed(String error);

  /// No description provided for @fileLabel.
  ///
  /// In en, this message translates to:
  /// **'File: {name}'**
  String fileLabel(String name);

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @uploadMaterial.
  ///
  /// In en, this message translates to:
  /// **'Upload material'**
  String get uploadMaterial;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @chooseYourStudyMode.
  ///
  /// In en, this message translates to:
  /// **'Choose your Study Mode'**
  String get chooseYourStudyMode;

  /// No description provided for @cameraMode.
  ///
  /// In en, this message translates to:
  /// **'Camera Mode'**
  String get cameraMode;

  /// No description provided for @concentrationMode.
  ///
  /// In en, this message translates to:
  /// **'Concentration Mode'**
  String get concentrationMode;

  /// No description provided for @pomodoroTimers.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro Timers'**
  String get pomodoroTimers;

  /// No description provided for @customTimer.
  ///
  /// In en, this message translates to:
  /// **'Custom Timer'**
  String get customTimer;

  /// No description provided for @createLinkWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Create link with friends'**
  String get createLinkWithFriends;

  /// No description provided for @studyWithYourFriends.
  ///
  /// In en, this message translates to:
  /// **'Study with your Friends'**
  String get studyWithYourFriends;

  /// No description provided for @createNewLink.
  ///
  /// In en, this message translates to:
  /// **'Create new Link'**
  String get createNewLink;

  /// No description provided for @createLinkAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Create your Link and password'**
  String get createLinkAndPassword;

  /// No description provided for @comingSoonFeature.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon!'**
  String get comingSoonFeature;

  /// No description provided for @mentorLibrary.
  ///
  /// In en, this message translates to:
  /// **'Mentor Library'**
  String get mentorLibrary;

  /// No description provided for @communityEvents.
  ///
  /// In en, this message translates to:
  /// **'Community Events'**
  String get communityEvents;

  /// No description provided for @mentorshipHistory.
  ///
  /// In en, this message translates to:
  /// **'Mentorship History'**
  String get mentorshipHistory;

  /// No description provided for @joinNewCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join a New Community'**
  String get joinNewCommunity;

  /// No description provided for @rejoinSavedCommunity.
  ///
  /// In en, this message translates to:
  /// **'Rejoin your Saved Community'**
  String get rejoinSavedCommunity;

  /// No description provided for @theTask.
  ///
  /// In en, this message translates to:
  /// **'The Task:'**
  String get theTask;

  /// No description provided for @typeYourTaskHere.
  ///
  /// In en, this message translates to:
  /// **'Type your task here'**
  String get typeYourTaskHere;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time:'**
  String get time;

  /// No description provided for @startTimer.
  ///
  /// In en, this message translates to:
  /// **'Start Timer'**
  String get startTimer;

  /// No description provided for @studyTime.
  ///
  /// In en, this message translates to:
  /// **'Study Time'**
  String get studyTime;

  /// No description provided for @shortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short Break'**
  String get shortBreak;

  /// No description provided for @longBreak.
  ///
  /// In en, this message translates to:
  /// **'Long Break'**
  String get longBreak;

  /// No description provided for @mins.
  ///
  /// In en, this message translates to:
  /// **'mins'**
  String get mins;

  /// No description provided for @completedCycles.
  ///
  /// In en, this message translates to:
  /// **'Completed cycles'**
  String get completedCycles;

  /// No description provided for @areYouStillThere.
  ///
  /// In en, this message translates to:
  /// **'Are you still there?'**
  String get areYouStillThere;

  /// No description provided for @howIsYourMoodWhileStudying.
  ///
  /// In en, this message translates to:
  /// **'How is your mood while studying?'**
  String get howIsYourMoodWhileStudying;

  /// No description provided for @yesContinue.
  ///
  /// In en, this message translates to:
  /// **'Yes, Continue'**
  String get yesContinue;

  /// No description provided for @noStop.
  ///
  /// In en, this message translates to:
  /// **'No, Stop'**
  String get noStop;

  /// No description provided for @customYourOwnTimer.
  ///
  /// In en, this message translates to:
  /// **'Custom Your Own Timer:'**
  String get customYourOwnTimer;

  /// No description provided for @recentlyCustomizedTimers.
  ///
  /// In en, this message translates to:
  /// **'Recently customized Timers:'**
  String get recentlyCustomizedTimers;

  /// No description provided for @cameraOn.
  ///
  /// In en, this message translates to:
  /// **'Camera On'**
  String get cameraOn;

  /// No description provided for @videoCallWithMishka.
  ///
  /// In en, this message translates to:
  /// **'Video call with Mishka'**
  String get videoCallWithMishka;

  /// No description provided for @cameraIsOn.
  ///
  /// In en, this message translates to:
  /// **'Camera is On'**
  String get cameraIsOn;

  /// No description provided for @cameraIsOff.
  ///
  /// In en, this message translates to:
  /// **'Camera is Off'**
  String get cameraIsOff;

  /// No description provided for @timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  /// No description provided for @yourStudyLink.
  ///
  /// In en, this message translates to:
  /// **'Your study link:'**
  String get yourStudyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied!'**
  String get linkCopied;

  /// No description provided for @linkCopiedAndReady.
  ///
  /// In en, this message translates to:
  /// **'Link copied and ready to share!'**
  String get linkCopiedAndReady;

  /// No description provided for @copyAndShare.
  ///
  /// In en, this message translates to:
  /// **'Copy & Share'**
  String get copyAndShare;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @noPreviousCustomTimers.
  ///
  /// In en, this message translates to:
  /// **'No previous custom timers.'**
  String get noPreviousCustomTimers;

  /// No description provided for @howIsYourModeWhileStudying.
  ///
  /// In en, this message translates to:
  /// **'How is your mode while studying?'**
  String get howIsYourModeWhileStudying;

  /// No description provided for @makingGoodProgressToday.
  ///
  /// In en, this message translates to:
  /// **'Making good progress today?'**
  String get makingGoodProgressToday;

  /// No description provided for @takeBreak.
  ///
  /// In en, this message translates to:
  /// **'Take Break'**
  String get takeBreak;

  /// No description provided for @endCall.
  ///
  /// In en, this message translates to:
  /// **'End Call'**
  String get endCall;

  /// No description provided for @backToCall.
  ///
  /// In en, this message translates to:
  /// **'Back to Call'**
  String get backToCall;

  /// No description provided for @breakTime.
  ///
  /// In en, this message translates to:
  /// **'Break Time'**
  String get breakTime;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required for video call mode.'**
  String get cameraPermissionRequired;

  /// No description provided for @onboardingIntroLine1.
  ///
  /// In en, this message translates to:
  /// **'I am Mishka, custodian of'**
  String get onboardingIntroLine1;

  /// No description provided for @onboardingIntroLine2.
  ///
  /// In en, this message translates to:
  /// **'knowledge our quest for glory'**
  String get onboardingIntroLine2;

  /// No description provided for @onboardingIntroLine3.
  ///
  /// In en, this message translates to:
  /// **'begins now!'**
  String get onboardingIntroLine3;

  /// No description provided for @welcomeToMishka.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mishka!'**
  String get welcomeToMishka;

  /// No description provided for @welcomeToMishkaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let the guardian of knowledge guide your path to discovery.'**
  String get welcomeToMishkaSubtitle;

  /// No description provided for @educationLevel.
  ///
  /// In en, this message translates to:
  /// **'Education Level'**
  String get educationLevel;

  /// No description provided for @educationLevelComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Education level selection will be available in the next update.'**
  String get educationLevelComingSoon;

  /// No description provided for @educationStatusQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which Of The Following Best Describes Your Current Education Status?'**
  String get educationStatusQuestion;

  /// No description provided for @school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// No description provided for @university.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get university;

  /// No description provided for @otherColon.
  ///
  /// In en, this message translates to:
  /// **'Other:'**
  String get otherColon;

  /// No description provided for @schoolStageQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which School Stage Are You Currently In?'**
  String get schoolStageQuestion;

  /// No description provided for @middleSchoolColon.
  ///
  /// In en, this message translates to:
  /// **'Middle School:'**
  String get middleSchoolColon;

  /// No description provided for @highSchoolColon.
  ///
  /// In en, this message translates to:
  /// **'High School:'**
  String get highSchoolColon;

  /// No description provided for @firstPreparatory.
  ///
  /// In en, this message translates to:
  /// **'1st Preparatory'**
  String get firstPreparatory;

  /// No description provided for @secondPreparatory.
  ///
  /// In en, this message translates to:
  /// **'2nd Preparatory'**
  String get secondPreparatory;

  /// No description provided for @thirdPreparatory.
  ///
  /// In en, this message translates to:
  /// **'3rd Preparatory'**
  String get thirdPreparatory;

  /// No description provided for @firstSecondary.
  ///
  /// In en, this message translates to:
  /// **'1st Secondary'**
  String get firstSecondary;

  /// No description provided for @secondSecondary.
  ///
  /// In en, this message translates to:
  /// **'2nd Secondary'**
  String get secondSecondary;

  /// No description provided for @thirdSecondary.
  ///
  /// In en, this message translates to:
  /// **'3rd Secondary'**
  String get thirdSecondary;

  /// No description provided for @universityYearQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which Academic Year Are You Currently In?'**
  String get universityYearQuestion;

  /// No description provided for @universityColon.
  ///
  /// In en, this message translates to:
  /// **'University:'**
  String get universityColon;

  /// No description provided for @firstYear.
  ///
  /// In en, this message translates to:
  /// **'1st Year'**
  String get firstYear;

  /// No description provided for @secondYear.
  ///
  /// In en, this message translates to:
  /// **'2nd Year'**
  String get secondYear;

  /// No description provided for @thirdYear.
  ///
  /// In en, this message translates to:
  /// **'3rd Year'**
  String get thirdYear;

  /// No description provided for @fourthYear.
  ///
  /// In en, this message translates to:
  /// **'4th Year'**
  String get fourthYear;

  /// No description provided for @fifthYear.
  ///
  /// In en, this message translates to:
  /// **'5th Year'**
  String get fifthYear;

  /// No description provided for @pleaseSpecifyEducationStatus.
  ///
  /// In en, this message translates to:
  /// **'Please specify your education level:'**
  String get pleaseSpecifyEducationStatus;

  /// No description provided for @educationOtherHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your education level'**
  String get educationOtherHint;

  /// No description provided for @editEducation.
  ///
  /// In en, this message translates to:
  /// **'Edit education'**
  String get editEducation;

  /// No description provided for @yourReport.
  ///
  /// In en, this message translates to:
  /// **'Your Report'**
  String get yourReport;

  /// No description provided for @reportPeriodDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get reportPeriodDaily;

  /// No description provided for @reportPeriodWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get reportPeriodWeekly;

  /// No description provided for @reportPeriodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get reportPeriodMonthly;

  /// No description provided for @reportPeriodYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get reportPeriodYearly;

  /// No description provided for @reportPeriodDailySuffix.
  ///
  /// In en, this message translates to:
  /// **'/day'**
  String get reportPeriodDailySuffix;

  /// No description provided for @reportPeriodWeeklySuffix.
  ///
  /// In en, this message translates to:
  /// **'/week'**
  String get reportPeriodWeeklySuffix;

  /// No description provided for @reportPeriodMonthlySuffix.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get reportPeriodMonthlySuffix;

  /// No description provided for @reportPeriodYearlySuffix.
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get reportPeriodYearlySuffix;

  /// No description provided for @reportCreatePdfEmail.
  ///
  /// In en, this message translates to:
  /// **'Create PDF and share'**
  String get reportCreatePdfEmail;

  /// No description provided for @reportEmailMyReport.
  ///
  /// In en, this message translates to:
  /// **'Email my report'**
  String get reportEmailMyReport;

  /// No description provided for @reportPdfEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Report sent to {email}'**
  String reportPdfEmailSent(String email);

  /// No description provided for @reportPdfOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the report PDF link.'**
  String get reportPdfOpenFailed;

  /// No description provided for @reportPdfSharedLocally.
  ///
  /// In en, this message translates to:
  /// **'Server export unavailable — shared a local PDF copy instead.'**
  String get reportPdfSharedLocally;

  /// No description provided for @reportUsingLegacyData.
  ///
  /// In en, this message translates to:
  /// **'Using classic report APIs until the new bundle is deployed.'**
  String get reportUsingLegacyData;

  /// No description provided for @reportStudyWithMishka.
  ///
  /// In en, this message translates to:
  /// **'Study with Mishka'**
  String get reportStudyWithMishka;

  /// No description provided for @reportDuringConcentrationMode.
  ///
  /// In en, this message translates to:
  /// **'Total study time (Concentration + Camera modes):'**
  String get reportDuringConcentrationMode;

  /// No description provided for @reportAiTools.
  ///
  /// In en, this message translates to:
  /// **'Using Mishka\'s AI tools'**
  String get reportAiTools;

  /// No description provided for @reportDailyStreak.
  ///
  /// In en, this message translates to:
  /// **'Daily Streak'**
  String get reportDailyStreak;

  /// No description provided for @reportDailyStreakChartHint.
  ///
  /// In en, this message translates to:
  /// **'Each bar is one day: 100% = streak kept, 0% = missed.'**
  String get reportDailyStreakChartHint;

  /// No description provided for @reportStreakCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get reportStreakCurrent;

  /// No description provided for @reportStreakLongest.
  ///
  /// In en, this message translates to:
  /// **'Longest'**
  String get reportStreakLongest;

  /// No description provided for @reportStreakFreezes.
  ///
  /// In en, this message translates to:
  /// **'Freezes left'**
  String get reportStreakFreezes;

  /// No description provided for @reportTasksDue.
  ///
  /// In en, this message translates to:
  /// **'Tasks completed'**
  String get reportTasksDue;

  /// No description provided for @reportTasksDueHint.
  ///
  /// In en, this message translates to:
  /// **'Each bar is one day — how many to-do tasks you marked done.'**
  String get reportTasksDueHint;

  /// No description provided for @reportNoTasksInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No tasks completed in this period yet.'**
  String get reportNoTasksInPeriod;

  /// No description provided for @reportTotalQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Total Quizzes'**
  String get reportTotalQuizzes;

  /// No description provided for @reportTotalFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Total Flashcards'**
  String get reportTotalFlashcards;

  /// No description provided for @reportTotalSummaries.
  ///
  /// In en, this message translates to:
  /// **'Total Summaries'**
  String get reportTotalSummaries;

  /// No description provided for @reportLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your report. Pull to refresh.'**
  String get reportLoadFailed;

  /// No description provided for @reportPdfFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create report PDF: {error}'**
  String reportPdfFailed(String error);

  /// No description provided for @settingsReportAutoEmail.
  ///
  /// In en, this message translates to:
  /// **'Automatic report email'**
  String get settingsReportAutoEmail;

  /// No description provided for @settingsReportAutoEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Receive your weekly or monthly report by email.'**
  String get settingsReportAutoEmailHint;

  /// No description provided for @reportEmailWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get reportEmailWeekly;

  /// No description provided for @reportEmailMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get reportEmailMonthly;

  /// No description provided for @settingsReportRecipientRow.
  ///
  /// In en, this message translates to:
  /// **'Send reports to'**
  String get settingsReportRecipientRow;

  /// No description provided for @settingsReportRecipientNotSet.
  ///
  /// In en, this message translates to:
  /// **'Add email'**
  String get settingsReportRecipientNotSet;

  /// No description provided for @settingsReportRecipientTitle.
  ///
  /// In en, this message translates to:
  /// **'Report email address'**
  String get settingsReportRecipientTitle;

  /// No description provided for @settingsReportRecipientBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the email address that should receive your weekly or monthly report, and one-off exports from Your Report.'**
  String get settingsReportRecipientBody;

  /// No description provided for @settingsReportRecipientLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient email'**
  String get settingsReportRecipientLabel;

  /// No description provided for @settingsReportRecipientSaved.
  ///
  /// In en, this message translates to:
  /// **'Report email address saved.'**
  String get settingsReportRecipientSaved;

  /// No description provided for @settingsReportRecipientSavedLocal.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device. Server sync will apply when the backend adds report email recipient support.'**
  String get settingsReportRecipientSavedLocal;

  /// No description provided for @settingsReportRecipientUseAccount.
  ///
  /// In en, this message translates to:
  /// **'Use my account email ({email})'**
  String settingsReportRecipientUseAccount(String email);

  /// No description provided for @communityCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Community'**
  String get communityCreateTitle;

  /// No description provided for @communityCreateVisibilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Select your community\'s visibility:'**
  String get communityCreateVisibilityLabel;

  /// No description provided for @communityVisibilityPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get communityVisibilityPrivate;

  /// No description provided for @communityVisibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get communityVisibilityPublic;

  /// No description provided for @communityCreateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Community name:'**
  String get communityCreateNameLabel;

  /// No description provided for @communityCreateNameHint.
  ///
  /// In en, this message translates to:
  /// **'Community name'**
  String get communityCreateNameHint;

  /// No description provided for @communityCreateDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional):'**
  String get communityCreateDescLabel;

  /// No description provided for @communityCreateDescHint.
  ///
  /// In en, this message translates to:
  /// **'Community description'**
  String get communityCreateDescHint;

  /// No description provided for @communityCreateDiscoverSection.
  ///
  /// In en, this message translates to:
  /// **'Discovery (public communities)'**
  String get communityCreateDiscoverSection;

  /// No description provided for @communityCreateDiscoverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help others find your community in Discover and recommendations.'**
  String get communityCreateDiscoverSubtitle;

  /// No description provided for @communityCreateNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a community name'**
  String get communityCreateNameRequired;

  /// No description provided for @communityCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your community was created successfully!'**
  String get communityCreateSuccess;

  /// No description provided for @communityCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Community'**
  String get communityCreateButton;

  /// No description provided for @communityCreateEducationHintUniversity.
  ///
  /// In en, this message translates to:
  /// **'Using your profile: University, year {year}'**
  String communityCreateEducationHintUniversity(String year);

  /// No description provided for @communityCreateEducationHintSchool.
  ///
  /// In en, this message translates to:
  /// **'Using your profile: School, grade {grade}'**
  String communityCreateEducationHintSchool(String grade);

  /// No description provided for @communityCreateEducationHintProfile.
  ///
  /// In en, this message translates to:
  /// **'Using your profile: {status}'**
  String communityCreateEducationHintProfile(String status);

  /// No description provided for @communityHubSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get communityHubSearchHint;

  /// No description provided for @communityHubCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create New Community'**
  String get communityHubCreateNew;

  /// No description provided for @communityHubJoinPrivate.
  ///
  /// In en, this message translates to:
  /// **'Join Private Community'**
  String get communityHubJoinPrivate;

  /// No description provided for @communityHubSavedSection.
  ///
  /// In en, this message translates to:
  /// **'Saved Communities:'**
  String get communityHubSavedSection;

  /// No description provided for @communityHubSavedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved communities yet. Open a community and tap ⋮ → Save Community.'**
  String get communityHubSavedEmpty;

  /// No description provided for @communityHubPrivateSection.
  ///
  /// In en, this message translates to:
  /// **'Private Communities you\'re in:'**
  String get communityHubPrivateSection;

  /// No description provided for @communityHubPublicSection.
  ///
  /// In en, this message translates to:
  /// **'Public Communities you\'re in:'**
  String get communityHubPublicSection;

  /// No description provided for @communityHubRecommendedSection.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get communityHubRecommendedSection;

  /// No description provided for @communityHubSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get communityHubSeeAll;

  /// No description provided for @communityHubDiscoverButton.
  ///
  /// In en, this message translates to:
  /// **'Discover Communities'**
  String get communityHubDiscoverButton;

  /// No description provided for @communityHubEmpty.
  ///
  /// In en, this message translates to:
  /// **'No communities yet. Create one or join with a code.'**
  String get communityHubEmpty;

  /// No description provided for @communityHubSavedEmptySnack.
  ///
  /// In en, this message translates to:
  /// **'No saved communities yet. Open a community and use ⋮ → Save Community.'**
  String get communityHubSavedEmptySnack;

  /// No description provided for @communitySave.
  ///
  /// In en, this message translates to:
  /// **'Save Community'**
  String get communitySave;

  /// No description provided for @communityUnsave.
  ///
  /// In en, this message translates to:
  /// **'Unsave Community'**
  String get communityUnsave;

  /// No description provided for @communitySavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Community saved successfully!'**
  String get communitySavedSuccess;

  /// No description provided for @communityUnsavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Community removed from saved.'**
  String get communityUnsavedSuccess;

  /// No description provided for @communityDiscoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Communities'**
  String get communityDiscoverTitle;

  /// No description provided for @communityDiscoverSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search communities…'**
  String get communityDiscoverSearchHint;

  /// No description provided for @communityDiscoverForYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get communityDiscoverForYou;

  /// No description provided for @communityDiscoverPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get communityDiscoverPopular;

  /// No description provided for @communityDiscoverNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get communityDiscoverNew;

  /// No description provided for @communityDiscoverSubjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get communityDiscoverSubjects;

  /// No description provided for @communityDiscoverAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get communityDiscoverAll;

  /// No description provided for @communityDiscoverProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Complete your education in Profile to get better recommendations.'**
  String get communityDiscoverProfileHint;

  /// No description provided for @communityDiscoverEmpty.
  ///
  /// In en, this message translates to:
  /// **'No communities to show yet.'**
  String get communityDiscoverEmpty;

  /// No description provided for @communityDiscoverJoin.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get communityDiscoverJoin;

  /// No description provided for @communityMemberPromoteAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make Admin'**
  String get communityMemberPromoteAdmin;

  /// No description provided for @communityMemberDemoteMember.
  ///
  /// In en, this message translates to:
  /// **'Make Member'**
  String get communityMemberDemoteMember;

  /// No description provided for @communityMemberRoleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Member role updated.'**
  String get communityMemberRoleUpdated;

  /// No description provided for @communityChatSenderMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get communityChatSenderMe;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
