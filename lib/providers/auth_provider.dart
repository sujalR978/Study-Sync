import 'package:flutter/material.dart';
import 'package:study_sync/models/user_model.dart';


class Authprovider extends ChangeNotifier {


  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel userData) {
    _user = userData;
    notifyListeners();
  }

  void clearUser() { 
    _user = null;
    notifyListeners();
  }
}
