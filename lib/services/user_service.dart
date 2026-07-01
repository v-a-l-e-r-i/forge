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

  Future<List<Team>> getTeams() async {
    final snapshot = await _teams.orderBy('name').get();
    return snapshot.docs.map(Team.fromFirestore).toList();
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
}
