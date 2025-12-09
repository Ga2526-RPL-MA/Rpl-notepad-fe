import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rpl_notepad_fe/core/network/api_config.dart';
import 'package:rpl_notepad_fe/core/router/navigation_service.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/core/widgets/no_connection_page.dart';
import 'package:rpl_notepad_fe/core/widgets/toast_notification.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  late final Alice alice;

  ApiService._internal() {
    alice = Alice(
      configuration: AliceConfiguration(
        showNotification: false,
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
        validateStatus: (status) => status != null && status < 400,
      ),
    );

    // Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Authorization header
          final token = await AuthService.token;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Delete header
          options.headers.remove('access-control-allow-origin');
          options.headers.remove('access-control-allow-methods');
          options.headers.remove('access-control-allow-headers');
          return handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (DioException e, handler) async {
          // Handle network errors globally
          if (_isNetworkIssue(e)) {
            if (!kIsWeb) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final nav = navigatorKey.currentState;
                if (nav != null) {
                  nav.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const NoConnectionPage()),
                    (route) => false,
                  );
                }
              });
            }
          }
          if (e.response != null) {
            print(
              'Error response: ${e.response?.statusCode} - ${e.response?.data}',
            );

            // Global 401/403
            if (e.response?.statusCode == 401 ||
                e.response?.statusCode == 403) {
              try {
                final ctx = navigatorKey.currentContext;
                if (ctx != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showAppToast(
                      ctx,
                      message: 'Sesi login telah berakhir. Silakan login lagi.',
                      type: AppToastType.info,
                      duration: const Duration(seconds: 3),
                    );
                  });
                }
              } catch (_) {}

              try {
                await AuthService.clearToken();
              } catch (_) {}

              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          } else {
            print('Error: ${e.message}');
          }
          return handler.next(e);
        },
      ),
    );

    // Alice
    final aliceAdapter = AliceDioAdapter();
    alice.addAdapter(aliceAdapter);
    _dio.interceptors.add(aliceAdapter);
  }

  Dio get client => _dio;

  bool _isNetworkIssue(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.error?.toString().contains('SocketException') == true;
  }

  // HTTP METHODS

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

      if (response.data == null) {
        throw Exception('Response kosong dari server (GET $path)');
      }

      return response.data as T;
    } on DioException catch (e) {
      if (_isNetworkIssue(e)) {
        if (!kIsWeb) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final nav = navigatorKey.currentState;
            if (nav != null) {
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const NoConnectionPage()),
                (route) => false,
              );
            }
          });
        }
        throw Exception('no_internet');
      }
      rethrow;
    }
  }

  Future<T> post<T>(String path, {dynamic data, Options? options}) async {
    try {
      final response = await _dio.post(path, data: data, options: options);
      return response.data as T;
    } on DioException catch (e) {
      if (_isNetworkIssue(e)) {
        if (!kIsWeb) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final nav = navigatorKey.currentState;
            if (nav != null) {
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const NoConnectionPage()),
                (route) => false,
              );
            }
          });
        }
        throw Exception('no_internet');
      }
      rethrow;
    }
  }

  Future<T> put<T>(String path, {dynamic data, Options? options}) async {
    try {
      final response = await _dio.put<T>(path, data: data, options: options);

      if (response.data == null) {
        throw Exception('Response kosong dari server (PUT $path)');
      }

      return response.data as T;
    } on DioException {
      rethrow;
    }
  }

  Future<T> patch<T>(String path, {dynamic data, Options? options}) async {
    try {
      final response = await _dio.patch<T>(path, data: data, options: options);

      if (response.data == null) {
        throw Exception('Response kosong dari server (PATCH $path)');
      }

      return response.data as T;
    } on DioException {
      rethrow;
    }
  }

  Future<T> delete<T>(String path, {dynamic data, Options? options}) async {
    try {
      final response = await _dio.delete<T>(path, data: data, options: options);

      if (response.data == null) {
        throw Exception('Response kosong dari server (DELETE $path)');
      }

      return response.data as T;
    } on DioException {
      rethrow;
    }
  }
}
