import 'package:rpl_notepad_fe/features/admin/domain/repositories/admin_repository.dart';

class DeleteSubAnswerUseCase {
  final AdminRepository repository;

  DeleteSubAnswerUseCase(this.repository);

  Future<void> call(int subAnswerId) {
    return repository.deleteSubAnswer(subAnswerId);
  }
}
