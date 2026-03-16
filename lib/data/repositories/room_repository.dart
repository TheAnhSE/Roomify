import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class RoomRepository {
  final _db = FirebaseFirestore.instance;

  Future<List<RoomModel>> getRoomsByHotel(String hotelId) async {
    try {
      final snapshot = await _db
          .collection('rooms')
          .where('hotelId', isEqualTo: hotelId)
          .get();
      return snapshot.docs
          .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách phòng. Vui lòng thử lại.');
    }
  }

  Future<List<RoomModel>> getAvailableRooms(String hotelId) async {
    try {
      final snapshot = await _db
          .collection('rooms')
          .where('hotelId', isEqualTo: hotelId)
          .where('isAvailable', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => RoomModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách phòng trống. Vui lòng thử lại.');
    }
  }
}
