# Forge

**Forge** — gamified Flutter workspace for teams. Employees register a profile, build a character card, earn XP, and manage tasks inside a dark/light themed app backed by Firebase.

## Features

- **Authentication** — sign in and register with nickname + password (Firebase Auth via synthetic email)
- **Multi-step registration** — personal data, nickname, skills, password, avatar photo, and battle slogan
- **Character card** — tarot-style collectible card with level, role, team, abilities, and avatar
- **User profile** — level, XP, active/completed task counters, team assignment
- **Tasks** — task list and management per user
- **Themes** — light (Soft Linen) and dark (Graphite/Black) palettes with persistent toggle
- **Firebase backend** — Auth, Firestore, Storage

## Tech stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter (Dart SDK ^3.12) |
| State | Provider |
| Backend | Firebase Auth, Cloud Firestore, Firebase Storage |
| Media | image_picker, lottie |
| Preferences | shared_preferences |

## Project structure

```
lib/
├── features/
│   ├── pages/          # Login, Register, Home, Tasks
│   └── theme/          # lightTheme, darkTheme, ThemeProvider
├── models/             # AppUser, Character, Task, Team, Warning
├── screens/            # AuthWrapper (auth routing)
├── services/           # Auth, User, Task, Storage
├── firebase_options.dart
└── main.dart
```

## Firestore schema

### `users/{uid}`

```json
{
  "nickname": "valeria",
  "firstName": "Valeria",
  "middleName": "...",
  "lastName": "...",
  "name": "Valeria ...",
  "email": "valeria@forge.local",
  "role": "employee | team_lead | admin",
  "level": 1,
  "xp": 0,
  "teamId": null,
  "activeTaskCount": 0,
  "completedTaskCount": 0,
  "createdAt": "Timestamp"
}
```

### `characters/{uid}` (1:1 with user)

```json
{
  "userId": "...",
  "name": "nickname",
  "slogan": "...",
  "level": 1,
  "abilitiesText": "Code Crafting Bug Hunting",
  "avatarUrl": "https://...",
  "createdAt": "Timestamp"
}
```

### Relations

- `users` → `tasks` (1 → many) via `assigneeId`
- `users` → `teams` (many → 1) via `teamId`
- `users` → `warnings` (1 → many) via `userId`
- `users` → `characters` (1 → 1) via document id

## Getting started

### Prerequisites

- Flutter SDK
- Firebase project with **Email/Password** auth enabled
- FlutterFire CLI configured (`flutterfire configure`)

### Install and run

```bash
flutter pub get
flutter run
```

### Supported platforms

- Android
- iOS
- Windows

## Firebase setup

1. Create a project in [Firebase Console](https://console.firebase.google.com).
2. Enable **Authentication → Email/Password**.
3. Create Firestore database.
4. Run `flutterfire configure` and select your platforms.
5. (Optional) Enable **Firebase Storage** for avatar uploads.

## Color palette

| Token | Light | Dark |
|-------|-------|------|
| Background | Soft Linen `#EDE7D9` | Black `#242424` |
| Surface | White | Graphite `#333333` |
| Primary | Amethyst `#9055A2` | Amethyst `#9055A2` |
| Text | Graphite `#333333` | White |

## Scripts

```bash
flutter analyze lib   # static analysis
flutter test          # run tests
flutter build apk     # Android release build
```

## License

Private project — not published to pub.dev.
