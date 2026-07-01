import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document: `characters/{userId}` (1 → 1 with user)
class Character {
  const Character({
    required this.userId,
    required this.name,
    required this.slogan,
    required this.level,
    required this.abilities,
    required this.createdAt,
    required this.avatarUrl,
  });

  final String userId;
  final String name;
  final String slogan;
  final int level;
  final List<String> abilities;
  final DateTime createdAt;
  final String avatarUrl;

  factory Character.newForRegistration({
    required String userId,
    required String name,
    required String slogan,
    required String avatarUrl,
    required String abilitiesText,
  }) {
    return Character(
      userId: userId,
      name: name,
      slogan: slogan,
      level: 1,
      abilities: abilitiesText
          .split(' ')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      createdAt: DateTime.now(),
      avatarUrl: avatarUrl,
    );
  }

  factory Character.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return Character(
      userId: doc.id,
      name: data['name'] as String? ?? '',
      slogan: data['slogan'] as String? ?? '',
      level: data['level'] as int? ?? 1,
      abilities: List<String>.from(data['abilities'] ?? []),
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      avatarUrl: data['avatarUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'slogan': slogan,
      'level': level,
      'abilities': abilities,
      'createdAt': Timestamp.fromDate(createdAt),
      'avatarUrl': avatarUrl,
    };
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
