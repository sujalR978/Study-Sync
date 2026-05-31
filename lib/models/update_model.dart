class UpdateProfileData {
  final String fullname;
  final String username;
  final String phone;
  final String photoUrl;
  final DateTime updatedAt;
  UpdateProfileData({
    required this.fullname,
    required this.username,
    required this.phone,
    required this.photoUrl,
    required this.updatedAt,
  });

  Map<String, dynamic> updateMap() {
    return {
      'fullname': fullname,
      'username': username,
      'phone': phone,
      'photoUrl': photoUrl,
      'updatedAt': updatedAt,
    };
  }
}