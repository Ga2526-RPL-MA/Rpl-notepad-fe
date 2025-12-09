import 'package:rpl_notepad_fe/features/admin/domain/repositories/admin_repository.dart';

class DeleteIssueUseCase {
  final AdminRepository repository;

  DeleteIssueUseCase(this.repository);

  Future<void> call(int issueId) {
    return repository.deleteIssue(issueId);
  }
}
