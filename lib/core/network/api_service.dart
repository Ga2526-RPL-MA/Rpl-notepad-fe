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
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 5000),
      ),
    );
    final aliceAdapter = AliceDioAdapter();
    alice.addAdapter(aliceAdapter);
    _dio.interceptors.add(aliceAdapter);
  }

  Dio get client => _dio;

  // GET
  Future<T> get<T>(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      return response.data as T;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // POST
  Future<T> post<T>(String path, {dynamic data, Options? options}) async {
    try {
      final response = await _dio.post(path, data: data, options: options);
      return response.data as T;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message);
    }
  }

  // TODO: Add PUT, DELETE
}
