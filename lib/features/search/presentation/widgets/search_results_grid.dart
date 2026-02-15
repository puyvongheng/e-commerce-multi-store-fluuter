import 'package:app1/features/product/presentation/pages/product_detail_page.dart';
import 'package:app1/features/product/presentation/widgets/product_card.dart';
import 'package:app1/models/product.dart';
import 'package:flutter/material.dart';

class SearchResultsGrid extends StatelessWidget {
  final List<Product> products;
  final String? error;

  const SearchResultsGrid({
    super.key,
    required this.products,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Text(
          error!,
          style: TextStyle(color: Colors.red[400]),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Use LayoutBuilder to be responsive
    return LayoutBuilder(builder: (context, constraints) {
      // Simple responsive logic:
      // If width < 600 (mobile), 2 columns.
      // If width >= 600 (tablet+), 3 or more.
      final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

      // Adjust aspect ratio based on card content needs.
      // ProductCard usually needs about 0.65 - 0.75 ratio for tall images + text.
      // To fix overflow, we can decrease the aspect ratio (make it taller)
      // OR fix the ProductCard itself.
      // Let's try a safer aspect ratio first.
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio:
              0.55, // Adjusted to prevent bottom overflow on mobile
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(
            product: products[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProductDetailPage(initialProduct: products[index]),
                ),
              );
            },
          );
        },
      );
    });
  }
}
