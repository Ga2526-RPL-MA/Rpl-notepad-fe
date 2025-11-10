import 'package:equatable/equatable.dart';

class CreateIssueDto extends Equatable {
  final int classId;
  final String content;

  const CreateIssueDto({required this.classId, required this.content});

  factory CreateIssueDto.fromJson(Map<String, dynamic> json) {
    return CreateIssueDto(
      classId: json['classId'] as int,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'classId': classId, 'content': content};

  @override
  List<Object?> get props => [classId, content];
}
