import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_sync/models/Notes_model.dart';

class NotesService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> AddNotes({required String title, required String body}) async {
    String uid = _auth.currentUser!.uid;

    CollectionReference notes = await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes');

    DocumentReference idRef = notes.doc();
    String id = idRef.id;

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .get();

    int order = snapshot.docs.length;

    NotesModel note = NotesModel(
      title: title,
      body: body,
      id: id,
      order: order,
    );

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .add(note.toMap());
  }
}
