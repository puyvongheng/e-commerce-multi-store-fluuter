// lib/services/product_service.dart
import 'package:app1/models/product.dart';
import 'package:app1/models/category.dart';
import 'package:app1/models/slide.dart';
import 'package:app1/services/api_client.dart';
import 'package:dio/dio.dart';

import 'package:app1/services/api_constants.dart'; // Import ApiConstants

class ProductService {
  static Future<List<Slide>> fetchSlides() async {
    try {
      final dio = await ApiClient.getDio();
      final response = await dio.get('/slides');

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          final List<dynamic> slidesJson = response.data['data'];
          return slidesJson.map((json) {
            String image = json['image'];
            if (!image.startsWith('http')) {
              // Fallback if backend returns relative path (e.g. if APP_URL is not set)
              // ApiConstants.baseUrl usually ends with /api
              final host =
                  ApiConstants.baseUrl.replaceAll(RegExp(r'/api/?$'), '');
              json['image'] =
                  image.startsWith('/') ? '$host$image' : '$host/$image';
            }
            return Slide.fromJson(json);
          }).toList();
        }
      }
    } on DioException catch (e) {
      print("Error fetching slides: $e");
    }
    return [];
  }

  static Future<List<Product>> fetchProducts({
    int page = 1,
    int? storeId,
    int? categoryId,
    String? sortBy,
    String? search,
  }) async {
    String query = "?page=$page&limit=20";
    if (storeId != null) query += "&storeId=$storeId";
    if (categoryId != null) query += "&categoryId=$categoryId";
    if (sortBy != null) query += "&sortBy=$sortBy";
    if (search != null && search.isNotEmpty) query += "&search=$search";

    try {
      final dio = await ApiClient.getDio();
      final response = await dio.get('/shop$query');

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          final List<dynamic> productsJson = response.data['data'];
          return productsJson.map((json) => Product.fromJson(json)).toList();
        }
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to load products: ${e.response?.data}');
      }
    }
    throw Exception('Failed to load products');
  }

  static Future<Map<String, dynamic>> getCategories({int? categoryId}) async {
    try {
      final dio = await ApiClient.getDio();
      String url = '/categories';
      if (categoryId != null) url += '?categoryId=$categoryId';

      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> categoriesJson = response.data['data'];
        final List<Category> categories =
            categoriesJson.map((json) => Category.fromJson(json)).toList();

        List<Map<String, dynamic>> breadcrumbs = [];
        if (response.data['breadcrumbs'] != null) {
          breadcrumbs =
              List<Map<String, dynamic>>.from(response.data['breadcrumbs']);
        }

        return {
          'categories': categories,
          'breadcrumbs': breadcrumbs,
        };
      }
    } on DioException catch (e) {
      print("Error fetching categories: $e");
    }
    return {'categories': <Category>[], 'breadcrumbs': []};
  }

  static Future<Product> getProductDetail(int id) async {
    try {
      final dio = await ApiClient.getDio();
      final response = await dio.get('/product/$id');

      if (response.statusCode == 200) {
        if (response.data['success'] == true && response.data['data'] != null) {
          return Product.fromJson(response.data['data']);
        }
      }
    } on DioException catch (e) {
      throw Exception('Failed to load detail: ${e.message}');
    }
    throw Exception('Failed to load detail');
  }

  static Future<List<Product>> searchProducts({
    required String query,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int page = 1,
  }) async {
    Map<String, dynamic> params = {
      'q': query,
      'page': page,
      'limit': 20,
    };
    if (categoryId != null) params['categoryId'] = categoryId;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (sort != null) params['sort'] = sort;

    try {
      final dio = await ApiClient.getDio();
      final response = await dio.get('/search', queryParameters: params);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> productsJson = response.data['data'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      throw Exception('Search failed: ${e.message}');
    }
    return [];
  }

  static Future<List<Product>> fetchFlashSaleProducts({int page = 1}) async {
    String query = "?page=$page&limit=20";

    try {
      final dio = await ApiClient.getDio();
      final response = await dio.get('/flash-sale$query');

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          final List<dynamic> productsJson = response.data['data'];
          return productsJson.map((json) => Product.fromJson(json)).toList();
        }
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            'Failed to load flash sale products: ${e.response?.data}');
      }
    }
    throw Exception('Failed to load flash sale products');
  }
}
