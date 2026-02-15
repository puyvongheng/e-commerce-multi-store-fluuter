// lib/services/cart_service.dart
import 'package:app1/services/api_client.dart';
import 'package:dio/dio.dart';

class CartService {
  static Future<Map<String, dynamic>> getCart(int userId) async {
    try {
      final dio = await ApiClient.getDio();
      final response = await dio.get('/cart');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load cart');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load cart: ${e.response?.data ?? e.message}');
    }
  }

  static Future<void> addToCart(int userId, int productId, int quantity,
      {int? variantId}) async {
    try {
      final dio = await ApiClient.getDio();
      final response = await dio.post(
        '/cart/add',
        data: {
          'productId': productId,
          'quantity': quantity,
          'variantId': variantId,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update cart: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to update cart: ${e.response?.data ?? e.message}');
    }
  }

  static Future<void> deleteFromCart(int userId, int productId,
      {int? variantId}) async {
    try {
      final dio = await ApiClient.getDio();
      final response = await dio.post(
        '/cart/remove',
        data: {
          'productId': productId,
          'variantId': variantId,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove item: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception(
          'Failed to remove item: ${e.response?.data ?? e.message}');
    }
  }
}
