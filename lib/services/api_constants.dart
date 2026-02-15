// lib/services/api_constants.dart
class ApiConstants {
  // Use http://10.0.2.2:4000/api for Android Emulator
  // Use http://localhost:4000/api for iOS Simulator or Desktop
  static const String baseUrl = "http://localhost:4000/api";

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
