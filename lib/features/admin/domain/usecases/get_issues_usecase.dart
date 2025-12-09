import 'package:rpl_notepad_fe/features/admin/domain/repositories/admin_repository.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/issue.dart';

class GetIssuesUseCase {
  final AdminRepository repository;

  GetIssuesUseCase(this.repository);

  Future<List<Issue>> call() async {
    return await repository.getIssues();
  }
}
