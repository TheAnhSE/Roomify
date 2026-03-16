class RoomModel {
  final String id;
  final String hotelId;
  final String roomNumber;
  final String roomType;
  final double pricePerNight;
  final int capacity;
  final List<String> imageUrls;
  final bool isAvailable;
  final List<String> amenities;

  RoomModel({
    required this.id,
    required this.hotelId,
    required this.roomNumber,
    required this.roomType,
    required this.pricePerNight,
    required this.capacity,
    required this.imageUrls,
    required this.isAvailable,
    required this.amenities,
  });

  // Same pattern as HotelModel — first image or empty string
  String get thumbnailUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  factory RoomModel.fromMap(Map<String, dynamic> map, String id) => RoomModel(
        id: id,
        hotelId: map['hotelId'] ?? '',
        roomNumber: map['roomNumber'] ?? '',
        roomType: map['roomType'] ?? 'Standard',
        pricePerNight: (map['pricePerNight'] ?? 0).toDouble(),
        capacity: map['capacity'] ?? 2,
        imageUrls: List<String>.from(map['imageUrls'] ?? []),
        isAvailable: map['isAvailable'] ?? true,
        amenities: List<String>.from(map['amenities'] ?? []),
      );

  Map<String, dynamic> toMap() => {
        'hotelId': hotelId,
        'roomNumber': roomNumber,
        'roomType': roomType,
        'pricePerNight': pricePerNight,
        'capacity': capacity,
        'imageUrls': imageUrls,
        'isAvailable': isAvailable,
        'amenities': amenities,
      };
}
