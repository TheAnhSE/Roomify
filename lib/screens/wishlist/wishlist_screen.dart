import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/user_model.dart';
import '../../data/models/hotel_model.dart';
import '../hotel/hotel_detail_screen.dart';

class WishListScreen extends StatefulWidget {
  final UserModel user;
  final Set<String> wishlistIds;
  final List<HotelModel> allHotels;

  const WishListScreen({
    super.key,
    required this.user,
    required this.wishlistIds,
    required this.allHotels,
  });

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  late final Set<String> _localWishlistIds;

  @override
  void initState() {
    super.initState();
    _localWishlistIds = Set.from(widget.wishlistIds);
  }

  List<HotelModel> get _wishlistedHotels =>
      widget.allHotels.where((h) => _localWishlistIds.contains(h.id)).toList();

  void _removeFromWishlist(String hotelId) {
    setState(() {
      _localWishlistIds.remove(hotelId);
      widget.wishlistIds.remove(hotelId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hotels = _wishlistedHotels;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ── List ──────────────────────────────────────────
            hotels.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No hotels in wishlist yet.',
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
                        context,
                        hotels[index],
                        isLast: index == hotels.length - 1,
                      ),
                      childCount: hotels.length,
                    ),
                  ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
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

  Widget _buildWishlistItem(
    BuildContext context,
    HotelModel hotel, {
    required bool isLast,
  }) {
    return _SwipeToDeleteItem(
      key: ValueKey(hotel.id),
      onDelete: () => _removeFromWishlist(hotel.id),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HotelDetailScreen(hotel: hotel),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: 355,
                height: 150,
                child: Row(
                  children: [
                    // ── Thumbnail w122 h122 ───────────────────────────────
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

                    // -- Info: w203 h134, vertically centered in h150 --
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
                                  text: CurrencyFormatter.format(
                                    hotel.priceFrom,
                                  ),
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
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                              ),
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

          // Divider - hidden for the last item
          if (!isLast)
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF0F0F0),
              indent: 16,
              endIndent: 16,
            ),
        ],
      ),
    );
  }
}

// ── Swipe to delete widget ────────────────────────────────────────────────────

class _SwipeToDeleteItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;

  const _SwipeToDeleteItem({
    super.key,
    required this.child,
    required this.onDelete,
  });

  @override
  State<_SwipeToDeleteItem> createState() => _SwipeToDeleteItemState();
}

class _SwipeToDeleteItemState extends State<_SwipeToDeleteItem> {
  double _offset = 0;
  static const double _maxOffset = 150;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _offset = (_offset + details.delta.dx).clamp(-_maxOffset, 0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_offset <= -_maxOffset / 2) {
      // Đã kéo qua nửa — snap tới -_maxOffset để hiện nút
      setState(() => _offset = -_maxOffset);
    } else {
      // Chưa đủ hoặc kéo phải — snap về 0
      setState(() => _offset = 0);
    }
  }

  Future<void> _onDeleteTap() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from wishlist'),
        content: const Text('Remove this hotel from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      widget.onDelete();
    } else {
      setState(() => _offset = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: ClipRect(
        child: Stack(
          children: [
            // Nút xóa — chỉ hiện khi đang trượt
            if (_offset < 0)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: _offset.abs(),
                child: GestureDetector(
                  onTap: _onDeleteTap,
                  child: Container(
                    color: AppColors.error,
                    alignment: Alignment.center,
                    child: _offset.abs() > 60
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Remove',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                ),
              ),

            // Card trượt theo offset
            AnimatedContainer(
              duration: _offset == 0
                  ? const Duration(milliseconds: 200)
                  : Duration.zero,
              transform: Matrix4.translationValues(_offset, 0, 0),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
