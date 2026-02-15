// lib/features/home/presentation/widgets/example_products.dart

import 'package:app1/models/product.dart';

class ExampleProducts {
  static List<Product> getSampleProducts() {
    return [
      Product(
        id: 1,
        salesCount: 100,
        name: "Wireless Bluetooth Headphones",
        price: 79.99,
        image:
            "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400",
      ),
      Product(
        id: 2,
        salesCount: 200,
        name: "Smart Watch Series 7",
        price: 299.99,
        image:
            "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400",
      ),
      Product(
        id: 3,
        salesCount: 300,
        name: "Portable Power Bank 20000mAh",
        price: 34.99,
        image:
            "https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400",
      ),
    ];
  }
}
