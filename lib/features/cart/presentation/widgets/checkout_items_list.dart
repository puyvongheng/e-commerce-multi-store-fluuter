import 'package:flutter/material.dart';
import 'package:app1/models/product.dart';
import 'package:app1/models/product_variant.dart';

class CheckoutItemsList extends StatelessWidget {
  final List<dynamic> selectedItems;
  final bool isDark;

  const CheckoutItemsList({
    super.key,
    required this.selectedItems,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const Color lazadaOrange = Color(0xFFFF6600);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? Colors.white10
        : const Color.fromARGB(255, 76, 76, 76).withOpacity(0.1);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: selectedItems.map((item) {
          if (item == null || item is! Map<String, dynamic>) {
            return const SizedBox.shrink();
          }

          final productData = item['Product'] ?? item['product'];
          final variantData = item['ProductVariant'] ?? item['productVariant'];
          final quantity = item['quantity'] ?? 1;

          if (productData == null || productData is! Map<String, dynamic>) {
            return const SizedBox.shrink();
          }

          final Product product = Product.fromJson(productData);
          final ProductVariant? variant =
              (variantData != null && variantData is Map<String, dynamic>)
                  ? ProductVariant.fromJson(variantData)
                  : null;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey[100]!,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                    image: DecorationImage(
                      image: NetworkImage(variant?.image ?? product.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (variant != null)
                        Text(
                          variant.attributesSummary,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        "x$quantity",
                        style: const TextStyle(
                          fontSize: 13,
                          color: lazadaOrange,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "\$${((variant?.price ?? product.price) * quantity).toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
