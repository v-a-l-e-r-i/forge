import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

class NotificationService {
  NotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  /// Сповіщення, релевантні герою: broadcast (усім) + власна команда
  /// (якщо є) + особисті. [teamId] передається з AppUser.teamId —
  /// якщо null/порожній, команда просто не потрапляє у фільтр.
  Stream<List<ForgeNotification>> watchMyNotifications({
    required String userId,
    String? teamId,
  }) {
    final broadcastFilter = Filter('audienceType', isEqualTo: 'broadcast');
    final individualFilter = Filter.and(
      Filter('audienceType', isEqualTo: 'individual'),
      Filter('targetUserId', isEqualTo: userId),
    );

    // Filter.or приймає окремі позиційні Filter-и (не List), тому гілку
    // команди додаємо умовно, а не через .add() у список.
    final Filter combinedFilter;
    if (teamId != null && teamId.isNotEmpty) {
      final teamFilter = Filter.and(
        Filter('audienceType', isEqualTo: 'team'),
        Filter('targetTeamId', isEqualTo: teamId),
      );
      combinedFilter = Filter.or(broadcastFilter, individualFilter, teamFilter);
    } else {
      combinedFilter = Filter.or(broadcastFilter, individualFilter);
    }

    return _notifications
        .where(combinedFilter)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(ForgeNotification.fromFirestore).toList(),
        );
  }

  /// Точкове оновлення лише поля readBy — відповідає правилу безпеки
  /// hasOnly(['readBy']) для героїв.
  Future<void> markAsRead({
    required String notificationId,
    required String userId,
  }) async {
    await _notifications.doc(notificationId).update({
      'readBy.$userId': FieldValue.serverTimestamp(),
    });
  }
}
