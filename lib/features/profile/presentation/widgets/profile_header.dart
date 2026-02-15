import 'package:app1/features/settings/presentation/pages/settings_page.dart';
import 'package:app1/features/favorite/presentation/pages/favorite_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic>? user;
  final bool isLoggedIn;
  final VoidCallback onThemeToggle;
  final Function(String) onLanguageChange;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.isLoggedIn,
    required this.onThemeToggle,
    required this.onLanguageChange,
  });

  static const Color primaryBrand = Color(0xFFFF6600);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final surfaceColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F7FA);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      width: double.infinity,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: surfaceColor,
                      backgroundImage: user?['avatar'] != null
                          ? NetworkImage(user!['avatar'])
                          : null,
                      child: user?['avatar'] == null
                          ? Icon(Icons.person_rounded,
                              size: 20, color: subTextColor)
                          : null,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?['name'] ?? "Welcome Guest",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),

                  // Favorite icon
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoritePage(),
                      ),
                    ),
                    icon: Icon(
                      Icons.favorite_border_rounded,
                      color: textColor,
                    ),
                  ),

                  // Settings icon (same row ✔️)
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsPage(
                          onThemeToggle: onThemeToggle,
                          onLanguageChange: onLanguageChange,
                        ),
                      ),
                    ),
                    icon: SvgPicture.asset(
                      'assets/icons/setting.svg',
                      colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),

              // // Modern Stats Container
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              //   decoration: BoxDecoration(
              //     color: surfaceColor,
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceAround,
              //     children: [
              //       _buildStatItem("Wallet", "\$1.2k", textColor, subTextColor),
              //       _buildStatItem("Coupons", "5", textColor, subTextColor),
              //       _buildStatItem("Points", "350", textColor, subTextColor),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.05, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildStatItem(
      String label, String value, Color textColor, Color? subColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
              color: subColor, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
