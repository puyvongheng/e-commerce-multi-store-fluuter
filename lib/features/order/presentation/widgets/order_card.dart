import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app1/models/order.dart';
import 'package:app1/features/order/presentation/widgets/payment_status_badge.dart';
import 'package:app1/features/order/presentation/widgets/order_status_badge.dart';
import 'package:app1/features/product/presentation/pages/product_detail_page.dart';
import 'package:app1/features/order/presentation/pages/order_detail_page.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool isDark;

  static const Color lazadaOrange = Color(0xFFFF6600);

  const OrderCard({
    super.key,
    required this.order,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Styling constants
    final cardColor = isDark ? const Color(0xFF1E2026) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final labelColor = isDark ? Colors.white54 : Colors.grey[600];
    final dividerColor = isDark ? Colors.white10 : Colors.grey[200];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(order: order, isDark: isDark),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: dividerColor!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Receipt ID & Date | Status
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          "#${order.orderNumber ?? 'N/A'}",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(order.createdAt),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 6),
                      OrderStatusBadge(status: order.status ?? 'pending'),
                    ],
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: dividerColor),

            // Items List
            ...order.items.map((item) =>
                _buildReceiptItem(context, item, textColor, labelColor)),

            Divider(height: 1, color: dividerColor),

            // Footer: Settled Amount
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          PaymentStatusBadge(
                              status: order.paymentStatus ?? 'pending'),
                          const SizedBox(width: 6),
                          Text(
                            "\$${order.totalPrice?.toStringAsFixed(2) ?? '0.00'}",
                            style: TextStyle(
                              color:
                                  textColor, // Use primary text color for value, or orange if preferred
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptItem(BuildContext context, OrderItem item,
      Color textColor, Color? labelColor) {
    // Logic to build detailed item row without depending on OrderItemTile if we want full custom look
    // Or we can keep using OrderItemTile. Let's build a custom one here to match the image exactly.
    final product = item.product;
    return GestureDetector(
      onTap: () {
        if (product != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(initialProduct: product),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                image: product?.image != null && product!.image.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(product.image),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: product?.image == null || product!.image.isEmpty
                  ? Icon(Icons.image_not_supported, size: 20, color: labelColor)
                  : null,
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product?.name ?? "Product Name",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Variant Chips
                  if (item.productVariant != null &&
                      item.productVariant!.attributeOptions.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        ...item.productVariant!.attributeOptions.map((option) {
                          final attrName =
                              option.attributeName?.toUpperCase() ?? '';
                          final attrValue = option.value;
                          if (attrName.isNotEmpty && attrValue.isNotEmpty) {
                            return _buildVariantChip("$attrName: $attrValue");
                          }
                          return null;
                        }).whereType<Widget>(),
                        _buildVariantChip("QTY: ${item.quantity}"),
                        _buildVariantChip(
                            "PRICE: \$${item.price.toStringAsFixed(2)}"),
                      ],
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildVariantChip("QTY: ${item.quantity}"),
                        _buildVariantChip(
                            "PRICE: \$${item.price.toStringAsFixed(2)}"),
                      ],
                    ),
                ],
              ),
            ),

            // Total
            const SizedBox(width: 12),
            Text(
              "\$${(item.price * item.quantity).toStringAsFixed(2)}",
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2C32) : Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[700],
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
