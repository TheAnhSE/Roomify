import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/user_model.dart';
import '../../data/models/hotel_model.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../hotel/hotel_detail_screen.dart';

// ─── Sort options ─────────────────────────────────────────────────────────────
enum WishlistSort { dateAdded, rating, price }

class WishListScreen extends StatefulWidget {
  final UserModel user;
  final List<HotelModel> allHotels;

  const WishListScreen({
    super.key,
    required this.user,
    required this.allHotels,
  });

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  final _repo = WishlistRepository();
  StreamSubscription<Set<String>>? _wishlistSub;

  // Cache stream data locally — no StreamBuilder in build()
  Set<String> _wishlistIds = {};
  bool _loading = true;

  WishlistSort _sort = WishlistSort.dateAdded;

  // Compare mode
  final Set<String> _compareIds = {};
  bool _compareMode = false;

  @override
  void initState() {
    super.initState();
    _wishlistSub = _repo.watchWishlistedIds().listen((ids) {
      if (mounted) {
        setState(() {
          _wishlistIds = ids;
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _wishlistSub?.cancel();
    super.dispose();
  }

  HotelModel? _hotelById(String id) {
    try {
      return widget.allHotels.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  List<HotelModel> _sortedHotels() {
    final hotels = _wishlistIds
        .map((id) => _hotelById(id))
        .whereType<HotelModel>()
        .toList();

    switch (_sort) {
      case WishlistSort.rating:
        hotels.sort((a, b) => b.rating.compareTo(a.rating));
      case WishlistSort.price:
        hotels.sort((a, b) => a.priceFrom.compareTo(b.priceFrom));
      case WishlistSort.dateAdded:
        break;
    }
    return hotels;
  }

  // ── Compare ────────────────────────────────────────────────────────────────

  void _toggleCompare(String hotelId) {
    setState(() {
      if (_compareIds.contains(hotelId)) {
        _compareIds.remove(hotelId);
      } else if (_compareIds.length < 3) {
        _compareIds.add(hotelId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can compare up to 3 hotels')),
        );
      }
    });
  }

  void _openCompare() {
    if (_compareIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 2 hotels to compare')),
      );
      return;
    }
    final hotels = _compareIds
        .map((id) => _hotelById(id))
        .whereType<HotelModel>()
        .toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CompareSheet(hotels: hotels),
    );
  }

  // ── Share ──────────────────────────────────────────────────────────────────

  void _shareWishlist(List<HotelModel> hotels) {
    final buffer = StringBuffer();
    buffer.writeln('❤ My Hotel Wishlist');
    buffer.writeln();
    for (final h in hotels) {
      buffer.writeln(' ${h.name}, ${h.city}');
      buffer.writeln(
        '    ${h.rating.toStringAsFixed(1)}  •  from ${CurrencyFormatter.format(h.priceFrom)}/person',
      );
      buffer.writeln();
    }
    buffer.writeln('— Shared via Roomify');
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wishlist copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hotels = _sortedHotels();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(hotels),
            Expanded(
              child: hotels.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: hotels.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFFF0F0F0)),
                      itemBuilder: (ctx, i) => _buildHotelTile(hotels[i]),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _compareMode
          ? FloatingActionButton.extended(
              onPressed: _openCompare,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.compare_arrows, color: Colors.white),
              label: Text(
                'Compare (${_compareIds.length})',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(List<HotelModel> hotels) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Wishlist',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Compare toggle
          IconButton(
            tooltip: 'Compare hotels',
            onPressed: () => setState(() {
              _compareMode = !_compareMode;
              if (!_compareMode) _compareIds.clear();
            }),
            icon: Icon(
              Icons.compare_arrows,
              color: _compareMode ? AppColors.primary : Colors.grey,
            ),
          ),
          // Sort
          PopupMenuButton<WishlistSort>(
            icon: const Icon(Icons.sort, color: Colors.grey),
            tooltip: 'Sort',
            onSelected: (s) => setState(() => _sort = s),
            itemBuilder: (_) => [
              _sortItem(
                WishlistSort.dateAdded,
                'Date added',
                Icons.calendar_today,
              ),
              _sortItem(WishlistSort.rating, 'Rating', Icons.star),
              _sortItem(
                WishlistSort.price,
                'Price: low to high',
                Icons.attach_money,
              ),
            ],
          ),
          // Share
          if (hotels.isNotEmpty)
            IconButton(
              tooltip: 'Share wishlist',
              onPressed: () => _shareWishlist(hotels),
              icon: const Icon(Icons.ios_share, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  PopupMenuItem<WishlistSort> _sortItem(
    WishlistSort val,
    String label,
    IconData icon,
  ) => PopupMenuItem(
    value: val,
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(label),
        if (_sort == val) ...[
          const Spacer(),
          const Icon(Icons.check, size: 16, color: AppColors.primary),
        ],
      ],
    ),
  );

  Widget _buildHotelTile(HotelModel hotel) {
    final isSelected = _compareIds.contains(hotel.id);
    return _SwipeToDeleteItem(
      key: ValueKey(hotel.id),
      onDelete: () => _repo.removeFromWishlist(hotel.id),
      child: InkWell(
        onTap: _compareMode
            ? () => _toggleCompare(hotel.id)
            : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HotelDetailScreen(hotel: hotel),
                ),
              ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compare checkbox
              if (_compareMode)
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),

              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: hotel.thumbnailUrl,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: Colors.grey.shade300),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.hotel,
                      color: Colors.white54,
                      size: 28,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            Icons.star,
                            size: 12,
                            color: i < hotel.rating.round()
                                ? AppColors.star
                                : Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${hotel.rating.toStringAsFixed(1)} · ${(hotel.rating * 20).round()} reviews',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hotel.city,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text(
          'Your wishlist is empty',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Save hotels you love by tapping ♡',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}

// ─── Compare Bottom Sheet ─────────────────────────────────────────────────────
class _CompareSheet extends StatelessWidget {
  final List<HotelModel> hotels;

  const _CompareSheet({required this.hotels});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Rating', (HotelModel h) => h.rating.toStringAsFixed(1)),
      ('Stars', (HotelModel h) => '★' * h.stars),
      ('Price from', (HotelModel h) => CurrencyFormatter.format(h.priceFrom)),
      ('City', (HotelModel h) => h.city),
      ('Check-in', (HotelModel h) => h.checkInTime),
      ('Check-out', (HotelModel h) => h.checkOutTime),
    ];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Compare Hotels',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Table(
                border: TableBorder.all(
                  color: const Color(0xFFF0F0F0),
                  width: 1,
                ),
                columnWidths: {
                  0: const FixedColumnWidth(90),
                  for (int i = 1; i <= hotels.length; i++)
                    i: const FlexColumnWidth(),
                },
                children: [
                  // Header row
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFF8F8F8)),
                    children: [
                      const _TCell(text: '', isHeader: true),
                      ...hotels.map(
                        (h) =>
                            _TCell(text: h.name, isHeader: true, maxLines: 2),
                      ),
                    ],
                  ),
                  // Thumbnail row
                  TableRow(
                    children: [
                      const _TCell(text: 'Photo'),
                      ...hotels.map(
                        (h) => Padding(
                          padding: const EdgeInsets.all(6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: h.thumbnailUrl,
                              height: 70,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                height: 70,
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.hotel,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Data rows
                  ...rows.map((row) {
                    final (label, getValue) = row;
                    final values = hotels.map((h) => getValue(h)).toList();
                    String? best;
                    if (label == 'Rating') {
                      best = hotels
                          .reduce((a, b) => a.rating > b.rating ? a : b)
                          .id;
                    } else if (label == 'Price from') {
                      best = hotels
                          .reduce((a, b) => a.priceFrom < b.priceFrom ? a : b)
                          .id;
                    }
                    return TableRow(
                      children: [
                        _TCell(text: label),
                        ...hotels.asMap().entries.map(
                          (e) => _TCell(
                            text: values[e.key],
                            highlight: best != null && best == hotels[e.key].id,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final bool highlight;
  final int? maxLines;

  const _TCell({
    required this.text,
    this.isHeader = false,
    this.highlight = false,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader || highlight
              ? FontWeight.bold
              : FontWeight.normal,
          color: highlight
              ? AppColors.primary
              : isHeader
              ? AppColors.textPrimary
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─── Swipe to delete ──────────────────────────────────────────────────────────
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
  static const double _maxOffset = 130;

  void _onHorizontalDragUpdate(DragUpdateDetails d) {
    setState(() {
      _offset = (_offset + d.delta.dx).clamp(-_maxOffset, 0);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    setState(() => _offset = _offset <= -_maxOffset / 2 ? -_maxOffset : 0);
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
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
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
            if (_offset < 0)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: _offset.abs(),
                child: GestureDetector(
                  onTap: _onDeleteTap,
                  child: Container(
                    color: Colors.red,
                    alignment: Alignment.center,
                    child: _offset.abs() > 60
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(height: 3),
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
                            size: 22,
                          ),
                  ),
                ),
              ),
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
