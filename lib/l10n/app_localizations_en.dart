// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabHome => 'Home';

  @override
  String get tabPractice => 'Practice';

  @override
  String get tabStatistics => 'Statistics';

  @override
  String get tabSettings => 'Settings';

  @override
  String get appName => 'Leit';

  @override
  String get searchHint => 'Search...';

  @override
  String get searchResults => 'Search Results';

  @override
  String get noResults => 'No results found';

  @override
  String get yourCategories => 'Your Categories';

  @override
  String get viewAllCategories => 'View all categories';

  @override
  String get noItemsYet => 'No items yet. Add your first word!';

  @override
  String get continueLearning => 'Continue Learning';

  @override
  String get startLeitnerSession => 'Start your Leitner session';

  @override
  String get addNewItemAction => 'Add New Item';

  @override
  String get addItemSubtitle => 'Words, verbs, sentences...';

  @override
  String get recentlyAdded => 'Recently Added';

  @override
  String get practiceTitle => 'Practice';

  @override
  String get reversePracticeTitle => 'Reverse Practice';

  @override
  String get mixedPracticeTitle => 'Mixed Practice';

  @override
  String get startTrainingSession => 'Start Training Session';

  @override
  String get chooseMode => 'Choose Mode';

  @override
  String get modeNormal => 'Normal';

  @override
  String get modeNormalDesc => 'German → English/Persian';

  @override
  String get modeReverse => 'Reverse';

  @override
  String get modeReverseDesc => 'English/Persian → German';

  @override
  String get modeMixed => 'Mixed';

  @override
  String get modeMixedDesc => 'Randomly mixed cards';

  @override
  String get overview => 'Overview';

  @override
  String get totalCards => 'Total Cards';

  @override
  String get weakCards => 'Weak Cards';

  @override
  String get dueToday => 'Due Today';

  @override
  String get weeklyProgress => 'Weekly Progress';

  @override
  String get boxStatus => 'Box Status';

  @override
  String leitnerBoxLabel(Object number) {
    return 'Leitner Box $number';
  }

  @override
  String cardsCount(Object count) {
    return '$count cards';
  }

  @override
  String get sessionNoCardsTitle => 'No cards due!';

  @override
  String get sessionNoCardsSubtitle => 'You\'re all caught up for now.';

  @override
  String get sessionCompleteTitle => 'Session Complete!';

  @override
  String sessionCompleteSubtitle(Object count) {
    return 'You\'ve reviewed $count cards.';
  }

  @override
  String sessionMoreAvailable(Object count) {
    return 'Great job! You did $count cards. Ready for more?';
  }

  @override
  String get btnContinueSession => 'Continue Session';

  @override
  String get btnFinishForNow => 'Finish for Now';

  @override
  String get progressLabel => 'Progress';

  @override
  String get btnAgain => 'Again';

  @override
  String get btnHard => 'Hard';

  @override
  String get btnEasy => 'Easy';

  @override
  String get statsPageTitle => 'Statistics';

  @override
  String get statReviewed => 'Reviewed';

  @override
  String get statLearned => 'Learned';

  @override
  String get statAccuracy => 'Accuracy';

  @override
  String get reviewTrendTitle => 'Review Trend (Last 10 Days)';

  @override
  String get noReviewActivity => 'No review activity recently';

  @override
  String get accuracyChartTitle => 'Accuracy (Last 10 Days)';

  @override
  String get noAccuracyData => 'No accuracy data available';

  @override
  String get leitnerDistribution => 'Leitner Distribution';

  @override
  String get box1New => 'Box 1 (New)';

  @override
  String get box2 => 'Box 2';

  @override
  String get box3 => 'Box 3';

  @override
  String get box4 => 'Box 4';

  @override
  String get box5 => 'Box 5';

  @override
  String get box6Mastered => 'Box 6 (Fully Mastered)';

  @override
  String get smartInsight => 'Smart Insight';

  @override
  String get insightBox1Full =>
      'Your Box 1 is getting full. Consider a review session today!';

  @override
  String insightMastered(Object count) {
    return 'You have fully mastered $count items! Outstanding work.';
  }

  @override
  String get insightLongTerm =>
      'You are building strong long-term memory. Keep it up!';

  @override
  String get insightDefault => 'Keep practicing regularly to see improvements.';

  @override
  String get strongAreas => 'Strong Areas';

  @override
  String get needsPractice => 'Needs Practice';

  @override
  String get notEnoughData => 'Not enough data yet.';

  @override
  String get dayStreak => 'Day Streak';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get weeklyGoal => 'Weekly Goal';

  @override
  String get btnContinuePractice => 'Continue Practice';

  @override
  String get errorLoadingStats => 'Error loading stats';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionDataSync => 'Data & Sync';

  @override
  String get sectionAbout => 'About';

  @override
  String get langTitle => 'Language';

  @override
  String get darkModeTitle => 'Dark Mode';

  @override
  String get dailyReminderTitle => 'Daily Reminder';

  @override
  String get backupToFile => 'Backup to File';

  @override
  String get restoreFromFile => 'Restore from File';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get version => 'Version';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signInSync => 'Sign in with Google';

  @override
  String get developedWith => 'Developed with';

  @override
  String get byAuthor => 'by';

  @override
  String get selectLanguageDialog => 'Select Language';

  @override
  String get restoreDialogTitle => 'Restore Backup';

  @override
  String get restoreDialogMsg =>
      'Current data will be replaced with the selected file.\nThis action cannot be undone.\nAre you sure?';

  @override
  String get clearDialogTitle => 'Clear All Data?';

  @override
  String get clearDialogMsg =>
      'Warning: This will permanently delete ALL your words, progress, and statistics.\nThis action cannot be undone!';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnRestore => 'Restore';

  @override
  String get btnDeleteEverything => 'Delete Everything';

  @override
  String get msgDataRestored =>
      'Data restored successfully! Please restart app.';

  @override
  String get msgBackupFailed => 'Backup failed';

  @override
  String get msgDataDeleted => 'All data has been deleted successfully.';

  @override
  String get msgReminderSet => 'Daily reminder set for 10:00 AM';

  @override
  String get msgPermissionDenied => 'Permission denied.';

  @override
  String msgLanguageChanged(Object lang) {
    return 'Language changed to $lang. Restart app to apply fully if needed.';
  }

  @override
  String get introSkip => 'Skip';

  @override
  String get introNext => 'Get Started';

  @override
  String get intro1Title => 'Save Words';

  @override
  String get intro1Text =>
      'Collect and organize German words, phrases, idioms, and verb–noun combinations with clean translations in English and Persian.';

  @override
  String get intro2Title => 'Learn Smart';

  @override
  String get intro2Text =>
      'Strengthen your memory using the proven Leitner system. Review items at the perfect time, improve retention naturally.';

  @override
  String get intro3Title => 'Hear Clearly';

  @override
  String get intro3Text =>
      'Listen to precise German and English pronunciations and understand meanings in both languages with clarity.';

  @override
  String get allItemsTitle => 'All Items';

  @override
  String get noItemsFound => 'No items found';

  @override
  String get msgItemDeleted => 'Item deleted successfully';

  @override
  String get optionViewDetails => 'View Details';

  @override
  String get optionEditItem => 'Edit Item';

  @override
  String get optionDeleteItem => 'Delete Item';

  @override
  String get deleteItemDialogTitle => 'Delete Item?';

  @override
  String deleteItemDialogMsg(Object item) {
    return 'Are you sure you want to delete \'$item\'?';
  }

  @override
  String get btnDelete => 'Delete';

  @override
  String get detailsTitle => 'Details';

  @override
  String get sectionTranslations => 'Translations';

  @override
  String get labelEnglish => 'English';

  @override
  String get labelPersian => 'Persian';

  @override
  String get sectionGrammar => 'Grammar & Forms';

  @override
  String get labelArticle => 'Article';

  @override
  String get labelPlural => 'Plural';

  @override
  String get labelPrateritum => 'Präteritum';

  @override
  String get labelPerfekt => 'Perfekt';

  @override
  String get labelPartizip => 'Partizip II';

  @override
  String get sectionExamples => 'Example sentences';

  @override
  String get sectionExplanation => 'Explanation';

  @override
  String get sectionSynAnt => 'Synonyms & Antonyms';

  @override
  String get labelSynonyms => 'Synonyms';

  @override
  String get labelAntonyms => 'Antonyms';

  @override
  String get sectionExtra => 'Extra';

  @override
  String get labelTags => 'Tags';

  @override
  String get labelNotes => 'Notes';

  @override
  String get addItemTitle => 'Add New Item';

  @override
  String get editItemTitle => 'Edit Item';

  @override
  String get btnSave => 'Save';

  @override
  String get btnUpdate => 'Update';

  @override
  String get labelContentType => 'Content type';

  @override
  String get hintSelectType => 'Select content type';

  @override
  String get sheetChooseType => 'Choose content type';

  @override
  String get labelGermanText => 'German text';

  @override
  String get hintGermanText => 'Wort, Satz oder Ausdruck...';

  @override
  String get labelEnTrans => 'English translations';

  @override
  String get hintEnTrans => 'English meaning';

  @override
  String get btnAddEn => 'Add English meaning';

  @override
  String get labelFaTrans => 'Persian meanings';

  @override
  String get hintFaTrans => 'Persian meaning';

  @override
  String get btnAddFa => 'Add Persian meaning';

  @override
  String get labelLevel => 'Level';

  @override
  String get trailingOptional => 'Optional';

  @override
  String get trailingMultiple => 'Multiple allowed';

  @override
  String get hintExample => 'Example sentence in German';

  @override
  String get btnAddExample => 'Add example';

  @override
  String get hintTags => 'grammar, travel, B2 ... (comma separated)';

  @override
  String get hintNotes => 'Any extra notes about usage, register, etc.';

  @override
  String get sectionNounDetails => 'Noun details';

  @override
  String get hintPlural => 'Plural form (optional)';

  @override
  String get sectionVerbForms => 'Verb forms';

  @override
  String get hintPrateritum => 'Präteritum (simple past)';

  @override
  String get hintPerfekt => 'Perfekt (haben/sein + Partizip II)';

  @override
  String get hintPartizip => 'Partizip II (optional)';

  @override
  String get hintSynonym => 'Synonym';

  @override
  String get btnAddSynonym => 'Add synonym';

  @override
  String get hintAntonym => 'Antonym';

  @override
  String get btnAddAntonym => 'Add antonym';

  @override
  String get sectionUsageNotes => 'Usage notes';

  @override
  String get hintUsageNotes => 'How is this adverb usually used?';

  @override
  String get hintExplanation => 'Short explanation or context of use';

  @override
  String get errSelectType => 'Please select content type';

  @override
  String get errEnterEnglish => 'Please enter at least 1 English meaning';

  @override
  String get errEnterPersian => 'Please enter at least 1 Persian meaning';

  @override
  String get errPrateritum => 'Please enter Präteritum form';

  @override
  String get errPerfekt => 'Please enter Perfekt form';

  @override
  String get errGermanText => 'Please enter the main German text';

  @override
  String get errDuplicate => 'This item already exists in your database!';

  @override
  String get msgSaved => 'Saved successfully';

  @override
  String get msgUpdated => 'Item updated successfully';

  @override
  String get typeWord => 'Word (Noun)';

  @override
  String get typeWordSub => 'Simple word with article and plural';

  @override
  String get typeVerb => 'Verb';

  @override
  String get typeVerbSub => 'With past forms & example';

  @override
  String get typeAdj => 'Adjective';

  @override
  String get typeAdjSub => 'With synonyms & antonyms';

  @override
  String get typeAdv => 'Adverb';

  @override
  String get typeAdvSub => 'Usage and example sentence';

  @override
  String get typeVerbNoun => 'Verb–Noun Phrase';

  @override
  String get typeVerbNounSub => 'e.g. eine Entscheidung treffen';

  @override
  String get typeSentence => 'Sentence';

  @override
  String get typeSentenceSub => 'Full sentence + translations';

  @override
  String get typeIdiom => 'Idiom / Fixed Phrase';

  @override
  String get typeIdiomSub => 'Expression with explanation';

  @override
  String get typeNounPhrase => 'Noun Phrase';

  @override
  String get typeNounPhraseSub => 'e.g. der rote Apfel';

  @override
  String get catWords => 'Words';

  @override
  String get catVerbs => 'Verbs';

  @override
  String get catAdj => 'Adjectives';

  @override
  String get catAdv => 'Adverbs';

  @override
  String get catVerbNoun => 'Verb–Noun Phrases';

  @override
  String get catIdioms => 'Idioms';

  @override
  String get catSentences => 'Sentences';

  @override
  String get catUnknown => 'Unknown';
}
