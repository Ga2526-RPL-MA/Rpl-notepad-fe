import 'package:rpl_notepad_fe/features/admin/domain/repositories/admin_repository.dart';

class DeleteAnswerUseCase {
  final AdminRepository repository;

  DeleteAnswerUseCase(this.repository);

  Future<void> call(int answerId) {
    return repository.deleteAnswer(answerId);
  }
}
