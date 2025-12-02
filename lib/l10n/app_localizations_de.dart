// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get tabHome => 'Startseite';

  @override
  String get tabPractice => 'Üben';

  @override
  String get tabStatistics => 'Statistik';

  @override
  String get tabSettings => 'Einstellungen';

  @override
  String get appName => 'Leit';

  @override
  String get searchHint => 'Suchen...';

  @override
  String get searchResults => 'Suchergebnisse';

  @override
  String get noResults => 'Keine Ergebnisse gefunden';

  @override
  String get yourCategories => 'Deine Kategorien';

  @override
  String get viewAllCategories => 'Alle anzeigen';

  @override
  String get noItemsYet => 'Noch keine Einträge. Füge dein erstes Wort hinzu!';

  @override
  String get continueLearning => 'Weiterlernen';

  @override
  String get startLeitnerSession => 'Leitner-Sitzung starten';

  @override
  String get addNewItemAction => 'Neues Element';

  @override
  String get addItemSubtitle => 'Wörter, Verben, Sätze...';

  @override
  String get recentlyAdded => 'Kürzlich hinzugefügt';

  @override
  String get practiceTitle => 'Üben';

  @override
  String get reversePracticeTitle => 'Umgekehrtes Üben';

  @override
  String get mixedPracticeTitle => 'Gemischtes Üben';

  @override
  String get startTrainingSession => 'Training starten';

  @override
  String get chooseMode => 'Modus wählen';

  @override
  String get modeNormal => 'Normal';

  @override
  String get modeNormalDesc => 'Deutsch → Englisch/Persisch';

  @override
  String get modeReverse => 'Umgekehrt';

  @override
  String get modeReverseDesc => 'Englisch/Persisch → Deutsch';

  @override
  String get modeMixed => 'Gemischt';

  @override
  String get modeMixedDesc => 'Zufällig gemischt';

  @override
  String get overview => 'Übersicht';

  @override
  String get totalCards => 'Gesamtkarten';

  @override
  String get weakCards => 'Schwache Karten';

  @override
  String get dueToday => 'Heute fällig';

  @override
  String get weeklyProgress => 'Wöchentlicher Fortschritt';

  @override
  String get boxStatus => 'Box-Status';

  @override
  String leitnerBoxLabel(Object number) {
    return 'Leitner Box $number';
  }

  @override
  String cardsCount(Object count) {
    return '$count Karten';
  }

  @override
  String get sessionNoCardsTitle => 'Keine Karten fällig!';

  @override
  String get sessionNoCardsSubtitle => 'Du bist auf dem Laufenden.';

  @override
  String get sessionCompleteTitle => 'Sitzung beendet!';

  @override
  String sessionCompleteSubtitle(Object count) {
    return 'Du hast $count Karten wiederholt.';
  }

  @override
  String sessionMoreAvailable(Object count) {
    return 'Super! $count Karten erledigt. Bereit für mehr?';
  }

  @override
  String get btnContinueSession => 'Weiterlernen';

  @override
  String get btnFinishForNow => 'Jetzt beenden';

  @override
  String get progressLabel => 'Fortschritt';

  @override
  String get btnAgain => 'Nochmal';

  @override
  String get btnHard => 'Schwer';

  @override
  String get btnEasy => 'Einfach';

  @override
  String get statsPageTitle => 'Statistik';

  @override
  String get statReviewed => 'Wiederholt';

  @override
  String get statLearned => 'Gelernt';

  @override
  String get statAccuracy => 'Genauigkeit';

  @override
  String get reviewTrendTitle => 'Lerntrend (letzte 10 Tage)';

  @override
  String get noReviewActivity => 'Keine Lernaktivität in letzter Zeit';

  @override
  String get accuracyChartTitle => 'Genauigkeit (letzte 10 Tage)';

  @override
  String get noAccuracyData => 'Keine Daten verfügbar';

  @override
  String get leitnerDistribution => 'Leitner-Verteilung';

  @override
  String get box1New => 'Box 1 (Neu)';

  @override
  String get box2 => 'Box 2';

  @override
  String get box3 => 'Box 3';

  @override
  String get box4 => 'Box 4';

  @override
  String get box5 => 'Box 5';

  @override
  String get box6Mastered => 'Box 6 (Gemeistert)';

  @override
  String get smartInsight => 'Smarte Einsicht';

  @override
  String get insightBox1Full =>
      'Deine Box 1 wird voll. Erwäge heute eine Wiederholung!';

  @override
  String insightMastered(Object count) {
    return 'Du hast $count Elemente gemeistert! Hervorragend.';
  }

  @override
  String get insightLongTerm =>
      'Du baust ein starkes Langzeitgedächtnis auf. Weiter so!';

  @override
  String get insightDefault => 'Übe regelmäßig, um Verbesserungen zu sehen.';

  @override
  String get strongAreas => 'Starke Bereiche';

  @override
  String get needsPractice => 'Braucht Übung';

  @override
  String get notEnoughData => 'Noch nicht genügend Daten.';

  @override
  String get dayStreak => 'Tage-Streak';

  @override
  String get dailyGoal => 'Tagesziel';

  @override
  String get weeklyGoal => 'Wochenziel';

  @override
  String get btnContinuePractice => 'Weiter üben';

  @override
  String get errorLoadingStats => 'Fehler beim Laden der Statistik';

  @override
  String get settingsPageTitle => 'Einstellungen';

  @override
  String get sectionGeneral => 'Allgemein';

  @override
  String get sectionDataSync => 'Cloud & Sync';

  @override
  String get sectionAbout => 'Über';

  @override
  String get langTitle => 'Sprache';

  @override
  String get darkModeTitle => 'Dunkelmodus';

  @override
  String get dailyReminderTitle => 'Tägliche Erinnerung';

  @override
  String get backupToCloud => 'Backup in die Cloud';

  @override
  String get restoreFromCloud => 'Aus Cloud wiederherstellen';

  @override
  String get clearAllData => 'Alle Daten löschen';

  @override
  String get rateOnGooglePlay => 'Auf Google Play bewerten';

  @override
  String get aboutApp => 'Über die App';

  @override
  String get version => 'Version';

  @override
  String get openSourceLicenses => 'Open-Source-Lizenzen';

  @override
  String get signOut => 'Abmelden';

  @override
  String get signInSync => 'Anmelden mit Google';

  @override
  String get developedWith => 'Entwickelt mit';

  @override
  String get byAuthor => 'von';

  @override
  String get selectLanguageDialog => 'Sprache auswählen';

  @override
  String get restoreDialogTitle => 'Aus Cloud wiederherstellen';

  @override
  String get restoreDialogMsg =>
      'Dies führt deine Cloud-Daten mit den aktuellen Daten zusammen.';

  @override
  String get clearDialogTitle => 'Alles löschen?';

  @override
  String get clearDialogMsg =>
      'Warnung: Dies löscht dauerhaft ALLE deine Wörter und Fortschritte.';

  @override
  String get clearDialogOptionCloud => 'Auch Cloud-Backup löschen';

  @override
  String get btnCancel => 'Abbrechen';

  @override
  String get btnRestore => 'Wiederherstellen';

  @override
  String get btnDeleteEverything => 'Alles löschen';

  @override
  String get msgDataRestored =>
      'Daten erfolgreich aus der Cloud wiederhergestellt!';

  @override
  String get msgBackupSuccess => 'Backup erfolgreich in die Cloud hochgeladen!';

  @override
  String msgBackupFailed(Object error) {
    return 'Cloud-Backup fehlgeschlagen: $error';
  }

  @override
  String msgRestoreFailed(Object error) {
    return 'Wiederherstellung fehlgeschlagen: $error';
  }

  @override
  String get msgSignInRequired =>
      'Bitte melden Sie sich an, um diese Funktion zu nutzen.';

  @override
  String get msgDataDeleted => 'Alle Daten wurden erfolgreich gelöscht.';

  @override
  String get msgReminderSet => 'Erinnerung auf 10:00 Uhr gesetzt';

  @override
  String get msgPermissionDenied => 'Berechtigung verweigert.';

  @override
  String msgLanguageChanged(Object lang) {
    return 'Sprache zu $lang geändert.';
  }

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAccountDialogTitle => 'Konto dauerhaft löschen?';

  @override
  String get deleteAccountDialogMsg =>
      'Diese Aktion ist unwiderruflich. Sie löscht dauerhaft:\n• Dein Konto\n• Deine Cloud-Backups\n• Alle lokalen Daten\n\nBist du sicher?';

  @override
  String get msgAccountDeleted => 'Dein Konto und deine Daten wurden gelöscht.';

  @override
  String get msgReauthRequired =>
      'Sicherheitsprüfung fehlgeschlagen. Bitte melde dich ab und erneut an, um das Konto zu löschen.';

  @override
  String get introSkip => 'Überspringen';

  @override
  String get introNext => 'Loslegen';

  @override
  String get intro1Title => 'Wörter speichern';

  @override
  String get intro1Text =>
      'Sammle und organisiere deutsche Wörter, Phrasen und Redewendungen mit klaren Übersetzungen.';

  @override
  String get intro2Title => 'Smart lernen';

  @override
  String get intro2Text =>
      'Stärke dein Gedächtnis mit dem bewährten Leitner-System. Wiederhole zum perfekten Zeitpunkt.';

  @override
  String get intro3Title => 'Klar hören';

  @override
  String get intro3Text =>
      'Höre präzise deutsche und englische Aussprachen und verstehe die Bedeutungen klar.';

  @override
  String get allItemsTitle => 'Alle Elemente';

  @override
  String get noItemsFound => 'Keine Elemente gefunden';

  @override
  String get msgItemDeleted => 'Element gelöscht';

  @override
  String get optionViewDetails => 'Details anzeigen';

  @override
  String get optionEditItem => 'Bearbeiten';

  @override
  String get optionDeleteItem => 'Löschen';

  @override
  String get deleteItemDialogTitle => 'Löschen?';

  @override
  String deleteItemDialogMsg(Object item) {
    return 'Möchtest du \'$item\' wirklich löschen?';
  }

  @override
  String get btnDelete => 'Löschen';

  @override
  String get detailsTitle => 'Details';

  @override
  String get sectionTranslations => 'Übersetzungen';

  @override
  String get labelEnglish => 'Englisch';

  @override
  String get labelPersian => 'Persisch';

  @override
  String get sectionGrammar => 'Grammatik & Formen';

  @override
  String get labelArticle => 'Artikel';

  @override
  String get labelPlural => 'Plural';

  @override
  String get labelPrateritum => 'Präteritum';

  @override
  String get labelPerfekt => 'Perfekt';

  @override
  String get labelPartizip => 'Partizip II';

  @override
  String get sectionExamples => 'Beispielsätze';

  @override
  String get sectionExplanation => 'Erklärung';

  @override
  String get sectionSynAnt => 'Synonyme & Antonyms';

  @override
  String get labelSynonyms => 'Synonyme';

  @override
  String get labelAntonyms => 'Antonyme';

  @override
  String get sectionExtra => 'Extra';

  @override
  String get labelTags => 'Tags';

  @override
  String get labelNotes => 'Notizen';

  @override
  String get addItemTitle => 'Neues Element';

  @override
  String get editItemTitle => 'Element bearbeiten';

  @override
  String get btnSave => 'Speichern';

  @override
  String get btnUpdate => 'Aktualisieren';

  @override
  String get labelContentType => 'Inhaltstyp';

  @override
  String get hintSelectType => 'Typ wählen';

  @override
  String get sheetChooseType => 'Inhaltstyp wählen';

  @override
  String get labelGermanText => 'Deutscher Text';

  @override
  String get hintGermanText => 'Wort, Satz oder Ausdruck...';

  @override
  String get labelEnTrans => 'Englische Übersetzungen';

  @override
  String get hintEnTrans => 'Englische Bedeutung';

  @override
  String get btnAddEn => 'Englisch hinzufügen';

  @override
  String get labelFaTrans => 'Persische Bedeutungen';

  @override
  String get hintFaTrans => 'Persische Bedeutung';

  @override
  String get btnAddFa => 'Persisch hinzufügen';

  @override
  String get labelLevel => 'Niveau';

  @override
  String get trailingOptional => 'Optional';

  @override
  String get trailingMultiple => 'Mehrere erlaubt';

  @override
  String get hintExample => 'Beispielsatz auf Deutsch';

  @override
  String get btnAddExample => 'Beispiel hinzufügen';

  @override
  String get hintTags => 'Grammatik, Reise, B2 ... (kommagetrennt)';

  @override
  String get hintNotes => 'Zusätzliche Notizen zur Verwendung...';

  @override
  String get sectionNounDetails => 'Nomen-Details';

  @override
  String get hintPlural => 'Pluralform (optional)';

  @override
  String get sectionVerbForms => 'Verbformen';

  @override
  String get hintPrateritum => 'Präteritum';

  @override
  String get hintPerfekt => 'Perfekt (haben/sein + Partizip II)';

  @override
  String get hintPartizip => 'Partizip II (optional)';

  @override
  String get hintSynonym => 'Synonym';

  @override
  String get btnAddSynonym => 'Synonym hinzufügen';

  @override
  String get hintAntonym => 'Antonym';

  @override
  String get btnAddAntonym => 'Antonym hinzufügen';

  @override
  String get sectionUsageNotes => 'Verwendungshinweise';

  @override
  String get hintUsageNotes => 'Wie wird dieses Adverb verwendet?';

  @override
  String get hintExplanation => 'Kurze Erklärung oder Kontext';

  @override
  String get errSelectType => 'Bitte Inhaltstyp wählen';

  @override
  String get errEnterEnglish => 'Bitte mind. 1 englische Bedeutung eingeben';

  @override
  String get errEnterPersian => 'Bitte mind. 1 persische Bedeutung eingeben';

  @override
  String get errPrateritum => 'Bitte Präteritum eingeben';

  @override
  String get errPerfekt => 'Bitte Perfekt eingeben';

  @override
  String get errGermanText => 'Bitte deutschen Haupttext eingeben';

  @override
  String get errDuplicate => 'Dieses Element existiert bereits!';

  @override
  String get msgSaved => 'Erfolgreich gespeichert';

  @override
  String get msgUpdated => 'Erfolgreich aktualisiert';

  @override
  String get typeWord => 'Wort (Nomen)';

  @override
  String get typeWordSub => 'Einfaches Wort mit Artikel und Plural';

  @override
  String get typeVerb => 'Verb';

  @override
  String get typeVerbSub => 'Mit Vergangenheitsformen & Beispiel';

  @override
  String get typeAdj => 'Adjektiv';

  @override
  String get typeAdjSub => 'Mit Synonymen & Antonymen';

  @override
  String get typeAdv => 'Adverb';

  @override
  String get typeAdvSub => 'Verwendung und Beispielsatz';

  @override
  String get typeVerbNoun => 'Verb–Nomen-Verbindung';

  @override
  String get typeVerbNounSub => 'z.B. eine Entscheidung treffen';

  @override
  String get typeSentence => 'Satz';

  @override
  String get typeSentenceSub => 'Ganzer Satz + Übersetzungen';

  @override
  String get typeIdiom => 'Redewendung';

  @override
  String get typeIdiomSub => 'Ausdruck mit Erklärung';

  @override
  String get typeNounPhrase => 'Nominalphrase';

  @override
  String get typeNounPhraseSub => 'z.B. der rote Apfel';

  @override
  String get catWords => 'Wörter';

  @override
  String get catVerbs => 'Verben';

  @override
  String get catAdj => 'Adjektive';

  @override
  String get catAdv => 'Adverbien';

  @override
  String get catVerbNoun => 'Verb–Nomen';

  @override
  String get catIdioms => 'Idiome';

  @override
  String get catSentences => 'Sätze';

  @override
  String get catUnknown => 'Unbekannt';
}
