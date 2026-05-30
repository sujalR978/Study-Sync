class UserModel {
  final String uid;
  final String fullname;
  final String username;
  final String email;
  final String phone;
  final String loginMethod;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.fullname,
    required this.username,
    required this.email,
    required this.phone,
    required this.loginMethod,
    required this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullname': fullname,
      'username': username,
      'email': email,
      'phone': phone,
      'loginMethod': loginMethod,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,

    };
  }
}


