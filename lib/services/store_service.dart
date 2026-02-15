import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app1/models/store.dart';
import 'api_constants.dart';

class StoreService {
  static Future<List<Store>> fetchStores() async {
    final url = Uri.parse("${ApiConstants.baseUrl}/stores");

    try {
      final response = await http.get(url, headers: ApiConstants.headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> storesJson = data['data'];
          return storesJson.map((json) => Store.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error fetching stores: $e');
    }
    return [];
  }

  static Future<Store?> fetchStoreDetail(int id) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/stores/$id");

    try {
      final response = await http.get(url, headers: ApiConstants.headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Store.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('Error fetching store detail: $e');
    }
    return null;
  }
}
