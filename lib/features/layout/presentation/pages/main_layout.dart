import 'package:flutter/material.dart';
import 'package:app1/features/home/presentation/pages/home_page.dart';
import 'package:app1/features/profile/presentation/pages/profile_page.dart';
import 'package:app1/features/cart/presentation/pages/cart_page.dart';
import '../widgets/navigation/modern_bottom_nav.dart';

class MainLayout extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final Function(String) onLanguageChange;

  const MainLayout({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onLanguageChange,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const CartPage(),
      ProfilePage(
        onThemeToggle: widget.onThemeToggle,
        onLanguageChange: widget.onLanguageChange,
      ),
    ];
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
      extendBody: true, // Content flows behind the curved bottom nav
      body: _pages[_selectedIndex],
      bottomNavigationBar: ModernBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
