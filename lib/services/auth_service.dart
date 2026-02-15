// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final dio = await ApiClient.getDio();

      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Cookies are automatically saved by CookieManager
        return response.data;
      } else {
        throw Exception('Login failed: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Login failed: ${e.response!.data}');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    }
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final dio = await ApiClient.getDio();

      final response = await dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Registration failed: ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Registration failed: ${e.response!.data}');
      } else {
        throw Exception('Registration failed: ${e.message}');
      }
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final dio = await ApiClient.getDio();

      final response = await dio.get('/me');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load profile');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to load profile: ${e.response!.data}');
      } else {
        throw Exception('Failed to load profile: ${e.message}');
      }
    }
  }

  static Future<void> logout() async {
    // Clear cookies on logout
    await ApiClient.clearCookies();
  }
}
