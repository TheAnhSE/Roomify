import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/room_repository.dart';
import 'booking_success_screen.dart';

/// Màn xác nhận thông tin trước thanh toán.
class BookingConfirmationScreen extends StatefulWidget {
  final BookingModel booking;
  final DateTime checkIn;
  final DateTime checkOut;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final _bookingRepo = BookingRepository();
  final _roomRepo = RoomRepository();
  bool _isLoading = false;

  int get _numberOfNights =>
      widget.checkOut.difference(widget.checkIn).inDays;

  double get _totalPrice {
    // Use booking's existing totalPrice as base for pricePerNight calc
    final nights = widget.booking.checkOut.difference(widget.booking.checkIn).inDays;
    if (nights <= 0) return 0;
    final pricePerNight = widget.booking.totalPrice / nights;
    return pricePerNight * _numberOfNights;
  }

  Future<void> _onPay() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final room = await _roomRepo.getRoomById(widget.booking.roomId);
      if (room == null) {
        throw Exception('Không tìm thấy thông tin phòng.');
      }

      final updated = await _bookingRepo.updateBookingDates(
        bookingId: widget.booking.id,
        checkIn: widget.checkIn,
        checkOut: widget.checkOut,
        pricePerNight: room.pricePerNight,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingSuccessScreen(booking: updated),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final guest = widget.booking.guest;
    final guestName = '${guest.firstName} ${guest.lastName}'.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
        title: const Text(
          'Xác nhận đặt phòng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Kiểm tra thông tin trước khi thanh toán',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSummaryCard(
                      'Khách sạn',
                      widget.booking.hotelName,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      'Phòng',
                      widget.booking.roomName,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      'Ngày đặt',
                      '${DateFormatter.format(widget.checkIn)} → ${DateFormatter.format(widget.checkOut)}',
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      'Khách',
                      guestName.isNotEmpty ? guestName : guest.email,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      'Số đêm',
                      '$_numberOfNights đêm',
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng tiền',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(_totalPrice),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onPay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text('Thanh toán'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
