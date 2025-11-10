import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_answer_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/issue_repository.dart';

class GetAnswersUsecase {
  final IssueRepository _repository;

  GetAnswersUsecase(this._repository);

  Future<List<GetAnswerDto>> call(int issueId) async {
    return await _repository.getAnswers(issueId);
  }
}
