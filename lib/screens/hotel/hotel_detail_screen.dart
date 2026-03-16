import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/hotel_model.dart';
import '../../data/repositories/room_repository.dart';

// TODO (Người 4): Implement hotel detail screen theo Figma:
//   - Detail.jpg → layout chính (image gallery, thông tin, tiện nghi, danh sách phòng)
// - Required param: HotelModel hotel
// - PageView của hotel.imageUrls — swipeable, có dot indicator
// - Thông tin khách sạn: name, hàng sao (Icon), rating, address, checkIn/checkOut time
// - Tiện nghi: Wrap của Chip widgets (hotel.amenities)
// - Danh sách phòng: ListView của RoomCard (gọi RoomRepository.getAvailableRooms)
//     RoomCard: thumbnailUrl + roomType + roomNumber + CurrencyFormatter.format(pricePerNight) + capacity
//     Nút "Đặt ngay" → BookingFormScreen(hotel: hotel, room: room, user: user)
// - Mọi Firestore call phải có try/catch với error message tiếng Việt
// - Phải có CircularProgressIndicator khi _isLoading == true
class HotelDetailScreen extends StatefulWidget {
  final HotelModel hotel;
  const HotelDetailScreen({super.key, required this.hotel});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  // ignore: unused_field
  final _roomRepo = RoomRepository();
  bool _isLoading = false;

  // TODO: implement _loadRooms() trong initState

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.hotel.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : const Center(
              child: Text('HotelDetailScreen — Người 4 implement'),
            ),
    );
  }
}
