import 'dart:convert';
import 'package:app1/services/api_service.dart';
import 'package:app1/models/product.dart';
import 'package:app1/features/auth/presentation/pages/login_page.dart';
import 'package:app1/features/profile/presentation/widgets/profile_header.dart';
import 'package:app1/features/profile/presentation/widgets/profile_orders_section.dart';
import 'package:app1/features/profile/presentation/widgets/profile_recommended_grid.dart';
import 'package:app1/features/profile/presentation/widgets/profile_recommended_title.dart';
import 'package:app1/features/profile/presentation/widgets/profile_tools_grid.dart';
import 'package:app1/features/profile/presentation/widgets/profile_utility_grid.dart';
import 'package:app1/features/profile/presentation/widgets/profile_wallet_section.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app1/features/store/presentation/pages/map_store_page.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final Function(String) onLanguageChange;

  const ProfilePage({
    super.key,
    required this.onThemeToggle,
    required this.onLanguageChange,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _user;
  List<Product> _recommendedProducts = [];
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchRecommended();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userDataString = prefs.getString('user_data');

    if (token != null && userDataString != null) {
      if (mounted) {
        setState(() {
          _isLoggedIn = true;
          _user = jsonDecode(userDataString);
        });
      }
    }
  }

  Future<void> _fetchRecommended() async {
    try {
      final products = await ApiService.fetchProducts(page: 1);
      if (mounted) {
        setState(() {
          _recommendedProducts = products;
        });
      }
    } catch (e) {
      debugPrint("Error fetching recommended products: $e");
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF8F8FA),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Header Section
            SliverToBoxAdapter(
              child: ProfileHeader(
                user: _user,
                isLoggedIn: _isLoggedIn,
                onThemeToggle: widget.onThemeToggle,
                onLanguageChange: widget.onLanguageChange,
              ),
            ),

            // 2. My Orders Section
            const SliverToBoxAdapter(
              child: ProfileOrdersSection(),
            ),

            // 3. Wallet Section
            const SliverToBoxAdapter(
              child: ProfileWalletSection(),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.map_rounded, size: 20),
                  label: const Text("Store Map"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MapStorePage(),
                      ),
                    );
                  },
                ),
              ),
            ),
            // 5. Utility Grid
            SliverToBoxAdapter(
              child: ProfileUtilityGrid(
                onLogout: _logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
