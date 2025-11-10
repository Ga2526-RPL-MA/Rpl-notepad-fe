import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_subanswer_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/issue_repository.dart';

class AddSubAnswerUsecase {
  final IssueRepository _repository;

  AddSubAnswerUsecase(this._repository);

  Future<GetSubAnswerDto> call({
    required int answerId,
    required String content,
  }) async {
    return await _repository.addSubAnswer(
      answerId: answerId,
      content: content,
    );
  }
}
