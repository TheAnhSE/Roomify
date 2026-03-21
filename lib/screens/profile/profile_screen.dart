import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/hotel_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../widgets/avatar_widget.dart';
import '../../main.dart';
import '../booking/booking_history_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final Set<String> wishlistIds;
  final List<HotelModel> allHotels;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.wishlistIds,
    required this.allHotels,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authRepo = AuthRepository();
  late UserModel _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  Future<void> _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _authRepo.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildHeader(),
                    const SizedBox(height: 8),
                    const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    _buildQuickMenu(),
                    const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Account Setting'),
                    const SizedBox(height: 8),
                    _buildSettingItem(
                      icon: Icons.person_outline,
                      label: 'Edit profile',
                      onTap: () async {
                        final updated = await Navigator.push<UserModel>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditProfileScreen(user: _currentUser),
                          ),
                        );
                        if (updated != null && mounted) {
                          setState(() => _currentUser = updated);
                        }
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.translate_outlined,
                      label: 'Change language',
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.dark_mode_outlined,
                      label: 'Color mode',
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Legal'),
                    const SizedBox(height: 8),
                    _buildSettingItem(
                      icon: Icons.article_outlined,
                      label: 'Terms and Condition',
                      trailing: Icons.open_in_new,
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.shield_outlined,
                      label: 'Privacy policy',
                      trailing: Icons.open_in_new,
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                    _buildLogoutButton(),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(fontSize: 12, color: Colors.black38),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          buildAvatar(_currentUser, radius: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser.email,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Quick menu ───────────────────────────────────────────────────────────────
  Widget _buildQuickMenu() {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: const Text(
            'Booking',
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.black54),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingHistoryScreen(userId: widget.user.id),
            ),
          ),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: const Text(
            'Wishlist',
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.black54),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WishListScreen(
                user: widget.user,
                wishlistIds: widget.wishlistIds,
                allHotels: widget.allHotels,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Section title ────────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // ─── Setting item ─────────────────────────────────────────────────────────────
  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    IconData trailing = Icons.chevron_right,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEEEEEE)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.black87),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                Icon(trailing, size: 18, color: Colors.black45),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Logout button ────────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _onLogout,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEEEEEE)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
