import 'package:app1/services/api_client.dart';
import 'package:app1/models/payment_method.dart';
import 'package:flutter/material.dart';

class PaymentService {
  static Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final dio = await ApiClient.getDio();
      final response = await dio.get('/payment/methods');
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PaymentMethod.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching payment methods: ");
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getWalletData() async {
    try {
      final dio = await ApiClient.getDio();
      final response = await dio.get('/payment/wallet/balance');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
    } catch (e) {
      debugPrint("Error fetching wallet data:");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> generateTopUpQR(double amount) async {
    try {
      final dio = await ApiClient.getDio();
      final response = await dio.post(
        '/payment/wallet/topup/generate',
        data: {'amount': amount},
      );
      if (response.data['success'] == true) {
        return response.data;
      }
    } catch (e) {
      debugPrint("Error generating top-up QR: ");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> checkTopUpStatus(String md5) async {
    try {
      final dio = await ApiClient.getDio();
      final response = await dio.get('/payment/wallet/topup/status/$md5');
      if (response.data['success'] == true) {
        return response.data;
      }
    } catch (e) {
      debugPrint("Error checking top-up status: ");
    }
    return null;
  }
}
