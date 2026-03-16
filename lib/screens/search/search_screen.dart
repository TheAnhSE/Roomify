import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/hotel_model.dart';
import '../../data/repositories/destination_repository.dart';
import '../../data/repositories/hotel_repository.dart';

// TODO (Người 3): Implement search screen theo Figma page-0009 ~ page-0011
// - Optional params: String? city, String? query
// - TextField với nút xoá (×)
// - Dropdown filter: "Tất cả thành phố" + danh sách từ Firestore
// - Kết quả: ListView của HotelCard
// - Empty state: Center(child: Text("Không tìm thấy kết quả"))
// - Mọi Firestore call phải có try/catch với error message tiếng Việt
// - Phải có CircularProgressIndicator khi _isLoading == true
class SearchScreen extends StatefulWidget {
  final String? city;
  final String? query;

  const SearchScreen({super.key, this.city, this.query});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // ignore: unused_field
  final _hotelRepo = HotelRepository();
  // ignore: unused_field
  final _destinationRepo = DestinationRepository();
  final _searchController = TextEditingController();
  // ignore: unused_field
  final List<HotelModel> _results = [];
  String? _selectedCity;
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // TODO: implement _search() và _loadDestinations() trong initState

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tìm kiếm')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Text(_selectedCity != null
                  ? 'SearchScreen (${_selectedCity!}) — Người 3 implement'
                  : 'SearchScreen — Người 3 implement'),
            ),
    );
  }
}
