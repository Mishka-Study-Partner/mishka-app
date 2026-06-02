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
  String enter5DigitsCodeEmail(String email) {
    return 'أدخل رمز الخمسة أرقام الذي تلقيته على بريدك الإلكتروني: $email';
  }

  @override
  String enter6DigitsCodeEmail(String email) {
    return 'أدخل رمز التحقق المكون من 6 أرقام الذي استلمته على بريدك الإلكتروني: $email';
  }

  @override
  String enter6DigitsCodePhone(String phone) {
    return 'أدخل رمز الـ 6 أرقام الذي تلقيته (SMS) على $phone';
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
  String enter5DigitsCodePhone(String phone) {
    return 'أدخل رمز الخمسة أرقام الذي تلقيته (SMS) على $phone';
  }

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
  String streakStats(int longest, int freezes) {
    return 'الأفضل: $longest · $freezes تجميدات متبقية';
  }

  @override
  String get streakMissed => 'فائت (اضغط للتجميد)';

  @override
  String get streakFreezeTitle => 'استخدام تجميد السلسلة؟';

  @override
  String streakFreezeMessage(String date) {
    return 'حماية سلسلتك ليوم $date؟';
  }

  @override
  String get streakFreezeConfirm => 'استخدام التجميد';

  @override
  String get streakFreezeSuccess => 'تم تطبيق تجميد السلسلة';

  @override
  String get streakFreezeFailed => 'تعذر تطبيق تجميد السلسلة';

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
  String get yourHistory => 'سجلّك';

  @override
  String get searchYourHistory => 'ابحث في سجلّك...';

  @override
  String get historyChats => 'المحادثات:';

  @override
  String get historyQuizzes => 'الاختبارات:';

  @override
  String get historyFlashCards => 'البطاقات:';

  @override
  String get historySummarization => 'الملخصات :';

  @override
  String get historyMindMaps => 'الخرائط الذهنية:';

  @override
  String get historyEmpty => 'لا يوجد سجل';

  @override
  String get historyLoadFailed => 'تعذر تحميل هذه المحادثة';

  @override
  String get chatGreeting => 'مرحباً، ارفع مادتك لنبدأ رحلتنا';

  @override
  String get chatAnalyzingPdf => 'جاري تحليل PDF...';

  @override
  String get chatWhichTool => 'أي أداة تريد استخدامها؟';

  @override
  String get chatWaitForExplanation => 'يرجى انتظار اكتمال الشرح أولاً.';

  @override
  String get chatUploadPdfHint => 'ارفع PDF للبدء';

  @override
  String get chatChooseDifficultyHint => 'اختر مستوى الصعوبة أعلاه';

  @override
  String get chatDifficultySimple => 'بسيط';

  @override
  String get chatDifficultyIntermediate => 'متوسط';

  @override
  String get chatDifficultyAdvanced => 'متقدم';

  @override
  String get chatToolQuiz => 'اختبار';

  @override
  String get chatToolFlashcards => 'بطاقات';

  @override
  String get chatToolMindMap => 'خريطة ذهنية';

  @override
  String get chatToolSummarize => 'تلخيص';

  @override
  String get chatRegenerate => 'إعادة إنشاء';

  @override
  String get chatAnotherTool => 'أداة أخرى';

  @override
  String chatToolSelected(String tool) {
    return 'رائع! اخترت: $tool. جاري إنشاؤها...';
  }

  @override
  String chatRegenerating(String tool) {
    return 'جاري إعادة إنشاء $tool...';
  }

  @override
  String chatRegenerationFailed(String error) {
    return 'فشلت إعادة الإنشاء.\n$error';
  }

  @override
  String chatAnalyzePdfFailed(String error) {
    return 'فشل تحليل PDF.\n$error';
  }

  @override
  String chatToolGenerationFailed(String error) {
    return 'فشل إنشاء الأداة.\n$error';
  }

  @override
  String chatMessageFailed(String error) {
    return 'فشلت الدردشة.\n$error';
  }

  @override
  String chatSessionStartFailed(String error) {
    return 'تعذر بدء جلسة الدردشة.\n$error';
  }

  @override
  String get chatNewChatTitle => 'بدء محادثة جديدة؟';

  @override
  String get chatNewChatMessage =>
      'محادثتك الحالية تبقى في السجل. يمكنك إعادة فتحها من القائمة.';

  @override
  String get chatNewChatConfirm => 'محادثة جديدة';

  @override
  String get chatNewChatAction => 'محادثة جديدة';

  @override
  String get renameSavedItem => 'إعادة تسمية العنصر';

  @override
  String get savedItemRenamed => 'تمت إعادة تسمية العنصر';

  @override
  String get savedRenameUnavailable => 'لا يمكن إعادة تسمية هذا العنصر';

  @override
  String get savedItemTitleHint => 'العنوان';

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
  String get invalidPhoneHint => 'يرجى إدخال رقم هاتف صالح.';

  @override
  String get nameTooLong => 'يجب ألا يزيد الاسم عن 50 حرفاً.';

  @override
  String get accountAlreadyExists =>
      'يوجد حساب مسجّل بهذا البريد أو رقم الهاتف مسبقاً.';

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
  String get settings => 'الإعدادات';

  @override
  String get settingsSubtitle => 'اللغة، المظهر، الإشعارات';

  @override
  String get settingsDescription =>
      'اختر شكل تطبيق Mishka وكيف نتواصل معك. تُطبَّق التغييرات على هذا الجهاز وتُزامَن مع حسابك عند تسجيل الدخول.';

  @override
  String get settingsPreferencesSection => 'التفضيلات';

  @override
  String get settingsSyncFailed =>
      'تعذّر مزامنة الإعدادات مع حسابك. تم حفظ اختيارك على هذا الجهاز.';

  @override
  String get privacyPolicyBody =>
      'يحترم Mishka خصوصيتك. نجمع فقط المعلومات اللازمة لتشغيل حسابك وتخصيص ميزات الدراسة وتحسين التطبيق.\n\nنستخدم بريدك الإلكتروني وبيانات ملفك للمصادقة والتواصل بشأن حسابك. يُخزَّن نشاط الدراسة والمهام وتفاعلات الذكاء الاصطناعي لتوفير السجل والسلاسل وميزات التدريس التي تستخدمها.\n\nلا نبيع بياناتك الشخصية. قد نشارك بيانات محدودة مع مزودي البنية التحتية والإشعارات بموجب سرية صارمة.\n\nيمكنك تحديث ملفك وتعليمك وتفضيلاتك من التطبيق. تواصل مع الدعم إذا احتجت الوصول أو التصحيح أو الحذف.\n\nهذا ملخص للتيسير. قد تُنشر سياسة قانونية كاملة لاحقًا على موقعنا.';

  @override
  String get helpSupportIntro =>
      'تحتاج مساعدة في Mishka؟ تواصل معنا عبر بيانات الاتصال أدناه.';

  @override
  String get helpSupportContactsTitle => 'تواصل معنا';

  @override
  String get helpSupportTapToOpen =>
      'اضغط على الصف لفتح Gmail أو واتساب أو الرابط في التطبيق المناسب.';

  @override
  String get linkOpenFailed => 'تعذّر فتح هذا الرابط على جهازك.';

  @override
  String get linkOpenFailedCopied =>
      'تعذّر فتح التطبيق — تم النسخ إلى الحافظة.';

  @override
  String get supportFacebook => 'فيسبوك';

  @override
  String get supportInstagram => 'إنستغرام';

  @override
  String get supportWhatsApp => 'واتساب';

  @override
  String get copiedToClipboard => 'تم النسخ';

  @override
  String get helpSupportBody =>
      'تحتاج مساعدة في Mishka؟ إليك خطوات سريعة.\n\nالحساب وتسجيل الدخول: استخدم «نسيت كلمة المرور» من شاشة الدخول. تأكد أن البريد أو الهاتف يطابق ما سجّلت به.\n\nالدراسة مع Mishka: ابدأ جلسة من الرئيسية، اختر مؤقتًا، وابقَ على شاشة الجلسة حتى تنهي أو تتوقف مبكرًا. إن فشل البدء، تحقق من الاتصال وأعد المحاولة.\n\nالمهام والقوائم: أنشئ قوائم من قسم المهام، ثم أضف مهامًا بمواعيد. اسحب للتحديث في الرئيسية لرؤية المهام القادمة.\n\nالملف والتعليم: افتح الملف الشخصي لتعديل الاسم والاتصال والجنس والمستوى التعليمي. استخدم الإعدادات للغة والمظهر والإشعارات.\n\nما زلت بحاجة لمساعدة؟ راسلنا على support@mishka.app مع وصف مختصر ولقطات إن أمكن. نرد عادة خلال أيام عمل.';

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
  String get shareCommunitiesYouJoined => 'المجتمعات التي انضممت إليها';

  @override
  String get shareToSelectedGroups => 'المشاركة إلى المجموعات المحددة';

  @override
  String shareMembersGroupsCount(int members, int groups) {
    return '$members عضو $groups مجموعات';
  }

  @override
  String shareGroupMembersCount(int count) {
    return '$count عضو';
  }

  @override
  String get shareSuccessTitle => 'تمت المشاركة بنجاح إلى المجموعة';

  @override
  String get shareSuccessContinue => 'متابعة';

  @override
  String get shareOpenGroup => 'فتح المجموعة';

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

  @override
  String get onboardingIntroLine1 => 'أنا ميشكا، حارس المعرفة،';

  @override
  String get onboardingIntroLine2 => 'تبدأ رحلتنا نحو المجد';

  @override
  String get onboardingIntroLine3 => 'الآن!';

  @override
  String get welcomeToMishka => 'مرحباً بك في ميشكا!';

  @override
  String get welcomeToMishkaSubtitle =>
      'دع حارس المعرفة يرشدك في طريق الاكتشاف.';

  @override
  String get educationLevel => 'المستوى التعليمي';

  @override
  String get educationLevelComingSoon =>
      'اختيار المستوى التعليمي سيتوفر في التحديث القادم.';

  @override
  String get educationStatusQuestion =>
      'أيٌّ مما يلي يصف وضعك التعليمي الحالي بشكل أفضل؟';

  @override
  String get school => 'مدرسة';

  @override
  String get university => 'جامعة';

  @override
  String get otherColon => 'أخرى:';

  @override
  String get schoolStageQuestion => 'في أي مرحلة مدرسية أنت الآن؟';

  @override
  String get middleSchoolColon => 'المرحلة الإعدادية:';

  @override
  String get highSchoolColon => 'المرحلة الثانوية:';

  @override
  String get firstPreparatory => 'الإعدادي الأول';

  @override
  String get secondPreparatory => 'الإعدادي الثاني';

  @override
  String get thirdPreparatory => 'الإعدادي الثالث';

  @override
  String get firstSecondary => 'الثانوي الأول';

  @override
  String get secondSecondary => 'الثانوي الثاني';

  @override
  String get thirdSecondary => 'الثانوي الثالث';

  @override
  String get universityYearQuestion => 'في أي سنة دراسية جامعية أنت الآن؟';

  @override
  String get universityColon => 'الجامعة:';

  @override
  String get firstYear => 'السنة الأولى';

  @override
  String get secondYear => 'السنة الثانية';

  @override
  String get thirdYear => 'السنة الثالثة';

  @override
  String get fourthYear => 'السنة الرابعة';

  @override
  String get fifthYear => 'السنة الخامسة';

  @override
  String get pleaseSpecifyEducationStatus => 'يرجى تحديد مستواك التعليمي:';

  @override
  String get educationOtherHint => 'أدخل مستواك التعليمي';

  @override
  String get editEducation => 'تعديل التعليم';

  @override
  String get yourReport => 'تقريرك';

  @override
  String get reportPeriodDaily => 'يومي';

  @override
  String get reportPeriodWeekly => 'أسبوعي';

  @override
  String get reportPeriodMonthly => 'شهري';

  @override
  String get reportPeriodYearly => 'سنوي';

  @override
  String get reportPeriodDailySuffix => '/يوم';

  @override
  String get reportPeriodWeeklySuffix => '/أسبوع';

  @override
  String get reportPeriodMonthlySuffix => '/شهر';

  @override
  String get reportPeriodYearlySuffix => '/سنة';

  @override
  String get reportCreatePdfEmail => 'إنشاء PDF ومشاركته';

  @override
  String get reportEmailMyReport => 'إرسال التقرير بالبريد';

  @override
  String reportPdfEmailSent(String email) {
    return 'تم إرسال التقرير إلى $email';
  }

  @override
  String get reportPdfOpenFailed => 'تعذر فتح رابط PDF للتقرير.';

  @override
  String get reportPdfSharedLocally =>
      'تعذر التصدير من الخادم — تمت مشاركة نسخة PDF محلية.';

  @override
  String get reportUsingLegacyData =>
      'يتم استخدام واجهات التقرير الكلاسيكية حتى يتم نشر الحزمة الجديدة.';

  @override
  String get reportStudyWithMishka => 'الدراسة مع ميشكا';

  @override
  String get reportDuringConcentrationMode =>
      'إجمالي وقت الدراسة (وضع التركيز + الكاميرا):';

  @override
  String get reportAiTools => 'استخدام أدوات ميشكا الذكية';

  @override
  String get reportDailyStreak => 'سلسلة الأيام';

  @override
  String get reportDailyStreakChartHint =>
      'كل شريط = يوم: 100% = حافظت على السلسلة، 0% = فاتك.';

  @override
  String get reportStreakCurrent => 'الحالية';

  @override
  String get reportStreakLongest => 'الأطول';

  @override
  String get reportStreakFreezes => 'تجميدات متبقية';

  @override
  String get reportTasksDue => 'المهام المنجزة';

  @override
  String get reportTasksDueHint => 'كل شريط = يوم — عدد المهام التي أنجزتها.';

  @override
  String get reportNoTasksInPeriod => 'لم تنجز مهاماً في هذه الفترة بعد.';

  @override
  String get reportTotalQuizzes => 'إجمالي الاختبارات';

  @override
  String get reportTotalFlashcards => 'إجمالي البطاقات';

  @override
  String get reportTotalSummaries => 'إجمالي الملخصات';

  @override
  String get reportLoadFailed => 'تعذر تحميل تقريرك. اسحب للتحديث.';

  @override
  String reportPdfFailed(String error) {
    return 'تعذر إنشاء PDF للتقرير: $error';
  }

  @override
  String get settingsReportAutoEmail => 'إرسال التقرير تلقائياً';

  @override
  String get settingsReportAutoEmailHint =>
      'استلم تقريرك الأسبوعي أو الشهري بالبريد.';

  @override
  String get reportEmailWeekly => 'أسبوعي';

  @override
  String get reportEmailMonthly => 'شهري';

  @override
  String get settingsReportRecipientRow => 'إرسال التقارير إلى';

  @override
  String get settingsReportRecipientNotSet => 'أضف بريداً';

  @override
  String get settingsReportRecipientTitle => 'بريد استلام التقرير';

  @override
  String get settingsReportRecipientBody =>
      'أدخل البريد الذي يستلم تقريرك الأسبوعي أو الشهري، وتصدير التقرير من شاشة «تقريرك».';

  @override
  String get settingsReportRecipientLabel => 'بريد المستلم';

  @override
  String get settingsReportRecipientSaved => 'تم حفظ بريد استلام التقرير.';

  @override
  String get settingsReportRecipientSavedLocal =>
      'تم الحفظ على هذا الجهاز. ستتم المزامنة مع الخادم عند دعم حقل بريد المستلم.';

  @override
  String settingsReportRecipientUseAccount(String email) {
    return 'استخدام بريد حسابي ($email)';
  }

  @override
  String get communityCreateTitle => 'إنشاء مجتمع جديد';

  @override
  String get communityCreateVisibilityLabel => 'اختر نوع المجتمع:';

  @override
  String get communityVisibilityPrivate => 'خاص';

  @override
  String get communityVisibilityPublic => 'عام';

  @override
  String get communityCreateNameLabel => 'اسم المجتمع:';

  @override
  String get communityCreateNameHint => 'اسم المجتمع';

  @override
  String get communityCreateDescLabel => 'الوصف (اختياري):';

  @override
  String get communityCreateDescHint => 'وصف المجتمع';

  @override
  String get communityCreateDiscoverSection => 'الاكتشاف (مجتمعات عامة)';

  @override
  String get communityCreateDiscoverSubtitle =>
      'ساعد الآخرين على إيجاد مجتمعك في الاكتشاف والتوصيات.';

  @override
  String get communityCreateNameRequired => 'يرجى إدخال اسم المجتمع';

  @override
  String get communityCreateSuccess => 'تم إنشاء مجتمعك بنجاح!';

  @override
  String get communityCreateButton => 'إنشاء المجتمع';

  @override
  String communityCreateEducationHintUniversity(String year) {
    return 'من ملفك: جامعة، السنة $year';
  }

  @override
  String communityCreateEducationHintSchool(String grade) {
    return 'من ملفك: مدرسة، الصف $grade';
  }

  @override
  String communityCreateEducationHintProfile(String status) {
    return 'من ملفك: $status';
  }

  @override
  String get communityHubSearchHint => 'بحث...';

  @override
  String get communityHubCreateNew => 'إنشاء مجتمع جديد';

  @override
  String get communityHubJoinPrivate => 'انضم لمجتمع خاص';

  @override
  String get communityHubSavedSection => 'المجتمعات المحفوظة:';

  @override
  String get communityHubSavedEmpty =>
      'لا توجد مجتمعات محفوظة بعد. افتح مجتمعاً واضغط ⋮ → حفظ المجتمع.';

  @override
  String get communityHubPrivateSection => 'مجتمعات خاصة أنت فيها:';

  @override
  String get communityHubPublicSection => 'مجتمعات عامة أنت فيها:';

  @override
  String get communityHubRecommendedSection => 'موصى به لك';

  @override
  String get communityHubSeeAll => 'عرض الكل';

  @override
  String get communityHubDiscoverButton => 'اكتشف المجتمعات';

  @override
  String get communityHubEmpty =>
      'لا توجد مجتمعات بعد. أنشئ واحداً أو انضم برمز.';

  @override
  String get communityHubSavedEmptySnack =>
      'لا توجد مجتمعات محفوظة. افتح مجتمعاً واستخدم ⋮ → حفظ المجتمع.';

  @override
  String get communitySave => 'حفظ المجتمع';

  @override
  String get communityUnsave => 'إلغاء الحفظ';

  @override
  String get communitySavedSuccess => 'تم حفظ المجتمع بنجاح!';

  @override
  String get communityUnsavedSuccess => 'تمت إزالة المجتمع من المحفوظة.';

  @override
  String get communityDiscoverTitle => 'اكتشف المجتمعات';

  @override
  String get communityDiscoverSearchHint => 'ابحث في المجتمعات…';

  @override
  String get communityDiscoverForYou => 'لك';

  @override
  String get communityDiscoverPopular => 'الأكثر شعبية';

  @override
  String get communityDiscoverNew => 'جديد';

  @override
  String get communityDiscoverSubjects => 'المواد';

  @override
  String get communityDiscoverAll => 'الكل';

  @override
  String get communityDiscoverProfileHint =>
      'أكمل تعليمك في الملف الشخصي للحصول على توصيات أفضل.';

  @override
  String get communityDiscoverEmpty => 'لا توجد مجتمعات للعرض بعد.';

  @override
  String get communityDiscoverJoin => 'انضم';

  @override
  String get communityMemberPromoteAdmin => 'تعيين مشرف';

  @override
  String get communityMemberDemoteMember => 'تعيين عضو';

  @override
  String get communityMemberRoleUpdated => 'تم تحديث دور العضو.';

  @override
  String get communityChatSenderMe => 'أنا';

  @override
  String get communityShareMenuTitle => 'مشاركة المجتمع';

  @override
  String get communityShareSendLink => 'إرسال الرابط';

  @override
  String get communityShareCreateCode => 'إنشاء رمز';

  @override
  String get communityShareInsertEmail => 'إدخال البريد';

  @override
  String get communityShareInsertUsername => 'إدخال اسم المستخدم';

  @override
  String get communityShareDialogTitle => 'مشاركة المجتمع:';

  @override
  String get communitySharePublicLinkHint =>
      'يمكن لأي شخص لديه هذا الرابط العثور على مجتمعك العام والانضمام إليه.';

  @override
  String get communitySharePrivateCodeHint =>
      'شارك رمز الدعوة هذا لينضم الآخرون إلى مجتمعك الخاص.';

  @override
  String get communitySharePublicCodeHint =>
      'المجتمعات العامة تُشارك بالرابط. هذا المعرّف يساعد الآخرين على الانضمام في التطبيق.';

  @override
  String get communityShareYourCode => 'رمزك';

  @override
  String get communityShareGenerateNewCode => 'إنشاء رمز جديد';

  @override
  String get communityEditCommunity => 'تعديل المجتمع';

  @override
  String get communityDeleteCommunity => 'حذف المجتمع';

  @override
  String get communityHubRecommendedEmpty =>
      'لقد اطلعت على كل التوصيات — استكشف «اكتشف» لمزيد من المجتمعات.';

  @override
  String get communityInviteRequiresAccount =>
      'يجب أن يكون لدى الشخص حساب في ميشكا (مسجّل في التطبيق).';

  @override
  String get communityInviteUserNotFound =>
      'لا يوجد حساب ميشكا بهذا البريد أو اسم المستخدم.';

  @override
  String get communityInviteCannotInviteSelf =>
      'لا يمكنك دعوة نفسك. استخدم بريدًا أو اسم مستخدم لعضو آخر.';

  @override
  String get communityInviteUsernameHint => 'اسم مستخدم ميشكا (بدون @)';

  @override
  String get communityInviteSend => 'إرسال الدعوة';

  @override
  String communityInviteEmailSent(String email) {
    return 'تم إرسال الدعوة إلى $email';
  }

  @override
  String get communityJoinPrivateTitle => 'انضم إلى مجتمع خاص';

  @override
  String get communityJoinPrivateCodePrompt => 'أدخل رمز دعوة المجتمع:';

  @override
  String get communityJoinPrivateCodeHint => 'رمز المجتمع';

  @override
  String get communityJoinPrivateButton => 'انضم إلى المجتمع';

  @override
  String get communityJoinPrivateSuccess => 'لقد انضممت إلى المجتمع!';

  @override
  String get communityDeleteConfirm => 'هل أنت متأكد أنك تريد حذف هذا المجتمع؟';

  @override
  String get communityDeletedSuccess => 'تم حذف المجتمع بنجاح!';

  @override
  String get communityConfirmJoinGroup =>
      'هل أنت متأكد أنك تريد الانضمام إلى هذه المجموعة؟';

  @override
  String get communityJoinedGroupSuccess => 'لقد انضممت إلى المجموعة.';

  @override
  String get communityConfirmDeleteGroup =>
      'هل أنت متأكد أنك تريد حذف هذه المجموعة؟';

  @override
  String get communityExitConfirm =>
      'هل أنت متأكد أنك تريد مغادرة هذا المجتمع؟';

  @override
  String get communityExitAndDeleteConfirm =>
      'مغادرة المجتمع وإزالته من قائمتك؟';

  @override
  String get communityRemoveMemberConfirm => 'إزالة هذا العضو من المجتمع؟';

  @override
  String get communityMemberRemovedSuccess => 'تمت إزالة العضو من المجتمع.';

  @override
  String get communityRemoveFromGroupConfirm => 'إزالة هذا العضو من المجموعة؟';

  @override
  String get communityMemberRemovedFromGroupSuccess =>
      'تمت إزالة العضو من المجموعة.';

  @override
  String communityInviteUsernameSent(String username) {
    return 'تم إرسال الدعوة إلى @$username';
  }

  @override
  String get communityHubJoinFailedOpenAnyway =>
      'تعذّر الانضمام. سيتم فتح المجتمع على أي حال…';

  @override
  String get communityHubNoneYet => 'لا يوجد بعد.';

  @override
  String get communityHomeTypeLabel => 'مجتمع';

  @override
  String get communityHomeAnnouncements => 'الإعلانات';

  @override
  String get communityHomeWelcomeDefault => 'مرحبًا بك في مجتمعك';

  @override
  String get communityHomeNoGroups =>
      'لا توجد مجموعات بعد. أضف مجموعتك الأولى.';

  @override
  String get communityHomeAddGroup => 'إضافة مجموعة';

  @override
  String communityDetailStats(int groupCount, int memberCount) {
    return 'المجتمع: $groupCount مجموعات • $memberCount أعضاء';
  }

  @override
  String get communityDetailViewGroups => 'عرض المجموعات';

  @override
  String get communityDetailViewMembers => 'عرض الأعضاء:';

  @override
  String get communityDetailManageMembers => 'إدارة الأعضاء';

  @override
  String get communityDetailExitCommunity => 'مغادرة المجتمع';

  @override
  String get communityDetailExitAndDelete => 'المغادرة والإزالة من قائمتك';

  @override
  String communityGroupsTitle(String communityName) {
    return 'مجموعات $communityName';
  }

  @override
  String communityMembersTitle(String communityName) {
    return 'أعضاء $communityName';
  }

  @override
  String get communityGroupJoin => 'انضم إلى المجموعة';

  @override
  String get communityGroupDelete => 'حذف المجموعة';

  @override
  String get communityGroupAddNew => '+ إضافة مجموعة جديدة';

  @override
  String get communityAddGroupTitle => 'إضافة مجموعة';

  @override
  String get communityAddGroupSuccess => 'تمت إضافة مجموعتك إلى المجتمع!';

  @override
  String get communityAddGroupHeader => 'إضافة مجموعة جديدة إلى مجتمعك';

  @override
  String get communityAddGroupProfileLabel => 'أضف ملف مجموعتك:';

  @override
  String get communityAddGroupNameLabel => 'اسم المجموعة:';

  @override
  String get communityAddGroupNameHint => 'اسم المجموعة';

  @override
  String get communityAddGroupDescLabel => 'وصف المجموعة';

  @override
  String get communityAddGroupDescHint => 'وصف المجموعة';

  @override
  String get communityAddButton => 'إضافة';

  @override
  String get communityLabelOptional => '(اختياري):';

  @override
  String get communityEditProfileHeader => 'تعديل ملف مجتمعك:';

  @override
  String get communityEditNameLabel => 'اسم المجتمع:';

  @override
  String get communityEditDescHint => 'وصف المجتمع';

  @override
  String get communityEditGroupsLabel => 'مجموعات المجتمع:';

  @override
  String get communityEditSaving => 'جارٍ الحفظ…';

  @override
  String get communityChatEmpty => 'لا توجد رسائل بعد. قل مرحبًا!';

  @override
  String get communityChatTypeHint => 'اكتب رسالة…';

  @override
  String get communityChatMemberFallback => 'عضو';

  @override
  String get communityChatSharedFromMishka => 'مشارَك من Mishka';

  @override
  String get communityMemberAddToGroup => 'إضافة إلى مجموعة';

  @override
  String get communityMemberRemoveFromCommunity => 'إزالة من المجتمع';

  @override
  String communitySelectGroupPrompt(String memberName) {
    return 'اختر مجموعة لـ $memberName';
  }

  @override
  String get communityMemberAddedToGroupSuccess =>
      'تمت إضافة العضو إلى المجموعة.';

  @override
  String get communityShareChooseMaterial =>
      'اختر مادة ذكاء اصطناعي محفوظة لمشاركتها مع هذه المجموعة.';

  @override
  String get communityShareNoSavedInCategory =>
      'لا توجد عناصر محفوظة في هذه الفئة بعد.';

  @override
  String get communityDiscoverySubjectsOptional => 'المواد (اختياري)';

  @override
  String get communityDiscoveryPurposeOptional => 'الغرض (اختياري)';

  @override
  String get communityInviteEmailHint => 'عنوان البريد الإلكتروني';

  @override
  String get communityErrorServerUnreachable =>
      'تعذّر الاتصال بالخادم. تحقق من أن الخادم يعمل.';

  @override
  String get communityRoleOwner => 'المالك';

  @override
  String get communityRoleAdmin => 'مسؤول';

  @override
  String get communityRoleMember => 'عضو';

  @override
  String get communityFallbackName => 'مجتمع';

  @override
  String get communityFallbackGroupName => 'مجموعة';

  @override
  String get communityFallbackMemberName => 'عضو';

  @override
  String get communityBrandMishka => 'Mishka';

  @override
  String get reportCommunitySection => 'مجتمعنا';

  @override
  String get reportCommunityMessages => 'الرسائل المنشورة';

  @override
  String get reportCommunityMaterialShares => 'المواد المشاركة';

  @override
  String get reportCommunityChannelJoins => 'انضمامات القنوات';
}
