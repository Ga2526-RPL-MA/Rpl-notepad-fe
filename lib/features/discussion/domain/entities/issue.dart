import 'package:equatable/equatable.dart';
import 'answer.dart';

class Issue extends Equatable {
  final int id;
  final String userName;
  final String content;
  final DateTime reportedAt;
  final int classId;
  final List<Answer> answers;
  final bool isAnswer;

  const Issue({
    required this.id,
    required this.userName,
    required this.content,
    required this.reportedAt,
    required this.classId,
    this.answers = const [],
    this.isAnswer = false,
  });

  @override
  List<Object?> get props => [
        id,
        userName,
        content,
        reportedAt,
        classId,
        answers,
        isAnswer,
      ];
}
