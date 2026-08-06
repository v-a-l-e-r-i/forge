import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/pages/login_page.dart';
import '../features/pages/notifications_page.dart';
import '../features/app_shell.dart';
import '../main.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/push_notification_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        if (user == null || user.isAnonymous) {
          return const LoginPage();
        }

        return const _PushSessionManager(child: AppShell());
      },
    );
  }
}

/// Ініціалізує push-шар і тримає FCM-токен/теми синхронізованими з
/// AppUser.teamId героя, поки він залогінений.
class _PushSessionManager extends StatefulWidget {
  const _PushSessionManager({required this.child});

  final Widget child;

  @override
  State<_PushSessionManager> createState() => _PushSessionManagerState();
}

class _PushSessionManagerState extends State<_PushSessionManager> {
  StreamSubscription<AppUser?>? _appUserSub;

  @override
  void initState() {
    super.initState();

    PushNotificationService.instance.initialize(
      onNotificationTap: (notificationId) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        );
      },
    );

    _appUserSub = context.read<AuthService>().watchCurrentAppUser().listen((user) {
      if (user != null) {
        PushNotificationService.instance.registerForUser(
          uid: user.id,
          teamId: user.teamId,
        );
      }
    });
  }

  @override
  void dispose() {
    _appUserSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}