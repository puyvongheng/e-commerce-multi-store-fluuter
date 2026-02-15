// lib/services/api_client.dart

import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'api_constants.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiClient {
//   File នេះ = API brain
// Dio = HTTP client
// CookieJar = session memory
// Interceptors = middleware
// Singleton = performance + consistency

  static Dio? _dio;
  static CookieJar? _cookieJar;

  static Future<Dio> getDio() async {
    if (_dio != null) return _dio!;

    if (!kIsWeb) {
      if (_cookieJar == null) {
        try {
          final appDocDir = await getApplicationDocumentsDirectory();
          final appDocPath = appDocDir.path;
          _cookieJar = PersistCookieJar(
            storage: FileStorage('$appDocPath/.cookies/'),
          );
        } catch (e) {
          _cookieJar = CookieJar();
        }
      }
    }

    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: ApiConstants.headers,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => status! < 500,
    ));

    if (!kIsWeb && _cookieJar != null) {
      _dio!.interceptors.add(CookieManager(_cookieJar!));
    }

    _dio!.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[DIO] $obj'),
    ));
    return _dio!;
  }

  static Future<void> clearCookies() async {
    if (_cookieJar != null) {
      await _cookieJar!.deleteAll();
    }
  }
}
