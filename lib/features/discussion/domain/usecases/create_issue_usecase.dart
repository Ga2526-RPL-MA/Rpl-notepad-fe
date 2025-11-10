import 'package:rpl_notepad_fe/features/discussion/data/dtos/create_issue_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/issue_repository.dart';

class CreateIssueUsecase {
  final IssueRepository _repository;

  CreateIssueUsecase(this._repository);

  Future<CreateIssueDto> call({
    required int classId,
    required String content,
  }) async {
    return await _repository.createIssue(
      classId: classId,
      content: content,
    );
  }
}
