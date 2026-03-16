import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/hotel_model.dart';
import '../../data/models/room_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/booking_repository.dart';

// TODO (Người 4): Implement booking form screen theo Figma:
//   - Booking Date.jpg → date range picker + summary card
//   - Payment1.jpg     → guest info form + nút xác nhận
// - Required params: HotelModel hotel, RoomModel room, UserModel user
// - Date selection: showDateRangePicker cho checkIn / checkOut
//     firstDate: DateTime.now() — không cho chọn ngày trong quá khứ
//     Validate: checkOut phải sau checkIn, tối đa 30 đêm
//     Nếu không hợp lệ → show SnackBar "Ngày không hợp lệ"
// - Guest form: firstName, lastName, phone, email — bắt buộc hết
// - Summary card: roomName + numberOfNights + CurrencyFormatter.format(totalPrice)
// - Nút "Xác nhận đặt phòng":
//     Guard double-tap: if (_isLoading) return;
//     Show CircularProgressIndicator khi _isLoading == true
//     Thành công → BookingConfirmationScreen(booking: result)
//     Lỗi → show SnackBar với error message tiếng Việt
class BookingFormScreen extends StatefulWidget {
  final HotelModel hotel;
  final RoomModel room;
  final UserModel user;

  const BookingFormScreen({
    super.key,
    required this.hotel,
    required this.room,
    required this.user,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  // ignore: unused_field
  final _bookingRepo = BookingRepository();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _checkIn; // ignore: unused_field
  DateTime? _checkOut; // ignore: unused_field
  bool _isLoading = false;

  // ignore: unused_element
  bool _isValidDateRange(DateTime checkIn, DateTime checkOut) {
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (checkIn.isBefore(today)) return false;
    if (!checkOut.isAfter(checkIn)) return false;
    if (checkOut.difference(checkIn).inDays > 30) return false;
    return true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // TODO: implement _onConfirm() — dùng _isValidDateRange trước khi gọi BookingRepository

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Đặt phòng')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Text(
                  'BookingFormScreen\n${widget.hotel.name} — ${widget.room.roomType}\nNgười 4 implement',
                  textAlign: TextAlign.center),
            ),
    );
  }
}
