import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app1/models/product.dart';
import 'package:app1/features/product/presentation/widgets/product_card.dart';
import 'package:app1/features/product/presentation/pages/product_detail_page.dart';

class RecommendedProductsSection extends StatelessWidget {
  final List<Product> products;

  const RecommendedProductsSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "You May Also Like",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int crossAxisCount = 3; // 3 columns on mobile as requested
              double childAspectRatio =
                  0.48; // Decreased from 0.55 to fix bottom overflow

              if (width > 1200) {
                crossAxisCount = 6;
                childAspectRatio = 0.75;
              } else if (width > 800) {
                crossAxisCount = 4;
                childAspectRatio = 0.7;
              } else if (width > 600) {
                crossAxisCount = 3;
                childAspectRatio = 0.65;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: products[index],
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(
                              initialProduct: products[index]),
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: (100 + index * 50).ms).scale(
                      begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
