// lib/services/order_service.dart
import 'package:app1/services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class OrderService {
  static Future<Map<String, dynamic>> getCheckoutData(
      int userId, List<int> itemIds) async {
    try {
      final dio = await ApiClient.getDio();
      final response = await dio.get('/checkout', queryParameters: {
        'userId': userId,
        'items': itemIds.join(','),
      });
      if (response.data['success'] == true) {
        return response.data;
      }
      throw Exception('Failed to load checkout data');
    } catch (e) {
      throw Exception('Failed to load checkout data: $e');
    }
  }

  static Future<void> placeOrder(
      int userId, int addressId, String paymentMethod,
      {List<int>? selectedCartItemIds,
      Map<String, dynamic>? storeDeliveryMethods,
      String? couponCode}) async {
    try {
      final dio = await ApiClient.getDio();
      final response = await dio.post(
        '/checkout',
        data: {
          'userId': userId,
          'addressId': addressId,
          'paymentMethod': paymentMethod,
          'notes': 'Order via Flutter App',
          'selectedCartItemIds': selectedCartItemIds,
          'storeDeliveryMethods': storeDeliveryMethods,
          'couponCode': couponCode,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Checkout failed: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception('Checkout failed: ${e.response?.data ?? e.message}');
    }
  }

  static Future<List<dynamic>> getOrders(int userId) async {
    try {
      final dio = await ApiClient.getDio();
      final response = await dio.get('/orders');
      debugPrint('Orders response');

      if (response.statusCode == 200) {
        if (response.data['success'] == true && response.data['data'] != null) {
          return response.data['data'];
        }
        return [];
      } else {
        throw Exception('Failed to load orders');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load orders');
    }
  }

  static Future<Map<String, dynamic>> validateCoupon(String code) async {
    try {
      final dio = await ApiClient.getDio();
      final response =
          await dio.post('/coupons/validate', data: {'code': code});
      return response.data;
    } catch (e) {
      throw Exception('Failed to validate coupon: $e');
    }
  }
}
