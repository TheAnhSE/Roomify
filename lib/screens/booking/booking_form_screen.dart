import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/hotel_model.dart';
import '../../data/models/room_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/booking_repository.dart';

// TODO (Member 4): Implement booking form screen based on Figma:
//   - Booking Date.jpg -> date range picker + summary card
//   - Payment1.jpg     -> guest info form + confirm button
// - Required params: HotelModel hotel, RoomModel room, UserModel user
// - Date selection: showDateRangePicker for checkIn/checkOut
//     firstDate: DateTime.now() - no past date
//     Validate: checkOut must be after checkIn, max 30 nights
//     Invalid -> show SnackBar "Invalid date"
// - Guest form: firstName, lastName, phone, email - all required
// - Summary card: roomName + numberOfNights + CurrencyFormatter.format(totalPrice)
// - "Confirm booking" button:
//     Guard double-tap: if (_isLoading) return;
//     Show CircularProgressIndicator khi _isLoading == true
//     Success -> BookingConfirmationScreen(booking: result)
//     Error -> show SnackBar with message
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

  // TODO: implement _onConfirm() and validate date range first

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Book room')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Text(
                  'BookingFormScreen\n${widget.hotel.name} - ${widget.room.roomType}\nMember 4 implement',
                  textAlign: TextAlign.center),
            ),
    );
  }
}
