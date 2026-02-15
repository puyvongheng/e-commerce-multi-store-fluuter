import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/models/store.dart';
import 'package:app1/models/product.dart';
import 'package:app1/features/store/presentation/pages/store_profile_page.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreInfoSection extends StatelessWidget {
  final Store store;
  final Product? product;

  const StoreInfoSection({super.key, required this.store, this.product});

  Future<void> _contactTelegram() async {
    final telegramUser = store.telegram?.replaceAll('@', '') ?? '';
    if (telegramUser.isEmpty) return;

    String message = "Hello ${store.name}, I'm interested in ";
    if (product != null) {
      message += "${product!.name}. \nPrice: \$${product!.price}";
    } else {
      message += "your products.";
    }

    final url = Uri.parse(
        "https://t.me/$telegramUser?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color lazadaOrange = Color(0xFFFF6600);

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoreProfilePage(store: store),
                ),
              );
            },
            child: Row(
              children: [
                // Store Logo
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),

                  clipBehavior: Clip.antiAlias, // 👈 important
                  child: store.logo != null && store.logo!.isNotEmpty
                      ? Image.network(
                          store.logo!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return const Icon(
                              Icons.store_rounded,
                              color: Colors.grey,
                            );
                          },
                        )
                      : const Icon(
                          Icons.store_rounded,
                          color: Colors.grey,
                        ),
                ),

                const SizedBox(width: 12),

                // Store Name & Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            store.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (store.isVerified) const SizedBox(width: 4),
                          if (store.isVerified)
                            const Icon(Icons.verified,
                                size: 16, color: Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
                // Visit Store Button
              ],
            ),
          ),
        ],
      ),
    );
  }
}
