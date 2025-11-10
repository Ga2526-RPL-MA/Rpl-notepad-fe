import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_answer_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/issue_repository.dart';

class AddAnswerUsecase {
  final IssueRepository _repository;

  AddAnswerUsecase(this._repository);

  Future<GetAnswerDto> call({
    required int issueId,
    required String content,
  }) async {
    return await _repository.addAnswer(
      issueId: issueId,
      content: content,
    );
  }
}
