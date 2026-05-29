import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:study_sync/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser({
    required String fullname,
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async{

UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

  String uid = userCredential.user!.uid;

  UserModel user = UserModel(uid: uid, fullname: fullname, username: username, email: email, phone: phone);

  await _firestore.collection('users').doc(uid).set(user.toMap());

  }
}
