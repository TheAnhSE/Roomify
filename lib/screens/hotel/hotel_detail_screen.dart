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

// TODO (Member 4): Implement hotel detail screen based on Figma:
//   - Detail.jpg -> main layout (image gallery, info, amenities, room list)
// - Required param: HotelModel hotel
// - PageView for hotel.imageUrls with dot indicator
// - Hotel information: name, stars (Icon), rating, address, checkIn/checkOut time
// - Amenities: Wrap of Chip widgets (hotel.amenities)
// - Room list: ListView of RoomCard (call RoomRepository.getAvailableRooms)
//     RoomCard: thumbnailUrl + roomType + roomNumber + CurrencyFormatter.format(pricePerNight) + capacity
//     "Book now" button -> BookingFormScreen(hotel: hotel, room: room, user: user)
// - All Firestore calls must use try/catch
// - Must show CircularProgressIndicator when _isLoading == true
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

  double get _startingPrice {
    if (_rooms.isEmpty) return 0;
    return _rooms
        .map((room) => room.pricePerNight)
        .reduce((current, next) => current < next ? current : next);
  }

  String _formatFromPrice(double amount) {
    final formatted = CurrencyFormatter.format(amount)
        .replaceAll(' ₫', '')
        .replaceAll('.', ',');
    return '$formatted VND';
  }

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
          content: Text('User information not found. Please sign in again.'),
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

  void _openRoomsSheet() {
    if (_rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available rooms for booking right now.'),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.86,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Choose a room',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${_rooms.length} rooms',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _rooms.length,
                  itemBuilder: (context, index) => _buildRoomCard(
                    _rooms[index],
                    isCompact: false,
                    onBook: (room) {
                      Navigator.pop(sheetContext);
                      _onBookNow(room);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _isLoading || _errorMessage != null
          ? null
          : _buildBottomBookBar(),
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
                        const SliverToBoxAdapter(child: SizedBox(height: 110)),
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
            'Amenities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: hotel.amenities.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.25,
            ),
            itemBuilder: (context, index) {
              final amenity = hotel.amenities[index];
              final meta = _resolveAmenityMeta(amenity);
              return _buildAmenityCard(meta);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityCard(_AmenityMeta amenity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceDark),
      ),
      child: Row(
        children: [
          Icon(amenity.icon, size: 22, color: AppColors.textPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amenity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amenity.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(
    RoomModel room, {
    required bool isCompact,
    required ValueChanged<RoomModel> onBook,
  }) {
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
                  'Capacity: ${room.capacity} guests',
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
                  height: isCompact ? 34 : 38,
                  width: isCompact ? null : double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => onBook(room),
                    child: const Text('Book now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBookBar() {
    final hasRooms = _rooms.isNotEmpty;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 14,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'From',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasRooms ? _formatFromPrice(_startingPrice) : 'Sold out',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    'per night',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: hasRooms ? _openRoomsSheet : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.surfaceDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _AmenityMeta _resolveAmenityMeta(String rawAmenity) {
    final amenity = rawAmenity.trim();
    final lower = amenity.toLowerCase();

    if (lower.contains('wifi')) {
      return const _AmenityMeta(
        icon: Icons.wifi,
        title: 'Wi-Fi',
        subtitle: 'Internet access',
      );
    }
    if (lower.contains('spa') || lower.contains('wellness')) {
      return const _AmenityMeta(
        icon: Icons.spa_outlined,
        title: 'Spa',
        subtitle: 'Relaxation zone',
      );
    }
    if (lower.contains('gym') || lower.contains('fitness')) {
      return const _AmenityMeta(
        icon: Icons.fitness_center,
        title: 'Gym',
        subtitle: 'Workout area',
      );
    }
    if (lower.contains('restaurant') || lower.contains('nha hang')) {
      return const _AmenityMeta(
        icon: Icons.restaurant,
        title: 'Restaurant',
        subtitle: 'Dining service',
      );
    }
    if (lower.contains('bar')) {
      return const _AmenityMeta(
        icon: Icons.local_bar,
        title: 'Bar',
        subtitle: 'Drinks and lounge',
      );
    }
    if (lower.contains('airport') || lower.contains('san bay') || lower.contains('bus')) {
      return const _AmenityMeta(
        icon: Icons.directions_bus,
        title: 'Transport',
        subtitle: 'Pickup service',
      );
    }
    if (lower.contains('parking') || lower.contains('do xe')) {
      return const _AmenityMeta(
        icon: Icons.local_parking,
        title: 'Parking',
        subtitle: 'Car park area',
      );
    }
    if (lower.contains('trung tam') || lower.contains('shopping') || lower.contains('mall')) {
      return const _AmenityMeta(
        icon: Icons.store_mall_directory,
        title: 'Shopping',
        subtitle: 'Nearby mall',
      );
    }
    if (lower.contains('ho boi') || lower.contains('pool')) {
      return const _AmenityMeta(
        icon: Icons.pool,
        title: 'Pool',
        subtitle: 'Outdoor area',
      );
    }

    return _AmenityMeta(
      icon: Icons.check_circle_outline,
      title: amenity,
      subtitle: 'Hotel service',
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
              _errorMessage ?? 'Something went wrong.',
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
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmenityMeta {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AmenityMeta({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
