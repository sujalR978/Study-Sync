class UserModel {
  final String uid;
  final String fullname;
  final String username;
  final String email;
  final String phone;
  

  UserModel({
    required this.uid,
    required this.fullname,
    required this.username,
    required this.email,
    required this.phone,
    
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullname': fullname,
      'username': username,
      'email': email,
      'phone': phone,
      
    };
  }
}
