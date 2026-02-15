import 'package:app1/models/attribute_option.dart';

class ProductVariant {
  final int id;
  final int productId;
  final String? sku;
  final double? price;
  final int qty;
  final String? image;
  final List<AttributeOption> attributeOptions;

  ProductVariant({
    required this.id,
    required this.productId,
    this.sku,
    this.price,
    required this.qty,
    this.image,
    this.attributeOptions = const [],
  });

  String get attributesSummary {
    if (attributeOptions.isEmpty) return sku ?? 'Default';
    return attributeOptions.map((e) => e.value).join(', ');
  }

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    var options = <AttributeOption>[];
    if (json['attributeOptions'] != null) {
      json['attributeOptions'].forEach((v) {
        options.add(AttributeOption.fromJson(v));
      });
    } else if (json['variantOptions'] != null) {
      // Sometimes it might come as variantOptions depending on the API include structure
      json['variantOptions'].forEach((v) {
        if (v['attributeOption'] != null) {
          options.add(AttributeOption.fromJson(v['attributeOption']));
        }
      });
    }

    return ProductVariant(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      sku: json['sku'],
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      qty: json['qty'] ?? 0,
      image: json['image'],
      attributeOptions: options,
    );
  }
}
