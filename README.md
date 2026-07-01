# Forge

> **Forge** — gamified workspace для команд і компаній. Замість сухого task-tracker'а співробітники отримують RPG-подібний досвід: створюють персонажа, збирають колекційну картку, беруть квести (задачі), заробляють XP і ростуть у рівні.

---

## Зміст

- [Про проект](#про-проект)
- [Для кого](#для-кого)
- [Ключова ідея](#ключова-ідея)
- [Ігрові механіки](#ігрові-механіки)
- [Ролі користувачів](#ролі-користувачів)
- [Екрани та функціонал](#екрани-та-функціонал)
- [Користувацькі сценарії](#користувацькі-сценарії)
- [Архітектура](#архітектура)
- [Модель даних (Firestore)](#модель-даних-firestore)
- [Технології](#технології)
- [Структура проекту](#структура-проекту)
- [Запуск проекту](#запуск-проекту)
- [Налаштування Firebase](#налаштування-firebase)
- [Дизайн-система](#дизайн-система)
- [Roadmap](#roadmap)

---

## Про проект

**Forge** (Кузня) — це мобільний та десктопний Flutter-додаток, який перетворює робочі процеси команди на ігрову всесвіт. Кожен співробітник — це не просто акаунт у системі, а **герой з унікальною карткою**, навичками, рівнем і історією виконаних квестів.

Проект поєднує:

- **Корпоративний HR/team management** — реальні ПІБ, nickname, команда, роль
- **Gamification** — XP, level, quest board, collectible character card
- **Сучасний UI** — темна та світла тема в стилі «forge / mystic tarot card»

Назва **Forge** символізує місце, де «кується» професійна ідентичність: кожен крок, кожен виконаний квест і кожен рівень — результат роботи в кузні команди.

---

## Для кого

| Аудиторія | Що отримує |
|-----------|------------|
| **Співробітник (employee)** | Персональна картка, квести, прогрес XP, видимість у команді |
| **Team Lead** | Огляд активності команди, розподіл задач (майбутнє) |
| **Admin** | Керування ролями, командами, квестами (майбутнє) |
| **Компанія** | Мотивація через гейміфікацію замість сухих KPI |

---

## Ключова ідея

Традиційні таск-менеджери часто сприймаються як «ще одна робота». Forge вирішує це через **емоційний зв'язок з персонажем**:

1. При реєстрації людина створює **профіль героя** — фото, slogan, primary skill.
2. На головному екрані відображається **Character Card** у стилі колекційної/tarot-карти з рівнем, роллю, командою та здібностями.
3. Задачі називаються **Quests** — їх можна взяти з дошки, виконати й отримати XP.
4. Прогрес відображається публічно — **Team Heroes Bar** показує аватарки всіх зареєстрованих героїв команди.

---

## Ігрові механіки

### Рівень і XP

- Кожен користувач стартує з **level: 1** і **xp: 0**.
- За завершення квесту нараховується XP (`points` у документі task).
- Рівень персонажа відображається на картці та в Team Heroes Bar.

### Квести (Tasks)

| Статус | Опис |
|--------|------|
| **Available Quests** | Вільні задачі без виконавця (`assigneeId == ""`) |
| **My Active Quests** | Квести, які взяв поточний користувач |
| **Completed** | Завершені квести (`isCompleted: true`) |

**Цикл квесту:**
```
Створення квесту → Доступний на Quest Board → Користувач бере квест
→ activeTaskCount +1 → Виконання → completeTask()
→ xp +points, completedTaskCount +1, activeTaskCount -1
```

### Character Card

Колекційна вертикальна картка персонажа містить:

- **Аватар** — фото з галереї (локально або Firebase Storage URL)
- **Рівень** — круглий індикатор зверху
- **Роль** — employee / team_lead / admin
- **Команда** — `teamId` (якщо призначена)
- **Ім'я та nickname** — `@username`
- **Slogan** — battle motto / девіз героя
- **Abilities** — список навичок (розбивається по пробілу `" "`)

### Team Heroes Bar

Горизонтальна стрічка на Home — показує **всіх зареєстрованих персонажів** з аватаром і рівнем. Дає відчуття «живої команди героїв».

---

## Ролі користувачів

| Роль | Firestore value | Опис |
|------|-----------------|------|
| Employee | `employee` | Базова роль при реєстрації |
| Team Lead | `team_lead` | Керівник команди (призначається admin) |
| Admin | `admin` | Адміністратор системи |

При реєстрації всім автоматично призначається роль **employee**.

---

## Екрани та функціонал

### Login Page
- Вхід за **nickname + password**
- Перехід на реєстрацію («New to the smithy? Register»)
- Брендинг FORGE з amethyst-акцентами

### Register Page (4 кроки)

| Крок | Назва | Поля |
|------|-------|------|
| 1 | Create Profile | Прізвище, Ім'я, По батькові |
| 2 | Choose Identity | Nickname, Primary Skill / Class |
| 3 | Secure Account | Password (min 6 символів) |
| 4 | Upload Photo | Фото персонажа + Battle Slogan |

Після реєстрації створюються документи в `users/{uid}` та `characters/{uid}`.

### Home Page
- **Team Heroes Bar** — команда онлайн
- **Character Card** — головна колекційна картка
- **Profile stats** — ім'я, XP, active/completed tasks, abilities
- Перемикач **світлої/темної теми**
- Перехід на **Quest Board**
- **Sign out**

### Tasks Page (Quest Board)
- Вкладка **Available Quests** — вільні квести
- Вкладка **My Active Quests** — активні квести користувача
- Дії: взяти квест, завершити, отримати XP

---

## Користувацькі сценарії

### Новий співробітник

```
Відкриває додаток → Login Page → Register
→ 4 кроки реєстрації → Home Page з Character Card
→ Quest Board → бере квест → виконує → отримує XP
```

### Повернення в систему

```
Login Page → nickname + password → Home Page
```

### Автентифікація

Firebase Auth не підтримує nickname напряму, тому використовується **синтетичний email**:

```
nickname: "Valeria"  →  email: "valeria@forge.local"
```

Це внутрішній технічний ідентифікатор; користувач бачить лише nickname.

---

## Архітектура

```
┌─────────────────────────────────────────────────┐
│                   Flutter UI                     │
│  LoginPage │ RegisterPage │ HomePage │ TasksPage │
└──────────────────────┬──────────────────────────┘
                       │ Provider
┌──────────────────────▼──────────────────────────┐
│              Services Layer                      │
│  AuthService │ UserService │ TaskService         │
│              │ StorageService                     │
└──────────────────────┬──────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────┐
│                  Firebase                        │
│  Auth │ Firestore │ Storage                      │
└─────────────────────────────────────────────────┘
```

**State management:** `Provider` + `ChangeNotifier` (ThemeProvider)

**Realtime data:** Firestore `snapshots()` streams для users, characters, tasks

**Routing:** `AuthWrapper` слухає `authStateChanges` і показує Login або Home

---

## Модель даних (Firestore)

### `users/{uid}`

```json
{
  "nickname": "valeria",
  "firstName": "Valeria",
  "middleName": "Олегівна",
  "lastName": "Коваленко",
  "name": "Valeria Коваленко",
  "email": "valeria@forge.local",
  "role": "employee",
  "level": 1,
  "xp": 820,
  "teamId": "team_1",
  "activeTaskCount": 3,
  "completedTaskCount": 40,
  "createdAt": "Timestamp"
}
```

### `characters/{uid}` (1:1 з user)

```json
{
  "userId": "abc123",
  "name": "valeria",
  "slogan": "Code is my craft, bugs are my prey",
  "level": 1,
  "abilities": ["Developer", "Designer"],
  "avatarUrl": "https://... або локальний шлях",
  "createdAt": "Timestamp"
}
```

### `tasks/{taskId}`

```json
{
  "title": "Fix login bug",
  "description": "Resolve auth crash on Android",
  "assigneeId": "",
  "points": 50,
  "difficulty": "medium",
  "isCompleted": false,
  "createdAt": "Timestamp"
}
```

### `teams/{teamId}`

```json
{
  "name": "Team Alpha",
  "createdAt": "Timestamp"
}
```

### `warnings/{warningId}`

```json
{
  "userId": "abc123",
  "message": "Missed deadline on quest X",
  "createdAt": "Timestamp"
}
```

### Зв'язки між колекціями

```
users ──(1:N)──► tasks        assigneeId → users.id
users ──(N:1)──► teams        users.teamId → teams.id
users ──(1:N)──► warnings     warnings.userId → users.id
users ──(1:1)──► characters   characters.id == users.id
```

---

## Технології

| Категорія | Технологія |
|-----------|------------|
| Framework | Flutter (Dart SDK ^3.12) |
| State | Provider |
| Auth | Firebase Authentication (Email/Password) |
| Database | Cloud Firestore |
| Storage | Firebase Storage (аватари) |
| Preferences | shared_preferences (збереження теми) |
| Media | image_picker |
| Animation | lottie |
| Platforms | Android, iOS, Windows |

---

## Структура проекту

```
lib/
├── features/
│   ├── pages/
│   │   ├── login_page.dart       # Вхід у систему
│   │   ├── register_page.dart    # 4-крокова реєстрація
│   │   ├── home_page.dart        # Character Card + stats
│   │   └── tasks_page.dart       # Quest Board
│   └── theme/
│       ├── dark_mode.dart        # Темна тема (Graphite/Black)
│       ├── light_mode.dart       # Світла тема (Soft Linen)
│       └── theme_provider.dart   # Перемикач + збереження
├── models/
│   ├── app_user.dart             # Модель користувача
│   ├── character.dart            # Модель персонажа
│   ├── task.dart                 # Модель квесту
│   ├── team.dart                 # Модель команди
│   ├── user_role.dart            # Enum ролей
│   └── warning.dart              # Попередження
├── screens/
│   └── auth_wrapper.dart         # Auth routing
├── services/
│   ├── auth_service.dart         # Login, register, streams
│   ├── user_service.dart         # CRUD users + characters
│   ├── task_service.dart         # Quest board logic
│   └── storage_service.dart      # Upload avatars
├── firebase_options.dart
└── main.dart
```

---

## Запуск проекту

### Вимоги

- Flutter SDK (stable або ^3.12)
- Android Studio / VS Code
- Firebase project

### Команди

```bash
# Клонування та залежності
git clone <repo-url>
cd forge
flutter pub get

# Запуск
flutter run

# Аналіз коду
flutter analyze lib

# Збірка Android
flutter build apk
```

### Підтримувані платформи

- Android
- iOS
- Windows

---

## Налаштування Firebase

1. Створіть проект у [Firebase Console](https://console.firebase.google.com).
2. Увімкніть **Authentication → Sign-in method → Email/Password**.
3. Створіть **Cloud Firestore** database.
4. (Опційно) Увімкніть **Firebase Storage** для аватарів.
5. Виконайте конфігурацію FlutterFire:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

6. Переконайтесь, що `lib/firebase_options.dart` та `android/app/google-services.json` згенеровані.

### Приклад тестового квесту в Firestore

```json
// tasks/quest_001
{
  "title": "Setup dev environment",
  "description": "Install Flutter and run the app",
  "assigneeId": "",
  "points": 100,
  "difficulty": "easy",
  "isCompleted": false,
  "createdAt": "<server timestamp>"
}
```

---

## Дизайн-система

Палітра натхненна «кузнею + містика + amethyst»:

| Token | Light | Dark | Призначення |
|-------|-------|------|-------------|
| Background | Soft Linen `#EDE7D9` | Black `#242424` | Фон екранів |
| Surface | White | Graphite `#333333` | Картки, поля вводу |
| Primary | Amethyst `#9055A2` | Amethyst `#9055A2` | Кнопки, акценти, прогрес |
| Secondary | Graphite `#333333` | Soft Linen `#EDE7D9` | Текст, labels |
| On Surface | Graphite | White | Основний текст |

Тема зберігається локально через `SharedPreferences` і перемикається кнопкою на Home Page.

---

## Roadmap

- [ ] Admin panel — створення квестів і команд
- [ ] Автоматичний level-up при досягненні XP-порогу
- [ ] Push-сповіщення про нові квести
- [ ] Warnings system для team lead
- [ ] Повна інтеграція Firebase Storage для аватарів
- [ ] Фільтрація Team Heroes Bar по `teamId`
- [ ] Web-платформа

---

## Ліцензія

Приватний проект — не публікується на pub.dev.

---

<p align="center">
  <strong>FORGE</strong> — де кожен співробітник стає героєм своєї команди.
</p>
