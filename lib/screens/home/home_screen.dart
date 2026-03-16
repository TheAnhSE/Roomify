import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/destination_repository.dart';
import '../../data/repositories/hotel_repository.dart';

// TODO (Người 3): Implement home screen theo Figma page-0006 ~ page-0008
// - AppBar: tên app bên trái + buildAvatar(user) bên phải
// - Search TextField → onSubmitted: navigate đến SearchScreen(query: text)
// - Section "Địa danh nổi tiếng": horizontal ListView của DestinationCard
//     DestinationCard: CachedNetworkImage + name + "$hotelCount khách sạn"
//     Tap → SearchScreen(city: destination.name)
// - Section "Khách sạn nổi bật": vertical ListView của HotelCard
//     HotelCard: thumbnailUrl + name + city + rating + CurrencyFormatter.format(priceFrom)
//     Tap → HotelDetailScreen(hotel: hotel)
// - Mọi Firestore call phải có try/catch với error message tiếng Việt
// - Phải có CircularProgressIndicator khi _isLoading == true
class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: unused_field
  final _destinationRepo = DestinationRepository();
  // ignore: unused_field
  final _hotelRepo = HotelRepository();
  bool _isLoading = false;

  // TODO: implement _loadData() trong initState

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : const Center(
              child: Text('HomeScreen — Người 3 implement'),
            ),
    );
  }
}
