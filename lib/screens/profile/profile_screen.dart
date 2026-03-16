import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/models/user_model.dart';

// TODO (Người 5): Implement profile screen theo Figma page-0022 ~ page-0024
// - Required param: UserModel user
// - Header: buildAvatar(user, radius: 40) + fullName + email
// - Nút "Đăng xuất" → AuthRepository.logout() → navigate đến LoginScreen
//     (dùng Navigator.pushAndRemoveUntil để xoá hết stack)
// - Section "Lịch sử đặt phòng": ListView của BookingHistoryCard
//     BookingHistoryCard: hotelName + DateFormatter.format(dates) + confirmationCode
//     Status badge: xanh = "confirmed", đỏ = "cancelled", xám = "completed"
//     Nút "Huỷ" chỉ hiện khi status == "confirmed" → gọi BookingRepository.cancelBooking
// - Mọi Firestore call phải có try/catch với error message tiếng Việt
// - Phải có CircularProgressIndicator khi _isLoading == true
class ProfileScreen extends StatefulWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ignore: unused_field
  final _authRepo = AuthRepository();
  // ignore: unused_field
  final _bookingRepo = BookingRepository();
  bool _isLoading = false;

  // TODO: implement _loadBookings() trong initState
  // TODO: implement _onLogout()
  // TODO: implement _onCancelBooking(bookingId)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Text(
                  'ProfileScreen\n${widget.user.fullName}\nNgười 5 implement',
                  textAlign: TextAlign.center),
            ),
    );
  }
}
