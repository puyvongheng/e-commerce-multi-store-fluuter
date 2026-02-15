import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuickAccessItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  QuickAccessItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
}

class QuickAccessGrid extends StatelessWidget {
  final List<QuickAccessItem>? customItems;

  const QuickAccessGrid({super.key, this.customItems});

  static const Color lazadaOrange = Color(0xFFFF6600);
  static const Color lazadaRed = Color(0xFFD0011B);

  List<QuickAccessItem> get _defaultItems => [
        QuickAccessItem(
          icon: Icons.store_mall_directory_rounded,
          label: 'LazMall',
          color: lazadaRed,
        ),
        QuickAccessItem(
          icon: Icons.redeem_rounded,
          label: 'Vouchers',
          color: lazadaOrange,
        ),
        QuickAccessItem(
          icon: Icons.local_shipping_rounded,
          label: 'Free Ship',
          color: const Color(0xFF00C853),
        ),
        QuickAccessItem(
          icon: Icons.new_releases_rounded,
          label: 'New',
          color: const Color(0xFF2196F3),
        ),
        QuickAccessItem(
          icon: Icons.trending_up_rounded,
          label: 'Top Deals',
          color: const Color(0xFFE91E63),
        ),
        QuickAccessItem(
          icon: Icons.favorite_rounded,
          label: 'Wishlist',
          color: const Color(0xFF9C27B0),
        ),
        QuickAccessItem(
          icon: Icons.bolt_rounded,
          label: 'Flash Sale',
          color: const Color(0xFFFFC107),
        ),
        QuickAccessItem(
          icon: Icons.category_rounded,
          label: 'More',
          color: const Color(0xFF607D8B),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = customItems ?? _defaultItems;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _QuickAccessItemWidget(item: item, index: index);
        },
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }
}

class _QuickAccessItemWidget extends StatelessWidget {
  final QuickAccessItem item;
  final int index;

  const _QuickAccessItemWidget({
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: item.color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 26,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
              delay: (index * 200).ms,
              duration: 2000.ms,
              color: Colors.white.withOpacity(0.4)),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().scale(delay: (index * 50).ms, curve: Curves.easeOutBack);
  }
}
