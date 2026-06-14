import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_sync/models/chat_image_model.dart';
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

  Stream<QuerySnapshot> getChat() {
    String uid = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> addImageChat({
    required String roal,
    required String content,
    required String images,
    required Timestamp timestamp,
  }) async {
    String uid = _auth.currentUser!.uid;

    chatImageModel chat = chatImageModel(
      roal: roal,
      content: content,
      images: images,
      timestamp: timestamp,
    );

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .add(chat.toMap());
  }

  Stream<QuerySnapshot> getImageChat() {
    String uid = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('chats')
        .orderBy('timestamp')
        .snapshots();
  }
}
