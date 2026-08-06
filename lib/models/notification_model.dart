import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document: `notifications/{id}`
enum NotificationAudienceType { broadcast, team, individual }

NotificationAudienceType audienceTypeFromString(String value) {
  return NotificationAudienceType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => NotificationAudienceType.broadcast,
  );
}

class ForgeNotification {
  const ForgeNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.audienceType,
    this.targetTeamId,
    this.targetUserId,
    required this.createdAt,
    required this.createdBy,
    this.readBy = const {},
  });

  final String id;
  final String title;
  final String body;
  final NotificationAudienceType audienceType;
  final String? targetTeamId;
  final String? targetUserId;
  final DateTime createdAt;
  final String createdBy;
  final Map<String, DateTime> readBy;

  factory ForgeNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final rawReadBy = data['readBy'] as Map<String, dynamic>? ?? {};
    final readBy = <String, DateTime>{
      for (final entry in rawReadBy.entries)
        entry.key: (entry.value as Timestamp).toDate(),
    };

    return ForgeNotification(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      audienceType:
          audienceTypeFromString(data['audienceType'] as String? ?? 'broadcast'),
      targetTeamId: data['targetTeamId'] as String?,
      targetUserId: data['targetUserId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
      readBy: readBy,
    );
  }

  /// Чи прочитав це сповіщення конкретний герой.
  bool isReadBy(String uid) => readBy.containsKey(uid);
}
