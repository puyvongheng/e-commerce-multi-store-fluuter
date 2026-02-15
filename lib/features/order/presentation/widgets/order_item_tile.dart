import 'package:flutter/material.dart';
import 'package:app1/models/order.dart';
import 'package:app1/features/product/presentation/pages/product_detail_page.dart';

class OrderItemTile extends StatelessWidget {
  final OrderItem item;
  final bool isDark;

  static const Color lazadaOrange = Color(0xFFFF6600);

  const OrderItemTile({
    super.key,
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final storeName = product?.store?.name ?? "Official Store";

    return InkWell(
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                image: product?.image != null && product!.image.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(product.image), fit: BoxFit.cover)
                    : null,
              ),
              child: product?.image == null || product!.image.isEmpty
                  ? Icon(Icons.shopping_bag_outlined,
                      size: 28, color: Colors.grey[400])
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product?.name ?? "Product #${item.productId}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: lazadaOrange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.storefront_rounded,
                            size: 12, color: lazadaOrange),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        storeName,
                        style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16),
                ),
                Text(
                  "x${item.quantity}",
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
