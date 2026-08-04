import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotesService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- ADD NOTES (Upgraded with Subject Tags & Timestamp) ---
  Future<void> AddNotes({
    required String title,
    required String body,
    required String subject, // NEW: Added subject parameter for Tags
  }) async {
    String uid = _auth.currentUser!.uid;

    CollectionReference notes = _firestore
        .collection('users')
        .doc(uid)
        .collection('notes');

    // Generate a unique Document ID
    DocumentReference idRef = notes.doc();
    String id = idRef.id;

    // Get the current order count
    QuerySnapshot snapshot = await notes.get();
    int order = snapshot.docs.length;

    // Create the note data map directly to include new fields effortlessly
    Map<String, dynamic> noteData = {
      'id': id,
      'title': title,
      'body': body,
      'subject': subject, // Saving the tag
      'order': order,
      'timestamp':
          FieldValue.serverTimestamp(), // Important for date display in Shownotes
    };

    // BUG FIX: Using .set() on idRef instead of .add()
    // This ensures the document ID matches the 'id' field exactly.
    await idRef.set(noteData);
  }

  // --- GET NOTES ---
  Stream<QuerySnapshot<Map<String, dynamic>>> getNotes() {
    String uid = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .orderBy('order')
        .snapshots();
  }

  // --- DELETE NOTES ---
  Future<void> DeleteNotes(String noteId) async {
    String uid = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  // --- EDIT NOTES (Upgraded to optionally update subject) ---
  Future<void> EditNotes({
    required String title,
    required String body,
    required String taskId,
    String? subject,
  }) async {
    String uid = _auth.currentUser!.uid;

    Map<String, dynamic> updateData = {
      'title': title,
      'body': body,
      // You can add a 'lastEdited' timestamp here if you want to track edits
      'lastEdited': FieldValue.serverTimestamp(),
    };

    if (subject != null) {
      updateData['subject'] = subject;
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(taskId)
        .update(updateData);
  }
}
