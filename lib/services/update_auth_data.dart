import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_sync/models/update_model.dart';

class UpdateAuthData {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateAuthData ( {
    required fullname,
    required username,
    required phone,
    required photoUrl,
     
  }) async{
    String uid = _auth.currentUser!.uid;

    UpdateProfileData updateUser = UpdateProfileData(
      fullname: fullname,
      username: username,
      phone: phone,
      photoUrl: photoUrl,
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(uid)
        .update(updateUser.updateMap());
  }
}
