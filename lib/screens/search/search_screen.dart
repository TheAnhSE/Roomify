import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/hotel_model.dart';
import '../../data/repositories/destination_repository.dart';
import '../../data/repositories/hotel_repository.dart';

// TODO (Member 3): Implement search screen based on Figma:
//   - Search.jpg -> main layout (search bar, filter dropdown, result list)
// - Optional params: String? city, String? query
// - TextField with clear button (x)
// - Dropdown filter: "All cities" + city list from Firestore
// - Results: ListView of HotelCard
// - Empty state: Center(child: Text("No results found"))
// - All Firestore calls must use try/catch
// - Must show CircularProgressIndicator when _isLoading == true
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

  // TODO: implement _search() and _loadDestinations() in initState

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Search')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Text(_selectedCity != null
                  ? 'SearchScreen (${_selectedCity!}) - Member 3 implement'
                  : 'SearchScreen - Member 3 implement'),
            ),
    );
  }
}
