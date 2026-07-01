import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document: `warnings/{warningId}`
///
/// Relation: user (many → 1) via [userId] → users/{userId}
class Warning {
  const Warning({
    required this.id,
    required this.userId,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String message;
  final DateTime createdAt;

  factory Warning.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Warning(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      message: data['message'] as String? ?? '',
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
