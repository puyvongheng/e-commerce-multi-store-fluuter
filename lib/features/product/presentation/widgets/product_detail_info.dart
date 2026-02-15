import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductDetailInfoSection extends StatelessWidget {
  final String name;
  final int salesCount;
  final double price;
  final double? comparePrice;
  final int? stock_main;
  final bool isDark;

  const ProductDetailInfoSection({
    super.key,
    required this.name,
    required this.salesCount,
    this.stock_main,
    required this.price,
    this.comparePrice,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const Color lazadaOrange = Color(0xFFFF6600);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏷️ Price Row with Discount Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: lazadaOrange,
                  height: 1.5,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                price.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: lazadaOrange,
                  height: 1.0,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),

              if (comparePrice != null)
                Text(
                  "\$${comparePrice!.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),

              const Spacer(),

              // Share Icon Button
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: lazadaOrange.withOpacity(0.1),
              //     borderRadius: BorderRadius.circular(4),
              //   ),
              //   child: const Text(
              //     "-20%",
              //     style: TextStyle(
              //       color: lazadaOrange,
              //       fontWeight: FontWeight.bold,
              //       fontSize: 12,
              //     ),
              //   ),
              // ),
            ],
          ),

          const SizedBox(height: 12),

          // 📦 Product Name
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.3,
              fontSize: 18,
              color: isDark ? Colors.white : const Color(0xFF212121),
            ),
          ),

          const SizedBox(height: 12),

          // ⭐ Stats Row (Rating | Sold | Stock)
          Row(
            children: [
              // Rating
              const Icon(Icons.star_rounded,
                  color: Color(0xFFFFC107), size: 18),
              const SizedBox(width: 4),
              Text(
                "4.8",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[300] : Colors.black87,
                ),
              ),

              _buildDivider(),

              // Sold Count
              Text(
                "$salesCount Sold",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),

              _buildDivider(),

              // Stock Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (stock_main ?? 0) > 0
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  (stock_main ?? 0) > 0 ? "In Stock" : "Out of Stock",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: (stock_main ?? 0) > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDivider() {
    return Container(
      height: 12,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.grey[300],
    );
  }
}
