import 'package:equatable/equatable.dart';

class CreateNoteDto extends Equatable {
  final String? content;
  final int weekId;

  const CreateNoteDto({this.content, required this.weekId});

  // Convert JSON to DTO
  factory CreateNoteDto.fromJson(Map<String, dynamic> json) {
    return CreateNoteDto(
      content: json['content'] as String?,
      weekId: json['weekId'] as int,
    );
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {'content': content, 'weekId': weekId};

  // Copy DTO
  CreateNoteDto copyWith({String? content, int? weekId}) {
    return CreateNoteDto(
      content: content ?? this.content,
      weekId: weekId ?? this.weekId,
    );
  }

  @override
  List<Object?> get props => [content, weekId];
}
