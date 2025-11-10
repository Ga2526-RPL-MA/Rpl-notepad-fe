import 'package:rpl_notepad_fe/features/discussion/domain/entities/sub_answer.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/issue_repository.dart';

class GetSubAnswersUsecase {
  final IssueRepository _repository;

  GetSubAnswersUsecase(this._repository);

  Future<List<SubAnswer>> call(int answerId) async {
    final subAnswersDto = await _repository.getSubAnswers(answerId);
    return subAnswersDto.map((dto) => dto.toEntity()).toList();
  }
}
