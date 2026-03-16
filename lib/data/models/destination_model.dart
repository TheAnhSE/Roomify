class DestinationModel {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final int hotelCount;

  DestinationModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.hotelCount,
  });

  factory DestinationModel.fromMap(Map<String, dynamic> map, String id) =>
      DestinationModel(
        id: id,
        name: map['name'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        description: map['description'] ?? '',
        hotelCount: map['hotelCount'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'imageUrl': imageUrl,
        'description': description,
        'hotelCount': hotelCount,
      };
}
