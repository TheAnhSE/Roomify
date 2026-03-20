import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/hotel_model.dart';
import '../../data/models/room_model.dart';
import '../../data/models/user_model.dart';
import 'qr_payment_screen.dart';

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
  static const int _fixedNights = 2;

  int get _totalPrice => (widget.room.pricePerNight * _fixedNights).toInt();

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    ) +
        ' VND';
  }

  void _onBookNow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QrPaymentScreen(
          hotelName: widget.hotel.name,
          roomName: widget.room.roomType,
          totalAmount: _totalPrice,
          nights: _fixedNights,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Đặt phòng')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin khách sạn
            Text(widget.hotel.name,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(widget.room.roomType,
                style: TextStyle(
                    fontSize: 16, color: Colors.grey.shade600)),

            const SizedBox(height: 24),

            // Card tóm tắt
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _infoRow('Số đêm', '$_fixedNights đêm'),
                  const Divider(height: 20),
                  _infoRow(
                    'Tổng tiền',
                    _formatCurrency(_totalPrice),
                    bold: true,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Nút Book Now
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _onBookNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        Text(value,
            style: TextStyle(
                fontWeight:
                bold ? FontWeight.w700 : FontWeight.normal,
                fontSize: bold ? 16 : 14)),
      ],
    );
  }
}