import 'package:rpl_notepad_fe/features/auth/data/dtos/login_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/login_response_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/logout_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/logout_response_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/register_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/register_response_dto.dart';

abstract class AuthRepository {
  Future<LoginResponseDto> login(LoginDto loginDto);
  Future<RegisterResponseDto> register(RegisterDto registerDto);
  Future<LogoutResponseDto> logout(LogoutDto logoutDto);
}
