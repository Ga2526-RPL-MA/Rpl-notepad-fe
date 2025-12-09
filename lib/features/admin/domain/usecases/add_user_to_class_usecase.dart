import '../../domain/repositories/admin_repository.dart';

class AddUserToClassUseCase {
  final AdminRepository repository;

  AddUserToClassUseCase(this.repository);

  Future<void> call(int userId, int classId) async {
    return await repository.addUserToClass(userId, classId);
  }
}
