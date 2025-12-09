import 'package:equatable/equatable.dart';
import 'answer.dart';

class Issue extends Equatable {
  final int id;
  final String userName;
  final String content;
  final DateTime reportedAt;
  final int classId;
  final List<Answer> answers;
  final String nrp;
  final bool isAnswer;

  const Issue({
    required this.id,
    required this.userName,
    required this.content,
    required this.reportedAt,
    required this.classId,
    this.answers = const [],
    this.nrp = '',
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
        nrp,
        isAnswer,
      ];

  Issue copyWith({
    int? id,
    String? userName,
    String? content,
    DateTime? reportedAt,
    int? classId,
    List<Answer>? answers,
    String? nrp,
    bool? isAnswer,
  }) {
    return Issue(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      reportedAt: reportedAt ?? this.reportedAt,
      classId: classId ?? this.classId,
      answers: answers ?? this.answers,
      nrp: nrp ?? this.nrp,
      isAnswer: isAnswer ?? this.isAnswer,
    );
  }
}
