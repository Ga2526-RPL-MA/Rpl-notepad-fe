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
      final response = await _api.post(
        APIEndpoint.login.path,
        data: loginDto.toJson(),
      );
      return LoginResponseDto.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RegisterResponseDto> register(RegisterDto registerDto) async {
    try {
      final response = await _api.post(
        APIEndpoint.register.path,
        data: registerDto.toJson(),
      );
      return RegisterResponseDto.fromJson(response);
    } catch (e) {
      rethrow;
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
      rethrow;
    }
  }
}
