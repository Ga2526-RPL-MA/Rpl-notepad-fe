import 'package:rpl_notepad_fe/core/network/api_endpoint.dart';
import 'package:rpl_notepad_fe/core/network/api_sevice.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/login_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/login_response_dto.dart';
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
}
