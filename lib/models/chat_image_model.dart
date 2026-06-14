import 'package:cloud_firestore/cloud_firestore.dart';

class chatImageModel {
  String roal;
  String content;
  String images;
  Timestamp timestamp;

  chatImageModel({
    required this.roal,
    required this.content,
    required this.images,
    required this.timestamp,
  });

  Map<String, String> toMap() {
    return {
      'roal': roal,
      'content': content,
      'images': images,
      'timestamp': timestamp.toString(),
    };
  }
}
