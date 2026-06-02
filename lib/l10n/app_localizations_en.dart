// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mishka';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createAccountAtMishka => 'Create your account at MISHKA';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get exampleEmail => 'Example1234@gmail.com';

  @override
  String get password => 'Password';

  @override
  String get examplePassword => 'Pass123#!\\\$';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgetPassword => 'Forget Password?';

  @override
  String get agreeToTerms => 'Agree to terms and conditions & privacy policy';

  @override
  String get alreadyHaveAccount => 'Already have account? Sign In';

  @override
  String get orSignUpWith => 'or sign up with';

  @override
  String get signIn => 'Sign In';

  @override
  String get welcomeBackToMishka => 'Welcome back to MISHKA';

  @override
  String get email => 'Email';

  @override
  String get dontHaveAccount => 'Don\'t have account? create account';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordUsing => 'Reset your password using:';

  @override
  String get writeEmailForCode =>
      'write your email to receive your confirmation code to create your new password';

  @override
  String get getCode => 'Get Code';

  @override
  String get verificationCode => 'Verification Code';

  @override
  String get verifyByEmail => 'Verify by Email Address';

  @override
  String enter5DigitsCodeEmail(String email) {
    return 'Enter the 5 digits code you received at your gmail: $email';
  }

  @override
  String enter6DigitsCodeEmail(String email) {
    return 'Enter the 6 digits code you received at your gmail: $email';
  }

  @override
  String enter6DigitsCodePhone(String phone) {
    return 'Enter the 6 digits code you received (SMS) at $phone';
  }

  @override
  String get verify => 'Verify';

  @override
  String get successfullyVerified => 'Successfully Verified';

  @override
  String get letsStartSettingAccount =>
      'Let\'s start setting your account so you can start using the app';

  @override
  String get enterNewPassword => 'Enter your new password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New password';

  @override
  String get passwordRequirements => 'your password must contain:';

  @override
  String get passwordRequirement1 => 'Between 8 and 20 characters';

  @override
  String get passwordRequirement2 => '1 upper case letter';

  @override
  String get passwordRequirement3 => '1 or more numbers';

  @override
  String get passwordRequirement4 => '1 or more special character';

  @override
  String get setPassword => 'Set Password';

  @override
  String get passwordSuccessfullySet => 'Password Is Successfully Set';

  @override
  String get writePhoneForCode =>
      'write your PHONE NUMBER to receive your confirmation code to create your new password';

  @override
  String get verifyByPhoneNumber => 'Verify by phone number';

  @override
  String enter5DigitsCodePhone(String phone) {
    return 'Enter the 5 digits code you received (SMS) at $phone';
  }

  @override
  String get welcomeBackSara => 'Welcome, Back Ziad!';

  @override
  String get sundayJan26 => 'Sunday, Jan 26, 2026';

  @override
  String get dailyStreaks => 'Daily Streaks:';

  @override
  String days(int count) {
    return '$count days';
  }

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get completed => 'completed';

  @override
  String get today => 'Today';

  @override
  String get upcoming => 'Upcoming';

  @override
  String streakStats(int longest, int freezes) {
    return 'Best: $longest · $freezes freezes left';
  }

  @override
  String get streakMissed => 'Missed (tap to freeze)';

  @override
  String get streakFreezeTitle => 'Use streak freeze?';

  @override
  String streakFreezeMessage(String date) {
    return 'Protect your streak for $date?';
  }

  @override
  String get streakFreezeConfirm => 'Use freeze';

  @override
  String get streakFreezeSuccess => 'Streak freeze applied';

  @override
  String get streakFreezeFailed => 'Could not apply streak freeze';

  @override
  String get tipOfTheDay => 'Tip Of The Day';

  @override
  String get tipQuote =>
      'I am more impressed by your effort and your process than by the final grade.';

  @override
  String get upComingDeadlines => 'Up Coming Deadlines:';

  @override
  String get viewYourToDoList => 'View your To Do List';

  @override
  String get task => 'Task:';

  @override
  String get plcSheet2Offline => 'PLC sheet 2 (offline)';

  @override
  String get meetingForGraduationProject => 'Meating for Graduation project';

  @override
  String get list => 'List:';

  @override
  String get collegeTasksList => 'College Tasks List.';

  @override
  String get workTasksList => 'Work Tasks List.';

  @override
  String get deadline => 'Deadline:';

  @override
  String get sunJan262025 => 'Sun, Jan 26, 2025';

  @override
  String get pm700 => '07:00 pm';

  @override
  String get pm900 => '09:00 pm';

  @override
  String get pm200 => '02:00 pm';

  @override
  String get mishkasAiTools => 'Mishka\'s AI Tools:';

  @override
  String get viewMore => 'View more';

  @override
  String get chatWithMishka => 'Chat with Mishka';

  @override
  String get yourHistory => 'Your History';

  @override
  String get searchYourHistory => 'Search your history...';

  @override
  String get historyChats => 'chats:';

  @override
  String get historyQuizzes => 'Quizzes:';

  @override
  String get historyFlashCards => 'FlashCards:';

  @override
  String get historySummarization => 'Summarization :';

  @override
  String get historyMindMaps => 'Mind Maps:';

  @override
  String get historyEmpty => 'No history found';

  @override
  String get historyLoadFailed => 'Could not load this chat session';

  @override
  String get chatGreeting =>
      'Hello, please upload your material to start our journey';

  @override
  String get chatAnalyzingPdf => 'Analyzing PDF...';

  @override
  String get chatWhichTool => 'Which tool would you like to use?';

  @override
  String get chatWaitForExplanation =>
      'Please wait for the explanation to complete first.';

  @override
  String get chatUploadPdfHint => 'Upload PDF to start';

  @override
  String get chatChooseDifficultyHint => 'Choose difficulty above';

  @override
  String get chatDifficultySimple => 'Simple';

  @override
  String get chatDifficultyIntermediate => 'Intermediate';

  @override
  String get chatDifficultyAdvanced => 'Advanced';

  @override
  String get chatToolQuiz => 'Quiz';

  @override
  String get chatToolFlashcards => 'Flashcards';

  @override
  String get chatToolMindMap => 'Mind Map';

  @override
  String get chatToolSummarize => 'Summarize';

  @override
  String get chatRegenerate => 'Regenerate';

  @override
  String get chatAnotherTool => 'Another Tool';

  @override
  String chatToolSelected(String tool) {
    return 'Great! You selected: $tool. Generating it for you...';
  }

  @override
  String chatRegenerating(String tool) {
    return 'Regenerating $tool...';
  }

  @override
  String chatRegenerationFailed(String error) {
    return 'Regeneration failed.\n$error';
  }

  @override
  String chatAnalyzePdfFailed(String error) {
    return 'Failed to analyze PDF.\n$error';
  }

  @override
  String chatToolGenerationFailed(String error) {
    return 'Tool generation failed.\n$error';
  }

  @override
  String chatMessageFailed(String error) {
    return 'Chat failed.\n$error';
  }

  @override
  String chatSessionStartFailed(String error) {
    return 'Could not start chat session.\n$error';
  }

  @override
  String get chatNewChatTitle => 'Start a new chat?';

  @override
  String get chatNewChatMessage =>
      'Your current conversation stays in history. You can reopen it from the menu.';

  @override
  String get chatNewChatConfirm => 'New chat';

  @override
  String get chatNewChatAction => 'New chat';

  @override
  String get renameSavedItem => 'Rename item';

  @override
  String get savedItemRenamed => 'Item renamed';

  @override
  String get savedRenameUnavailable => 'This item cannot be renamed';

  @override
  String get savedItemTitleHint => 'Title';

  @override
  String get summarizeWithMishka => 'Summarize with Mishka';

  @override
  String get makeFlashcardsWithMishka => 'Make Flashcards with Mishka';

  @override
  String get makeQuizzesWithMishka => 'Make Quizes with Mishka';

  @override
  String get studyWithMishka => 'Study With Mishka:';

  @override
  String get start => 'Start';

  @override
  String get mishkasCommunity => 'Mishka\'s Community:';

  @override
  String get join => 'Join';

  @override
  String get youCanAddNewCommunity => 'You can add new Community';

  @override
  String get youCanRejoinSavedCommunity =>
      'You can rejoin your saved Community';

  @override
  String get exploreCommunitiesByMajor =>
      'Explore Our communities based on your major';

  @override
  String get mishkasSupport => 'Mishka\'s Support:';

  @override
  String get exploreMore => 'Explore more';

  @override
  String get countDailyStudyHours => 'Count Your daily study hours with Mishka';

  @override
  String get winMishkasChallenges =>
      'Win Mishka\'s Challenges and get your Prize';

  @override
  String get getPointsByChatting =>
      'Get Points by chatting with Mishka everyday';

  @override
  String get viewAllBadgesMonthly => 'View all your Badges monthly with Mishka';

  @override
  String get home => 'Home';

  @override
  String get toDo => 'To-Do';

  @override
  String get category => 'Category';

  @override
  String get saved => 'Saved';

  @override
  String get profile => 'Profile';

  @override
  String get profileFieldNotSet => '—';

  @override
  String get profileLoadFailed => 'Could not refresh profile.';

  @override
  String get removeProfilePhotoConfirm => 'Remove your profile photo?';

  @override
  String get remove => 'Remove';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get profileUpdateFailed => 'Could not save profile.';

  @override
  String get fieldRequired => 'This field is required.';

  @override
  String get invalidEmailHint => 'Enter a valid email address.';

  @override
  String get invalidPhoneHint => 'Enter a valid phone number.';

  @override
  String get nameTooLong => 'Name must be 50 characters or fewer.';

  @override
  String get accountAlreadyExists =>
      'An account with this email or phone number already exists.';

  @override
  String get retry => 'Retry';

  @override
  String get aiTools => 'Ai tools';

  @override
  String get aiToolsSubtitle =>
      'Chat with Mishka, Quizzes, Flash Cards, Summary.';

  @override
  String get toDoList => 'To Do List';

  @override
  String get yourToDoList => 'Your To do list.';

  @override
  String get studyWithMe => 'Study with Me';

  @override
  String get studyWithMeSubtitle => 'solo mode, group mode, Mishka partner.';

  @override
  String get ourCommunity => 'Our Community';

  @override
  String get ourCommunitySubtitle =>
      'Mentor Library, Events community, Mentorship History.';

  @override
  String get gamification => 'Gamification';

  @override
  String get gamificationSubtitle => 'points, streaks, Badges, Challenges.';

  @override
  String get accountSetting => 'Account Setting:';

  @override
  String get fullName => 'Full Name:';

  @override
  String get yourFullName => 'Your Full Name';

  @override
  String get userName => 'User Name:';

  @override
  String get yourUserName => 'Your user Name';

  @override
  String get gender => 'Gender:';

  @override
  String get female => 'Female';

  @override
  String get male => 'Male';

  @override
  String get ratherNotToSay => 'rather not to say';

  @override
  String get contactInfo => 'Contact Info:';

  @override
  String get exampleEmailContact => 'example123@gmail.com';

  @override
  String get language => 'Language:';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get theme => 'Theme:';

  @override
  String get lightMode => 'Light mode';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get themeSystem => 'System default';

  @override
  String get notification => 'Notification:';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get chooseAppearance => 'Choose appearance';

  @override
  String get settings => 'Settings';

  @override
  String get settingsSubtitle => 'Language, theme, notifications';

  @override
  String get settingsDescription =>
      'Choose how Mishka looks and how we reach you. Changes apply on this device and sync to your account when you are signed in.';

  @override
  String get settingsPreferencesSection => 'Preferences';

  @override
  String get settingsSyncFailed =>
      'Could not sync settings to your account. Your choice is saved on this device.';

  @override
  String get privacyPolicyBody =>
      'Mishka respects your privacy. We collect only the information needed to run your account, personalize study features, and improve the app.\n\nWe use your email and profile details to authenticate you and to communicate about your account. Study activity, tasks, and AI interactions are stored to provide history, streaks, and tutoring features you use.\n\nWe do not sell your personal data. We may share limited data with service providers that host our infrastructure and deliver notifications, under strict confidentiality.\n\nYou can update your profile, education details, and preferences in the app. Contact support if you need access, correction, or deletion of your data.\n\nThis summary is provided for convenience. A full legal policy may be published separately on our website.';

  @override
  String get helpSupportIntro =>
      'Need help with Mishka? Reach us using the contacts below, or read the quick tips in this screen when contacts are not configured yet.';

  @override
  String get helpSupportContactsTitle => 'Contact us';

  @override
  String get helpSupportTapToOpen =>
      'Tap a row to open Gmail, WhatsApp, or the link in its app.';

  @override
  String get linkOpenFailed => 'Could not open this link on your device.';

  @override
  String get linkOpenFailedCopied =>
      'Could not open the app — copied to clipboard instead.';

  @override
  String get supportFacebook => 'Facebook';

  @override
  String get supportInstagram => 'Instagram';

  @override
  String get supportWhatsApp => 'WhatsApp';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get helpSupportBody =>
      'Need help with Mishka? Here is how to get unstuck.\n\nAccount & sign-in: Use Forgot password on the login screen if you cannot sign in. Make sure your email or phone matches what you registered with.\n\nStudy With Mishka: Start a session from Home, pick a timer, and stay on the session screen until you finish or end early. If a session fails to start, check your connection and try again.\n\nTasks & lists: Create lists from the To-Do area, then add tasks with deadlines. Pull to refresh on Home to see upcoming tasks.\n\nProfile & education: Open Profile to edit your name, contact info, gender, and education level. Use Settings for language, theme, and notifications.\n\nStill stuck? Email our team at support@mishka.app with a short description and screenshots if possible. We typically reply within a few business days.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get logOut => 'Log Out';

  @override
  String get search => 'Search ...';

  @override
  String get chatWithMishkaTitle => 'Chat with MISHKA';

  @override
  String get flashCards => 'Flash Cards';

  @override
  String get quizzes => 'Quizzes';

  @override
  String get summarize => 'Summarize';

  @override
  String get mishka => 'Mishka';

  @override
  String get helloSara => 'Hello, Sara!';

  @override
  String get askMishka => 'Ask MISHKA ....';

  @override
  String get apologizeNotUnderstand =>
      'I apologize, but I did not understand this input';

  @override
  String get pleaseClarify => 'Could you please clarify your request .';

  @override
  String get tellMeMoreAboutMishkaApp => 'tell me more about MISHKA app?';

  @override
  String get mishkaDescription =>
      'Mishka is an AI-powered interactive study companion, designed to address the major obstacles faced by students in modern education: difficulty understanding complex material, distraction, lack of motivation, and limited collaboration opportunities. By combining artificial intelligence, gamification, and inclusive design into one integrated platform, Mishka transforms studying from an isolating and stressful activity into an engaging, structured, and rewarding experience.';

  @override
  String get whatMakesMishkaBetter =>
      'But What makes MISHKA better than other applications?';

  @override
  String get mishkaBetterDescription =>
      'Mishka stands out from other study apps by integrating AI, gamification, and inclusive design into a single platform, moving beyond basic tutoring to tackle the major student obstacles of complex material, distraction, and lack of motivation, transforming studying into an engaging, structured, and rewarding experience for all.';

  @override
  String get uploadFiles => 'Upload Files';

  @override
  String get uploadPDF => 'Upload PDF';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get uploadVideo => 'Upload Video';

  @override
  String get uploadArticle => 'Upload Article';

  @override
  String get pdfsName => 'pdf\'s name';

  @override
  String get file => 'File';

  @override
  String get photo => 'Photo';

  @override
  String get pdf => 'pdf';

  @override
  String get fileLower => 'file';

  @override
  String get pngJpeg => 'png/jpeg';

  @override
  String get article => 'Article';

  @override
  String get video => 'Video';

  @override
  String get text => 'text';

  @override
  String get mp3 => 'mp3';

  @override
  String get pleaseEnterMaterialFlashcards =>
      'please enter your material so I can create flashcards for you.';

  @override
  String get pleaseEnterMaterialQuizzes =>
      'please enter your material so I can turn them to mcq Quizzes.';

  @override
  String get pleaseEnterMaterialSummarize =>
      'please enter your material so I can Summarize them for you.';

  @override
  String get thisIsYourFlashcards => 'This is your flashcards:';

  @override
  String get successfullyReviewedFlashcards =>
      'You successfully reviewed all our flashcards great job!';

  @override
  String get eyeOfHorus => 'the eye of Horus';

  @override
  String get wedjitEye => '(wedjit eye)';

  @override
  String get ancientEgyptian => 'Ancient Egyptian';

  @override
  String get goldCollar => 'Gold collar';

  @override
  String get lifeKey => 'Life Key';

  @override
  String get hieroglyphs => 'Hieroglyphs';

  @override
  String get okThankYouMishka => 'Ok, Thank You Mishka';

  @override
  String get hereIsYourQuiz => 'Here is your quiz:';

  @override
  String get whatIsMishkaApp => 'What is Mishka app?';

  @override
  String quizProgress(int current, int total) {
    return '$current/$total';
  }

  @override
  String get next => 'Next';

  @override
  String get correctAnswer => 'Correct answer.';

  @override
  String get wrongAnswer => 'Wrong Answer';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get hereIsYourSummarizedArticle => 'Here is your Summarized article:';

  @override
  String get toDoListTitle => 'To Do list';

  @override
  String get yourList => 'Your List:';

  @override
  String get searchList => 'Search list ...';

  @override
  String get calender => 'Calender';

  @override
  String get allTasks => 'All Tasks';

  @override
  String get collegeTasks => 'College Tasks';

  @override
  String get workTasks => 'Work Tasks';

  @override
  String get personalTasks => 'Personal Tasks';

  @override
  String get addNewTask => 'Add New Task';

  @override
  String get addNewList => 'Add New List';

  @override
  String get selectList => 'Select List';

  @override
  String get chooseListIcon => 'Choose your list\'s icon';

  @override
  String get listName => 'List Name:';

  @override
  String get typeListName => 'Type your list\'s name here';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get editTask => 'Edit Task';

  @override
  String get areYouSureDeleteTask =>
      'Are you sure you want to delete this task??';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get savedFlashCards => 'Saved Flash Cards';

  @override
  String get view => 'View';

  @override
  String get savedQuizes => 'Saved Quizes';

  @override
  String get savedSummary => 'Saved Summary';

  @override
  String get savedSearchHint => 'Search saved items...';

  @override
  String get savedDetailPlaceholder =>
      'Your saved content will load here when the library is connected.';

  @override
  String get savedNoSearchResults => 'No saved items match your search.';

  @override
  String get savedLibraryEmpty =>
      'Nothing saved yet. Create content from AI tools and tap Save.';

  @override
  String get savedDetailItemUnavailable => 'This item is no longer available.';

  @override
  String get savedDetailNotInLibraryAnymore =>
      'This is not in your saved library anymore. Pull to refresh the list.';

  @override
  String get savedDetailNotFound => 'We could not find this item.';

  @override
  String get savedDetailMissingListId =>
      'This item has no id. Try refreshing the list.';

  @override
  String get savedLibraryRemoveQuestion =>
      'Remove this from your saved library?';

  @override
  String get savedLibraryRemoved => 'Removed from saved library.';

  @override
  String get savedLibraryShared => 'Shared to your channels.';

  @override
  String get result => 'Result';

  @override
  String get congratulation => 'Congratulation!';

  @override
  String get keepItUp => 'Keep it up';

  @override
  String get collectBadge => 'Collect Badge';

  @override
  String get answered100Percent => 'you have answered 100% correct answers';

  @override
  String get answered80Percent => 'you have answered 80% correct answers';

  @override
  String get answered40Percent => 'you have answered 40% correct answers';

  @override
  String get keepGoing => 'Keep going';

  @override
  String get delete => 'Delete';

  @override
  String get undo => 'Undo';

  @override
  String get deleteThisListQuestion => 'Delete this list?';

  @override
  String get listDeleted => 'List deleted';

  @override
  String get renameList => 'Rename List';

  @override
  String get listRenamed => 'List renamed';

  @override
  String get errorPrefix => 'Error';

  @override
  String get pleaseFillAllRequiredFields => 'Please fill all required fields';

  @override
  String get pleaseEnterVerificationCode => 'Please enter verification code';

  @override
  String get pleaseEnterBothPasswordFields =>
      'Please enter both password fields';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get myTasks => 'My Tasks';

  @override
  String get day => 'Day';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get noUpcomingDeadlinesYet => 'No upcoming deadlines yet.';

  @override
  String get ok => 'OK';

  @override
  String get privacyPolicyComingSoon => 'Privacy Policy screen coming soon.';

  @override
  String get helpSupportComingSoon => 'Help & Support screen coming soon.';

  @override
  String get taskActionsComingSoon =>
      'Task edit, delete, and complete will be available in a future update.';

  @override
  String get deleteTaskConfirm => 'Delete this task?';

  @override
  String get taskDeleted => 'Task deleted.';

  @override
  String get taskMarkedComplete => 'Task marked as completed.';

  @override
  String get taskMarkedPending => 'Task marked as pending.';

  @override
  String get createListBeforeAddingTasks =>
      'Create a list first, then add tasks inside it.';

  @override
  String get chooseListForNewTask => 'Which list should this task go in?';

  @override
  String get logoutConfirmationMessage => 'Are you sure you want to log out?';

  @override
  String get couldNotReadFilePath => 'Could not read file path';

  @override
  String get mindMap => 'Mind Map';

  @override
  String get share => 'Share';

  @override
  String get shareToCommunityChannels => 'Share to community channels';

  @override
  String get shareCommunitiesYouJoined => 'Communities You Joined';

  @override
  String get shareToSelectedGroups => 'Share to selected groups';

  @override
  String shareMembersGroupsCount(int members, int groups) {
    return '$members members $groups groups';
  }

  @override
  String shareGroupMembersCount(int count) {
    return '$count members';
  }

  @override
  String get shareSuccessTitle => 'Successfully Shared to the group';

  @override
  String get shareSuccessContinue => 'Continue';

  @override
  String get shareOpenGroup => 'Open group';

  @override
  String get noCommunityChannelsFound => 'No community channels found';

  @override
  String failedToLoadChannels(String error) {
    return 'Failed to load channels: $error';
  }

  @override
  String shareFailed(String error) {
    return 'Share failed: $error';
  }

  @override
  String sharedToChannelsCount(int count) {
    return 'Shared to $count channel(s)';
  }

  @override
  String get uploadMaterialToGenerateSummary =>
      'Upload your material to generate summary';

  @override
  String get uploadMaterialToGenerateQuiz =>
      'Upload your material to generate quiz';

  @override
  String get uploadMaterialToGenerateFlashcards =>
      'Upload your material to generate flashcards';

  @override
  String get uploadMaterialToGenerateMindMap =>
      'Upload your material to generate mind map';

  @override
  String generationFailed(String error) {
    return 'Generation failed: $error';
  }

  @override
  String get savedToYourLibrary => 'Saved to your library';

  @override
  String saveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String fileLabel(String name) {
    return 'File: $name';
  }

  @override
  String get generating => 'Generating...';

  @override
  String get uploadMaterial => 'Upload material';

  @override
  String get calendar => 'Calendar';

  @override
  String get chooseYourStudyMode => 'Choose your Study Mode';

  @override
  String get cameraMode => 'Camera Mode';

  @override
  String get concentrationMode => 'Concentration Mode';

  @override
  String get pomodoroTimers => 'Pomodoro Timers';

  @override
  String get customTimer => 'Custom Timer';

  @override
  String get createLinkWithFriends => 'Create link with friends';

  @override
  String get studyWithYourFriends => 'Study with your Friends';

  @override
  String get createNewLink => 'Create new Link';

  @override
  String get createLinkAndPassword => 'Create your Link and password';

  @override
  String get comingSoonFeature => 'This feature is coming soon!';

  @override
  String get mentorLibrary => 'Mentor Library';

  @override
  String get communityEvents => 'Community Events';

  @override
  String get mentorshipHistory => 'Mentorship History';

  @override
  String get joinNewCommunity => 'Join a New Community';

  @override
  String get rejoinSavedCommunity => 'Rejoin your Saved Community';

  @override
  String get theTask => 'The Task:';

  @override
  String get typeYourTaskHere => 'Type your task here';

  @override
  String get date => 'Date:';

  @override
  String get time => 'Time:';

  @override
  String get startTimer => 'Start Timer';

  @override
  String get studyTime => 'Study Time';

  @override
  String get shortBreak => 'Short Break';

  @override
  String get longBreak => 'Long Break';

  @override
  String get mins => 'mins';

  @override
  String get completedCycles => 'Completed cycles';

  @override
  String get areYouStillThere => 'Are you still there?';

  @override
  String get howIsYourMoodWhileStudying => 'How is your mood while studying?';

  @override
  String get yesContinue => 'Yes, Continue';

  @override
  String get noStop => 'No, Stop';

  @override
  String get customYourOwnTimer => 'Custom Your Own Timer:';

  @override
  String get recentlyCustomizedTimers => 'Recently customized Timers:';

  @override
  String get cameraOn => 'Camera On';

  @override
  String get videoCallWithMishka => 'Video call with Mishka';

  @override
  String get cameraIsOn => 'Camera is On';

  @override
  String get cameraIsOff => 'Camera is Off';

  @override
  String get timer => 'Timer';

  @override
  String get yourStudyLink => 'Your study link:';

  @override
  String get linkCopied => 'Link copied!';

  @override
  String get linkCopiedAndReady => 'Link copied and ready to share!';

  @override
  String get copyAndShare => 'Copy & Share';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get noPreviousCustomTimers => 'No previous custom timers.';

  @override
  String get howIsYourModeWhileStudying => 'How is your mode while studying?';

  @override
  String get makingGoodProgressToday => 'Making good progress today?';

  @override
  String get takeBreak => 'Take Break';

  @override
  String get endCall => 'End Call';

  @override
  String get backToCall => 'Back to Call';

  @override
  String get breakTime => 'Break Time';

  @override
  String get cameraPermissionRequired =>
      'Camera permission is required for video call mode.';

  @override
  String get onboardingIntroLine1 => 'I am Mishka, custodian of';

  @override
  String get onboardingIntroLine2 => 'knowledge our quest for glory';

  @override
  String get onboardingIntroLine3 => 'begins now!';

  @override
  String get welcomeToMishka => 'Welcome to Mishka!';

  @override
  String get welcomeToMishkaSubtitle =>
      'Let the guardian of knowledge guide your path to discovery.';

  @override
  String get educationLevel => 'Education Level';

  @override
  String get educationLevelComingSoon =>
      'Education level selection will be available in the next update.';

  @override
  String get educationStatusQuestion =>
      'Which Of The Following Best Describes Your Current Education Status?';

  @override
  String get school => 'School';

  @override
  String get university => 'University';

  @override
  String get otherColon => 'Other:';

  @override
  String get schoolStageQuestion => 'Which School Stage Are You Currently In?';

  @override
  String get middleSchoolColon => 'Middle School:';

  @override
  String get highSchoolColon => 'High School:';

  @override
  String get firstPreparatory => '1st Preparatory';

  @override
  String get secondPreparatory => '2nd Preparatory';

  @override
  String get thirdPreparatory => '3rd Preparatory';

  @override
  String get firstSecondary => '1st Secondary';

  @override
  String get secondSecondary => '2nd Secondary';

  @override
  String get thirdSecondary => '3rd Secondary';

  @override
  String get universityYearQuestion =>
      'Which Academic Year Are You Currently In?';

  @override
  String get universityColon => 'University:';

  @override
  String get firstYear => '1st Year';

  @override
  String get secondYear => '2nd Year';

  @override
  String get thirdYear => '3rd Year';

  @override
  String get fourthYear => '4th Year';

  @override
  String get fifthYear => '5th Year';

  @override
  String get pleaseSpecifyEducationStatus =>
      'Please specify your education level:';

  @override
  String get educationOtherHint => 'Enter your education level';

  @override
  String get editEducation => 'Edit education';

  @override
  String get yourReport => 'Your Report';

  @override
  String get reportPeriodDaily => 'Daily';

  @override
  String get reportPeriodWeekly => 'Weekly';

  @override
  String get reportPeriodMonthly => 'Monthly';

  @override
  String get reportPeriodYearly => 'Yearly';

  @override
  String get reportPeriodDailySuffix => '/day';

  @override
  String get reportPeriodWeeklySuffix => '/week';

  @override
  String get reportPeriodMonthlySuffix => '/month';

  @override
  String get reportPeriodYearlySuffix => '/year';

  @override
  String get reportCreatePdfEmail => 'Create PDF and share';

  @override
  String get reportEmailMyReport => 'Email my report';

  @override
  String reportPdfEmailSent(String email) {
    return 'Report sent to $email';
  }

  @override
  String get reportPdfOpenFailed => 'Could not open the report PDF link.';

  @override
  String get reportPdfSharedLocally =>
      'Server export unavailable — shared a local PDF copy instead.';

  @override
  String get reportUsingLegacyData =>
      'Using classic report APIs until the new bundle is deployed.';

  @override
  String get reportStudyWithMishka => 'Study with Mishka';

  @override
  String get reportDuringConcentrationMode =>
      'Total study time (Concentration + Camera modes):';

  @override
  String get reportAiTools => 'Using Mishka\'s AI tools';

  @override
  String get reportDailyStreak => 'Daily Streak';

  @override
  String get reportDailyStreakChartHint =>
      'Each bar is one day: 100% = streak kept, 0% = missed.';

  @override
  String get reportStreakCurrent => 'Current';

  @override
  String get reportStreakLongest => 'Longest';

  @override
  String get reportStreakFreezes => 'Freezes left';

  @override
  String get reportTasksDue => 'Tasks completed';

  @override
  String get reportTasksDueHint =>
      'Each bar is one day — how many to-do tasks you marked done.';

  @override
  String get reportNoTasksInPeriod => 'No tasks completed in this period yet.';

  @override
  String get reportTotalQuizzes => 'Total Quizzes';

  @override
  String get reportTotalFlashcards => 'Total Flashcards';

  @override
  String get reportTotalSummaries => 'Total Summaries';

  @override
  String get reportLoadFailed => 'Could not load your report. Pull to refresh.';

  @override
  String reportPdfFailed(String error) {
    return 'Could not create report PDF: $error';
  }

  @override
  String get settingsReportAutoEmail => 'Automatic report email';

  @override
  String get settingsReportAutoEmailHint =>
      'Receive your weekly or monthly report by email.';

  @override
  String get reportEmailWeekly => 'Weekly';

  @override
  String get reportEmailMonthly => 'Monthly';

  @override
  String get settingsReportRecipientRow => 'Send reports to';

  @override
  String get settingsReportRecipientNotSet => 'Add email';

  @override
  String get settingsReportRecipientTitle => 'Report email address';

  @override
  String get settingsReportRecipientBody =>
      'Enter the email address that should receive your weekly or monthly report, and one-off exports from Your Report.';

  @override
  String get settingsReportRecipientLabel => 'Recipient email';

  @override
  String get settingsReportRecipientSaved => 'Report email address saved.';

  @override
  String get settingsReportRecipientSavedLocal =>
      'Saved on this device. Server sync will apply when the backend adds report email recipient support.';

  @override
  String settingsReportRecipientUseAccount(String email) {
    return 'Use my account email ($email)';
  }

  @override
  String get communityCreateTitle => 'Create New Community';

  @override
  String get communityCreateVisibilityLabel =>
      'Select your community\'s visibility:';

  @override
  String get communityVisibilityPrivate => 'Private';

  @override
  String get communityVisibilityPublic => 'Public';

  @override
  String get communityCreateNameLabel => 'Community name:';

  @override
  String get communityCreateNameHint => 'Community name';

  @override
  String get communityCreateDescLabel => 'Description (optional):';

  @override
  String get communityCreateDescHint => 'Community description';

  @override
  String get communityCreateDiscoverSection => 'Discovery (public communities)';

  @override
  String get communityCreateDiscoverSubtitle =>
      'Help others find your community in Discover and recommendations.';

  @override
  String get communityCreateNameRequired => 'Please enter a community name';

  @override
  String get communityCreateSuccess =>
      'Your community was created successfully!';

  @override
  String get communityCreateButton => 'Create Community';

  @override
  String communityCreateEducationHintUniversity(String year) {
    return 'Using your profile: University, year $year';
  }

  @override
  String communityCreateEducationHintSchool(String grade) {
    return 'Using your profile: School, grade $grade';
  }

  @override
  String communityCreateEducationHintProfile(String status) {
    return 'Using your profile: $status';
  }

  @override
  String get communityHubSearchHint => 'Search...';

  @override
  String get communityHubCreateNew => 'Create New Community';

  @override
  String get communityHubJoinPrivate => 'Join Private Community';

  @override
  String get communityHubSavedSection => 'Saved Communities:';

  @override
  String get communityHubSavedEmpty =>
      'No saved communities yet. Open a community and tap ⋮ → Save Community.';

  @override
  String get communityHubPrivateSection => 'Private Communities you\'re in:';

  @override
  String get communityHubPublicSection => 'Public Communities you\'re in:';

  @override
  String get communityHubRecommendedSection => 'Recommended for you';

  @override
  String get communityHubSeeAll => 'See all';

  @override
  String get communityHubDiscoverButton => 'Discover Communities';

  @override
  String get communityHubEmpty =>
      'No communities yet. Create one or join with a code.';

  @override
  String get communityHubSavedEmptySnack =>
      'No saved communities yet. Open a community and use ⋮ → Save Community.';

  @override
  String get communitySave => 'Save Community';

  @override
  String get communityUnsave => 'Unsave Community';

  @override
  String get communitySavedSuccess => 'Community saved successfully!';

  @override
  String get communityUnsavedSuccess => 'Community removed from saved.';

  @override
  String get communityDiscoverTitle => 'Discover Communities';

  @override
  String get communityDiscoverSearchHint => 'Search communities…';

  @override
  String get communityDiscoverForYou => 'For you';

  @override
  String get communityDiscoverPopular => 'Popular';

  @override
  String get communityDiscoverNew => 'New';

  @override
  String get communityDiscoverSubjects => 'Subjects';

  @override
  String get communityDiscoverAll => 'All';

  @override
  String get communityDiscoverProfileHint =>
      'Complete your education in Profile to get better recommendations.';

  @override
  String get communityDiscoverEmpty => 'No communities to show yet.';

  @override
  String get communityDiscoverJoin => 'Join';

  @override
  String get communityMemberPromoteAdmin => 'Make Admin';

  @override
  String get communityMemberDemoteMember => 'Make Member';

  @override
  String get communityMemberRoleUpdated => 'Member role updated.';

  @override
  String get communityChatSenderMe => 'Me';

  @override
  String get communityShareMenuTitle => 'Share Community';

  @override
  String get communityShareSendLink => 'Send Link';

  @override
  String get communityShareCreateCode => 'Create code';

  @override
  String get communityShareInsertEmail => 'Insert Email';

  @override
  String get communityShareInsertUsername => 'Insert User Name';

  @override
  String get communityShareDialogTitle => 'Share Community:';

  @override
  String get communitySharePublicLinkHint =>
      'Anyone with this link can find and join your public community.';

  @override
  String get communitySharePrivateCodeHint =>
      'Share this invite code so others can join your private community.';

  @override
  String get communitySharePublicCodeHint =>
      'Public communities share by link. This ID helps others join in the app.';

  @override
  String get communityShareYourCode => 'Your code';

  @override
  String get communityShareGenerateNewCode => 'Generate new code';

  @override
  String get communityEditCommunity => 'Edit Community';

  @override
  String get communityDeleteCommunity => 'Delete Community';

  @override
  String get communityHubRecommendedEmpty =>
      'You\'re all caught up — explore Discover for more communities.';

  @override
  String get communityInviteRequiresAccount =>
      'The person must already have a Mishka account (signed up in the app).';

  @override
  String get communityInviteUserNotFound =>
      'No Mishka account found for that email or username.';

  @override
  String get communityInviteCannotInviteSelf =>
      'You cannot invite yourself. Use another member\'s email or username.';

  @override
  String get communityInviteUsernameHint => 'Mishka username (no @)';

  @override
  String get communityInviteSend => 'Send invite';

  @override
  String communityInviteEmailSent(String email) {
    return 'Invitation sent to $email';
  }

  @override
  String get communityJoinPrivateTitle => 'Join Private Community';

  @override
  String get communityJoinPrivateCodePrompt =>
      'Enter your community invite code:';

  @override
  String get communityJoinPrivateCodeHint => 'Community code';

  @override
  String get communityJoinPrivateButton => 'Join community';

  @override
  String get communityJoinPrivateSuccess => 'You have joined the community!';

  @override
  String get communityDeleteConfirm =>
      'Are you sure you want to delete this community?';

  @override
  String get communityDeletedSuccess => 'Community deleted successfully!';

  @override
  String get communityConfirmJoinGroup =>
      'Are you sure you want to join this group?';

  @override
  String get communityJoinedGroupSuccess => 'You joined the group.';

  @override
  String get communityConfirmDeleteGroup =>
      'Are you sure you want to delete this group?';

  @override
  String get communityExitConfirm =>
      'Are you sure you want to leave this community?';

  @override
  String get communityExitAndDeleteConfirm =>
      'Leave and remove this community from your list?';

  @override
  String get communityRemoveMemberConfirm =>
      'Remove this member from the community?';

  @override
  String get communityMemberRemovedSuccess =>
      'Member removed from the community.';

  @override
  String get communityRemoveFromGroupConfirm =>
      'Remove this member from the group?';

  @override
  String get communityMemberRemovedFromGroupSuccess =>
      'Member removed from the group.';

  @override
  String communityInviteUsernameSent(String username) {
    return 'Invitation sent to @$username';
  }

  @override
  String get communityHubJoinFailedOpenAnyway =>
      'Could not join community. Opening anyway…';

  @override
  String get communityHubNoneYet => 'None yet.';

  @override
  String get communityHomeTypeLabel => 'Community';

  @override
  String get communityHomeAnnouncements => 'Announcements';

  @override
  String get communityHomeWelcomeDefault => 'Welcome to your community';

  @override
  String get communityHomeNoGroups => 'No groups yet. Add your first group.';

  @override
  String get communityHomeAddGroup => 'Add Group';

  @override
  String communityDetailStats(int groupCount, int memberCount) {
    return 'Community: $groupCount groups • $memberCount members';
  }

  @override
  String get communityDetailViewGroups => 'View Groups';

  @override
  String get communityDetailViewMembers => 'View Members:';

  @override
  String get communityDetailManageMembers => 'Manage Members';

  @override
  String get communityDetailExitCommunity => 'Leave community';

  @override
  String get communityDetailExitAndDelete => 'Leave and remove from your list';

  @override
  String communityGroupsTitle(String communityName) {
    return '$communityName Groups';
  }

  @override
  String communityMembersTitle(String communityName) {
    return '$communityName Members';
  }

  @override
  String get communityGroupJoin => 'Join Group';

  @override
  String get communityGroupDelete => 'Delete Group';

  @override
  String get communityGroupAddNew => '+ Add new Group';

  @override
  String get communityAddGroupTitle => 'Add Group';

  @override
  String get communityAddGroupSuccess =>
      'Your group was added to the community!';

  @override
  String get communityAddGroupHeader => 'Add New Group To Your Community';

  @override
  String get communityAddGroupProfileLabel => 'Add your group\'s profile:';

  @override
  String get communityAddGroupNameLabel => 'Group name:';

  @override
  String get communityAddGroupNameHint => 'Group name';

  @override
  String get communityAddGroupDescLabel => 'Group description';

  @override
  String get communityAddGroupDescHint => 'Group description';

  @override
  String get communityAddButton => 'Add';

  @override
  String get communityLabelOptional => '(optional):';

  @override
  String get communityEditProfileHeader => 'Edit your community profile:';

  @override
  String get communityEditNameLabel => 'Community name:';

  @override
  String get communityEditDescHint => 'Community description';

  @override
  String get communityEditGroupsLabel => 'Community groups:';

  @override
  String get communityEditSaving => 'Saving…';

  @override
  String get communityChatEmpty => 'No messages yet. Say hello!';

  @override
  String get communityChatTypeHint => 'Type a message…';

  @override
  String get communityChatMemberFallback => 'Member';

  @override
  String get communityChatSharedFromMishka => 'Shared from Mishka';

  @override
  String get communityMemberAddToGroup => 'Add to group';

  @override
  String get communityMemberRemoveFromCommunity => 'Remove from community';

  @override
  String communitySelectGroupPrompt(String memberName) {
    return 'Select a group for $memberName';
  }

  @override
  String get communityMemberAddedToGroupSuccess => 'Member added to the group.';

  @override
  String get communityShareChooseMaterial =>
      'Choose saved AI material to share with this group.';

  @override
  String get communityShareNoSavedInCategory =>
      'No saved items in this category yet.';

  @override
  String get communityDiscoverySubjectsOptional => 'Subjects (optional)';

  @override
  String get communityDiscoveryPurposeOptional => 'Purpose (optional)';

  @override
  String get communityInviteEmailHint => 'Email address';

  @override
  String get communityErrorServerUnreachable =>
      'Could not reach the server. Check that the backend is running.';

  @override
  String get communityRoleOwner => 'Owner';

  @override
  String get communityRoleAdmin => 'Admin';

  @override
  String get communityRoleMember => 'Member';

  @override
  String get communityFallbackName => 'Community';

  @override
  String get communityFallbackGroupName => 'Group';

  @override
  String get communityFallbackMemberName => 'Member';

  @override
  String get communityBrandMishka => 'Mishka';

  @override
  String get reportCommunitySection => 'Our Community';

  @override
  String get reportCommunityMessages => 'Messages posted';

  @override
  String get reportCommunityMaterialShares => 'Materials shared';

  @override
  String get reportCommunityChannelJoins => 'Channel joins';
}
