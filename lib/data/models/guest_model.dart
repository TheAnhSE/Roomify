class GuestModel {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String country;
  final String city;
  final String address;

  GuestModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.country,
    required this.city,
    required this.address,
  });

  factory GuestModel.fromMap(Map<String, dynamic> map) => GuestModel(
        firstName: map['firstName'] ?? '',
        lastName: map['lastName'] ?? '',
        phone: map['phone'] ?? '',
        email: map['email'] ?? '',
        country: map['country'] ?? '',
        city: map['city'] ?? '',
        address: map['address'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'country': country,
        'city': city,
        'address': address,
      };
}
