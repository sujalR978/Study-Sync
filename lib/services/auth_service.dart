import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = userCredential.user!.uid;

    UserModel user = UserModel(
      uid: uid,
      fullname: fullname,
      username: username,
      email: email,
      phone: phone,
    );

    await _firestore.collection('users').doc(uid).set(user.toMap());
  }

  Future loginUser({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return "Invalid email format";
      } else if (e.code == 'user-not-found') {
        return "No user found for this email";
      } else if (e.code == 'wrong-password') {
        return "Wrong password";
      } else {
        return "Login failed";
      }
    } catch (e) {
      return 'Somthing want wrong';
    }
  }
}
