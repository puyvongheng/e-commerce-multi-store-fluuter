import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VariantSelectorHeader extends StatelessWidget {
  final String imageUrl;
  final double price;
  final int? stock;
  final int? stock_main;

  final String attributesSummary;
  final bool isDark;
  final VoidCallback onClose;

  const VariantSelectorHeader({
    super.key,
    required this.imageUrl,
    required this.price,
    this.stock,
    this.stock_main,
    required this.attributesSummary,
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    const Color lazadaOrange = Color(0xFFFF6600);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Premium Image Frame
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "\$${price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: lazadaOrange,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Stock: ${stock ?? stock_main ?? ' '}",
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  attributesSummary.isNotEmpty
                      ? "Selected: $attributesSummary"
                      : "Choose Variation",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
