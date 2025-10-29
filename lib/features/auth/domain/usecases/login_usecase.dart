

import 'package:rpl_notepad_fe/features/auth/data/dtos/login_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/login_response_dto.dart';
import 'package:rpl_notepad_fe/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<LoginResponseDto> execute(LoginDto loginDto) async {
    return await repository.login(loginDto);
  }
}
