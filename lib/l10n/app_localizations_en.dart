// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageUkrainian => 'Ukrainian';

  @override
  String get settingsLanguageHint => 'Changes the interface language for this app';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutConfirmTitle => 'Sign out?';

  @override
  String get settingsSignOutConfirmBody => 'You will need to log in again to continue.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSend => 'Send';

  @override
  String get commonRequiredField => 'Required field';

  @override
  String get commonNone => 'None';

  @override
  String get navGuildOverview => 'Guild Overview';

  @override
  String get navHeroes => 'Heroes';

  @override
  String get navTeams => 'Teams';

  @override
  String get navQuestBoard => 'Quest Board';

  @override
  String get navWarnings => 'Warnings';

  @override
  String get navLevelingConfig => 'Leveling Config';

  @override
  String get navRolesAudit => 'Roles & Audit';

  @override
  String comingSoonSuffix(String title) {
    return '$title — coming soon';
  }

  @override
  String guildOverviewLoadError(String error) {
    return 'Failed to load overview: $error';
  }

  @override
  String get statTotalHeroes => 'Total Heroes';

  @override
  String get statTeams => 'Teams';

  @override
  String get statActiveQuests => 'Active Quests';

  @override
  String get statCompletedQuests => 'Completed Quests';

  @override
  String get statTotalMembers => 'Total Members';

  @override
  String heroesLoadError(String error) {
    return 'Failed to load Heroes: $error';
  }

  @override
  String get heroesEmpty => 'No Heroes registered yet.';

  @override
  String get heroesSearchHint => 'Filter by nickname or name';

  @override
  String heroesCount(int count) {
    return '$count Heroes';
  }

  @override
  String get tableColHero => 'Hero';

  @override
  String get tableColRole => 'Role';

  @override
  String get tableColLevel => 'Level';

  @override
  String get tableColXp => 'XP';

  @override
  String get tableColActiveQuests => 'Active Quests';

  @override
  String get tableColCompleted => 'Completed';

  @override
  String heroCardSummary(String level, int xp) {
    return '$level · $xp XP';
  }

  @override
  String heroCardTasksSummary(int active, int completed) {
    return '$active active · $completed completed';
  }

  @override
  String get heroCardViewProfile => 'View Profile';

  @override
  String teamsLoadError(String error) {
    return 'Failed to load teams: $error';
  }

  @override
  String get teamsEmpty => 'No teams yet. Create one in the \"teams\" collection to get started.';

  @override
  String teamCardMembersCount(int count) {
    return '$count members';
  }

  @override
  String get teamCardMembersLabel => 'MEMBERS';

  @override
  String get teamCardNoMembers => 'No Heroes assigned to this team yet.';

  @override
  String heroDetailActiveQuests(int count) {
    return 'Active Quests ($count)';
  }

  @override
  String heroDetailCompletedQuests(int count) {
    return 'Completed Quests ($count)';
  }

  @override
  String get heroDetailLoadError => 'Failed to load hero data';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsNew => 'New notification';

  @override
  String get notificationsDeleteTitle => 'Delete notification?';

  @override
  String notificationsDeleteBody(String title) {
    return '\"$title\" will be permanently deleted.';
  }

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get notificationsFilterAll => 'All';

  @override
  String get notificationsFilterBroadcast => 'Broadcast';

  @override
  String get notificationsFilterTeam => 'Teams';

  @override
  String get notificationsFilterIndividual => 'Individual';

  @override
  String get notificationsAudienceAll => 'All Heroes';

  @override
  String notificationsAudienceTeam(String name) {
    return 'Team: $name';
  }

  @override
  String notificationsAudienceIndividual(String name) {
    return 'Hero: $name';
  }

  @override
  String notificationsReadCount(int count) {
    return 'Read: $count';
  }

  @override
  String get notifDialogEditTitle => 'Edit notification';

  @override
  String get notifDialogNewTitle => 'New notification';

  @override
  String get notifDialogTitleField => 'Title';

  @override
  String get notifDialogBodyField => 'Message';

  @override
  String get notifDialogAudienceLabel => 'Send to';

  @override
  String get notifDialogAudienceBroadcast => 'All';

  @override
  String get notifDialogAudienceTeam => 'Team';

  @override
  String get notifDialogAudienceIndividual => 'Hero';

  @override
  String get notifDialogSelectTeam => 'Select a team';

  @override
  String get notifDialogSelectHero => 'Select a hero';

  @override
  String get notifDialogTeamPickerLabel => 'Team';

  @override
  String get notifDialogHeroPickerLabel => 'Hero';

  @override
  String readStatusTitle(int count) {
    return 'Read by ($count)';
  }

  @override
  String get readStatusEmpty => 'No one has read this notification yet';

  @override
  String get questFormEditTitle => 'Edit Quest';

  @override
  String get questFormNewTitle => 'New Quest';

  @override
  String get questFormTitleField => 'Title';

  @override
  String get questFormTitleRequired => 'Enter a title';

  @override
  String get questFormDescriptionField => 'Description';

  @override
  String get questFormDescriptionRequired => 'Enter a description';

  @override
  String get questFormDifficulty => 'Difficulty';

  @override
  String get questFormPoints => 'Points';

  @override
  String get questFormPointsInvalid => 'Enter a valid number';

  @override
  String questFormSaveError(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get questFormSaveChanges => 'Save Changes';

  @override
  String get questFormCreateQuest => 'Create Quest';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get sidebarLoadHeroError => 'Failed to load hero data';

  @override
  String get sidebarSignOut => 'Sign out';

  @override
  String get forgeBrandTagline => 'BUILDING DIGITAL.\nSHAPING FUTURES.';

  @override
  String get forgeBrandWhoTitle => 'WHO WE ARE';

  @override
  String get forgeBrandWhoDescription => 'Forge is a forward-thinking technology company passionate about building innovative digital solutions that empower businesses and people.';

  @override
  String get forgeBrandWhatTitle => 'WHAT WE DO';

  @override
  String get forgeBrandWhatDescription => 'We design, develop and scale custom software solutions that solve real problems and drive meaningful impact.';

  @override
  String get forgeBrandFeatureInnovativeTitle => 'INNOVATIVE';

  @override
  String get forgeBrandFeatureInnovativeSubtitle => 'Solutions';

  @override
  String get forgeBrandFeatureReliableTitle => 'RELIABLE';

  @override
  String get forgeBrandFeatureReliableSubtitle => 'Partnership';

  @override
  String get forgeBrandFeatureImpactfulTitle => 'IMPACTFUL';

  @override
  String get forgeBrandFeatureImpactfulSubtitle => 'Results';
}
