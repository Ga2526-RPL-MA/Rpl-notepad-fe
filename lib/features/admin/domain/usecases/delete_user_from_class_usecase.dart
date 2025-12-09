import '../../domain/repositories/admin_repository.dart';

class DeleteUserFromClassUseCase {
  final AdminRepository repository;

  DeleteUserFromClassUseCase(this.repository);

  Future<void> call(int userId, int classId) async {
    return await repository.deleteUserFromClass(userId, classId);
  }
}
