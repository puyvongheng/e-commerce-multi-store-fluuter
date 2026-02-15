import 'package:app1/models/product.dart';
import 'package:app1/models/product_variant.dart';

class CartItem {
  final int id;
  final int cartId;
  final int productId;
  final int quantity;
  final bool isSavedLater;
  final int? productVariantId;
  final Product? product;
  final ProductVariant? productVariant;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    this.isSavedLater = false,
    this.productVariantId,
    this.product,
    this.productVariant,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      cartId: json['cartId'],
      productId: json['productId'],
      quantity: json['quantity'] ?? 1,
      isSavedLater: json['isSavedLater'] ?? false,
      productVariantId: json['productVariantId'],
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
      productVariant: json['productVariant'] != null
          ? ProductVariant.fromJson(json['productVariant'])
          : null,
    );
  }
}

class Cart {
  final int id;
  final int userId;
  final List<CartItem> cartItems;

  Cart({
    required this.id,
    required this.userId,
    this.cartItems = const [],
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    var list = <CartItem>[];
    if (json['cartItems'] != null) {
      json['cartItems'].forEach((v) {
        list.add(CartItem.fromJson(v));
      });
    }
    return Cart(
      id: json['id'],
      userId: json['userId'],
      cartItems: list,
    );
  }
}
