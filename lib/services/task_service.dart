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

  /// Лише вільні таски.
  ///
  /// ВАЖЛИВО: фільтруємо "вільність" на клієнті через Task.isOpen, а не
  /// через .where('isCompleted', isEqualTo: false) у запиті. Firestore
  /// виключає з результатів рівності документи, в яких поля взагалі немає
  /// (а не лише ті, де воно == true) — а квести, створені в адмінці, пишуть
  /// лише `status`, без `isCompleted`. Композитний фільтр по `isCompleted`
  /// їх просто не бачив, тому вони не показувались у "New". Фільтр по
  /// `assigneeId` лишаємо в запиті — це поле пишеться завжди й з обох боків.
  Stream<List<Task>> watchAvailableTasks() {
    return _tasks
        .where('assigneeId', isEqualTo: '')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => Task.fromFirestore(doc))
          .where((task) => !task.isCompleted && !task.pendingApproval)
          .toList(),
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

    // 1. Оновлюємо документ таски (status тримаємо в парі з assigneeId,
    //    щоб адмінка й мобільний бачили той самий стан).
    batch.update(_tasks.doc(taskId), {
      'assigneeId': userId,
      'status': 'assigned',
    });

    // 2. Збільшуємо кількість активних тасок у користувача
    final userRef = _firestore.collection('users').doc(userId);
    batch.update(userRef, {
      'activeTaskCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Здати таск на перевірку адміну.
  ///
  /// Це НЕ завершує таск і НЕ нараховує XP — таск лише переходить у
  /// 'pendingApproval' і чекає на підтвердження. Фактичне завершення,
  /// нарахування XP та оновлення лічильників користувача виконується
  /// виключно на боці адміна, у QuestBoardService.approveQuest() —
  /// свідомо єдине місце, де це відбувається, щоб герой не міг
  /// самостійно "завершити" квест і нарахувати собі очки.
  ///
  /// Якщо адмін відхилить заявку — QuestBoardService.reopenQuest()
  /// поверне таск у 'available' і зніме виконавця.
  Future<void> submitForApproval(String taskId) async {
    await _tasks.doc(taskId).update({
      'status': 'pendingApproval',
    });
  }

  /// Зняти виконавця
  Future<void> unassignTask(String taskId) async {
    await _tasks.doc(taskId).update({
      'assigneeId': '',
      'status': 'available',
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