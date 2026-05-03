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
  /// **'Verify BY email address'**
  String get verifyByEmail;

  /// No description provided for @enter5DigitsCodeEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the 5 digits code you received at your Gmail : example123@gamil.com'**
  String get enter5DigitsCodeEmail;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @successfullyVerified.
  ///
  /// In en, this message translates to:
  /// **'successfully Verified'**
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
  /// **'Password is successfully set'**
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
  /// **'Enter the 5 digits code you received (SMS) at +20 1010101010'**
  String get enter5DigitsCodePhone;

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

  /// No description provided for @yourHistory.
  ///
  /// In en, this message translates to:
  /// **'your History'**
  String get yourHistory;

  /// No description provided for @searchYourHistory.
  ///
  /// In en, this message translates to:
  /// **'Search your history...'**
  String get searchYourHistory;

  /// No description provided for @chats.
  ///
  /// In en, this message translates to:
  /// **'chats:'**
  String get chats;

  /// No description provided for @tellMeMoreAboutMishka.
  ///
  /// In en, this message translates to:
  /// **'Tell me more about MISHKA app?'**
  String get tellMeMoreAboutMishka;

  /// No description provided for @quizes.
  ///
  /// In en, this message translates to:
  /// **'Quizes:'**
  String get quizes;

  /// No description provided for @makeMeFlashcards.
  ///
  /// In en, this message translates to:
  /// **'make me flashcards and quizzes and summarize the article for these uploaded files'**
  String get makeMeFlashcards;

  /// No description provided for @flashCardsColon.
  ///
  /// In en, this message translates to:
  /// **'FlashCards:'**
  String get flashCardsColon;

  /// No description provided for @summarization.
  ///
  /// In en, this message translates to:
  /// **'Summarization :'**
  String get summarization;

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
