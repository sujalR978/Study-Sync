import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_sync/models/Notes_model.dart';

class NotesService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> AddNotes({required String title, required String body}) async {
    String uid = _auth.currentUser!.uid;

    NotesModel notes = NotesModel(title: title, body: body);

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .add(notes.toMap());
  }
}
