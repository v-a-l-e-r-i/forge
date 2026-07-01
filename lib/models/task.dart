import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document: `tasks/{taskId}`
///
/// Relation: user (many → 1) via [assigneeId] → users/{assigneeId}
class Task {
  const Task({
    required this.id,
    required this.assigneeId,
    required this.title,
    required this.description,
    required this.points,
    required this.difficulty,
    required this.isCompleted,
    required this.createdAt,
  });

  final String id;
  final String assigneeId;
  final String description;
  final int points;
  final String difficulty;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Task(
      id: doc.id,
      assigneeId: data['assigneeId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      points: data['points'] as int? ?? 0,
      difficulty: data['difficulty'] as String? ?? '',
      isCompleted: data['isCompleted'] as bool? ?? false,
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'assigneeId': assigneeId,
      'title': title,
      'isCompleted': isCompleted,
      'description': description,
      'points': points,
      'difficulty': difficulty,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
