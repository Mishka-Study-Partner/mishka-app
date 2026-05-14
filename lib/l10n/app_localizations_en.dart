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
  String get verifyByEmail => 'Verify BY email address';

  @override
  String get enter5DigitsCodeEmail =>
      'Enter the 5 digits code you received at your Gmail : example123@gamil.com';

  @override
  String enter6DigitsCodeEmail(String email) {
    return 'Enter the 6 digits code you received at your email: $email';
  }

  @override
  String get verify => 'Verify';

  @override
  String get successfullyVerified => 'successfully Verified';

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
  String get passwordSuccessfullySet => 'Password is successfully set';

  @override
  String get writePhoneForCode =>
      'write your PHONE NUMBER to receive your confirmation code to create your new password';

  @override
  String get verifyByPhoneNumber => 'Verify by phone number';

  @override
  String get enter5DigitsCodePhone =>
      'Enter the 5 digits code you received (SMS) at +20 1010101010';

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
  String get yourHistory => 'your History';

  @override
  String get searchYourHistory => 'Search your history...';

  @override
  String get chats => 'chats:';

  @override
  String get tellMeMoreAboutMishka => 'Tell me more about MISHKA app?';

  @override
  String get quizes => 'Quizes:';

  @override
  String get makeMeFlashcards =>
      'make me flashcards and quizzes and summarize the article for these uploaded files';

  @override
  String get flashCardsColon => 'FlashCards:';

  @override
  String get summarization => 'Summarization :';

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
}
