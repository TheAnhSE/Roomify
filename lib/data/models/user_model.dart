class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String? photoUrl; // URL ảnh đại diện từ Firebase Storage (nullable)

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    this.photoUrl,
  });

  // First letter of fullName uppercased — used as avatar initials everywhere
  String get initials =>
      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

  factory UserModel.fromMap(Map<String, dynamic> map, String id) => UserModel(
        id: id,
        email: map['email'] ?? '',
        fullName: map['fullName'] ?? '',
        phone: map['phone'] ?? '',
        photoUrl: map['photoUrl'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'email': email,
        'fullName': fullName,
        'phone': phone,
        'photoUrl': photoUrl,
      };
}
