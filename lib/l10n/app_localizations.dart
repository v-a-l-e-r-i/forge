import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk')
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageUkrainian.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get settingsLanguageUkrainian;

  /// No description provided for @settingsLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Changes the interface language for this app'**
  String get settingsLanguageHint;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get settingsSignOutConfirmTitle;

  /// No description provided for @settingsSignOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to log in again to continue.'**
  String get settingsSignOutConfirmBody;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get commonSend;

  /// No description provided for @commonRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get commonRequiredField;

  /// No description provided for @commonNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// No description provided for @navGuildOverview.
  ///
  /// In en, this message translates to:
  /// **'Guild Overview'**
  String get navGuildOverview;

  /// No description provided for @navHeroes.
  ///
  /// In en, this message translates to:
  /// **'Heroes'**
  String get navHeroes;

  /// No description provided for @navTeams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get navTeams;

  /// No description provided for @navQuestBoard.
  ///
  /// In en, this message translates to:
  /// **'Quest Board'**
  String get navQuestBoard;

  /// No description provided for @navWarnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get navWarnings;

  /// No description provided for @navLevelingConfig.
  ///
  /// In en, this message translates to:
  /// **'Leveling Config'**
  String get navLevelingConfig;

  /// No description provided for @navRolesAudit.
  ///
  /// In en, this message translates to:
  /// **'Roles & Audit'**
  String get navRolesAudit;

  /// No description provided for @comingSoonSuffix.
  ///
  /// In en, this message translates to:
  /// **'{title} — coming soon'**
  String comingSoonSuffix(String title);

  /// No description provided for @guildOverviewLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load overview: {error}'**
  String guildOverviewLoadError(String error);

  /// No description provided for @statTotalHeroes.
  ///
  /// In en, this message translates to:
  /// **'Total Heroes'**
  String get statTotalHeroes;

  /// No description provided for @statTeams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get statTeams;

  /// No description provided for @statActiveQuests.
  ///
  /// In en, this message translates to:
  /// **'Active Quests'**
  String get statActiveQuests;

  /// No description provided for @statCompletedQuests.
  ///
  /// In en, this message translates to:
  /// **'Completed Quests'**
  String get statCompletedQuests;

  /// No description provided for @statTotalMembers.
  ///
  /// In en, this message translates to:
  /// **'Total Members'**
  String get statTotalMembers;

  /// No description provided for @heroesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Heroes: {error}'**
  String heroesLoadError(String error);

  /// No description provided for @heroesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No Heroes registered yet.'**
  String get heroesEmpty;

  /// No description provided for @heroesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Filter by nickname or name'**
  String get heroesSearchHint;

  /// No description provided for @heroesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Heroes'**
  String heroesCount(int count);

  /// No description provided for @tableColHero.
  ///
  /// In en, this message translates to:
  /// **'Hero'**
  String get tableColHero;

  /// No description provided for @tableColRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get tableColRole;

  /// No description provided for @tableColLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get tableColLevel;

  /// No description provided for @tableColXp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get tableColXp;

  /// No description provided for @tableColActiveQuests.
  ///
  /// In en, this message translates to:
  /// **'Active Quests'**
  String get tableColActiveQuests;

  /// No description provided for @tableColCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tableColCompleted;

  /// No description provided for @heroCardSummary.
  ///
  /// In en, this message translates to:
  /// **'{level} · {xp} XP'**
  String heroCardSummary(String level, int xp);

  /// No description provided for @heroCardTasksSummary.
  ///
  /// In en, this message translates to:
  /// **'{active} active · {completed} completed'**
  String heroCardTasksSummary(int active, int completed);

  /// No description provided for @heroCardViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get heroCardViewProfile;

  /// No description provided for @teamsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load teams: {error}'**
  String teamsLoadError(String error);

  /// No description provided for @teamsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No teams yet. Create one in the \"teams\" collection to get started.'**
  String get teamsEmpty;

  /// No description provided for @teamCardMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String teamCardMembersCount(int count);

  /// No description provided for @teamCardMembersLabel.
  ///
  /// In en, this message translates to:
  /// **'MEMBERS'**
  String get teamCardMembersLabel;

  /// No description provided for @teamCardNoMembers.
  ///
  /// In en, this message translates to:
  /// **'No Heroes assigned to this team yet.'**
  String get teamCardNoMembers;

  /// No description provided for @heroDetailActiveQuests.
  ///
  /// In en, this message translates to:
  /// **'Active Quests ({count})'**
  String heroDetailActiveQuests(int count);

  /// No description provided for @heroDetailCompletedQuests.
  ///
  /// In en, this message translates to:
  /// **'Completed Quests ({count})'**
  String heroDetailCompletedQuests(int count);

  /// No description provided for @heroDetailLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load hero data'**
  String get heroDetailLoadError;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsNew.
  ///
  /// In en, this message translates to:
  /// **'New notification'**
  String get notificationsNew;

  /// No description provided for @notificationsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete notification?'**
  String get notificationsDeleteTitle;

  /// No description provided for @notificationsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be permanently deleted.'**
  String notificationsDeleteBody(String title);

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// No description provided for @notificationsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsFilterAll;

  /// No description provided for @notificationsFilterBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Broadcast'**
  String get notificationsFilterBroadcast;

  /// No description provided for @notificationsFilterTeam.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get notificationsFilterTeam;

  /// No description provided for @notificationsFilterIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get notificationsFilterIndividual;

  /// No description provided for @notificationsAudienceAll.
  ///
  /// In en, this message translates to:
  /// **'All Heroes'**
  String get notificationsAudienceAll;

  /// No description provided for @notificationsAudienceTeam.
  ///
  /// In en, this message translates to:
  /// **'Team: {name}'**
  String notificationsAudienceTeam(String name);

  /// No description provided for @notificationsAudienceIndividual.
  ///
  /// In en, this message translates to:
  /// **'Hero: {name}'**
  String notificationsAudienceIndividual(String name);

  /// No description provided for @notificationsReadCount.
  ///
  /// In en, this message translates to:
  /// **'Read: {count}'**
  String notificationsReadCount(int count);

  /// No description provided for @notifDialogEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit notification'**
  String get notifDialogEditTitle;

  /// No description provided for @notifDialogNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New notification'**
  String get notifDialogNewTitle;

  /// No description provided for @notifDialogTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get notifDialogTitleField;

  /// No description provided for @notifDialogBodyField.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get notifDialogBodyField;

  /// No description provided for @notifDialogAudienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Send to'**
  String get notifDialogAudienceLabel;

  /// No description provided for @notifDialogAudienceBroadcast.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notifDialogAudienceBroadcast;

  /// No description provided for @notifDialogAudienceTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get notifDialogAudienceTeam;

  /// No description provided for @notifDialogAudienceIndividual.
  ///
  /// In en, this message translates to:
  /// **'Hero'**
  String get notifDialogAudienceIndividual;

  /// No description provided for @notifDialogSelectTeam.
  ///
  /// In en, this message translates to:
  /// **'Select a team'**
  String get notifDialogSelectTeam;

  /// No description provided for @notifDialogSelectHero.
  ///
  /// In en, this message translates to:
  /// **'Select a hero'**
  String get notifDialogSelectHero;

  /// No description provided for @notifDialogTeamPickerLabel.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get notifDialogTeamPickerLabel;

  /// No description provided for @notifDialogHeroPickerLabel.
  ///
  /// In en, this message translates to:
  /// **'Hero'**
  String get notifDialogHeroPickerLabel;

  /// No description provided for @readStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Read by ({count})'**
  String readStatusTitle(int count);

  /// No description provided for @readStatusEmpty.
  ///
  /// In en, this message translates to:
  /// **'No one has read this notification yet'**
  String get readStatusEmpty;

  /// No description provided for @questFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Quest'**
  String get questFormEditTitle;

  /// No description provided for @questFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Quest'**
  String get questFormNewTitle;

  /// No description provided for @questFormTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get questFormTitleField;

  /// No description provided for @questFormTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get questFormTitleRequired;

  /// No description provided for @questFormDescriptionField.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get questFormDescriptionField;

  /// No description provided for @questFormDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a description'**
  String get questFormDescriptionRequired;

  /// No description provided for @questFormDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get questFormDifficulty;

  /// No description provided for @questFormPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get questFormPoints;

  /// No description provided for @questFormPointsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get questFormPointsInvalid;

  /// No description provided for @questFormSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String questFormSaveError(String error);

  /// No description provided for @questFormSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get questFormSaveChanges;

  /// No description provided for @questFormCreateQuest.
  ///
  /// In en, this message translates to:
  /// **'Create Quest'**
  String get questFormCreateQuest;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @sidebarLoadHeroError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load hero data'**
  String get sidebarLoadHeroError;

  /// No description provided for @sidebarSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get sidebarSignOut;

  /// No description provided for @forgeBrandTagline.
  ///
  /// In en, this message translates to:
  /// **'BUILDING DIGITAL.\nSHAPING FUTURES.'**
  String get forgeBrandTagline;

  /// No description provided for @forgeBrandWhoTitle.
  ///
  /// In en, this message translates to:
  /// **'WHO WE ARE'**
  String get forgeBrandWhoTitle;

  /// No description provided for @forgeBrandWhoDescription.
  ///
  /// In en, this message translates to:
  /// **'Forge is a forward-thinking technology company passionate about building innovative digital solutions that empower businesses and people.'**
  String get forgeBrandWhoDescription;

  /// No description provided for @forgeBrandWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'WHAT WE DO'**
  String get forgeBrandWhatTitle;

  /// No description provided for @forgeBrandWhatDescription.
  ///
  /// In en, this message translates to:
  /// **'We design, develop and scale custom software solutions that solve real problems and drive meaningful impact.'**
  String get forgeBrandWhatDescription;

  /// No description provided for @forgeBrandFeatureInnovativeTitle.
  ///
  /// In en, this message translates to:
  /// **'INNOVATIVE'**
  String get forgeBrandFeatureInnovativeTitle;

  /// No description provided for @forgeBrandFeatureInnovativeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Solutions'**
  String get forgeBrandFeatureInnovativeSubtitle;

  /// No description provided for @forgeBrandFeatureReliableTitle.
  ///
  /// In en, this message translates to:
  /// **'RELIABLE'**
  String get forgeBrandFeatureReliableTitle;

  /// No description provided for @forgeBrandFeatureReliableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Partnership'**
  String get forgeBrandFeatureReliableSubtitle;

  /// No description provided for @forgeBrandFeatureImpactfulTitle.
  ///
  /// In en, this message translates to:
  /// **'IMPACTFUL'**
  String get forgeBrandFeatureImpactfulTitle;

  /// No description provided for @forgeBrandFeatureImpactfulSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get forgeBrandFeatureImpactfulSubtitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'uk': return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
