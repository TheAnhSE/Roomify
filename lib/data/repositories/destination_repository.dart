import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/destination_model.dart';

class DestinationRepository {
  final _db = FirebaseFirestore.instance;

  Future<List<DestinationModel>> getDestinations() async {
    try {
      final snapshot = await _db
          .collection('destinations')
          .orderBy('name')
          .get();
      return snapshot.docs
          .map((doc) => DestinationModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách địa danh. Vui lòng thử lại.');
    }
  }
}
