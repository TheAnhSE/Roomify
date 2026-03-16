import 'package:cloud_firestore/cloud_firestore.dart';
import 'guest_model.dart';

class BookingModel {
  final String id;
  final String userId;
  final String hotelId;
  final String hotelName;
  final String roomId;
  final String roomName;
  final DateTime checkIn;
  final DateTime checkOut;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final String confirmationCode;
  final GuestModel guest;

  BookingModel({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.hotelName,
    required this.roomId,
    required this.roomName,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.confirmationCode,
    required this.guest,
  });

  int get numberOfNights => checkOut.difference(checkIn).inDays;

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) =>
      BookingModel(
        id: id,
        userId: map['userId'] ?? '',
        hotelId: map['hotelId'] ?? '',
        hotelName: map['hotelName'] ?? '',
        roomId: map['roomId'] ?? '',
        roomName: map['roomName'] ?? '',
        // Null-check Timestamp before casting — direct cast crashes if field missing
        checkIn: map['checkIn'] != null
            ? (map['checkIn'] as Timestamp).toDate()
            : DateTime.now(),
        checkOut: map['checkOut'] != null
            ? (map['checkOut'] as Timestamp).toDate()
            : DateTime.now().add(const Duration(days: 1)),
        createdAt: map['createdAt'] != null
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        totalPrice: (map['totalPrice'] ?? 0).toDouble(),
        status: map['status'] ?? 'confirmed',
        confirmationCode: map['confirmationCode'] ?? '',
        guest: GuestModel.fromMap(map['guest'] ?? {}),
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'hotelId': hotelId,
        'hotelName': hotelName,
        'roomId': roomId,
        'roomName': roomName,
        'checkIn': Timestamp.fromDate(checkIn),
        'checkOut': Timestamp.fromDate(checkOut),
        'totalPrice': totalPrice,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        'confirmationCode': confirmationCode,
        'guest': guest.toMap(),
      };
}
