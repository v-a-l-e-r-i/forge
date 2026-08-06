// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get settingsLanguageSection => 'Мова';

  @override
  String get settingsLanguageEnglish => 'Англійська';

  @override
  String get settingsLanguageUkrainian => 'Українська';

  @override
  String get settingsLanguageHint => 'Змінює мову інтерфейсу цього додатку';

  @override
  String get settingsAccountSection => 'Обліковий запис';

  @override
  String get settingsSignOut => 'Вийти';

  @override
  String get settingsSignOutConfirmTitle => 'Вийти з облікового запису?';

  @override
  String get settingsSignOutConfirmBody => 'Для продовження роботи потрібно буде увійти знову.';

  @override
  String get commonCancel => 'Скасувати';

  @override
  String get commonConfirm => 'Підтвердити';

  @override
  String get commonDelete => 'Видалити';

  @override
  String get commonEdit => 'Редагувати';

  @override
  String get commonClose => 'Закрити';

  @override
  String get commonSave => 'Зберегти';

  @override
  String get commonSend => 'Надіслати';

  @override
  String get commonRequiredField => 'Обов\'язкове поле';

  @override
  String get commonNone => 'Немає';

  @override
  String get navGuildOverview => 'Загальна аналітика';

  @override
  String get navHeroes => 'Герої';

  @override
  String get navTeams => 'Департаменти';

  @override
  String get navQuestBoard => 'Управління проєктами';

  @override
  String get navWarnings => 'Звіти та порушення';

  @override
  String get navLevelingConfig => 'Статистика';

  @override
  String get navRolesAudit => 'Адмін ролей';

  @override
  String comingSoonSuffix(String title) {
    return '$title — незабаром';
  }

  @override
  String guildOverviewLoadError(String error) {
    return 'Не вдалося завантажити огляд: $error';
  }

  @override
  String get statTotalHeroes => 'Усього героїв';

  @override
  String get statTeams => 'Команди';

  @override
  String get statActiveQuests => 'Активні квести';

  @override
  String get statCompletedQuests => 'Завершені квести';

  @override
  String get statTotalMembers => 'Усього учасників';

  @override
  String heroesLoadError(String error) {
    return 'Не вдалося завантажити героїв: $error';
  }

  @override
  String get heroesEmpty => 'Ще немає зареєстрованих героїв.';

  @override
  String get heroesSearchHint => 'Фільтр за ніком або ім\'ям';

  @override
  String heroesCount(int count) {
    return 'Героїв: $count';
  }

  @override
  String get tableColHero => 'Герой';

  @override
  String get tableColRole => 'Роль';

  @override
  String get tableColLevel => 'Рівень';

  @override
  String get tableColXp => 'XP';

  @override
  String get tableColActiveQuests => 'Активні квести';

  @override
  String get tableColCompleted => 'Завершено';

  @override
  String heroCardSummary(String level, int xp) {
    return '$level · $xp XP';
  }

  @override
  String heroCardTasksSummary(int active, int completed) {
    return 'Активних: $active · Завершено: $completed';
  }

  @override
  String get heroCardViewProfile => 'Переглянути профіль';

  @override
  String teamsLoadError(String error) {
    return 'Не вдалося завантажити команди: $error';
  }

  @override
  String get teamsEmpty => 'Команд ще немає. Створіть команду в колекції \"teams\", щоб почати.';

  @override
  String teamCardMembersCount(int count) {
    return '$count персонажів';
  }

  @override
  String get teamCardMembersLabel => 'УЧАСНИКИ';

  @override
  String get teamCardNoMembers => 'До цієї команди ще не додано жодного героя.';

  @override
  String heroDetailActiveQuests(int count) {
    return 'Активні квести ($count)';
  }

  @override
  String heroDetailCompletedQuests(int count) {
    return 'Завершені квести ($count)';
  }

  @override
  String get heroDetailLoadError => 'Не вдалося завантажити дані героя';

  @override
  String get notificationsTitle => 'Сповіщення';

  @override
  String get notificationsNew => 'Нове сповіщення';

  @override
  String get notificationsDeleteTitle => 'Видалити сповіщення?';

  @override
  String notificationsDeleteBody(String title) {
    return '«$title» буде видалено безповоротно.';
  }

  @override
  String get notificationsEmpty => 'Сповіщень поки немає';

  @override
  String get notificationsFilterAll => 'Усі';

  @override
  String get notificationsFilterBroadcast => 'Broadcast';

  @override
  String get notificationsFilterTeam => 'Команди';

  @override
  String get notificationsFilterIndividual => 'Особисті';

  @override
  String get notificationsAudienceAll => 'Усі герої';

  @override
  String notificationsAudienceTeam(String name) {
    return 'Команда: $name';
  }

  @override
  String notificationsAudienceIndividual(String name) {
    return 'Герой: $name';
  }

  @override
  String notificationsReadCount(int count) {
    return 'Прочитано: $count';
  }

  @override
  String get notifDialogEditTitle => 'Редагувати сповіщення';

  @override
  String get notifDialogNewTitle => 'Нове сповіщення';

  @override
  String get notifDialogTitleField => 'Заголовок';

  @override
  String get notifDialogBodyField => 'Текст сповіщення';

  @override
  String get notifDialogAudienceLabel => 'Кому надіслати';

  @override
  String get notifDialogAudienceBroadcast => 'Усі';

  @override
  String get notifDialogAudienceTeam => 'Команда';

  @override
  String get notifDialogAudienceIndividual => 'Герой';

  @override
  String get notifDialogSelectTeam => 'Оберіть команду';

  @override
  String get notifDialogSelectHero => 'Оберіть героя';

  @override
  String get notifDialogTeamPickerLabel => 'Команда';

  @override
  String get notifDialogHeroPickerLabel => 'Герой';

  @override
  String readStatusTitle(int count) {
    return 'Прочитали ($count)';
  }

  @override
  String get readStatusEmpty => 'Ще ніхто не прочитав це сповіщення';

  @override
  String get questFormEditTitle => 'Редагувати квест';

  @override
  String get questFormNewTitle => 'Новий квест';

  @override
  String get questFormTitleField => 'Назва';

  @override
  String get questFormTitleRequired => 'Введіть назву';

  @override
  String get questFormDescriptionField => 'Опис';

  @override
  String get questFormDescriptionRequired => 'Введіть опис';

  @override
  String get questFormDifficulty => 'Складність';

  @override
  String get questFormPoints => 'Бали';

  @override
  String get questFormPointsInvalid => 'Введіть коректне число';

  @override
  String questFormSaveError(String error) {
    return 'Не вдалося зберегти: $error';
  }

  @override
  String get questFormSaveChanges => 'Зберегти зміни';

  @override
  String get questFormCreateQuest => 'Створити квест';

  @override
  String get difficultyEasy => 'Легко';

  @override
  String get difficultyMedium => 'Середньо';

  @override
  String get difficultyHard => 'Важко';

  @override
  String get sidebarLoadHeroError => 'Не вдалося завантажити дані героя';

  @override
  String get sidebarSignOut => 'Вийти';

  @override
  String get forgeBrandTagline => 'СТВОРЮЄМО ЦИФРОВЕ.\nФОРМУЄМО МАЙБУТНЄ.';

  @override
  String get forgeBrandWhoTitle => 'ХТО МИ';

  @override
  String get forgeBrandWhoDescription => 'Forge — технологічна компанія, що з ентузіазмом створює інноваційні цифрові рішення, які підсилюють бізнес і людей.';

  @override
  String get forgeBrandWhatTitle => 'ЩО МИ РОБИМО';

  @override
  String get forgeBrandWhatDescription => 'Ми проєктуємо, розробляємо та масштабуємо кастомні програмні рішення, що вирішують реальні проблеми та дають відчутний результат.';

  @override
  String get forgeBrandFeatureInnovativeTitle => 'ІННОВАЦІЙНІСТЬ';

  @override
  String get forgeBrandFeatureInnovativeSubtitle => 'Рішення';

  @override
  String get forgeBrandFeatureReliableTitle => 'НАДІЙНІСТЬ';

  @override
  String get forgeBrandFeatureReliableSubtitle => 'Партнерство';

  @override
  String get forgeBrandFeatureImpactfulTitle => 'ЕФЕКТИВНІСТЬ';

  @override
  String get forgeBrandFeatureImpactfulSubtitle => 'Результат';
}
