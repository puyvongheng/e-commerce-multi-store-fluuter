import 'package:flutter/material.dart';
import 'package:app1/models/product.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAddTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddTap,
  });

  static const Color lazadaOrange = Color(0xFFFF6600);
  static const Color premiumAmber = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF252525)
                        : const Color(0xFFF9F9F9),
                  ),
                  child: Stack(
                    children: [
                      // Product Image
                      AspectRatio(
                        aspectRatio: 1,
                        child: Hero(
                          tag: "product_card_${product.id}",
                          child: product.image.isNotEmpty
                              ? Image.network(
                                  product.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/a/a3/Image-not-found.png',
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/a/a3/Image-not-found.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      // if (isOfficial)
                      //   Positioned(
                      //     top: 8,
                      //     left: 8,
                      //     child: Container(
                      //       padding: const EdgeInsets.symmetric(
                      //           horizontal: 6, vertical: 2),
                      //       decoration: BoxDecoration(
                      //         gradient: const LinearGradient(
                      //           colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                      //         ),
                      //         borderRadius: BorderRadius.circular(4),
                      //       ),
                      //       child: const Text(
                      //         "Mall",
                      //         style: TextStyle(
                      //           fontSize: 9,
                      //           fontWeight: FontWeight.bold,
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ),
                      //   ),

                      // Positioned(
                      //   bottom: 0,
                      //   right: 0,
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 8, vertical: 4),
                      //     decoration: const BoxDecoration(
                      //       color: Color(0xFFFFEBE3),
                      //       borderRadius:
                      //           BorderRadius.only(topLeft: Radius.circular(12)),
                      //     ),
                      //     child: Text(
                      //       "-$discount%",
                      //       style: const TextStyle(
                      //         fontSize: 10,
                      //         fontWeight: FontWeight.w900,
                      //         color: lazadaOrange,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),

                // Details Section
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 4,
                        runSpacing: 2,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "\$",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: lazadaOrange,
                                ),
                              ),
                              Text(
                                product.price.toStringAsFixed(
                                    product.price % 1 == 0 ? 0 : 2),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: lazadaOrange,
                                ),
                              ),
                            ],
                          ),

                          // Compare price (only if exists & higher)
                          if (product.comparePrice != null &&
                              product.comparePrice! > product.price)
                            Text(
                              "\$${product.comparePrice!.toStringAsFixed(product.comparePrice! % 1 == 0 ? 0 : 2)}",
                              style: TextStyle(
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${product.salesCount} sold",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
