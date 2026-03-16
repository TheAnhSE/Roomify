import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/booking_model.dart';

// TODO (Người 4): Implement booking confirmation screen theo Figma:
//   - Payment2.jpg → màn hình xác nhận thành công (icon check, confirmation code, tóm tắt)
// - Required param: BookingModel booking
// - Icon check_circle lớn màu xanh lá ở trên cùng
// - confirmationCode in đậm, chữ to
// - Tóm tắt: hotelName, roomName, DateFormatter.format(checkIn/checkOut), CurrencyFormatter.format(totalPrice)
// - Nút "Về trang chủ" → Navigator.pushAndRemoveUntil đến MainScreen (xoá hết stack)
class BookingConfirmationScreen extends StatelessWidget {
  final BookingModel booking;
  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text('BookingConfirmationScreen — Người 4 implement'),
      ),
    );
  }
}
