import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';

class TaskService {
  TaskService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _firestore.collection('tasks');

  /// Всі таски
  Stream<List<Task>> watchTasks() {
    return _tasks
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList(),
    );
  }

  /// Один таск
  Stream<Task?> watchTask(String taskId) {
    return _tasks.doc(taskId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Task.fromFirestore(doc);
    });
  }

  /// Таски конкретного користувача
  Stream<List<Task>> watchUserTasks(String userId) {
    return _tasks
        .where('assigneeId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList(),
    );
  }

  /// Лише вільні таски
  Stream<List<Task>> watchAvailableTasks() {
    return _tasks
        .where('assigneeId', isEqualTo: '')
        .where('isCompleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList(),
    );
  }

  /// Створення таска
  Future<void> createTask(Task task) async {
    await _tasks.doc(task.id).set(task.toFirestore());
  }

  /// Взяти таск
  Future<void> assignTask({
    required String taskId,
    required String userId,
  }) async {
    final batch = _firestore.batch();

    // 1. Оновлюємо документ таски
    batch.update(_tasks.doc(taskId), {
      'assigneeId': userId,
    });

    // 2. Збільшуємо кількість активних тасок у користувача
    final userRef = _firestore.collection('users').doc(userId);
    batch.update(userRef, {
      'activeTaskCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Завершити таск
  Future<void> completeTask({
    required String taskId,
    required String userId,
    required int points,
  }) async {
    final batch = _firestore.batch();

    // 1. Помічаємо таску як завершену
    batch.update(_tasks.doc(taskId), {
      'isCompleted': true,
    });

    // 2. Додаємо XP та змінюємо лічильники користувача
    final userRef = _firestore.collection('users').doc(userId);
    batch.update(userRef, {
      'xp': FieldValue.increment(points),              // Додаємо очки за завдання
      'completedTaskCount': FieldValue.increment(1),   // +1 до завершених
      'activeTaskCount': FieldValue.increment(-1),     // -1 від активних
    });

    await batch.commit();
  }

  /// Зняти виконавця
  Future<void> unassignTask(String taskId) async {
    await _tasks.doc(taskId).update({
      'assigneeId': '',
    });
  }

  /// Видалити таск
  Future<void> deleteTask(String taskId) async {
    await _tasks.doc(taskId).delete();
  }

  /// Оновити назву
  Future<void> updateTitle({
    required String taskId,
    required String title,
  }) async {
    await _tasks.doc(taskId).update({
      'title': title,
    });
  }

  /// Отримати всі таски один раз
  Future<List<Task>> getTasks() async {
    final snapshot = await _tasks
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Task.fromFirestore(doc))
        .toList();
  }

  /// Отримати один таск
  Future<Task?> getTask(String taskId) async {
    final doc = await _tasks.doc(taskId).get();

    if (!doc.exists) return null;

    return Task.fromFirestore(doc);
  }
}