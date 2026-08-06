import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document: `tasks/{taskId}`
///
/// Relation: user (many → 1) via [assigneeId] → users/{assigneeId}
///
/// `status` ('available' | 'assigned' | 'pendingApproval' | 'completed') is
/// the single source of truth — written by both the mobile app and
/// QuestBoardService (admin), same as task_summary.dart on the admin side.
/// Docs created before this field existed won't have it, so we fall back to
/// the legacy boolean fields (isCompleted) only when `status` is absent.
class Task {
  const Task({
    required this.id,
    required this.assigneeId,
    required this.title,
    required this.description,
    required this.points,
    required this.difficulty,
    required this.isCompleted,
    required this.pendingApproval,
    required this.createdAt,
  });

  final String id;
  final String assigneeId;
  final String description;
  final int points;
  final String difficulty;
  final String title;
  final bool isCompleted;

  /// True once a hero has submitted this task as done, but an admin
  /// hasn't approved it yet. Additive — absent/false on tasks created
  /// before this workflow existed.
  final bool pendingApproval;

  final DateTime createdAt;

  bool get isOpen => assigneeId.isEmpty;
  bool get isTaken => !isOpen && !isCompleted && !pendingApproval;

  factory Task.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    // Same fallback logic as TaskSummary.fromFirestore on the admin side:
    // prefer `status`, and only look at the legacy booleans when `status`
    // is missing (docs written before the admin panel's migration).
    final status = data['status'] as String?;

    final bool isCompleted;
    final bool pendingApproval;
    if (status != null) {
      isCompleted = status == 'completed';
      pendingApproval = status == 'pendingApproval';
    } else {
      isCompleted = data['isCompleted'] as bool? ?? false;
      pendingApproval = data['pendingApproval'] as bool? ?? false;
    }

    return Task(
      id: doc.id,
      assigneeId: data['assigneeId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      points: (data['points'] as num?)?.toInt() ?? 0,
      difficulty: data['difficulty'] as String? ?? '',
      isCompleted: isCompleted,
      pendingApproval: pendingApproval,
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'assigneeId': assigneeId,
      'title': title,
      'description': description,
      'points': points,
      'difficulty': difficulty,
      'status': _status,
      // Legacy field, kept in sync so any old query/screen still relying
      // on it during the migration keeps working.
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get _status {
    if (isCompleted) return 'completed';
    if (pendingApproval) return 'pendingApproval';
    if (assigneeId.isEmpty) return 'available';
    return 'assigned';
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}