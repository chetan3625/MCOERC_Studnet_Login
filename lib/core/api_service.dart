import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    BaseOptions options = BaseOptions(
      baseUrl: 'https://matoshri-hackathon-backend-1.onrender.com/api',
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
        String message = 'An unexpected error occurred';
        
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout || 
            e.type == DioExceptionType.sendTimeout) {
          message = 'Connection timed out. Please check your internet.';
        } else if (e.type == DioExceptionType.connectionError || 
                   e.message?.contains('SocketException') == true ||
                   e.message?.contains('Failed host lookup') == true) {
          message = 'Server unreachable. Please check your internet or backend status.';
        } else if (e.response != null) {
          message = e.response?.data['error'] ?? 'Server error: ${e.response?.statusCode}';
        }

        // Add user-friendly message to the error
        final customError = DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: e.error,
          message: message,
        );
        
        return handler.next(customError);
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
