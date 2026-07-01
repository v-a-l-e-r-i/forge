import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document: `teams/{teamId}`
///
/// Relation: users (1 → many) — users reference this doc via teamId
class Team {
  const Team({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;

  factory Team.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Team(
      id: doc.id,
      name: data['name'] as String? ?? doc.id,
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
