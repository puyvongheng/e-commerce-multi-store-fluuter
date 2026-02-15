import 'package:flutter/material.dart';
import 'package:app1/l10n/app_localizations.dart';
import 'package:app1/features/layout/presentation/widgets/navigation/modern_nav_item.dart';

class ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Premium color palette
    const Color activeColor = Color(0xFFFF6600); // Lazada Orange
    final Color inactiveColor = isDark ? Colors.white54 : Colors.black45;
    final Color backgroundColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ModernNavItem(
                iconPath: 'assets/icons/home.svg',
                label: t.translate('home'),
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              ModernNavItem(
                iconPath: 'assets/icons/cart.svg',
                label: t.translate('cart'),
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              ModernNavItem(
                iconPath: 'assets/icons/profile.svg',
                label: t.translate('profile'),
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
