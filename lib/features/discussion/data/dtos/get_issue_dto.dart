import 'package:equatable/equatable.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_answer_dto.dart';
import '../../domain/entities/issue.dart';

class GetIssueDto extends Equatable {
  final int id;
  final String userName;
  final String content;
  final DateTime reportedAt;
  final int classId;
  final List<GetAnswerDto> answers;
  final String nrp;

  const GetIssueDto({
    required this.id,
    required this.userName,
    required this.content,
    required this.reportedAt,
    required this.classId,
    this.answers = const [],
    this.nrp = '',
  });

  // Convert JSON to DTO
  factory GetIssueDto.fromJson(Map<String, dynamic> json) {
    return GetIssueDto(
      id: json['id'] as int,
      userName: json['userName'] as String,
      content: json['content'] as String,
      reportedAt: DateTime.parse(json['reportedAt'] as String),
      classId: json['classId'] as int,
      answers: (json['answers'] as List<dynamic>?)
              ?.map((answer) => GetAnswerDto.fromJson(answer as Map<String, dynamic>))
              .toList() ?? [],
      nrp: (json['nrp'] as String?) ?? '',
    );
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'content': content,
        'reportedAt': reportedAt.toIso8601String(),
        'classId': classId,
        'answers': answers.map((answer) => answer.toJson()).toList(),
        'nrp': nrp,
      };

  // Convert DTO to Entity
  Issue toEntity() {
    return Issue(
      id: id,
      userName: userName,
      content: content,
      reportedAt: reportedAt,
      classId: classId,
      answers: answers.map((dto) => dto.toEntity()).toList(),
      nrp: nrp,
    );
  }

  // Convert Entity to DTO
  factory GetIssueDto.fromEntity(Issue entity) {
    return GetIssueDto(
      id: entity.id,
      userName: entity.userName,
      content: entity.content,
      reportedAt: entity.reportedAt,
      classId: entity.classId,
      answers: entity.answers.map((answer) => GetAnswerDto.fromEntity(answer)).toList(),
      nrp: entity.nrp,
    );
  }

  // Copy DTO
  GetIssueDto copyWith({
    int? id,
    String? userName,
    String? content,
    DateTime? reportedAt,
    int? classId,
    List<GetAnswerDto>? answers,
    String? nrp,
  }) {
    return GetIssueDto(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      reportedAt: reportedAt ?? this.reportedAt,
      classId: classId ?? this.classId,
      answers: answers ?? this.answers,
      nrp: nrp ?? this.nrp,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userName,
        content,
        reportedAt,
        classId,
        answers,
        nrp,
      ];
}
