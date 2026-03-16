class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
  });

  // First letter of fullName uppercased — used as avatar initials everywhere
  String get initials =>
      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

  factory UserModel.fromMap(Map<String, dynamic> map, String id) => UserModel(
        id: id,
        email: map['email'] ?? '',
        fullName: map['fullName'] ?? '',
        phone: map['phone'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'email': email,
        'fullName': fullName,
        'phone': phone,
      };
}
