import 'package:flutter/material.dart';
import 'booking_confirmation_screen.dart';

class QrPaymentScreen extends StatelessWidget {
  final String hotelName;
  final String roomName;
  final int totalAmount;
  final int nights;

  const QrPaymentScreen({
    super.key,
    required this.hotelName,
    required this.roomName,
    required this.totalAmount,
    required this.nights,
  });

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    ) +
        ' VND';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Thông tin đơn
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotelName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(roomName,
                      style: TextStyle(color: Colors.grey.shade600)),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Số đêm'),
                      Text('$nights đêm'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng tiền',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        _formatCurrency(totalAmount),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text('Quét mã để thanh toán',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),

            // Ảnh QR tĩnh
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Image.asset(
                'assets/images/qr_bank.png',
                width: 220,
                height: 220,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 8),
            Text(
              'Chuyển khoản đúng số tiền trên',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),

            const SizedBox(height: 32),

            // Nút Confirm
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingConfirmationScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Đã thanh toán',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}// TODO Implement this library.