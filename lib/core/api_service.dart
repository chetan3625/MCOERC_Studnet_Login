import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    BaseOptions options = BaseOptions(
      baseUrl: 'https://matoshri-hackathon-backend.onrender.com/api',
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
    );
    _dio = Dio(options);
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        debugPrint('API Error: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  Future<Response> post(String path, dynamic data) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> get(String path) async {
    return await _dio.get(path);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }

  Future<Response> put(String path, dynamic data) async {
    return await _dio.put(path, data: data);
  }
}
