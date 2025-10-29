

import 'package:rpl_notepad_fe/features/auth/data/dtos/login_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/login_response_dto.dart';

abstract class AuthRepository {
  Future<LoginResponseDto> login(LoginDto loginDto);
}
