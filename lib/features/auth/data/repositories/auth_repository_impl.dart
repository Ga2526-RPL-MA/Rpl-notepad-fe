import 'package:dio/dio.dart';
import 'package:rpl_notepad_fe/core/network/api_endpoint.dart';
import 'package:rpl_notepad_fe/core/network/api_service.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/login_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/login_response_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/logout_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/logout_response_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/register_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/register_response_dto.dart';
import 'package:rpl_notepad_fe/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService _api;

  AuthRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  @override
  Future<LoginResponseDto> login(LoginDto loginDto) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        APIEndpoint.login.path,
        data: loginDto.toJson(),
      );

      return LoginResponseDto.fromJson(response);
    } on DioException catch (e) {
      // Handle specific error types
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      }

      // Handle response-based error
      switch (e.response?.statusCode) {
        case 401:
        case 404:
          throw 'Email tidak ditemukan atau kata sandi salah.';
        case 403:
          throw 'Akses ditolak. Anda tidak memiliki izin.';
        case 500:
          throw 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
        default:
          final message = e.response?.data is Map
              ? (e.response?.data['message'] ??
                    'Terjadi kesalahan. Silakan coba lagi.')
              : 'Terjadi kesalahan. Silakan coba lagi.';
          throw message;
      }
    } catch (e) {
      if (e is String) {
        throw e;
      }

      throw 'Terjadi kesalahan tak terduga. Silakan coba lagi nanti.';
    }
  }

  @override
  Future<RegisterResponseDto> register(RegisterDto registerDto) async {
    try {
      final response = await _api.post<Map<String, dynamic>>(
        APIEndpoint.register.path,
        data: registerDto.toJson(),
      );

      return RegisterResponseDto.fromJson(response);
    } on DioException catch (e) {
      // Handle register errors with custom messages
      final responseData = e.response?.data;
      String errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';

      if (e.response != null) {
        if (e.response!.statusCode == 400) {
          errorMessage = responseData is Map && responseData['message'] != null
              ? responseData['message'].toString()
              : 'NRP sudah terdaftar';
        } else if (e.response!.statusCode == 500) {
          errorMessage = 'Terjadi kesalahan server. Silakan coba lagi nanti.';
        } else if (e.response!.statusCode == 404) {
          errorMessage = 'Endpoint tidak ditemukan. Silakan coba lagi nanti.';
        }
      }

      throw errorMessage;
    } catch (e) {
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  @override
  Future<LogoutResponseDto> logout(LogoutDto logoutDto) async {
    try {
      final response = await _api.post(
        APIEndpoint.logout.path,
        data: logoutDto.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer ${AuthService.token}'},
        ),
      );
      return LogoutResponseDto.fromJson(response);
    } catch (e) {
      throw e.toString().replaceAll('Exception: ', '');
    }
  }
}
