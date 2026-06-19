import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:study_sync/models/Task_model.dart';

class TaskService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTask({
    required String title,
    required String description,
    required String category,
    required String priority,
    required DateTime dueDate,
    required String dueTime,
  }) async {
    String uid = _auth.currentUser!.uid;

    // get Task id
    CollectionReference Task = _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks');
    DocumentReference docRef = Task.doc();
    String id = docRef.id;

    // get order for reorderabel list
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .get();

    int order = snapshot.docs.length;

    TaskModel task = TaskModel(
      id: id,
      title: title,
      description: description,
      category: category,
      priority: priority, 
      dueDate: dueDate,
      dueTime: dueTime,
      isCompleted: false,
      order: order,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(id)
        .set(task.TaskMap());
  }

  Stream<QuerySnapshot> getTask() {
    String uid = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .orderBy('order')
        .snapshots();
  }

  Future<void> updateTaskOrder(String taskId, int newIndex) async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskId)
        .update({'order': newIndex});
  }

  Future<void> updateTaskComplete(String taskId, bool iscompleted) async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskId)
        .update({'isCompleted': iscompleted, 'updatedAt': DateTime.now()});
  }

  Future<void> taskDelete(String taskid) async {
    String uid = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskid)
        .delete();
  }

  Future<void> updateTask({
    required title,
    required description,
    required category,
    required priority,
    required dueDate,
    required dueTime,
    required updatedAt,
    required taskid,
  }) async {
    String uid = _auth.currentUser!.uid;

    updateTaskModel task = updateTaskModel(
      title: title,
      description: description,
      category: category,
      priority: priority,
      dueDate: dueDate,
      dueTime: dueTime,
      updatedAt: updatedAt,
    );

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskid)
        .update(task.toMap());
  }
}
