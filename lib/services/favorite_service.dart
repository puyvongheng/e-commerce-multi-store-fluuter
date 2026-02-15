import 'package:app1/models/product.dart';
import 'package:app1/services/api_client.dart';
import 'package:dio/dio.dart';

class FavoriteService {
  static Future<List<Product>> getFavorites() async {
    try {
      final dio = await ApiClient.getDio();
      final response = await dio.get('/favorite');

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data
            .where((item) => item['product'] != null)
            .map((item) => Product.fromJson(item['product']))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load favorites: $e');
    }
  }

  static Future<Map<String, dynamic>> toggleFavorite(int productId) async {
    try {
      final dio = await ApiClient.getDio();
      final response = await dio.post('/favorite/toggle', data: {
        'productId': productId,
      });

      return response.data;
    } on DioException catch (e) {
      throw Exception(
          'Failed to update favorite: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to update favorite: $e');
    }
  }
}
