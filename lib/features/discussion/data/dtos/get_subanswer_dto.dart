import 'package:equatable/equatable.dart';
import '../../domain/entities/sub_answer.dart';

class GetSubAnswerDto extends Equatable {
  final int id;
  final String userName;
  final String content;
  final DateTime answeredAt;
  final int answerId;

  const GetSubAnswerDto({
    required this.id,
    required this.userName,
    required this.content,
    required this.answeredAt,
    required this.answerId,
  });

  // Convert JSON to DTO
  factory GetSubAnswerDto.fromJson(Map<String, dynamic> json) {
    try {
      final id = (json['id'] as num?)?.toInt() ?? 0;

      final userName = json['userName'] as String? ?? 'Unknown User';

      final content = json['content'] as String? ?? '';

      DateTime parseDate(String? dateStr) {
        try {
          return dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
        } catch (_) {
          return DateTime.now();
        }
      }

      final answeredAt = parseDate(json['answeredAt'] as String?);

      final answerId = (json['answerId'] as num?)?.toInt() ?? 0;

      return GetSubAnswerDto(
        id: id,
        userName: userName,
        content: content,
        answeredAt: answeredAt,
        answerId: answerId,
      );
    } catch (e) {
      final now = DateTime.now();
      return GetSubAnswerDto(
        id: 0,
        userName: 'Error',
        content: 'Failed to load sub-answer',
        answeredAt: now,
        answerId: 0,
      );
    }
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'content': content,
    'answeredAt': answeredAt.toIso8601String(),
    'answerId': answerId,
  };

  // Convert DTO to Entity
  SubAnswer toEntity() {
    return SubAnswer(
      id: id,
      userName: userName,
      content: content,
      answeredAt: answeredAt,
      answerId: answerId,
    );
  }

  // Convert Entity to DTO
  factory GetSubAnswerDto.fromEntity(SubAnswer entity) {
    return GetSubAnswerDto(
      id: entity.id,
      userName: entity.userName,
      content: entity.content,
      answeredAt: entity.answeredAt,
      answerId: entity.answerId,
    );
  }

  @override
  List<Object> get props => [id, userName, content, answeredAt, answerId];
}
