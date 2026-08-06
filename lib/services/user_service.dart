import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../models/character.dart';
import '../models/team.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _characters =>
      _firestore.collection('characters');

  CollectionReference<Map<String, dynamic>> get _teams =>
      _firestore.collection('teams');

  Future<void> createUserWithCharacter({
    required AppUser user,
    required Character character,
  }) async {
    final batch = _firestore.batch();
    batch.set(_users.doc(user.id), user.toFirestore());
    batch.set(_characters.doc(character.userId), character.toFirestore());
    await batch.commit();
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    });
  }

  /// Усі герої компанії — для сторінки "Герої" (перегляд усіх/по команді).
  /// Правило безпеки на `users` дозволяє читання всієї колекції будь-якому
  /// залогіненому юзеру (`allow read: if request.auth != null`), тож
  /// звичайний список без where-фільтра тут безпечний.
  Stream<List<AppUser>> watchAllUsers() {
    return _users.snapshots().map(
          (snapshot) => snapshot.docs.map(AppUser.fromFirestore).toList(),
    );
  }

  Future<List<Team>> getTeams() async {
    final snapshot = await _teams.orderBy('name').get();
    return snapshot.docs.map(Team.fromFirestore).toList();
  }

  Stream<Team?> watchTeam(String teamId) {
    if (teamId.isEmpty) return Stream.value(null);
    return _teams.doc(teamId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Team.fromFirestore(doc);
    });
  }

  Future<Character?> getCharacter(String uid) async {
    final doc = await _characters.doc(uid).get();
    if (!doc.exists) return null;
    return Character.fromFirestore(doc);
  }

  Stream<Character?> watchCharacter(String uid) {
    return _characters.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Character.fromFirestore(doc);
    });
  }

  /// uid → Character для всіх героїв одразу — використовується сторінкою
  /// "Герої", щоб не робити окремий стрім на кожен рядок списку.
  Stream<Map<String, Character>> watchAllCharacters() {
    return _characters.snapshots().map(
          (snapshot) => {
        for (final doc in snapshot.docs) doc.id: Character.fromFirestore(doc),
      },
    );
  }
}