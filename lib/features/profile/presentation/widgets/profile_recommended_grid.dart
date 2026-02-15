import 'package:app1/features/product/presentation/pages/product_detail_page.dart';
import 'package:app1/features/product/presentation/widgets/product_card.dart';
import 'package:app1/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfileRecommendedGrid extends StatelessWidget {
  final List<Product> products;

  const ProfileRecommendedGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 900
              ? 4
              : MediaQuery.of(context).size.width > 600
                  ? 3
                  : 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ProductCard(
              product: products[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(
                      initialProduct: products[index],
                    ),
                  ),
                );
              },
            )
                .animate()
                .fadeIn(delay: (index * 100).ms)
                .moveY(begin: 20, end: 0);
          },
          childCount: products.length,
        ),
      ),
    );
  }
}
