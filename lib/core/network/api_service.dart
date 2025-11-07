import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';
import 'package:rpl_notepad_fe/core/network/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  late final Alice alice;

  ApiService._internal() {
    alice = Alice(
      configuration: AliceConfiguration(
        showNotification: true,
        showInspectorOnShake: true,
      ),
    );

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseURL,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Interceptor custom
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Hapus header CORS
        options.headers.remove('access-control-allow-origin');
        options.headers.remove('access-control-allow-methods');
        options.headers.remove('access-control-allow-headers');
        return handler.next(options);
      },
      onResponse: (response, handler) => handler.next(response),
      onError: (DioException e, handler) {
        if (e.response != null) {
          print('❌ Error response: ${e.response?.statusCode} - ${e.response?.data}');
        } else {
          print('❌ Error: ${e.message}');
        }
        return handler.next(e);
      },
    ));

    // Tambahkan adapter Alice
    final aliceAdapter = AliceDioAdapter();
    alice.addAdapter(aliceAdapter);
    _dio.interceptors.add(aliceAdapter);
  }

  Dio get client => _dio;

  // ====================
  // HTTP METHODS
  // ====================

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParams,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? e.message);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? e.message);
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? e.message);
    }
  }

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw Exception(e.response?.data?.toString() ?? e.message);
    }
  }
}
