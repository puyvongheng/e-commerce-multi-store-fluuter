import 'package:flutter/material.dart';
import 'package:app1/features/product/presentation/pages/product_detail_page.dart';
import 'package:app1/models/product.dart';
import 'package:app1/models/product_variant.dart';

class CartItemTile extends StatelessWidget {
  final dynamic item;
  final bool isSelected;
  final Function(bool?) onToggle;
  final Function(int) onUpdateQuantity;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onToggle,
    required this.onUpdateQuantity,
    required this.onRemove,
  });

  static const Color lazadaOrange = Color(0xFFFF6600);

  @override
  Widget build(BuildContext context) {
    // 1. Data Parsing
    final productData = item['Product'] ?? item['product'];
    if (productData == null) return const SizedBox.shrink();

    final Product product = Product.fromJson(productData);
    final variantData = item['ProductVariant'] ?? item['productVariant'];
    final ProductVariant? variant =
        variantData != null ? ProductVariant.fromJson(variantData) : null;

    final int quantity = item['quantity'] ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colors
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? Colors.white10
        : const Color.fromARGB(255, 47, 47, 47).withOpacity(0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductDetailPage(initialProduct: product),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Checkbox (Centered Vertically)
                Padding(
                  padding: const EdgeInsets.only(top: 24, right: 8),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isSelected,
                      activeColor: lazadaOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
                        width: 1.5,
                      ),
                      onChanged: onToggle,
                    ),
                  ),
                ),

                // 3. Product Image (Larger & Rounded)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                    image: (variant?.image ?? product.image).isNotEmpty
                        ? DecorationImage(
                            image:
                                NetworkImage(variant?.image ?? product.image),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (variant?.image ?? product.image).isEmpty
                      ? Icon(Icons.image_not_supported_rounded,
                          color: Colors.grey[400])
                      : null,
                ),

                const SizedBox(width: 12),

                // 4. Product Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Title + Delete Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: isDark ? Colors.white : Colors.black87,
                                height: 1.2,
                              ),
                            ),
                          ),
                          // Subtle Delete Button at top right
                          InkWell(
                            onTap: onRemove,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Variant Chip
                      if (variant != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            variant.attributesSummary,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark ? Colors.grey[300] : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // Footer: Price + Quantity Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Text(
                            "\$${(variant?.price ?? product.price).toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: lazadaOrange,
                            ),
                          ),

                          // Modern Quantity Stepper
                          Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildQtyBtn(Icons.remove_rounded,
                                    () => onUpdateQuantity(-1), isDark),
                                Container(
                                  width: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.symmetric(
                                      vertical: BorderSide(
                                        color: isDark
                                            ? Colors.grey[700]!
                                            : Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "$quantity",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                _buildQtyBtn(Icons.add_rounded,
                                    () => onUpdateQuantity(1), isDark),
                              ],
                            ),
                          ),
                        ],
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

  // Helper for Quantity Buttons
  Widget _buildQtyBtn(IconData icon, VoidCallback onPressed, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            icon,
            size: 16,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
