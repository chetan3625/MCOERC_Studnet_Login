import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    BaseOptions options = BaseOptions(
      baseUrl: 'https://matoshri-hackathon-backend.onrender.com/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );
    _dio = Dio(options);
    
    _dio.interceptors.add(InterceptorsWrapper(
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
}
