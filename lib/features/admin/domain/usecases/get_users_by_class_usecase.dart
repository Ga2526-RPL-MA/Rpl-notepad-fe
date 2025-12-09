import 'package:rpl_notepad_fe/features/admin/domain/repositories/admin_repository.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/user_dto.dart';

class GetUsersByClassUseCase {
  final AdminRepository repository;

  GetUsersByClassUseCase(this.repository);

  Future<List<UserDto>> call(int classId) {
    return repository.getUsersByClass(classId);
  }
}
