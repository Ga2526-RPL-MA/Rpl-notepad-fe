import 'package:rpl_notepad_fe/features/discussion/data/dtos/create_issue_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_answer_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_subanswer_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_issue_dto.dart';

abstract class IssueRepository {
  Future<List<GetIssueDto>> getIssues();
  Future<List<GetAnswerDto>> getAnswers(int issueId);
  Future<List<GetSubAnswerDto>> getSubAnswers(int answerId);
  Future<GetAnswerDto> addAnswer({
    required int issueId,
    required String content,
  });
  Future<GetSubAnswerDto> addSubAnswer({
    required int answerId,
    required String content,
  });
  Future<CreateIssueDto> createIssue({
    required int classId,
    required String content,
  });
}
