import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Реєстрація FCM-токена, підписка на теми та показ пушів у foreground.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _subscribedTeamTopic;
  bool _initialized = false;

  /// Викликати один раз з main(), одразу після Firebase.initializeApp().
  Future<void> initialize({
    required void Function(String? notificationId) onNotificationTap,
  }) async {
    if (_initialized) return;
    _initialized = true;

    try {
      // На Web запит дозволу та ініціалізація відрізняються
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');
      }

      if (!kIsWeb) {
        const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
        const iosInit = DarwinInitializationSettings();
        await _localNotifications.initialize(
          settings: const InitializationSettings(android: androidInit, iOS: iosInit),
          onDidReceiveNotificationResponse: (response) {
            onNotificationTap(response.payload);
          },
        );

        FirebaseMessaging.onMessage.listen(_showLocalNotification);
      }

      // Натиснули на пуш, коли застосунок був у фоні.
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        onNotificationTap(message.data['notificationId'] as String?);
      });

      // Застосунок запущений з натискання пушу.
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        onNotificationTap(initialMessage.data['notificationId'] as String?);
      }

      // Теми (topics) не підтримуються на Web напряму через SDK
      if (!kIsWeb) {
        await _messaging.subscribeToTopic('all_heroes');
      }

      _messaging.onTokenRefresh.listen(_saveTokenForCurrentUser);
    } catch (e) {
      debugPrint('Error initializing PushNotificationService: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (kIsWeb) return;
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'forge_notifications',
      'Forge — сповіщення',
      channelDescription: 'Сповіщення про квести, команду та гільдію',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: message.data['notificationId'] as String?,
    );
  }

  /// Викликати після кожного оновлення AppUser.
  Future<void> registerForUser({required String uid, String? teamId}) async {
    if (kIsWeb) return; // Skip on web to avoid service worker errors
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenForCurrentUser(token);
      }
      await _syncTeamTopic(teamId);
    } catch (e) {
      debugPrint('Error registering for user: $e');
    }
  }

  Future<void> _saveTokenForCurrentUser(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  Future<void> _syncTeamTopic(String? teamId) async {
    if (kIsWeb) return;
    if (_subscribedTeamTopic == teamId) return;
    try {
      if (_subscribedTeamTopic != null) {
        await _messaging.unsubscribeFromTopic('team_$_subscribedTeamTopic');
      }
      if (teamId != null && teamId.isNotEmpty) {
        await _messaging.subscribeToTopic('team_$teamId');
      }
      _subscribedTeamTopic = teamId;
    } catch (e) {
      debugPrint('Error syncing team topic: $e');
    }
  }

  /// Викликати перед signOut(), поки currentUser ще доступний.
  Future<void> unregisterForCurrentDevice({required String? previousUid}) async {
    if (kIsWeb) {
      // На Web без налаштованого service worker getToken() часто зависає або кидає помилку.
      // Для простоти виходу на Web просто обнуляємо локальний стан.
      _subscribedTeamTopic = null;
      return;
    }
    try {
      final token = await _messaging.getToken();
      if (token != null && previousUid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(previousUid)
            .update({
          'fcmTokens': FieldValue.arrayRemove([token]),
        });
      }
      if (_subscribedTeamTopic != null) {
        await _messaging.unsubscribeFromTopic('team_$_subscribedTeamTopic');
        _subscribedTeamTopic = null;
      }
    } catch (e) {
      debugPrint('Error unregistering device: $e');
    }
  }
}

/// Обов'язково top-level функція. Реєструється в main() ДО runApp():
///   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Системний трей сам показує сповіщення для background/terminated стану,
  // якщо FCM-payload містить блок `notification` (наша Cloud Function його
  // надсилає) — тут більше нічого не потрібно.
}
