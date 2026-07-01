import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_role.dart';

/// Firestore document: `users/{uid}`
class AppUser {
  const AppUser({
    required this.id,
    required this.nickname,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.name,
    required this.email,
    required this.role,
    required this.level,
    required this.xp,
    this.teamId,
    required this.activeTaskCount,
    required this.completedTaskCount,
    required this.createdAt,
  });

  final String id;
  final String nickname;
  final String firstName;
  final String middleName;
  final String lastName;
  final String name;
  final String email;
  final UserRole role;
  final int level;
  final int xp;
  final String? teamId;
  final int activeTaskCount;
  final int completedTaskCount;
  final DateTime createdAt;

  factory AppUser.newRegistration({
    required String id,
    required String nickname,
    required String firstName,
    required String middleName,
    required String lastName,
    required String authEmail,
    String? teamId,
    String? avatarUrl,
  }) {
    final name = '$firstName $lastName'.trim();
    return AppUser(
      id: id,
      nickname: nickname,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      name: name.isEmpty ? nickname : name,
      email: authEmail,
      role: UserRole.employee,
      level: 1,
      xp: 0,
      teamId: teamId,
      activeTaskCount: 0,
      completedTaskCount: 0,
      createdAt: DateTime.now(),
    );
  }

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      id: doc.id,
      nickname: data['nickname'] as String? ?? '',
      firstName: data['firstName'] as String? ?? '',
      middleName: data['middleName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: UserRole.fromFirestore(data['role'] as String? ?? 'employee'),
      level: data['level'] as int? ?? 1,
      xp: data['xp'] as int? ?? 0,
      teamId: data['teamId'] as String?,
      activeTaskCount: data['activeTaskCount'] as int? ?? 0,
      completedTaskCount: data['completedTaskCount'] as int? ?? 0,
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nickname': nickname,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'name': name,
      'email': email,
      'role': role.toFirestore(),
      'level': level,
      'xp': xp,
      'teamId': teamId,
      'activeTaskCount': activeTaskCount,
      'completedTaskCount': completedTaskCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
