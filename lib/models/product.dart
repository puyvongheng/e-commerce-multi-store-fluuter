import 'package:app1/models/store.dart';
import 'package:app1/models/product_variant.dart';

class Product {
  final int id;
  final String name;
  final double price;
  final double? comparePrice;
  final String image;
  final int? qty;
  final int salesCount;
  final String? description;
  final Store? store;
  final List<ProductVariant> variants;

  Product({
    required this.id,
    required this.name,
    this.qty,
    this.comparePrice,
    required this.salesCount,
    required this.price,
    required this.image,
    this.description,
    this.store,
    this.variants = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var variantsList = <ProductVariant>[];
    if (json['productVariants'] != null) {
      json['productVariants'].forEach((v) {
        variantsList.add(ProductVariant.fromJson(v));
      });
    }

    return Product(
      id: json['id'] ?? 0,
      qty: json['qty'] ?? 0,
      salesCount: json['salesCount'] ?? 0,
      name: json['name'] ?? 'No Name',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      comparePrice: double.tryParse(json['comparePrice'].toString()) ?? null,
      image: json['image'] ?? '',
      description: json['description'],
      store: json['store'] != null ? Store.fromJson(json['store']) : null,
      variants: variantsList,
    );
  }
}
