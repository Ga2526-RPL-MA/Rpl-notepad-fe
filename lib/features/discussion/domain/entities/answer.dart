import 'package:equatable/equatable.dart';
import 'sub_answer.dart';

class Answer extends Equatable {
  final int id;
  final String userName;
  final String content;
  final DateTime answeredAt;
  final int issueId;
  final List<SubAnswer> subAnswers;

  const Answer({
    required this.id,
    required this.userName,
    required this.content,
    required this.answeredAt,
    required this.issueId,
    this.subAnswers = const [],
  });

  @override
  List<Object?> get props => [
        id,
        userName,
        content,
        answeredAt,
        issueId,
        subAnswers,
      ];
}
