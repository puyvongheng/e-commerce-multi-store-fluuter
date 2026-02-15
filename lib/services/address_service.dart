import 'package:app1/services/api_client.dart';

class AddressService {
  static Future<List<dynamic>> getAddresses(int userId) async {
    final dio = await ApiClient.getDio();
    final response = await dio.get('/address/user/$userId');
    if (response.data['success'] == true) {
      return response.data['data'];
    }
    return [];
  }

  static Future<Map<String, dynamic>> addAddress(
      Map<String, dynamic> addressData) async {
    final dio = await ApiClient.getDio();
    final response = await dio.post('/address/add', data: addressData);
    return response.data;
  }

  static Future<Map<String, dynamic>> updateAddress(
      int id, Map<String, dynamic> addressData) async {
    final dio = await ApiClient.getDio();
    final response = await dio.put('/address/update/$id', data: addressData);
    return response.data;
  }

  static Future<void> deleteAddress(int id) async {
    final dio = await ApiClient.getDio();
    await dio.delete('/address/delete/$id');
  }
}
