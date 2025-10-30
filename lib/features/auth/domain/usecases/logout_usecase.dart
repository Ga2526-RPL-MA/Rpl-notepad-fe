import 'package:rpl_notepad_fe/features/auth/data/dtos/logout_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/logout_response_dto.dart';
import 'package:rpl_notepad_fe/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<LogoutResponseDto> execute(LogoutDto logoutDto) async {
    return await repository.logout(logoutDto);
  }
}
