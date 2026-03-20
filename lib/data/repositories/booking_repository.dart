import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/guest_model.dart';
import '../models/hotel_model.dart';
import '../models/room_model.dart';

class BookingRepository {
  final _db = FirebaseFirestore.instance;

  /// Tạo booking với status pending — không khoá phòng.
  Future<BookingModel> createPendingBooking({
    required String userId,
    required HotelModel hotel,
    required RoomModel room,
    required GuestModel guest,
  }) async {
    try {
      final bookingRef = _db.collection('bookings').doc();
      final checkIn = DateTime.now();
      final checkOut = DateTime.now().add(const Duration(days: 1));
      final totalPrice = room.pricePerNight * checkOut.difference(checkIn).inDays;
      final roomName = '${room.roomNumber} - ${room.roomType}';

      final prefix = userId.length >= 4
          ? userId.substring(0, 4).toUpperCase()
          : userId.toUpperCase();
      final confirmationCode =
          'BK-$prefix-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final booking = BookingModel(
        id: bookingRef.id,
        userId: userId,
        hotelId: hotel.id,
        hotelName: hotel.name,
        roomId: room.id,
        roomName: roomName,
        checkIn: checkIn,
        checkOut: checkOut,
        totalPrice: totalPrice,
        status: 'pending',
        createdAt: DateTime.now(),
        confirmationCode: confirmationCode,
        guest: guest,
      );

      await bookingRef.set(booking.toMap());
      return booking;
    } on FirebaseException catch (e) {
      throw Exception('Tạo đặt phòng thất bại: ${e.message ?? "Vui lòng thử lại."}');
    } catch (e) {
      rethrow;
    }
  }

  /// Cập nhật ngày và xác nhận booking — khoá phòng.
  Future<BookingModel> updateBookingDates({
    required String bookingId,
    required DateTime checkIn,
    required DateTime checkOut,
    required double pricePerNight,
  }) async {
    try {
      final bookingRef = _db.collection('bookings').doc(bookingId);
      final totalPrice = pricePerNight * checkOut.difference(checkIn).inDays;

      await _db.runTransaction((transaction) async {
        final bookingSnap = await transaction.get(bookingRef);
        final data = bookingSnap.data();
        if (data == null) throw Exception('Không tìm thấy thông tin đặt phòng.');

        final roomId = data['roomId'] as String?;
        if (roomId == null) throw Exception('Không tìm thấy thông tin phòng.');

        final roomRef = _db.collection('rooms').doc(roomId);
        final roomSnap = await transaction.get(roomRef);
        if (roomSnap.data()?['isAvailable'] == false) {
          throw Exception('Phòng hiện không khả dụng');
        }

        transaction.update(bookingRef, {
          'checkIn': Timestamp.fromDate(checkIn),
          'checkOut': Timestamp.fromDate(checkOut),
          'totalPrice': totalPrice,
          'status': 'confirmed',
        });
        transaction.update(roomRef, {'isAvailable': false});
      });

      final snap = await bookingRef.get();
      final data = snap.data();
      if (data == null) throw Exception('Không tìm thấy thông tin đặt phòng.');
      return BookingModel.fromMap(data, bookingId);
    } on FirebaseException catch (e) {
      throw Exception('Xác nhận đặt phòng thất bại: ${e.message ?? "Vui lòng thử lại."}');
    } catch (e) {
      rethrow;
    }
  }

  // createBooking dùng Firestore Transaction để tránh double booking
  Future<BookingModel> createBooking({
    required String userId,
    required HotelModel hotel,
    required RoomModel room,
    required DateTime checkIn,
    required DateTime checkOut,
    required GuestModel guest,
  }) async {
    try {
      final roomRef = _db.collection('rooms').doc(room.id);
      final bookingRef = _db.collection('bookings').doc();

      // Confirmation code: "BK-XXXX-XXXXXXX" — prefix từ userId tránh trùng
      final prefix = userId.length >= 4
          ? userId.substring(0, 4).toUpperCase()
          : userId.toUpperCase();
      final confirmationCode =
          'BK-$prefix-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final totalPrice =
          room.pricePerNight * checkOut.difference(checkIn).inDays;
      final roomName = '${room.roomNumber} - ${room.roomType}';

      return await _db.runTransaction((transaction) async {
        // Đọc room trong transaction — đảm bảo atomic check-and-set
        final roomSnap = await transaction.get(roomRef);
        if (roomSnap.data()?['isAvailable'] == false) {
          throw Exception('Phòng hiện không khả dụng');
        }

        final booking = BookingModel(
          id: bookingRef.id,
          userId: userId,
          hotelId: hotel.id,
          hotelName: hotel.name,
          roomId: room.id,
          roomName: roomName,
          checkIn: checkIn,
          checkOut: checkOut,
          totalPrice: totalPrice,
          status: 'confirmed',
          createdAt: DateTime.now(),
          confirmationCode: confirmationCode,
          guest: guest,
        );

        transaction.set(bookingRef, booking.toMap());
        // Khoá phòng ngay — ngăn booking khác trong khi transaction chạy
        transaction.update(roomRef, {'isAvailable': false});

        return booking;
      });
    } on FirebaseException catch (e) {
      throw Exception('Đặt phòng thất bại: ${e.message ?? "Vui lòng thử lại."}');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BookingModel>> getBookingsByUser(String userId) async {
    try {
      final snapshot = await _db
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể tải lịch sử đặt phòng. Vui lòng thử lại.');
    }
  }

  // cancelBooking dùng Transaction để mở khoá phòng một cách atomic
  Future<void> cancelBooking(String bookingId) async {
    try {
      final bookingRef = _db.collection('bookings').doc(bookingId);

      await _db.runTransaction((transaction) async {
        final bookingSnap = await transaction.get(bookingRef);
        final roomId = bookingSnap.data()?['roomId'] as String?;

        // Cập nhật trạng thái booking
        transaction.update(bookingRef, {'status': 'cancelled'});

        // Mở khoá phòng để người khác có thể đặt — KHÔNG được bỏ qua
        if (roomId != null) {
          transaction.update(
            _db.collection('rooms').doc(roomId),
            {'isAvailable': true},
          );
        }
      });
    } on FirebaseException catch (e) {
      throw Exception('Huỷ phòng thất bại: ${e.message ?? "Vui lòng thử lại."}');
    } catch (e) {
      throw Exception('Huỷ phòng thất bại. Vui lòng thử lại.');
    }
  }
}
