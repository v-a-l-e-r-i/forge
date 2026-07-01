import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:forge/services/task_service.dart';
import 'package:provider/provider.dart';

import 'features/theme/dark_mode.dart';
import 'features/theme/light_mode.dart';
import 'features/theme/theme_provider.dart';
import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider(create: (_) => UserService()),
        Provider<TaskService>(
          create: (_) => TaskService(),
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
      title: 'Forge',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AuthWrapper(),
    );
  }
}
