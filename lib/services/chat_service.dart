import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_sync/models/chat_model.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addChat({
    required String roal,
    required String content,
    required Timestamp timestamp,
  }) async {
    String uid = _auth.currentUser!.uid;

    ChatModel chat = ChatModel(
      roal: roal,
      content: content,
      timestamp: timestamp,
    );

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .add(chat.toMap());
  }

 
}
