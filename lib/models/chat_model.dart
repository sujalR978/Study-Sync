import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String roal;
  String content;

  Timestamp timestamp;

  ChatModel({
    required this.roal,
    required this.content,

    required this.timestamp,
  });

  Map<String, String> toMap() {
    return {
      'roal': roal,
      'content': content,

      'timestamp': timestamp.toString(),
    };
  }
}
