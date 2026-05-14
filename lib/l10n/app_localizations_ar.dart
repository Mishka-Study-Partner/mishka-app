// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ميشكا';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get createAccountAtMishka => 'أنشئ حسابك في MISHKA';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get exampleEmail => 'Example1234@gmail.com';

  @override
  String get password => 'كلمة المرور';

  @override
  String get examplePassword => 'Pass123#!\\\$';

  @override
  String get rememberMe => 'تذكرني';

  @override
  String get forgetPassword => 'نسيت كلمة المرور؟';

  @override
  String get agreeToTerms => 'الموافقة على الشروط والأحكام وسياسة الخصوصية';

  @override
  String get alreadyHaveAccount => 'هل لديك حساب بالفعل؟ تسجيل الدخول';

  @override
  String get orSignUpWith => 'أو سجل مع';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get welcomeBackToMishka => 'مرحباً بعودتك إلى MISHKA';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟ إنشاء حساب';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get resetPasswordUsing => 'إعادة تعيين كلمة المرور باستخدام:';

  @override
  String get writeEmailForCode =>
      'اكتب بريدك الإلكتروني لتلقي رمز التأكيد لإنشاء كلمة مرور جديدة';

  @override
  String get getCode => 'احصل على الرمز';

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String get verifyByEmail => 'التحقق عبر عنوان البريد الإلكتروني';

  @override
  String get enter5DigitsCodeEmail =>
      'أدخل رمز الخمسة أرقام الذي تلقيته على بريدك الإلكتروني: example123@gamil.com';

  @override
  String enter6DigitsCodeEmail(String email) {
    return 'أدخل رمز التحقق المكون من 6 أرقام الذي استلمته على بريدك الإلكتروني: $email';
  }

  @override
  String get verify => 'تحقق';

  @override
  String get successfullyVerified => 'تم التحقق بنجاح';

  @override
  String get letsStartSettingAccount =>
      'دعنا نبدأ بإعداد حسابك حتى تتمكن من بدء استخدام التطبيق';

  @override
  String get enterNewPassword => 'أدخل كلمة المرور الجديدة';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get passwordRequirements => 'يجب أن تحتوي كلمة المرور على:';

  @override
  String get passwordRequirement1 => 'بين 8 و 20 حرفاً';

  @override
  String get passwordRequirement2 => 'حرف كبير واحد على الأقل';

  @override
  String get passwordRequirement3 => 'رقم واحد أو أكثر';

  @override
  String get passwordRequirement4 => 'حرف خاص واحد أو أكثر';

  @override
  String get setPassword => 'تعيين كلمة المرور';

  @override
  String get passwordSuccessfullySet => 'تم تعيين كلمة المرور بنجاح';

  @override
  String get writePhoneForCode =>
      'اكتب رقم هاتفك لتلقي رمز التأكيد لإنشاء كلمة مرور جديدة';

  @override
  String get verifyByPhoneNumber => 'التحقق عبر رقم الهاتف';

  @override
  String get enter5DigitsCodePhone =>
      'أدخل رمز الخمسة أرقام الذي تلقيته (SMS) على +20 1010101010';

  @override
  String get welcomeBackSara => 'مرحباً بعودتك، زياد!';

  @override
  String get sundayJan26 => 'الأحد، 26 يناير 2026';

  @override
  String get dailyStreaks => 'سلسلة الأيام:';

  @override
  String days(int count) {
    return '$count أيام';
  }

  @override
  String get mon => 'الاثنين';

  @override
  String get tue => 'الثلاثاء';

  @override
  String get wed => 'الأربعاء';

  @override
  String get thu => 'الخميس';

  @override
  String get fri => 'الجمعة';

  @override
  String get sat => 'السبت';

  @override
  String get sun => 'الأحد';

  @override
  String get completed => 'مكتمل';

  @override
  String get today => 'اليوم';

  @override
  String get upcoming => 'قادم';

  @override
  String get tipOfTheDay => 'نصيحة اليوم';

  @override
  String get tipQuote => 'أنا معجب بجهدك وعملية عملك أكثر من الدرجة النهائية.';

  @override
  String get upComingDeadlines => 'المواعيد النهائية القادمة:';

  @override
  String get viewYourToDoList => 'عرض قائمة المهام الخاصة بك';

  @override
  String get task => 'المهمة:';

  @override
  String get plcSheet2Offline => 'ورقة PLC 2 (غير متصل)';

  @override
  String get meetingForGraduationProject => 'اجتماع لمشروع التخرج';

  @override
  String get list => 'القائمة:';

  @override
  String get collegeTasksList => 'قائمة مهام الكلية.';

  @override
  String get workTasksList => 'قائمة مهام العمل.';

  @override
  String get deadline => 'الموعد النهائي:';

  @override
  String get sunJan262025 => 'الأحد، 26 يناير 2025';

  @override
  String get pm700 => '07:00 م';

  @override
  String get pm900 => '09:00 م';

  @override
  String get pm200 => '02:00 م';

  @override
  String get mishkasAiTools => 'أدوات MISHKA الذكية:';

  @override
  String get viewMore => 'عرض المزيد';

  @override
  String get chatWithMishka => 'الدردشة مع ميشكا';

  @override
  String get summarizeWithMishka => 'تلخيص مع ميشكا';

  @override
  String get makeFlashcardsWithMishka => 'إنشاء بطاقات تعليمية مع ميشكا';

  @override
  String get makeQuizzesWithMishka => 'إنشاء اختبارات مع ميشكا';

  @override
  String get studyWithMishka => 'الدراسة مع ميشكا:';

  @override
  String get start => 'ابدأ';

  @override
  String get mishkasCommunity => 'مجتمع ميشكا:';

  @override
  String get join => 'انضم';

  @override
  String get youCanAddNewCommunity => 'يمكنك إضافة مجتمع جديد';

  @override
  String get youCanRejoinSavedCommunity =>
      'يمكنك إعادة الانضمام إلى مجتمعك المحفوظ';

  @override
  String get exploreCommunitiesByMajor => 'استكشف مجتمعاتنا بناءً على تخصصك';

  @override
  String get mishkasSupport => 'دعم ميشكا:';

  @override
  String get exploreMore => 'استكشف المزيد';

  @override
  String get countDailyStudyHours => 'احسب ساعات دراستك اليومية مع ميشكا';

  @override
  String get winMishkasChallenges => 'اربح تحديات ميشكا واحصل على جائزتك';

  @override
  String get getPointsByChatting =>
      'احصل على نقاط من خلال الدردشة مع ميشكا كل يوم';

  @override
  String get viewAllBadgesMonthly => 'عرض جميع شاراتك شهرياً مع ميشكا';

  @override
  String get home => 'الرئيسية';

  @override
  String get toDo => 'المهام';

  @override
  String get category => 'الفئة';

  @override
  String get saved => 'المحفوظات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get profileFieldNotSet => '—';

  @override
  String get profileLoadFailed => 'تعذّر تحديث الملف الشخصي.';

  @override
  String get removeProfilePhotoConfirm => 'إزالة صورة الملف الشخصي؟';

  @override
  String get remove => 'إزالة';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get profileUpdateFailed => 'تعذّر حفظ الملف الشخصي.';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب.';

  @override
  String get invalidEmailHint => 'يرجى إدخال بريد إلكتروني صالح.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get aiTools => 'الأدوات الذكية';

  @override
  String get aiToolsSubtitle =>
      'الدردشة مع ميشكا، الاختبارات، البطاقات التعليمية، الملخص.';

  @override
  String get toDoList => 'قائمة المهام';

  @override
  String get yourToDoList => 'قائمة مهامك.';

  @override
  String get studyWithMe => 'ادرس معي';

  @override
  String get studyWithMeSubtitle => 'الوضع الفردي، الوضع الجماعي، شريك ميشكا.';

  @override
  String get ourCommunity => 'مجتمعنا';

  @override
  String get ourCommunitySubtitle =>
      'مكتبة المرشدين، مجتمع الأحداث، تاريخ الإرشاد.';

  @override
  String get gamification => 'التلعيب';

  @override
  String get gamificationSubtitle => 'النقاط، السلاسل، الشارات، التحديات.';

  @override
  String get accountSetting => 'إعدادات الحساب:';

  @override
  String get fullName => 'الاسم الكامل:';

  @override
  String get yourFullName => 'اسمك الكامل';

  @override
  String get userName => 'اسم المستخدم:';

  @override
  String get yourUserName => 'اسم المستخدم الخاص بك';

  @override
  String get gender => 'الجنس:';

  @override
  String get female => 'أنثى';

  @override
  String get male => 'ذكر';

  @override
  String get ratherNotToSay => 'أفضل عدم القول';

  @override
  String get contactInfo => 'معلومات الاتصال:';

  @override
  String get exampleEmailContact => 'example123@gmail.com';

  @override
  String get language => 'اللغة:';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get theme => 'المظهر:';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get themeSystem => 'تلقائي (النظام)';

  @override
  String get notification => 'الإشعارات:';

  @override
  String get enabled => 'مفعل';

  @override
  String get disabled => 'متوقف';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get chooseAppearance => 'اختر المظهر';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get search => 'بحث ...';

  @override
  String get chatWithMishkaTitle => 'الدردشة مع MISHKA';

  @override
  String get flashCards => 'البطاقات التعليمية';

  @override
  String get quizzes => 'الاختبارات';

  @override
  String get summarize => 'تلخيص';

  @override
  String get yourHistory => 'سجلك';

  @override
  String get searchYourHistory => 'ابحث في سجلك...';

  @override
  String get chats => 'المحادثات:';

  @override
  String get tellMeMoreAboutMishka => 'أخبرني المزيد عن تطبيق MISHKA؟';

  @override
  String get quizes => 'الاختبارات:';

  @override
  String get makeMeFlashcards =>
      'اصنع لي بطاقات تعليمية واختبارات وملخص للمقال لهذه الملفات المرفوعة';

  @override
  String get flashCardsColon => 'البطاقات التعليمية:';

  @override
  String get summarization => 'التلخيص:';

  @override
  String get mishka => 'ميشكا';

  @override
  String get helloSara => 'مرحباً، سارة!';

  @override
  String get askMishka => 'اسأل MISHKA ....';

  @override
  String get apologizeNotUnderstand => 'أعتذر، لكنني لم أفهم هذا الإدخال';

  @override
  String get pleaseClarify => 'هل يمكنك توضيح طلبك.';

  @override
  String get tellMeMoreAboutMishkaApp => 'أخبرني المزيد عن تطبيق MISHKA؟';

  @override
  String get mishkaDescription =>
      'ميشكا هو رفيق دراسة تفاعلي مدعوم بالذكاء الاصطناعي، مصمم لمعالجة العقبات الرئيسية التي يواجهها الطلاب في التعليم الحديث: صعوبة فهم المواد المعقدة، التشتت، نقص التحفيز، وفرص التعاون المحدودة. من خلال الجمع بين الذكاء الاصطناعي والتلعيب والتصميم الشامل في منصة واحدة متكاملة، يحول ميشكا الدراسة من نشاط معزول ومرهق إلى تجربة جذابة ومنظمة ومجزية.';

  @override
  String get whatMakesMishkaBetter =>
      'لكن ما الذي يجعل MISHKA أفضل من التطبيقات الأخرى؟';

  @override
  String get mishkaBetterDescription =>
      'يتميز ميشكا عن تطبيقات الدراسة الأخرى من خلال دمج الذكاء الاصطناعي والتلعيب والتصميم الشامل في منصة واحدة، متجاوزاً التدريس الأساسي لمعالجة العقبات الرئيسية للطلاب من المواد المعقدة والتشتت ونقص التحفيز، وتحويل الدراسة إلى تجربة جذابة ومنظمة ومجزية للجميع.';

  @override
  String get uploadFiles => 'رفع الملفات';

  @override
  String get uploadPDF => 'رفع PDF';

  @override
  String get uploadImage => 'رفع صورة';

  @override
  String get uploadVideo => 'رفع فيديو';

  @override
  String get uploadArticle => 'رفع مقال';

  @override
  String get pdfsName => 'اسم ملف PDF';

  @override
  String get file => 'ملف';

  @override
  String get photo => 'صورة';

  @override
  String get pdf => 'pdf';

  @override
  String get fileLower => 'ملف';

  @override
  String get pngJpeg => 'png/jpeg';

  @override
  String get article => 'مقال';

  @override
  String get video => 'فيديو';

  @override
  String get text => 'نص';

  @override
  String get mp3 => 'mp3';

  @override
  String get pleaseEnterMaterialFlashcards =>
      'يرجى إدخال مادتك حتى أتمكن من إنشاء بطاقات تعليمية لك.';

  @override
  String get pleaseEnterMaterialQuizzes =>
      'يرجى إدخال مادتك حتى أتمكن من تحويلها إلى اختبارات متعددة الخيارات.';

  @override
  String get pleaseEnterMaterialSummarize =>
      'يرجى إدخال مادتك حتى أتمكن من تلخيصها لك.';

  @override
  String get thisIsYourFlashcards => 'هذه هي بطاقاتك التعليمية:';

  @override
  String get successfullyReviewedFlashcards =>
      'لقد راجعت جميع بطاقاتنا التعليمية بنجاح، عمل رائع!';

  @override
  String get eyeOfHorus => 'عين حورس';

  @override
  String get wedjitEye => '(عين وجيت)';

  @override
  String get ancientEgyptian => 'مصري قديم';

  @override
  String get goldCollar => 'طوق ذهبي';

  @override
  String get lifeKey => 'مفتاح الحياة';

  @override
  String get hieroglyphs => 'الهيروغليفية';

  @override
  String get okThankYouMishka => 'حسناً، شكراً لك ميشكا';

  @override
  String get hereIsYourQuiz => 'هذا هو اختبارك:';

  @override
  String get whatIsMishkaApp => 'ما هو تطبيق ميشكا؟';

  @override
  String quizProgress(int current, int total) {
    return '$current/$total';
  }

  @override
  String get next => 'التالي';

  @override
  String get correctAnswer => 'إجابة صحيحة.';

  @override
  String get wrongAnswer => 'إجابة خاطئة';

  @override
  String get back => 'رجوع';

  @override
  String get done => 'تم';

  @override
  String get hereIsYourSummarizedArticle => 'هذا هو مقالك الملخص:';

  @override
  String get toDoListTitle => 'قائمة المهام';

  @override
  String get yourList => 'قائمتك:';

  @override
  String get searchList => 'بحث في القائمة ...';

  @override
  String get calender => 'التقويم';

  @override
  String get allTasks => 'جميع المهام';

  @override
  String get collegeTasks => 'مهام الكلية';

  @override
  String get workTasks => 'مهام العمل';

  @override
  String get personalTasks => 'المهام الشخصية';

  @override
  String get addNewTask => 'إضافة مهمة جديدة';

  @override
  String get addNewList => 'إضافة قائمة جديدة';

  @override
  String get selectList => 'اختر القائمة';

  @override
  String get chooseListIcon => 'اختر أيقونة قائمتك';

  @override
  String get listName => 'اسم القائمة:';

  @override
  String get typeListName => 'اكتب اسم قائمتك هنا';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get editTask => 'تعديل المهمة';

  @override
  String get areYouSureDeleteTask => 'هل أنت متأكد أنك تريد حذف هذه المهمة؟؟';

  @override
  String get no => 'لا';

  @override
  String get yes => 'نعم';

  @override
  String get savedFlashCards => 'البطاقات التعليمية المحفوظة';

  @override
  String get view => 'عرض';

  @override
  String get savedQuizes => 'الاختبارات المحفوظة';

  @override
  String get savedSummary => 'الملخص المحفوظ';

  @override
  String get savedSearchHint => 'ابحث في المحفوظات...';

  @override
  String get savedDetailPlaceholder =>
      'سيظهر المحتوى المحفوظ هنا عند ربط المكتبة.';

  @override
  String get savedNoSearchResults => 'لا توجد عناصر مطابقة لبحثك.';

  @override
  String get savedLibraryEmpty =>
      'لا يوجد شيء محفوظ بعد. أنشئ محتوى من أدوات الذكاء الاصطناعي ثم احفظه.';

  @override
  String get savedDetailItemUnavailable => 'هذا العنصر لم يعد متاحاً.';

  @override
  String get savedDetailNotInLibraryAnymore =>
      'هذا العنصر لم يعد في مكتبتك المحفوظة. اسحب للتحديث.';

  @override
  String get savedDetailNotFound => 'تعذر العثور على هذا العنصر.';

  @override
  String get savedDetailMissingListId =>
      'لا يوجد معرّف لهذا العنصر. حدّث القائمة.';

  @override
  String get savedLibraryRemoveQuestion => 'إزالة هذا من مكتبتك المحفوظة؟';

  @override
  String get savedLibraryRemoved => 'تمت الإزالة من المحفوظات.';

  @override
  String get savedLibraryShared => 'تمت المشاركة إلى قنواتك.';

  @override
  String get result => 'النتيجة';

  @override
  String get congratulation => 'تهانينا!';

  @override
  String get keepItUp => 'استمر';

  @override
  String get collectBadge => 'اجمع الشارة';

  @override
  String get answered100Percent => 'لقد أجبت على 100% من الإجابات الصحيحة';

  @override
  String get answered80Percent => 'لقد أجبت على 80% من الإجابات الصحيحة';

  @override
  String get answered40Percent => 'لقد أجبت على 40% من الإجابات الصحيحة';

  @override
  String get keepGoing => 'استمر';

  @override
  String get delete => 'حذف';

  @override
  String get undo => 'تراجع';

  @override
  String get deleteThisListQuestion => 'حذف هذه القائمة؟';

  @override
  String get listDeleted => 'تم حذف القائمة';

  @override
  String get renameList => 'إعادة تسمية القائمة';

  @override
  String get listRenamed => 'تم إعادة تسمية القائمة';

  @override
  String get errorPrefix => 'خطأ';

  @override
  String get pleaseFillAllRequiredFields => 'يرجى ملء جميع الحقول المطلوبة';

  @override
  String get pleaseEnterVerificationCode => 'يرجى إدخال رمز التحقق';

  @override
  String get pleaseEnterBothPasswordFields => 'يرجى إدخال حقلي كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get myTasks => 'مهامي';

  @override
  String get day => 'اليوم';

  @override
  String get month => 'الشهر';

  @override
  String get year => 'السنة';

  @override
  String get noUpcomingDeadlinesYet => 'لا توجد مواعيد نهائية قادمة بعد.';

  @override
  String get ok => 'حسنًا';

  @override
  String get privacyPolicyComingSoon => 'شاشة سياسة الخصوصية قريبًا.';

  @override
  String get helpSupportComingSoon => 'شاشة المساعدة والدعم قريبًا.';

  @override
  String get taskActionsComingSoon =>
      'تعديل المهمة والحذف والإكمال ستتوفر في تحديث قادم.';

  @override
  String get deleteTaskConfirm => 'هل تريد حذف هذه المهمة؟';

  @override
  String get taskDeleted => 'تم حذف المهمة.';

  @override
  String get taskMarkedComplete => 'تم وضع علامة مكتمل على المهمة.';

  @override
  String get taskMarkedPending => 'تم إعادة المهمة إلى قيد الانتظار.';

  @override
  String get createListBeforeAddingTasks =>
      'أنشئ قائمة أولاً ثم أضف المهام داخلها.';

  @override
  String get chooseListForNewTask => 'إلى أي قائمة تريد إضافة هذه المهمة؟';

  @override
  String get logoutConfirmationMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get couldNotReadFilePath => 'تعذر قراءة مسار الملف';

  @override
  String get mindMap => 'الخريطة الذهنية';

  @override
  String get share => 'مشاركة';

  @override
  String get shareToCommunityChannels => 'المشاركة إلى قنوات المجتمع';

  @override
  String get noCommunityChannelsFound => 'لا توجد قنوات مجتمع متاحة';

  @override
  String failedToLoadChannels(String error) {
    return 'تعذر تحميل القنوات: $error';
  }

  @override
  String shareFailed(String error) {
    return 'فشلت المشاركة: $error';
  }

  @override
  String sharedToChannelsCount(int count) {
    return 'تمت المشاركة إلى $count قناة';
  }

  @override
  String get uploadMaterialToGenerateSummary => 'ارفع المادة لإنشاء ملخص';

  @override
  String get uploadMaterialToGenerateQuiz => 'ارفع المادة لإنشاء اختبار';

  @override
  String get uploadMaterialToGenerateFlashcards =>
      'ارفع المادة لإنشاء بطاقات تعليمية';

  @override
  String get uploadMaterialToGenerateMindMap =>
      'ارفع المادة لإنشاء خريطة ذهنية';

  @override
  String generationFailed(String error) {
    return 'فشل التوليد: $error';
  }

  @override
  String get savedToYourLibrary => 'تم الحفظ في مكتبتك';

  @override
  String saveFailed(String error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String fileLabel(String name) {
    return 'الملف: $name';
  }

  @override
  String get generating => 'جارٍ التوليد...';

  @override
  String get uploadMaterial => 'رفع المادة';

  @override
  String get calendar => 'التقويم';

  @override
  String get chooseYourStudyMode => 'اختر وضع الدراسة';

  @override
  String get cameraMode => 'وضع الكاميرا';

  @override
  String get concentrationMode => 'وضع التركيز';

  @override
  String get pomodoroTimers => 'مؤقت بومودورو';

  @override
  String get customTimer => 'مؤقت مخصص';

  @override
  String get createLinkWithFriends => 'أنشئ رابطاً مع الأصدقاء';

  @override
  String get studyWithYourFriends => 'ادرس مع أصدقائك';

  @override
  String get createNewLink => 'أنشئ رابطاً جديداً';

  @override
  String get createLinkAndPassword => 'أنشئ رابطاً وكلمة مرور';

  @override
  String get comingSoonFeature => 'هذه الميزة قادمة قريباً!';

  @override
  String get mentorLibrary => 'مكتبة المرشدين';

  @override
  String get communityEvents => 'فعاليات المجتمع';

  @override
  String get mentorshipHistory => 'سجل الإرشاد';

  @override
  String get joinNewCommunity => 'انضم لمجتمع جديد';

  @override
  String get rejoinSavedCommunity => 'أعد الانضمام لمجتمعك المحفوظ';

  @override
  String get theTask => 'المهمة:';

  @override
  String get typeYourTaskHere => 'اكتب مهمتك هنا';

  @override
  String get date => 'التاريخ:';

  @override
  String get time => 'الوقت:';

  @override
  String get startTimer => 'ابدأ المؤقت';

  @override
  String get studyTime => 'وقت الدراسة';

  @override
  String get shortBreak => 'استراحة قصيرة';

  @override
  String get longBreak => 'استراحة طويلة';

  @override
  String get mins => 'دقائق';

  @override
  String get completedCycles => 'الدورات المكتملة';

  @override
  String get areYouStillThere => 'هل ما زلت هنا؟';

  @override
  String get howIsYourMoodWhileStudying => 'كيف حالك أثناء الدراسة؟';

  @override
  String get yesContinue => 'نعم، أكمل';

  @override
  String get noStop => 'لا، توقف';

  @override
  String get customYourOwnTimer => 'خصص مؤقتك الخاص:';

  @override
  String get recentlyCustomizedTimers => 'المؤقتات المخصصة مؤخراً:';

  @override
  String get cameraOn => 'الكاميرا مفعلة';

  @override
  String get videoCallWithMishka => 'مكالمة فيديو مع مشكا';

  @override
  String get cameraIsOn => 'الكاميرا مفعلة';

  @override
  String get cameraIsOff => 'الكاميرا مغلقة';

  @override
  String get timer => 'المؤقت';

  @override
  String get yourStudyLink => 'رابط الدراسة الخاص بك:';

  @override
  String get linkCopied => 'تم نسخ الرابط!';

  @override
  String get linkCopiedAndReady => 'تم نسخ الرابط وجاهز للمشاركة!';

  @override
  String get copyAndShare => 'نسخ ومشاركة';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get noPreviousCustomTimers => 'لا توجد مؤقتات مخصصة سابقة.';

  @override
  String get howIsYourModeWhileStudying => 'كيف حالك أثناء الدراسة؟';

  @override
  String get makingGoodProgressToday => 'هل تحرز تقدماً جيداً اليوم؟';

  @override
  String get takeBreak => 'خذ استراحة';

  @override
  String get endCall => 'إنهاء المكالمة';

  @override
  String get backToCall => 'العودة للمكالمة';

  @override
  String get breakTime => 'وقت الاستراحة';

  @override
  String get cameraPermissionRequired =>
      'يجب السماح بالوصول للكاميرا لوضع مكالمة الفيديو.';
}
