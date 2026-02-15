import 'package:app1/models/product.dart';
import 'package:app1/models/product_variant.dart';
import 'package:app1/models/store.dart';

class OrderItem {
  final int id;
  final int productId;
  final int quantity;
  final double price;
  final Product? product;
  final ProductVariant? productVariant;

  OrderItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
    this.productVariant,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      quantity: json['quantity'] ?? 1,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      product: (json['product'] ?? json['Product']) != null
          ? Product.fromJson(json['product'] ?? json['Product'])
          : null,
      productVariant: (json['productVariant'] ?? json['ProductVariant']) != null
          ? ProductVariant.fromJson(
              json['productVariant'] ?? json['ProductVariant'])
          : null,
    );
  }
}

class Order {
  final int id;
  final String? orderNumber;
  final int? userId;
  final String? paymentStatus;
  final double? totalPrice;
  final double? subtotal;
  final double? shipping;
  final double? discount;
  final String? status;
  final String? shippingAddress;
  final String? trackingNumber;
  final String? notes;
  final DateTime createdAt;
  final List<OrderItem> items;
  final Store? store;

  Order({
    required this.id,
    this.orderNumber,
    this.userId,
    this.totalPrice,
    this.subtotal,
    this.shipping,
    this.discount,
    this.status,
    this.paymentStatus,
    this.shippingAddress,
    this.trackingNumber,
    this.notes,
    required this.createdAt,
    this.items = const [],
    this.store,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse Items
    var itemsList = <OrderItem>[];
    final itemsJson = json['orderItems'] ?? json['OrderItems'];
    if (itemsJson is List) {
      for (final v in itemsJson) {
        itemsList.add(OrderItem.fromJson(v));
      }
    }

    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['orderNumber'],
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0'),
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0'),
      shipping: double.tryParse(json['shipping']?.toString() ?? '0'),
      discount: double.tryParse(json['discount']?.toString() ?? '0'),
      status: json['status'],
      paymentStatus: json['paymentStatus'],
      shippingAddress: json['shippingAddress'],
      trackingNumber: json['trackingNumber'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      items: itemsList,
      store: (json['store'] ?? json['Store']) != null
          ? Store.fromJson(json['store'] ?? json['Store'])
          : null,
    );
  }
}
