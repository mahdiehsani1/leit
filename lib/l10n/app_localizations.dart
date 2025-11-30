import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
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
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get tabPractice;

  /// No description provided for @tabStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get tabStatistics;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Leit'**
  String get appName;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @yourCategories.
  ///
  /// In en, this message translates to:
  /// **'Your Categories'**
  String get yourCategories;

  /// No description provided for @viewAllCategories.
  ///
  /// In en, this message translates to:
  /// **'View all categories'**
  String get viewAllCategories;

  /// No description provided for @noItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No items yet. Add your first word!'**
  String get noItemsYet;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// No description provided for @startLeitnerSession.
  ///
  /// In en, this message translates to:
  /// **'Start your Leitner session'**
  String get startLeitnerSession;

  /// No description provided for @addNewItemAction.
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get addNewItemAction;

  /// No description provided for @addItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Words, verbs, sentences...'**
  String get addItemSubtitle;

  /// No description provided for @recentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get recentlyAdded;

  /// No description provided for @practiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceTitle;

  /// No description provided for @reversePracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reverse Practice'**
  String get reversePracticeTitle;

  /// No description provided for @mixedPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Mixed Practice'**
  String get mixedPracticeTitle;

  /// No description provided for @startTrainingSession.
  ///
  /// In en, this message translates to:
  /// **'Start Training Session'**
  String get startTrainingSession;

  /// No description provided for @chooseMode.
  ///
  /// In en, this message translates to:
  /// **'Choose Mode'**
  String get chooseMode;

  /// No description provided for @modeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get modeNormal;

  /// No description provided for @modeNormalDesc.
  ///
  /// In en, this message translates to:
  /// **'German → English/Persian'**
  String get modeNormalDesc;

  /// No description provided for @modeReverse.
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get modeReverse;

  /// No description provided for @modeReverseDesc.
  ///
  /// In en, this message translates to:
  /// **'English/Persian → German'**
  String get modeReverseDesc;

  /// No description provided for @modeMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get modeMixed;

  /// No description provided for @modeMixedDesc.
  ///
  /// In en, this message translates to:
  /// **'Randomly mixed cards'**
  String get modeMixedDesc;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @totalCards.
  ///
  /// In en, this message translates to:
  /// **'Total Cards'**
  String get totalCards;

  /// No description provided for @weakCards.
  ///
  /// In en, this message translates to:
  /// **'Weak Cards'**
  String get weakCards;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get dueToday;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @boxStatus.
  ///
  /// In en, this message translates to:
  /// **'Box Status'**
  String get boxStatus;

  /// No description provided for @leitnerBoxLabel.
  ///
  /// In en, this message translates to:
  /// **'Leitner Box {number}'**
  String leitnerBoxLabel(Object number);

  /// No description provided for @cardsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String cardsCount(Object count);

  /// No description provided for @sessionNoCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'No cards due!'**
  String get sessionNoCardsTitle;

  /// No description provided for @sessionNoCardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up for now.'**
  String get sessionNoCardsSubtitle;

  /// No description provided for @sessionCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Complete!'**
  String get sessionCompleteTitle;

  /// No description provided for @sessionCompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reviewed {count} cards.'**
  String sessionCompleteSubtitle(Object count);

  /// No description provided for @sessionMoreAvailable.
  ///
  /// In en, this message translates to:
  /// **'Great job! You did {count} cards. Ready for more?'**
  String sessionMoreAvailable(Object count);

  /// No description provided for @btnContinueSession.
  ///
  /// In en, this message translates to:
  /// **'Continue Session'**
  String get btnContinueSession;

  /// No description provided for @btnFinishForNow.
  ///
  /// In en, this message translates to:
  /// **'Finish for Now'**
  String get btnFinishForNow;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// No description provided for @btnAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get btnAgain;

  /// No description provided for @btnHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get btnHard;

  /// No description provided for @btnEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get btnEasy;

  /// No description provided for @statsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsPageTitle;

  /// No description provided for @statReviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get statReviewed;

  /// No description provided for @statLearned.
  ///
  /// In en, this message translates to:
  /// **'Learned'**
  String get statLearned;

  /// No description provided for @statAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get statAccuracy;

  /// No description provided for @reviewTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Trend (Last 10 Days)'**
  String get reviewTrendTitle;

  /// No description provided for @noReviewActivity.
  ///
  /// In en, this message translates to:
  /// **'No review activity recently'**
  String get noReviewActivity;

  /// No description provided for @accuracyChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Accuracy (Last 10 Days)'**
  String get accuracyChartTitle;

  /// No description provided for @noAccuracyData.
  ///
  /// In en, this message translates to:
  /// **'No accuracy data available'**
  String get noAccuracyData;

  /// No description provided for @leitnerDistribution.
  ///
  /// In en, this message translates to:
  /// **'Leitner Distribution'**
  String get leitnerDistribution;

  /// No description provided for @box1New.
  ///
  /// In en, this message translates to:
  /// **'Box 1 (New)'**
  String get box1New;

  /// No description provided for @box2.
  ///
  /// In en, this message translates to:
  /// **'Box 2'**
  String get box2;

  /// No description provided for @box3.
  ///
  /// In en, this message translates to:
  /// **'Box 3'**
  String get box3;

  /// No description provided for @box4.
  ///
  /// In en, this message translates to:
  /// **'Box 4'**
  String get box4;

  /// No description provided for @box5.
  ///
  /// In en, this message translates to:
  /// **'Box 5'**
  String get box5;

  /// No description provided for @box6Mastered.
  ///
  /// In en, this message translates to:
  /// **'Box 6 (Fully Mastered)'**
  String get box6Mastered;

  /// No description provided for @smartInsight.
  ///
  /// In en, this message translates to:
  /// **'Smart Insight'**
  String get smartInsight;

  /// No description provided for @insightBox1Full.
  ///
  /// In en, this message translates to:
  /// **'Your Box 1 is getting full. Consider a review session today!'**
  String get insightBox1Full;

  /// No description provided for @insightMastered.
  ///
  /// In en, this message translates to:
  /// **'You have fully mastered {count} items! Outstanding work.'**
  String insightMastered(Object count);

  /// No description provided for @insightLongTerm.
  ///
  /// In en, this message translates to:
  /// **'You are building strong long-term memory. Keep it up!'**
  String get insightLongTerm;

  /// No description provided for @insightDefault.
  ///
  /// In en, this message translates to:
  /// **'Keep practicing regularly to see improvements.'**
  String get insightDefault;

  /// No description provided for @strongAreas.
  ///
  /// In en, this message translates to:
  /// **'Strong Areas'**
  String get strongAreas;

  /// No description provided for @needsPractice.
  ///
  /// In en, this message translates to:
  /// **'Needs Practice'**
  String get needsPractice;

  /// No description provided for @notEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet.'**
  String get notEnoughData;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @weeklyGoal.
  ///
  /// In en, this message translates to:
  /// **'Weekly Goal'**
  String get weeklyGoal;

  /// No description provided for @btnContinuePractice.
  ///
  /// In en, this message translates to:
  /// **'Continue Practice'**
  String get btnContinuePractice;

  /// No description provided for @errorLoadingStats.
  ///
  /// In en, this message translates to:
  /// **'Error loading stats'**
  String get errorLoadingStats;

  /// No description provided for @settingsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPageTitle;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @sectionDataSync.
  ///
  /// In en, this message translates to:
  /// **'Data & Sync'**
  String get sectionDataSync;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @langTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get langTitle;

  /// No description provided for @darkModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeTitle;

  /// No description provided for @dailyReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminderTitle;

  /// No description provided for @backupToFile.
  ///
  /// In en, this message translates to:
  /// **'Backup to File'**
  String get backupToFile;

  /// No description provided for @restoreFromFile.
  ///
  /// In en, this message translates to:
  /// **'Restore from File'**
  String get restoreFromFile;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signInSync.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInSync;

  /// No description provided for @developedWith.
  ///
  /// In en, this message translates to:
  /// **'Developed with'**
  String get developedWith;

  /// No description provided for @byAuthor.
  ///
  /// In en, this message translates to:
  /// **'by'**
  String get byAuthor;

  /// No description provided for @selectLanguageDialog.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageDialog;

  /// No description provided for @restoreDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restoreDialogTitle;

  /// No description provided for @restoreDialogMsg.
  ///
  /// In en, this message translates to:
  /// **'Current data will be replaced with the selected file.\nThis action cannot be undone.\nAre you sure?'**
  String get restoreDialogMsg;

  /// No description provided for @clearDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data?'**
  String get clearDialogTitle;

  /// No description provided for @clearDialogMsg.
  ///
  /// In en, this message translates to:
  /// **'Warning: This will permanently delete ALL your words, progress, and statistics.\nThis action cannot be undone!'**
  String get clearDialogMsg;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get btnRestore;

  /// No description provided for @btnDeleteEverything.
  ///
  /// In en, this message translates to:
  /// **'Delete Everything'**
  String get btnDeleteEverything;

  /// No description provided for @msgDataRestored.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully! Please restart app.'**
  String get msgDataRestored;

  /// No description provided for @msgBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get msgBackupFailed;

  /// No description provided for @msgDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'All data has been deleted successfully.'**
  String get msgDataDeleted;

  /// No description provided for @msgReminderSet.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder set for 10:00 AM'**
  String get msgReminderSet;

  /// No description provided for @msgPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied.'**
  String get msgPermissionDenied;

  /// No description provided for @msgLanguageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {lang}. Restart app to apply fully if needed.'**
  String msgLanguageChanged(Object lang);

  /// No description provided for @introSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get introSkip;

  /// No description provided for @introNext.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get introNext;

  /// No description provided for @intro1Title.
  ///
  /// In en, this message translates to:
  /// **'Save Words'**
  String get intro1Title;

  /// No description provided for @intro1Text.
  ///
  /// In en, this message translates to:
  /// **'Collect and organize German words, phrases, idioms, and verb–noun combinations with clean translations in English and Persian.'**
  String get intro1Text;

  /// No description provided for @intro2Title.
  ///
  /// In en, this message translates to:
  /// **'Learn Smart'**
  String get intro2Title;

  /// No description provided for @intro2Text.
  ///
  /// In en, this message translates to:
  /// **'Strengthen your memory using the proven Leitner system. Review items at the perfect time, improve retention naturally.'**
  String get intro2Text;

  /// No description provided for @intro3Title.
  ///
  /// In en, this message translates to:
  /// **'Hear Clearly'**
  String get intro3Title;

  /// No description provided for @intro3Text.
  ///
  /// In en, this message translates to:
  /// **'Listen to precise German and English pronunciations and understand meanings in both languages with clarity.'**
  String get intro3Text;

  /// No description provided for @allItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'All Items'**
  String get allItemsTitle;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @msgItemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted successfully'**
  String get msgItemDeleted;

  /// No description provided for @optionViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get optionViewDetails;

  /// No description provided for @optionEditItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get optionEditItem;

  /// No description provided for @optionDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get optionDeleteItem;

  /// No description provided for @deleteItemDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Item?'**
  String get deleteItemDialogTitle;

  /// No description provided for @deleteItemDialogMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{item}\'?'**
  String deleteItemDialogMsg(Object item);

  /// No description provided for @btnDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// No description provided for @detailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsTitle;

  /// No description provided for @sectionTranslations.
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get sectionTranslations;

  /// No description provided for @labelEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get labelEnglish;

  /// No description provided for @labelPersian.
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get labelPersian;

  /// No description provided for @sectionGrammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar & Forms'**
  String get sectionGrammar;

  /// No description provided for @labelArticle.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get labelArticle;

  /// No description provided for @labelPlural.
  ///
  /// In en, this message translates to:
  /// **'Plural'**
  String get labelPlural;

  /// No description provided for @labelPrateritum.
  ///
  /// In en, this message translates to:
  /// **'Präteritum'**
  String get labelPrateritum;

  /// No description provided for @labelPerfekt.
  ///
  /// In en, this message translates to:
  /// **'Perfekt'**
  String get labelPerfekt;

  /// No description provided for @labelPartizip.
  ///
  /// In en, this message translates to:
  /// **'Partizip II'**
  String get labelPartizip;

  /// No description provided for @sectionExamples.
  ///
  /// In en, this message translates to:
  /// **'Example sentences'**
  String get sectionExamples;

  /// No description provided for @sectionExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get sectionExplanation;

  /// No description provided for @sectionSynAnt.
  ///
  /// In en, this message translates to:
  /// **'Synonyms & Antonyms'**
  String get sectionSynAnt;

  /// No description provided for @labelSynonyms.
  ///
  /// In en, this message translates to:
  /// **'Synonyms'**
  String get labelSynonyms;

  /// No description provided for @labelAntonyms.
  ///
  /// In en, this message translates to:
  /// **'Antonyms'**
  String get labelAntonyms;

  /// No description provided for @sectionExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra'**
  String get sectionExtra;

  /// No description provided for @labelTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get labelTags;

  /// No description provided for @labelNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get labelNotes;

  /// No description provided for @addItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get addItemTitle;

  /// No description provided for @editItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItemTitle;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @btnUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get btnUpdate;

  /// No description provided for @labelContentType.
  ///
  /// In en, this message translates to:
  /// **'Content type'**
  String get labelContentType;

  /// No description provided for @hintSelectType.
  ///
  /// In en, this message translates to:
  /// **'Select content type'**
  String get hintSelectType;

  /// No description provided for @sheetChooseType.
  ///
  /// In en, this message translates to:
  /// **'Choose content type'**
  String get sheetChooseType;

  /// No description provided for @labelGermanText.
  ///
  /// In en, this message translates to:
  /// **'German text'**
  String get labelGermanText;

  /// No description provided for @hintGermanText.
  ///
  /// In en, this message translates to:
  /// **'Wort, Satz oder Ausdruck...'**
  String get hintGermanText;

  /// No description provided for @labelEnTrans.
  ///
  /// In en, this message translates to:
  /// **'English translations'**
  String get labelEnTrans;

  /// No description provided for @hintEnTrans.
  ///
  /// In en, this message translates to:
  /// **'English meaning'**
  String get hintEnTrans;

  /// No description provided for @btnAddEn.
  ///
  /// In en, this message translates to:
  /// **'Add English meaning'**
  String get btnAddEn;

  /// No description provided for @labelFaTrans.
  ///
  /// In en, this message translates to:
  /// **'Persian meanings'**
  String get labelFaTrans;

  /// No description provided for @hintFaTrans.
  ///
  /// In en, this message translates to:
  /// **'Persian meaning'**
  String get hintFaTrans;

  /// No description provided for @btnAddFa.
  ///
  /// In en, this message translates to:
  /// **'Add Persian meaning'**
  String get btnAddFa;

  /// No description provided for @labelLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get labelLevel;

  /// No description provided for @trailingOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get trailingOptional;

  /// No description provided for @trailingMultiple.
  ///
  /// In en, this message translates to:
  /// **'Multiple allowed'**
  String get trailingMultiple;

  /// No description provided for @hintExample.
  ///
  /// In en, this message translates to:
  /// **'Example sentence in German'**
  String get hintExample;

  /// No description provided for @btnAddExample.
  ///
  /// In en, this message translates to:
  /// **'Add example'**
  String get btnAddExample;

  /// No description provided for @hintTags.
  ///
  /// In en, this message translates to:
  /// **'grammar, travel, B2 ... (comma separated)'**
  String get hintTags;

  /// No description provided for @hintNotes.
  ///
  /// In en, this message translates to:
  /// **'Any extra notes about usage, register, etc.'**
  String get hintNotes;

  /// No description provided for @sectionNounDetails.
  ///
  /// In en, this message translates to:
  /// **'Noun details'**
  String get sectionNounDetails;

  /// No description provided for @hintPlural.
  ///
  /// In en, this message translates to:
  /// **'Plural form (optional)'**
  String get hintPlural;

  /// No description provided for @sectionVerbForms.
  ///
  /// In en, this message translates to:
  /// **'Verb forms'**
  String get sectionVerbForms;

  /// No description provided for @hintPrateritum.
  ///
  /// In en, this message translates to:
  /// **'Präteritum (simple past)'**
  String get hintPrateritum;

  /// No description provided for @hintPerfekt.
  ///
  /// In en, this message translates to:
  /// **'Perfekt (haben/sein + Partizip II)'**
  String get hintPerfekt;

  /// No description provided for @hintPartizip.
  ///
  /// In en, this message translates to:
  /// **'Partizip II (optional)'**
  String get hintPartizip;

  /// No description provided for @hintSynonym.
  ///
  /// In en, this message translates to:
  /// **'Synonym'**
  String get hintSynonym;

  /// No description provided for @btnAddSynonym.
  ///
  /// In en, this message translates to:
  /// **'Add synonym'**
  String get btnAddSynonym;

  /// No description provided for @hintAntonym.
  ///
  /// In en, this message translates to:
  /// **'Antonym'**
  String get hintAntonym;

  /// No description provided for @btnAddAntonym.
  ///
  /// In en, this message translates to:
  /// **'Add antonym'**
  String get btnAddAntonym;

  /// No description provided for @sectionUsageNotes.
  ///
  /// In en, this message translates to:
  /// **'Usage notes'**
  String get sectionUsageNotes;

  /// No description provided for @hintUsageNotes.
  ///
  /// In en, this message translates to:
  /// **'How is this adverb usually used?'**
  String get hintUsageNotes;

  /// No description provided for @hintExplanation.
  ///
  /// In en, this message translates to:
  /// **'Short explanation or context of use'**
  String get hintExplanation;

  /// No description provided for @errSelectType.
  ///
  /// In en, this message translates to:
  /// **'Please select content type'**
  String get errSelectType;

  /// No description provided for @errEnterEnglish.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least 1 English meaning'**
  String get errEnterEnglish;

  /// No description provided for @errEnterPersian.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least 1 Persian meaning'**
  String get errEnterPersian;

  /// No description provided for @errPrateritum.
  ///
  /// In en, this message translates to:
  /// **'Please enter Präteritum form'**
  String get errPrateritum;

  /// No description provided for @errPerfekt.
  ///
  /// In en, this message translates to:
  /// **'Please enter Perfekt form'**
  String get errPerfekt;

  /// No description provided for @errGermanText.
  ///
  /// In en, this message translates to:
  /// **'Please enter the main German text'**
  String get errGermanText;

  /// No description provided for @errDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This item already exists in your database!'**
  String get errDuplicate;

  /// No description provided for @msgSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get msgSaved;

  /// No description provided for @msgUpdated.
  ///
  /// In en, this message translates to:
  /// **'Item updated successfully'**
  String get msgUpdated;

  /// No description provided for @typeWord.
  ///
  /// In en, this message translates to:
  /// **'Word (Noun)'**
  String get typeWord;

  /// No description provided for @typeWordSub.
  ///
  /// In en, this message translates to:
  /// **'Simple word with article and plural'**
  String get typeWordSub;

  /// No description provided for @typeVerb.
  ///
  /// In en, this message translates to:
  /// **'Verb'**
  String get typeVerb;

  /// No description provided for @typeVerbSub.
  ///
  /// In en, this message translates to:
  /// **'With past forms & example'**
  String get typeVerbSub;

  /// No description provided for @typeAdj.
  ///
  /// In en, this message translates to:
  /// **'Adjective'**
  String get typeAdj;

  /// No description provided for @typeAdjSub.
  ///
  /// In en, this message translates to:
  /// **'With synonyms & antonyms'**
  String get typeAdjSub;

  /// No description provided for @typeAdv.
  ///
  /// In en, this message translates to:
  /// **'Adverb'**
  String get typeAdv;

  /// No description provided for @typeAdvSub.
  ///
  /// In en, this message translates to:
  /// **'Usage and example sentence'**
  String get typeAdvSub;

  /// No description provided for @typeVerbNoun.
  ///
  /// In en, this message translates to:
  /// **'Verb–Noun Phrase'**
  String get typeVerbNoun;

  /// No description provided for @typeVerbNounSub.
  ///
  /// In en, this message translates to:
  /// **'e.g. eine Entscheidung treffen'**
  String get typeVerbNounSub;

  /// No description provided for @typeSentence.
  ///
  /// In en, this message translates to:
  /// **'Sentence'**
  String get typeSentence;

  /// No description provided for @typeSentenceSub.
  ///
  /// In en, this message translates to:
  /// **'Full sentence + translations'**
  String get typeSentenceSub;

  /// No description provided for @typeIdiom.
  ///
  /// In en, this message translates to:
  /// **'Idiom / Fixed Phrase'**
  String get typeIdiom;

  /// No description provided for @typeIdiomSub.
  ///
  /// In en, this message translates to:
  /// **'Expression with explanation'**
  String get typeIdiomSub;

  /// No description provided for @typeNounPhrase.
  ///
  /// In en, this message translates to:
  /// **'Noun Phrase'**
  String get typeNounPhrase;

  /// No description provided for @typeNounPhraseSub.
  ///
  /// In en, this message translates to:
  /// **'e.g. der rote Apfel'**
  String get typeNounPhraseSub;

  /// No description provided for @catWords.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get catWords;

  /// No description provided for @catVerbs.
  ///
  /// In en, this message translates to:
  /// **'Verbs'**
  String get catVerbs;

  /// No description provided for @catAdj.
  ///
  /// In en, this message translates to:
  /// **'Adjectives'**
  String get catAdj;

  /// No description provided for @catAdv.
  ///
  /// In en, this message translates to:
  /// **'Adverbs'**
  String get catAdv;

  /// No description provided for @catVerbNoun.
  ///
  /// In en, this message translates to:
  /// **'Verb–Noun Phrases'**
  String get catVerbNoun;

  /// No description provided for @catIdioms.
  ///
  /// In en, this message translates to:
  /// **'Idioms'**
  String get catIdioms;

  /// No description provided for @catSentences.
  ///
  /// In en, this message translates to:
  /// **'Sentences'**
  String get catSentences;

  /// No description provided for @catUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get catUnknown;
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
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
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
