import 'package:rpl_notepad_fe/features/admin/domain/repositories/admin_repository.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/user_dto.dart';

class GetAllUsersUseCase {
  final AdminRepository repository;

  GetAllUsersUseCase(this.repository);

  Future<List<UserDto>> call() {
    return repository.getAllUsers();
  }
}
