import 'package:flutter/material.dart';
import 'package:app1/models/product.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math'; // 👈 required

class ProductActionBottomBar extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final VoidCallback onStoreTap;

  const ProductActionBottomBar({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onStoreTap,
  });

  Future<void> _contactTelegram() async {
    final store = product.store;
    if (store == null || store.telegram == null || store.telegram!.isEmpty)
      return;

    final telegramUser = store.telegram!.replaceAll('@', '');
    final productUrl = "https://yourapp.com/product/${product.id}"; // Dummy URL
    final message = "សួស្តី ${store.name} ខ្ញុំចាប់អារម្មណ៍លើផលិតផលនេះ៖\n"
        "ឈ្មោះ៖ ${product.name}\n"
        "លេខសម្គាល់៖ ${product.id}\n"
        "តម្លៃ៖ \$${product.price}\n"
        "តំណភ្ជាប់៖ $productUrl";

    final url = Uri.parse(
        "https://t.me/$telegramUser?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color lazadaOrange = Color(0xFFFF6600);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        // ពណ៌ទឹកដោះគោខាប់ (Condensed Milk)
        borderRadius: BorderRadius.circular(50), // កោងខ្លាំងបែប iOS Modern
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Shop Icon
            // Shop Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: onStoreTap,
                  child: Center(
                    child: product.store?.logo != null &&
                            product.store!.logo!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              product.store!.logo!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.storefront_outlined,
                                color: Color(0xFF4E342E),
                                size: 24,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.storefront_outlined,
                            color: Color(0xFF4E342E),
                            size: 24,
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Telegram Icon (Replaced Chat/Cart)
            Container(
              decoration: BoxDecoration(
                // ពណ៌ទឹកដោះគោខាប់ (Condensed Milk)
                borderRadius:
                    BorderRadius.circular(50), // កោងខ្លាំងបែប iOS Modern
              ),
              width: 44,
              height: 44,
              child: Material(
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: _contactTelegram,
                  child: Center(
                    child: Transform.rotate(
                      angle: -30 * pi / 180, // 30°
                      child: const Icon(
                        Icons.send_rounded,
                        color: Color(0xFF229ED9),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),
            // Cart Button
            Expanded(
              child: GestureDetector(
                onTap: onAddToCart,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 102, 0),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Center(
                    child: Text(
                      "Add to Cart",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Buy Now Button
            // Expanded(
            //   child: GestureDetector(
            //     onTap: onBuyNow,
            //     child: Container(
            //       height: 48,
            //       decoration: const BoxDecoration(
            //         gradient: LinearGradient(
            //           colors: [lazadaOrange, Color(0xFFFF8833)],
            //         ),
            //         borderRadius: BorderRadius.only(
            //           topRight: Radius.circular(24),
            //           bottomRight: Radius.circular(24),
            //         ),
            //       ),
            //       child: const Center(
            //         child: Text(
            //           "Buy Now",
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontWeight: FontWeight.bold,
            //             fontSize: 14,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
