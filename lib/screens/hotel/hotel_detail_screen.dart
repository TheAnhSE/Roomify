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
          content: Text('No available rooms right now.'),
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
      builder: (sheetContext) => _RoomPickerSheet(
        rooms: _rooms,
        onBook: (room) {
          Navigator.pop(sheetContext);
          _onBookNow(room);
        },
      ),
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

    if (_containsAny(lower, const ['wifi'])) {
      return _AmenityMeta(
        icon: Icons.wifi,
        title: amenity,
        subtitle: 'Connectivity',
      );
    }
    if (_containsAny(lower, const ['spa', 'wellness', 'salon'])) {
      return _AmenityMeta(
        icon: Icons.spa_outlined,
        title: amenity,
        subtitle: 'Spa & wellness',
      );
    }

    if (_containsAny(lower, const ['restaurant', 'dining', 'buffet'])) {
      return _AmenityMeta(
        icon: Icons.restaurant,
        title: amenity,
        subtitle: 'Food & dining',
      );
    }
    if (_containsAny(lower, const ['bar', 'wine', 'champagne'])) {
      return _AmenityMeta(
        icon: Icons.local_bar,
        title: amenity,
        subtitle: 'Drinks & lounge',
      );
    }

    if (_containsAny(lower, const ['pool', 'beach'])) {
      return _AmenityMeta(
        icon: Icons.pool,
        title: amenity,
        subtitle: 'Pools & beach',
      );
    }
    if (_containsAny(lower, const ['kayak', 'snorkel', 'water sports'])) {
      return _AmenityMeta(
        icon: Icons.kayaking,
        title: amenity,
        subtitle: 'Water activities',
      );
    }
    if (_containsAny(lower, const ['tour', 'class', 'yoga', 'bicycles', 'bike', 'motorbike'])) {
      return _AmenityMeta(
        icon: Icons.explore,
        title: amenity,
        subtitle: 'Activities',
      );
    }

    if (_containsAny(lower, const ['fitness', 'gym'])) {
      return _AmenityMeta(
        icon: Icons.fitness_center,
        title: amenity,
        subtitle: 'Fitness',
      );
    }
    if (_containsAny(lower, const ['kids club'])) {
      return _AmenityMeta(
        icon: Icons.child_friendly,
        title: amenity,
        subtitle: 'Family',
      );
    }
    if (_containsAny(lower, const ['casino'])) {
      return _AmenityMeta(
        icon: Icons.casino,
        title: amenity,
        subtitle: 'Entertainment',
      );
    }
    if (_containsAny(lower, const ['water park', 'theme park', 'safari'])) {
      return _AmenityMeta(
        icon: Icons.park,
        title: amenity,
        subtitle: 'Attractions',
      );
    }
    if (_containsAny(lower, const ['villa'])) {
      return _AmenityMeta(
        icon: Icons.villa,
        title: amenity,
        subtitle: 'Stay experience',
      );
    }
    if (_containsAny(lower, const ['shopping'])) {
      return _AmenityMeta(
        icon: Icons.shopping_bag_outlined,
        title: amenity,
        subtitle: 'Shopping',
      );
    }
    if (_containsAny(lower, const ['business'])) {
      return _AmenityMeta(
        icon: Icons.business_center,
        title: amenity,
        subtitle: 'Business',
      );
    }
    if (_containsAny(lower, const ['parking'])) {
      return _AmenityMeta(
        icon: Icons.local_parking,
        title: amenity,
        subtitle: 'Parking',
      );
    }

    if (_containsAny(lower, const ['concierge', 'butler', 'all-inclusive'])) {
      return _AmenityMeta(
        icon: Icons.room_service_outlined,
        title: amenity,
        subtitle: 'Hotel service',
      );
    }
    if (_containsAny(lower, const ['airport', 'transfer', 'shuttle', 'seaplane', 'rolls-royce'])) {
      return _AmenityMeta(
        icon: Icons.airport_shuttle,
        title: amenity,
        subtitle: 'Transport',
      );
    }
    if (_containsAny(lower, const ['laundry'])) {
      return _AmenityMeta(
        icon: Icons.local_laundry_service,
        title: amenity,
        subtitle: 'Convenience',
      );
    }
    if (_containsAny(lower, const ['boat'])) {
      return _AmenityMeta(
        icon: Icons.directions_boat,
        title: amenity,
        subtitle: 'Transport',
      );
    }

    if (_containsAny(lower, const ['quarter', 'centre', 'center', 'town'])) {
      return _AmenityMeta(
        icon: Icons.location_city,
        title: amenity,
        subtitle: 'Location',
      );
    }
    if (_containsAny(lower, const ['river view', 'lake view', 'ocean view'])) {
      return _AmenityMeta(
        icon: Icons.landscape_outlined,
        title: amenity,
        subtitle: 'Scenic view',
      );
    }
    if (_containsAny(lower, const ['breakfast'])) {
      return _AmenityMeta(
        icon: Icons.free_breakfast,
        title: amenity,
        subtitle: 'Meals',
      );
    }
    if (_containsAny(lower, const ['heritage'])) {
      return _AmenityMeta(
        icon: Icons.museum_outlined,
        title: amenity,
        subtitle: 'Culture',
      );
    }

    return _AmenityMeta(
      icon: Icons.check_circle_outline,
      title: amenity,
      subtitle: 'Hotel service',
    );
  }

  bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) return true;
    }
    return false;
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

enum _SortOption {
  priceAsc,
  priceDesc,
  capacity,
}

class _RoomPickerSheet extends StatefulWidget {
  final List<RoomModel> rooms;
  final ValueChanged<RoomModel> onBook;

  const _RoomPickerSheet({
    required this.rooms,
    required this.onBook,
  });

  @override
  State<_RoomPickerSheet> createState() => _RoomPickerSheetState();
}

class _RoomPickerSheetState extends State<_RoomPickerSheet> {
  String? _typeFilter;
  int? _capacityFilter;
  _SortOption _sort = _SortOption.priceAsc;

  static const List<String> _typeOrder = ['Standard', 'Deluxe', 'Suite'];

  List<String> get _types {
    return _typeOrder
        .where((type) => widget.rooms.any((room) => room.roomType == type))
        .toList();
  }

  List<int> get _capacities {
    final values = widget.rooms.map((room) => room.capacity).toSet().toList();
    values.sort();
    return values;
  }

  List<RoomModel> get _visibleRooms {
    var result = widget.rooms.toList();

    if (_typeFilter != null) {
      result = result.where((room) => room.roomType == _typeFilter).toList();
    }

    if (_capacityFilter != null) {
      result =
          result.where((room) => room.capacity >= _capacityFilter!).toList();
    }

    switch (_sort) {
      case _SortOption.priceAsc:
        result.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
        break;
      case _SortOption.priceDesc:
        result.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
        break;
      case _SortOption.capacity:
        result.sort((a, b) => b.capacity.compareTo(a.capacity));
        break;
    }

    return result;
  }

  double _minPrice(List<RoomModel> rooms) {
    if (rooms.isEmpty) return 0;
    return rooms
        .map((room) => room.pricePerNight)
        .reduce((current, next) => current < next ? current : next);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleRooms;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHandle(),
          _buildHeader(),
          const SizedBox(height: 4),
          _buildTypeFilterRow(),
          const SizedBox(height: 4),
          _buildSortRow(),
          const Divider(height: 1),
          _buildResultsBar(visible.length),
          Expanded(child: _buildRoomList(visible)),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Choose Your Room',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${widget.rooms.length} available',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilterRow() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(
            label: 'All types',
            isSelected: _typeFilter == null,
            onTap: () => setState(() => _typeFilter = null),
          ),
          const SizedBox(width: 8),
          for (final type in _types) ...[
            _FilterChip(
              label: type,
              sublabel: _typeFilter == type
                  ? CurrencyFormatter.format(
                      _minPrice(
                        widget.rooms.where((room) => room.roomType == type).toList(),
                      ),
                    )
                  : null,
              isSelected: _typeFilter == type,
              onTap: () => setState(
                () => _typeFilter = _typeFilter == type ? null : type,
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (_capacities.length >= 2) ...[
            Container(
              width: 1,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              color: AppColors.surfaceDark,
            ),
            for (final cap in _capacities) ...[
              _FilterChip(
                label: '$cap+ guests',
                isSelected: _capacityFilter == cap,
                onTap: () => setState(
                  () => _capacityFilter = _capacityFilter == cap ? null : cap,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSortRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          const Text(
            'Sort:',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: 'Price ↑',
            isSelected: _sort == _SortOption.priceAsc,
            onTap: () => setState(() => _sort = _SortOption.priceAsc),
          ),
          const SizedBox(width: 6),
          _SortChip(
            label: 'Price ↓',
            isSelected: _sort == _SortOption.priceDesc,
            onTap: () => setState(() => _sort = _SortOption.priceDesc),
          ),
          const SizedBox(width: 6),
          _SortChip(
            label: 'Capacity',
            isSelected: _sort == _SortOption.capacity,
            onTap: () => setState(() => _sort = _SortOption.capacity),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsBar(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Text(
        'Showing $count room${count != 1 ? 's' : ''}',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildRoomList(List<RoomModel> rooms) {
    if (rooms.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 40, color: AppColors.textHint),
              SizedBox(height: 10),
              Text(
                'No rooms match your filters.\nTry removing a filter.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: rooms.length,
      itemBuilder: (context, index) => _buildRoomCard(rooms[index]),
    );
  }

  Widget _buildRoomCard(RoomModel room) {
    final badgeColor = switch (room.roomType) {
      'Standard' => const Color(0xFFEAF3DE),
      'Deluxe' => const Color(0xFFE6F1FB),
      'Suite' => const Color(0xFFEEEDFE),
      _ => AppColors.surface,
    };

    final badgeTextColor = switch (room.roomType) {
      'Standard' => const Color(0xFF3B6D11),
      'Deluxe' => const Color(0xFF185FA5),
      'Suite' => const Color(0xFF3C3489),
      _ => AppColors.textSecondary,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
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
                    placeholder: (_, __) => Container(
                      width: 88,
                      height: 88,
                      color: AppColors.surfaceDark,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 88,
                      height: 88,
                      color: AppColors.surfaceDark,
                      child: const Icon(
                        Icons.hotel,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Room ${room.roomNumber}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              room.roomType,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: badgeTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${room.capacity} guest${room.capacity > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        CurrencyFormatter.format(room.pricePerNight),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Text(
                        '/ night',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (room.amenities.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  ...room.amenities.take(4).map(
                        (amenity) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            amenity,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                  if (room.amenities.length > 4)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+${room.amenities.length - 4} more',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => widget.onBook(room),
                child: const Text(
                  'Book This Room',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceDark,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (sublabel != null) ...[
              const SizedBox(width: 5),
              Text(
                sublabel!,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceDark,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
