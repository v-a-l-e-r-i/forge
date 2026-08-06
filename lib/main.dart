import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:forge/services/task_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/pages/notifications_page.dart';
import 'features/theme/dark_mode.dart';
import 'features/theme/light_mode.dart';
import 'features/theme/theme_provider.dart';
import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/push_notification_service.dart';
import 'services/user_service.dart';

/// Використовується, щоб навігувати на NotificationsPage з натискання пушу,
/// коли ще невідомо, який саме BuildContext активний у дереві.
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Має бути зареєстровано ДО runApp().
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Supabase.initialize(
    url: dotenv.get('URL'),
    anonKey: dotenv.get('KEY'),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider(create: (_) => UserService()),
        Provider<TaskService>(
          create: (_) => TaskService(),
        ),
        Provider<NotificationService>(
          create: (_) => NotificationService(),
        ),
        ProxyProvider<UserService, AuthService>(
          update: (_, userService, previous) =>
              previous ?? AuthService(userService: userService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Forge',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AuthWrapper(),
    );
  }
}
