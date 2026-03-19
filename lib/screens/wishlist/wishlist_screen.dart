import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/user_model.dart';
import '../../data/models/hotel_model.dart';
import '../../data/repositories/hotel_repository.dart';
import '../hotel/hotel_detail_screen.dart';

class WishListScreen extends StatefulWidget {
  final UserModel user;
  const WishListScreen({super.key, required this.user});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  final _hotelRepo = HotelRepository();

  List<HotelModel> _hotels = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final hotels = await _hotelRepo.getHotels();
      setState(() => _hotels = hotels);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
      setState(() {
        _errorMessage = 'Không thể tải danh sách. Vui lòng thử lại.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildError()
            : RefreshIndicator(
                onRefresh: _loadData,
                child: CustomScrollView(
                  slivers: [
                    // ── Header ────────────────────────────────────────
                    SliverToBoxAdapter(child: _buildHeader()),

                    // ── List ──────────────────────────────────────────
                    _hotels.isEmpty
                        ? const SliverFillRemaining(
                            child: Center(
                              child: Text(
                                'Chưa có khách sạn nào.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildWishlistItem(
                                _hotels[index],
                                isLast: index == _hotels.length - 1,
                              ),
                              childCount: _hotels.length,
                            ),
                          ),

                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(26, 44, 26, 15),
      child: Text(
        'Wishlist',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ── Wishlist item ─────────────────────────────────────────────────────────

  Widget _buildWishlistItem(HotelModel hotel, {required bool isLast}) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HotelDetailScreen(hotel: hotel)),
          ),
          // Khung ngoài: w355 h150
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: 355,
              height: 150,
              child: Row(
                children: [
                  // ── Thumbnail w122 h150 ───────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: hotel.thumbnailUrl,
                      fit: BoxFit.cover,
                      width: 122,
                      height: 122,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.hotel,
                            color: Colors.white54,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ── Info: w203 h134, căn giữa dọc trong h150 ─────────
                  SizedBox(
                    width: 203,
                    height: 134,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          hotel.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 5),

                        // Rating row
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                Icons.star,
                                size: 13,
                                color: i < hotel.rating.round()
                                    ? AppColors.star
                                    : Colors.grey.shade300,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              '100 reviews',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 3),

                        // City
                        Text(
                          hotel.city,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 3),

                        // Price
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'from ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: CurrencyFormatter.format(hotel.priceFrom),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const TextSpan(
                                text: '/person',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Tag "2 day 1 night"
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: const Text(
                            '2 day 1 night',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Divider — không hiện ở item cuối
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF0F0F0),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
  // ── Error state ───────────────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: _loadData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
