import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel_model.dart';

class HotelRepository {
  final _db = FirebaseFirestore.instance;

  Future<List<HotelModel>> getHotels() async {
    try {
      final snapshot = await _db.collection('hotels').get();
      return snapshot.docs
          .map((doc) => HotelModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách khách sạn. Vui lòng thử lại.');
    }
  }

  Future<List<HotelModel>> getHotelsByCity(String city) async {
    try {
      final snapshot = await _db
          .collection('hotels')
          .where('city', isEqualTo: city)
          .get();
      return snapshot.docs
          .map((doc) => HotelModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể tải khách sạn theo thành phố. Vui lòng thử lại.');
    }
  }

  Future<List<HotelModel>> searchHotels(String query) async {
    try {
      final snapshot = await _db.collection('hotels').get();
      final all = snapshot.docs
          .map((doc) => HotelModel.fromMap(doc.data(), doc.id))
          .toList();
      if (query.isEmpty) return all;
      final lower = query.toLowerCase();
      return all
          .where((hotel) => hotel.name.toLowerCase().contains(lower))
          .toList();
    } catch (e) {
      throw Exception('Không thể tìm kiếm khách sạn. Vui lòng thử lại.');
    }
  }

  Future<HotelModel?> getHotelById(String hotelId) async {
    try {
      final doc = await _db.collection('hotels').doc(hotelId).get();
      if (!doc.exists || doc.data() == null) return null;
      return HotelModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Không thể tải thông tin khách sạn. Vui lòng thử lại.');
    }
  }
}
