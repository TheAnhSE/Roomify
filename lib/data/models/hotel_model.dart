class HotelModel {
  final String id;
  final String name;
  final String city;
  final String country;
  final String address;
  final List<String> imageUrls;
  final double rating;
  final double priceFrom;
  final String description;
  final List<String> amenities;
  final int stars;
  final String checkInTime;
  final String checkOutTime;
  final double? latitude;
  final double? longitude;

  HotelModel({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.address,
    required this.imageUrls,
    required this.rating,
    required this.priceFrom,
    required this.description,
    required this.amenities,
    required this.stars,
    required this.checkInTime,
    required this.checkOutTime,
    this.latitude,
    this.longitude,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  // imageUrls[0] = thumbnail. Empty list → empty string, NEVER crash
  String get thumbnailUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  factory HotelModel.fromMap(Map<String, dynamic> map, String id) => HotelModel(
        id: id,
        name: map['name'] ?? '',
        city: map['city'] ?? '',
        country: map['country'] ?? 'Việt Nam',
        address: map['address'] ?? '',
        imageUrls: List<String>.from(map['imageUrls'] ?? []),
        rating: (map['rating'] ?? 0).toDouble(),
        priceFrom: (map['priceFrom'] ?? 0).toDouble(),
        description: map['description'] ?? '',
        amenities: List<String>.from(map['amenities'] ?? []),
        stars: map['stars'] ?? 3,
        checkInTime: map['checkInTime'] ?? '14:00',
        checkOutTime: map['checkOutTime'] ?? '12:00',
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'city': city,
        'country': country,
        'address': address,
        'imageUrls': imageUrls,
        'rating': rating,
        'priceFrom': priceFrom,
        'description': description,
        'amenities': amenities,
        'stars': stars,
        'checkInTime': checkInTime,
        'checkOutTime': checkOutTime,
        'latitude': latitude,
        'longitude': longitude,
      };
}
