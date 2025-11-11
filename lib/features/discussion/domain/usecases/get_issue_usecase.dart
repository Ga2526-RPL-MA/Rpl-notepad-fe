import 'package:rpl_notepad_fe/features/discussion/domain/entities/answer.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/issue.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/sub_answer.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/issue_repository.dart';

class GetIssueUsecase {
  final IssueRepository repository;

  GetIssueUsecase(this.repository);

  Future<List<Issue>> execute() async {
    final issuesDto = await repository.getIssues();

    final issues = await Future.wait(
      issuesDto.map((dto) async {
        try {
          final answersDto = await repository.getAnswers(dto.id);
          return Issue(
            id: dto.id,
            userName: dto.userName,
            content: dto.content,
            reportedAt: dto.reportedAt,
            classId: dto.classId,
            answers: answersDto
                .map(
                  (a) => Answer(
                    id: a.id,
                    userName: a.userName,
                    content: a.content,
                    answeredAt: a.answeredAt,
                    issueId: a.issueId,
                    subAnswers: a.subAnswers
                        .map((sub) => SubAnswer(
                              id: sub.id,
                              userName: sub.userName,
                              content: sub.content,
                              answeredAt: sub.answeredAt,
                              answerId: sub.answerId,
                            ))
                        .toList(),
                  ),
                )
                .toList(),
          );
        } catch (e) {
          return Issue(
            id: dto.id,
            userName: dto.userName,
            content: dto.content,
            reportedAt: dto.reportedAt,
            classId: dto.classId,
            answers: const [],
          );
        }
      }),
    );

    return issues;
  }
}
