
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_sync/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ------------------------------------------------------------
  // REGISTER WITH EMAIL & PASSWORD
  // ------------------------------------------------------------
  Future<String?> registerUser({
    required String fullname,
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return 'Registration failed';
      }

      final String uid = firebaseUser.uid;

      final UserModel user = UserModel(
        uid: uid,
        fullname: fullname,
        username: username,
        email: email,
        phone: phone,
        loginMethod: 'register',
        photoUrl: 'assets/icons/ic_appIcon.png',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'This email is already registered';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email format';
      } else if (e.code == 'weak-password') {
        return 'Password is too weak';
      } else {
        return e.message ?? 'Registration failed';
      }
    } catch (e) {
      return 'Something went wrong';
    }
  }

  // ------------------------------------------------------------
  // GOOGLE USER -> FIRESTORE
  // ------------------------------------------------------------
  Future<String?> googleUser({
    required String username,
    required String phone,
  }) async {
    try {
      final User? firebaseUser = _auth.currentUser;

      if (firebaseUser == null) {
        return 'Google user is not signed in';
      }

      final String uid = firebaseUser.uid;
      final String email = firebaseUser.email ?? '';
      final String fullname = firebaseUser.displayName ?? '';
      final String photoUrl = firebaseUser.photoURL ?? '';

      final UserModel user = UserModel(
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

      await _firestore.collection('users').doc(uid).set(
            user.toMap(),
            SetOptions(merge: true),
          );

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ------------------------------------------------------------
  // EMAIL LOGIN
  // ------------------------------------------------------------
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return 'Invalid email format';
      } else if (e.code == 'user-not-found') {
        return 'No user found for this email';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password';
      } else if (e.code == 'invalid-credential') {
        return 'Invalid email or password';
      } else {
        return e.message ?? 'Login failed';
      }
    } catch (e) {
      return 'Something went wrong';
    }
  }

  // ------------------------------------------------------------
  // GOOGLE SIGN IN
  // ------------------------------------------------------------
  Future<String?> googleSignIn() async {
    try {
      // Initialize Google Sign-In.
      await GoogleSignIn.instance.initialize(
        serverClientId:
            '687051857629-h4f322mvlloj96b8701nr5l220uvg9l2.apps.googleusercontent.com',
      );

      // Open Google account selection.
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      // Get authentication information.
      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      // Make sure ID token exists.
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return 'Google Sign-In failed: ID token is null';
      }

      // Create Firebase credential.
      final AuthCredential credential =
          GoogleAuthProvider.credential(
        idToken: idToken,
      );

      // Sign in to Firebase.
      await _auth.signInWithCredential(credential);

      return null;
    } on FirebaseAuthException catch (e) {
      return 'Firebase error: ${e.message ?? e.code}';
    } on GoogleSignInException catch (e) {
      return 'Google Sign-In error: ${e.code}';
    } catch (e) {
      return 'Google Sign-In failed: $e';
    }
  }

  // ------------------------------------------------------------
  // LOGOUT
  // ------------------------------------------------------------
  Future<void> logOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn.instance.signOut();

      final SharedPreferences spSet =
          await SharedPreferences.getInstance();

      await spSet.setBool('logIn', false);
    } catch (e) {
      // You can print this while debugging.
      print('Logout error: $e');
    }
  }

  // ------------------------------------------------------------
  // GET CURRENT USER DATA
  // ------------------------------------------------------------
  Future<UserModel?> getCurrentUserData() async {
    try {
      final User? firebaseUser = _auth.currentUser;

      if (firebaseUser == null) {
        return null;
      }

      final String uid = firebaseUser.uid;

      final DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(
          doc.data() as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }
}
