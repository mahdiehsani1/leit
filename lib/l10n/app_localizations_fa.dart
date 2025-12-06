// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get tabHome => 'خانه';

  @override
  String get tabPractice => 'تمرین';

  @override
  String get tabStatistics => 'آمار';

  @override
  String get tabSettings => 'تنظیمات';

  @override
  String get appName => 'Leit';

  @override
  String get searchHint => 'جستجو...';

  @override
  String get searchResults => 'نتایج جستجو';

  @override
  String get noResults => 'نتیجه‌ای یافت نشد';

  @override
  String get yourCategories => 'دسته‌های شما';

  @override
  String get viewAllCategories => 'مشاهده همه دسته‌ها';

  @override
  String get noItemsYet => 'هنوز موردی ندارید. اولین کلمه را اضافه کنید!';

  @override
  String get continueLearning => 'ادامه یادگیری';

  @override
  String get startLeitnerSession => 'شروع جلسه لایتنر';

  @override
  String get addNewItemAction => 'افزودن مورد جدید';

  @override
  String get addItemSubtitle => 'کلمات، افعال، جملات...';

  @override
  String get recentlyAdded => 'اخیراً اضافه‌شده‌ها';

  @override
  String get practiceTitle => 'تمرین';

  @override
  String get reversePracticeTitle => 'تمرین معکوس';

  @override
  String get mixedPracticeTitle => 'تمرین ترکیبی';

  @override
  String get startTrainingSession => 'شروع جلسه تمرین';

  @override
  String get chooseMode => 'انتخاب حالت';

  @override
  String get modeNormal => 'عادی';

  @override
  String get modeNormalDesc => 'آلمانی → انگلیسی/فارسی';

  @override
  String get modeReverse => 'معکوس';

  @override
  String get modeReverseDesc => 'انگلیسی/فارسی → آلمانی';

  @override
  String get modeMixed => 'ترکیبی';

  @override
  String get modeMixedDesc => 'کارت‌های ترکیبی تصادفی';

  @override
  String get overview => 'نمای کلی';

  @override
  String get totalCards => 'کل کارت‌ها';

  @override
  String get weakCards => 'کارت‌های ضعیف';

  @override
  String get dueToday => 'موعد امروز';

  @override
  String get weeklyProgress => 'پیشرفت هفتگی';

  @override
  String get boxStatus => 'وضعیت جعبه‌ها';

  @override
  String leitnerBoxLabel(Object number) {
    return 'جعبه لایتنر $number';
  }

  @override
  String cardsCount(Object count) {
    return '$count کارت';
  }

  @override
  String get sessionNoCardsTitle => 'کارت موعددار ندارید!';

  @override
  String get sessionNoCardsSubtitle => 'فعلاً همه چیز بررسی شده است.';

  @override
  String get sessionCompleteTitle => 'جلسه کامل شد!';

  @override
  String sessionCompleteSubtitle(Object count) {
    return 'شما $count کارت را مرور کردید.';
  }

  @override
  String sessionMoreAvailable(Object count) {
    return 'عالی بود! $count کارت انجام دادید. آماده ادامه هستید؟';
  }

  @override
  String get btnContinueSession => 'ادامه جلسه';

  @override
  String get btnFinishForNow => 'فعلاً کافیست';

  @override
  String get progressLabel => 'پیشرفت';

  @override
  String get btnAgain => 'دوباره';

  @override
  String get btnHard => 'سخت';

  @override
  String get btnEasy => 'آسان';

  @override
  String get statsPageTitle => 'آمار';

  @override
  String get statReviewed => 'مرور شده';

  @override
  String get statLearned => 'یادگرفته‌شده';

  @override
  String get statAccuracy => 'دقت';

  @override
  String get reviewTrendTitle => 'روند مرور (۱۰ روز گذشته)';

  @override
  String get noReviewActivity => 'اخیراً فعالیت مروری نداشته‌اید';

  @override
  String get accuracyChartTitle => 'دقت (۱۰ روز گذشته)';

  @override
  String get noAccuracyData => 'داده‌ای برای دقت موجود نیست';

  @override
  String get leitnerDistribution => 'توزیع لایتنر';

  @override
  String get box1New => 'جعبه ۱ (جدید)';

  @override
  String get box2 => 'جعبه ۲';

  @override
  String get box3 => 'جعبه ۳';

  @override
  String get box4 => 'جعبه ۴';

  @override
  String get box5 => 'جعبه ۵';

  @override
  String get box6Mastered => 'جعبه ۶ (کاملاً مسلط)';

  @override
  String get smartInsight => 'بینش هوشمند';

  @override
  String get insightBox1Full =>
      'جعبه ۱ شما در حال پر شدن است. بهتر است امروز مرور داشته باشید!';

  @override
  String insightMastered(Object count) {
    return 'شما $count مورد را کاملاً مسلط شده‌اید! عالی عمل کردید.';
  }

  @override
  String get insightLongTerm =>
      'در حال ساختن حافظه بلندمدت قوی هستید. ادامه دهید!';

  @override
  String get insightDefault => 'با تمرین منظم، پیشرفت بیشتری می‌بینید.';

  @override
  String get strongAreas => 'نقاط قوت';

  @override
  String get needsPractice => 'نیازمند تمرین';

  @override
  String get notEnoughData => 'داده کافی موجود نیست.';

  @override
  String get dayStreak => 'زنجیره روزانه';

  @override
  String get dailyGoal => 'هدف روزانه';

  @override
  String get weeklyGoal => 'هدف هفتگی';

  @override
  String get btnContinuePractice => 'ادامه تمرین';

  @override
  String get errorLoadingStats => 'خطا در بارگذاری آمار';

  @override
  String get settingsPageTitle => 'تنظیمات';

  @override
  String get sectionGeneral => 'عمومی';

  @override
  String get sectionDataSync => 'فضای ابری و همگام‌سازی';

  @override
  String get sectionAbout => 'درباره';

  @override
  String get langTitle => 'زبان';

  @override
  String get darkModeTitle => 'حالت تیره';

  @override
  String get dailyReminderTitle => 'یادآوری روزانه';

  @override
  String get backupToCloud => 'پشتیبان‌گیری در فضای ابری';

  @override
  String get restoreFromCloud => 'بازیابی از فضای ابری';

  @override
  String get clearAllData => 'حذف تمام داده‌ها';

  @override
  String get rateOnGooglePlay => 'امتیاز در گوگل‌پلی';

  @override
  String get aboutApp => 'درباره برنامه';

  @override
  String get version => 'نسخه';

  @override
  String get openSourceLicenses => 'مجوزهای متن‌باز';

  @override
  String get signOut => 'خروج';

  @override
  String get signInSync => 'ورود با گوگل';

  @override
  String get developedWith => 'ساخته شده با';

  @override
  String get byAuthor => 'توسط';

  @override
  String get selectLanguageDialog => 'انتخاب زبان';

  @override
  String get restoreDialogTitle => 'بازیابی از فضای ابری';

  @override
  String get restoreDialogMsg =>
      'این عملیات داده‌های ابری را با داده‌های فعلی دستگاه ترکیب می‌کند.';

  @override
  String get clearDialogTitle => 'حذف همه داده‌ها؟';

  @override
  String get clearDialogMsg =>
      'هشدار: این کار تمام کلمات، پیشرفت و آمار شما را برای همیشه حذف می‌کند.';

  @override
  String get clearDialogOptionCloud => 'حذف پشتیبان ابری نیز';

  @override
  String get btnCancel => 'انصراف';

  @override
  String get btnRestore => 'بازیابی';

  @override
  String get btnDeleteEverything => 'حذف همه';

  @override
  String get msgDataRestored => 'داده‌ها با موفقیت از فضای ابری بازیابی شدند!';

  @override
  String get msgBackupSuccess =>
      'پشتیبان‌گیری با موفقیت در فضای ابری ذخیره شد!';

  @override
  String msgBackupFailed(Object error) {
    return 'خطا در پشتیبان‌گیری: $error';
  }

  @override
  String msgRestoreFailed(Object error) {
    return 'خطا در بازیابی: $error';
  }

  @override
  String get msgSignInRequired => 'لطفاً برای استفاده از این قابلیت وارد شوید.';

  @override
  String get msgDataDeleted => 'تمام داده‌ها با موفقیت حذف شدند.';

  @override
  String get msgReminderSet => 'یادآوری روزانه برای ساعت ۱۰ صبح تنظیم شد.';

  @override
  String get msgPermissionDenied => 'دسترسی رد شد.';

  @override
  String msgLanguageChanged(Object lang) {
    return 'زبان به $lang تغییر کرد.';
  }

  @override
  String get deleteAccount => 'حذف حساب';

  @override
  String get deleteAccountDialogTitle => 'حذف دائمی حساب؟';

  @override
  String get deleteAccountDialogMsg =>
      'این عمل برگشت‌ناپذیر است و برای همیشه حذف خواهد کرد:\n• حساب شما\n• پشتیبان‌های ابری\n• تمام داده‌های محلی\n\nآیا مطمئن هستید؟';

  @override
  String get msgAccountDeleted => 'حساب و داده‌های شما حذف شدند.';

  @override
  String get msgReauthRequired =>
      'بررسی امنیتی ناموفق بود. لطفاً خروج و دوباره ورود کنید.';

  @override
  String get introSkip => 'رد کردن';

  @override
  String get introNext => 'شروع';

  @override
  String get intro1Title => 'ذخیره کلمات';

  @override
  String get intro1Text =>
      'کلمات، عبارات، اصطلاحات و ترکیب‌های فعل-اسم آلمانی را با ترجمه‌های دقیق انگلیسی و فارسی جمع‌آوری و سازماندهی کنید.';

  @override
  String get intro2Title => 'یادگیری هوشمند';

  @override
  String get intro2Text =>
      'با سیستم اثبات‌شده لایتنر حافظه خود را تقویت کنید؛ در زمان مناسب مرور کنید و ماندگاری را افزایش دهید.';

  @override
  String get intro3Title => 'شنیدن شفاف';

  @override
  String get intro3Text =>
      'تلفظ دقیق آلمانی و انگلیسی را بشنوید و معنی‌ها را با وضوح بیشتری درک کنید.';

  @override
  String get allItemsTitle => 'همه موارد';

  @override
  String get noItemsFound => 'موردی یافت نشد';

  @override
  String get msgItemDeleted => 'مورد با موفقیت حذف شد';

  @override
  String get optionViewDetails => 'مشاهده جزئیات';

  @override
  String get optionEditItem => 'ویرایش';

  @override
  String get optionDeleteItem => 'حذف';

  @override
  String get deleteItemDialogTitle => 'حذف مورد؟';

  @override
  String deleteItemDialogMsg(Object item) {
    return 'آیا می‌خواهید «$item» را حذف کنید؟';
  }

  @override
  String get btnDelete => 'حذف';

  @override
  String get detailsTitle => 'جزئیات';

  @override
  String get sectionTranslations => 'ترجمه‌ها';

  @override
  String get labelEnglish => 'انگلیسی';

  @override
  String get labelPersian => 'فارسی';

  @override
  String get sectionGrammar => 'گرامر و حالت‌ها';

  @override
  String get labelArticle => 'آرتیکل';

  @override
  String get labelPlural => 'جمع';

  @override
  String get labelPrateritum => 'Präteritum';

  @override
  String get labelPerfekt => 'Perfekt';

  @override
  String get labelPartizip => 'Partizip II';

  @override
  String get sectionExamples => 'جملات نمونه';

  @override
  String get sectionExplanation => 'توضیح';

  @override
  String get sectionSynAnt => 'مترادف‌ها و متضادها';

  @override
  String get labelSynonyms => 'مترادف‌ها';

  @override
  String get labelAntonyms => 'متضادها';

  @override
  String get sectionExtra => 'سایر موارد';

  @override
  String get labelTags => 'برچسب‌ها';

  @override
  String get labelNotes => 'یادداشت‌ها';

  @override
  String get addItemTitle => 'افزودن مورد جدید';

  @override
  String get editItemTitle => 'ویرایش مورد';

  @override
  String get btnSave => 'ذخیره';

  @override
  String get btnUpdate => 'به‌روزرسانی';

  @override
  String get labelContentType => 'نوع محتوا';

  @override
  String get hintSelectType => 'انتخاب نوع محتوا';

  @override
  String get sheetChooseType => 'انتخاب نوع محتوا';

  @override
  String get labelGermanText => 'متن آلمانی';

  @override
  String get hintGermanText => 'کلمه، جمله یا عبارت...';

  @override
  String get labelEnTrans => 'معانی انگلیسی';

  @override
  String get hintEnTrans => 'معنای انگلیسی';

  @override
  String get btnAddEn => 'افزودن معنای انگلیسی';

  @override
  String get labelFaTrans => 'معانی فارسی';

  @override
  String get hintFaTrans => 'معنای فارسی';

  @override
  String get btnAddFa => 'افزودن معنای فارسی';

  @override
  String get labelLevel => 'سطح';

  @override
  String get trailingOptional => 'اختیاری';

  @override
  String get trailingMultiple => 'چندتایی مجاز است';

  @override
  String get hintExample => 'جمله نمونه به آلمانی';

  @override
  String get btnAddExample => 'افزودن مثال';

  @override
  String get hintTags => 'گرامر، سفر، B2 ... (با کاما جدا کنید)';

  @override
  String get hintNotes => 'یادداشت اضافی درباره کاربرد، لحن و ...';

  @override
  String get sectionNounDetails => 'جزئیات اسم';

  @override
  String get hintPlural => 'فرم جمع (اختیاری)';

  @override
  String get sectionVerbForms => 'زمان‌های فعل';

  @override
  String get hintPrateritum => 'Präteritum (گذشته ساده)';

  @override
  String get hintPerfekt => 'Perfekt (haben/sein + Partizip II)';

  @override
  String get hintPartizip => 'Partizip II (اختیاری)';

  @override
  String get hintSynonym => 'مترادف';

  @override
  String get btnAddSynonym => 'افزودن مترادف';

  @override
  String get hintAntonym => 'متضاد';

  @override
  String get btnAddAntonym => 'افزودن متضاد';

  @override
  String get sectionUsageNotes => 'یادداشت‌های کاربردی';

  @override
  String get hintUsageNotes => 'این قید معمولاً چگونه استفاده می‌شود؟';

  @override
  String get hintExplanation => 'توضیح کوتاه یا زمینه استفاده';

  @override
  String get errSelectType => 'لطفاً نوع محتوا را انتخاب کنید';

  @override
  String get errEnterEnglish => 'حداقل یک معنای انگلیسی وارد کنید';

  @override
  String get errEnterPersian => 'حداقل یک معنای فارسی وارد کنید';

  @override
  String get errPrateritum => 'فرم Präteritum را وارد کنید';

  @override
  String get errPerfekt => 'فرم Perfekt را وارد کنید';

  @override
  String get errGermanText => 'لطفاً متن اصلی آلمانی را وارد کنید';

  @override
  String get errDuplicate => 'این مورد قبلاً در پایگاه داده وجود دارد!';

  @override
  String get msgSaved => 'با موفقیت ذخیره شد';

  @override
  String get msgUpdated => 'مورد با موفقیت به‌روزرسانی شد';

  @override
  String get typeWord => 'اسم';

  @override
  String get typeWordSub => 'کلمه ساده با آرتیکل و جمع';

  @override
  String get typeVerb => 'فعل';

  @override
  String get typeVerbSub => 'با زمان‌های گذشته و مثال';

  @override
  String get typeAdj => 'صفت';

  @override
  String get typeAdjSub => 'با مترادف و متضاد';

  @override
  String get typeAdv => 'قید';

  @override
  String get typeAdvSub => 'کاربرد و جمله نمونه';

  @override
  String get typeVerbNoun => 'عبارت فعل–اسم';

  @override
  String get typeVerbNounSub => 'مثلاً eine Entscheidung treffen';

  @override
  String get typeSentence => 'جمله';

  @override
  String get typeSentenceSub => 'جمله کامل + ترجمه‌ها';

  @override
  String get typeIdiom => 'اصطلاح / عبارت ثابت';

  @override
  String get typeIdiomSub => 'عبارت با توضیح';

  @override
  String get typeNounPhrase => 'عبارت اسمی';

  @override
  String get typeNounPhraseSub => 'مثلاً der rote Apfel';

  @override
  String get catWords => 'کلمات';

  @override
  String get catVerbs => 'افعال';

  @override
  String get catAdj => 'صفت‌ها';

  @override
  String get catAdv => 'قیدها';

  @override
  String get catVerbNoun => 'عبارات فعل–اسم';

  @override
  String get catIdioms => 'اصطلاحات';

  @override
  String get catSentences => 'جملات';

  @override
  String get catUnknown => 'نامشخص';

  @override
  String get btnYes => 'بله';

  @override
  String get btnNo => 'خیر';

  @override
  String get magicFillTooltip => 'پرکردن جادویی با هوش مصنوعی';

  @override
  String get msgMagicFillSuccess => 'داده‌ها با موفقیت دریافت شدند ✨';

  @override
  String get errLoginRequiredAI =>
      'برای استفاده از امکانات هوش مصنوعی باید وارد شوید.';

  @override
  String get errNoInternet =>
      'اتصال اینترنت وجود ندارد. لطفاً شبکه را بررسی کنید.';

  @override
  String get errInvalidGerman => 'ورودی به‌نظر یک واژه آلمانی معتبر نیست.';

  @override
  String get errPremiumRequired => 'اشتراک پریمیوم لازم است.';

  @override
  String get dialogOverwriteTitle => 'بازنویسی داده‌ها؟';

  @override
  String get dialogOverwriteContent =>
      'فیلدهای ترجمه قبلاً پر شده‌اند. آیا می‌خواهید با داده‌های هوش مصنوعی جایگزین شوند؟';
}
