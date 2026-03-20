import 'package:flutter/material.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle,
                  color: Colors.green, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Đặt phòng thành công!',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Chúng tôi sẽ xác nhận và sẽ liên hệ với bạn trong vài phút tới.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Về màn hình chính
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Về trang chủ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}