import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_sync/models/user_model.dart';
import 'package:study_sync/providers/auth_provider.dart';

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
      loginMethod: 'registor',
      photoUrl: 'assets/icons/ic_appIcon.png',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(user.toMap());
  }

  Future<void> googleUser({required username, required phone}) async {
    User? US = _auth.currentUser;
    String uid = US!.uid;
    String email = US.email ?? '';
    String fullname = US.displayName ?? '';
    String photoUrl = US.photoURL ?? '';
    UserModel user = UserModel(
      uid: uid,
      fullname: fullname,
      username: username,
      email: email,
      phone: phone,
      loginMethod: 'google',
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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

  Future googleSingIn() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId:
            '687051857629-h4f322mvlloj96b8701nr5l220uvg9l2.apps.googleusercontent.com',
      );

      final GoogleSignInAccount gUser = await GoogleSignIn.instance
          .authenticate();

      final GoogleSignInAuthentication gAuth = gUser.authentication;

      final credential = GoogleAuthProvider.credential(idToken: gAuth.idToken);

      await _auth.signInWithCredential(credential);
      return null;
    } catch (e) {
      return e;
    }
    ;
  }

  Future logOut() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
    SharedPreferences spSet = await SharedPreferences.getInstance();

    spSet.setBool('logIn', false);
   
  }

  Future<UserModel?> getCurrentUserData() async {
    String uid = _auth.currentUser!.uid;

    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }

    return null;
  }


}
