import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/booking_model.dart';

// TODO (Member 4): Implement booking confirmation screen based on Figma:
//   - Payment2.jpg -> success confirmation screen (check icon, code, summary)
// - Required param: BookingModel booking
// - Large green check_circle icon at the top
// - Bold, large confirmationCode
// - Summary: hotelName, roomName, DateFormatter.format(checkIn/checkOut), CurrencyFormatter.format(totalPrice)
// - "Back to Home" button -> Navigator.pushAndRemoveUntil to MainScreen
class BookingConfirmationScreen extends StatelessWidget {
  final BookingModel booking;
  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text('BookingConfirmationScreen - Member 4 implement'),
      ),
    );
  }
}
