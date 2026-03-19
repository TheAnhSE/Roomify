import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/hotel_model.dart';
import '../../data/models/room_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/room_repository.dart';
import '../booking/booking_form_screen.dart';

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
  final _roomRepo = RoomRepository();
  final _authRepo = AuthRepository();
  final _pageCtrl = PageController();

  List<RoomModel> _rooms = [];
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final rooms = await _roomRepo.getAvailableRooms(widget.hotel.id);
      final user = await _authRepo.getCurrentUser();
      if (mounted) {
        setState(() {
          _rooms = rooms;
          _currentUser = user;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onBookNow(RoomModel room) {
    final user = _currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingFormScreen(
          hotel: widget.hotel,
          room: room,
          user: user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: _buildImageGallery(hotel)),
                        SliverToBoxAdapter(child: _buildHotelInfo(hotel)),
                        SliverToBoxAdapter(child: _buildAmenities(hotel)),
                        SliverToBoxAdapter(child: _buildRoomsSection()),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildImageGallery(HotelModel hotel) {
    final imageUrls = hotel.imageUrls;
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: 260,
              width: double.infinity,
              child: imageUrls.isEmpty
                  ? Container(
                      color: AppColors.surfaceDark,
                      child: const Center(
                        child: Icon(Icons.image_outlined, color: Colors.white70, size: 40),
                      ),
                    )
                  : PageView.builder(
                      controller: _pageCtrl,
                      itemCount: imageUrls.length,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: imageUrls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.surfaceDark,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surfaceDark,
                            child: const Center(
                              child: Icon(Icons.broken_image_outlined,
                                  color: Colors.white70, size: 40),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
        if (imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageUrls.length, (index) {
                final isActive = _currentImageIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildHotelInfo(HotelModel hotel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hotel.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(
                hotel.stars,
                (index) => const Padding(
                  padding: EdgeInsets.only(right: 2),
                  child: Icon(Icons.star, size: 16, color: AppColors.star),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${hotel.rating.toStringAsFixed(1)} rating',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${hotel.address}, ${hotel.city}, ${hotel.country}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.login, 'Check-in ${hotel.checkInTime}'),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.logout, 'Check-out ${hotel.checkOutTime}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hotel.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAmenities(HotelModel hotel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiện nghi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: hotel.amenities.map((a) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.surfaceDark),
                ),
                child: Text(
                  a,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phòng còn trống',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (_rooms.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Hiện chưa có phòng trống.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else
            Column(
              children: _rooms.map((room) => _buildRoomCard(room)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(RoomModel room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: room.thumbnailUrl,
              width: 88,
              height: 88,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 88,
                height: 88,
                color: AppColors.surfaceDark,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 88,
                height: 88,
                color: AppColors.surfaceDark,
                child: const Icon(Icons.hotel, color: Colors.white70),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${room.roomType} • ${room.roomNumber}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sức chứa: ${room.capacity} người',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.format(room.pricePerNight),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _onBookNow(room),
                    child: const Text('Đặt ngay'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42, color: AppColors.error),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'Đã xảy ra lỗi.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
