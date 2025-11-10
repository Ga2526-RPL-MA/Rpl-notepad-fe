import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'get_subanswer_dto.dart';
import '../../domain/entities/answer.dart';

class GetAnswerDto extends Equatable {
  final int id;
  final String userName;
  final String content;
  final DateTime createdAt;
  final DateTime answeredAt;
  final int issueId;
  final List<GetSubAnswerDto> subAnswers;

  const GetAnswerDto({
    required this.id,
    required this.userName,
    required this.content,
    required this.createdAt,
    required this.answeredAt,
    required this.issueId,
    this.subAnswers = const [],
  });

  // Convert JSON to DTO
  factory GetAnswerDto.fromJson(
    Map<String, dynamic> json, {
    int currentIssueId = 0,
  }) {
    try {
      final id = (json['id'] as num?)?.toInt() ?? 0;
      final userName = (json['userName'] as String?) ?? 'Unknown User';
      final content = (json['content'] as String?) ?? '';

      // Fallback to currentIssueId if available, otherwise default to 0
      final issueId = (json['issueId'] as num?)?.toInt() ?? currentIssueId;

      if (kDebugMode) {
        print("Parsing answer JSON: $json");
      }

      DateTime parseDate(String? dateStr, DateTime fallback) {
        try {
          return dateStr != null ? DateTime.parse(dateStr) : fallback;
        } catch (_) {
          return fallback;
        }
      }

      final now = DateTime.now();
      // Use answeredAt as fallback for createdAt if it exists
      final answeredAt = parseDate(json['answeredAt'] as String?, now);
      final createdAt = parseDate(
        json['createdAt'] as String?,
        json['answeredAt'] != null ? answeredAt : now,
      );

      return GetAnswerDto(
        id: id,
        userName: userName,
        content: content,
        createdAt: createdAt,
        answeredAt: answeredAt,
        issueId: issueId,
        subAnswers:
            (json['subAnswers'] as List?)?.map((sub) {
              try {
                return GetSubAnswerDto.fromJson(sub as Map<String, dynamic>);
              } catch (e) {
                if (kDebugMode) {
                  print('⚠️ Error parsing subAnswer: $e');
                }
                return GetSubAnswerDto(
                  id: 0,
                  userName: 'Unknown',
                  content: 'Failed to load sub-answer',
                  answeredAt: now,
                  answerId: 0, // Default answerId
                );
              }
            }).toList() ??
            [],
      );
    } catch (e) {
      print("Raw JSON: $json");
      // Fallback in case of any parsing error
      final now = DateTime.now();
      return GetAnswerDto(
        id: 0,
        userName: 'Error',
        content: 'Failed to load answer',
        createdAt: now,
        answeredAt: now,
        issueId: 0,
        subAnswers: [],
      );
    }
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'answeredAt': answeredAt.toIso8601String(),
    'issueId': issueId,
    'subAnswers': subAnswers.map((subAnswer) => subAnswer.toJson()).toList(),
  };

  // Convert DTO to Entity
  Answer toEntity() {
    return Answer(
      id: id,
      userName: userName,
      content: content,
      answeredAt: answeredAt,
      issueId: issueId,
      subAnswers: subAnswers.map((dto) => dto.toEntity()).toList(),
    );
  }

  // Convert Entity to DTO
  factory GetAnswerDto.fromEntity(Answer entity) {
    return GetAnswerDto(
      id: entity.id,
      userName: entity.userName,
      content: entity.content,
      createdAt: entity.answeredAt, // Using answeredAt as the creation time
      answeredAt: entity.answeredAt,
      issueId: entity.issueId,
      subAnswers: entity.subAnswers
          .map((subAnswer) => GetSubAnswerDto.fromEntity(subAnswer))
          .toList(),
    );
  }

  // Copy with method for immutability
  GetAnswerDto copyWith({
    int? id,
    String? userName,
    String? content,
    DateTime? createdAt,
    DateTime? answeredAt,
    int? issueId,
    List<GetSubAnswerDto>? subAnswers,
  }) {
    return GetAnswerDto(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      answeredAt: answeredAt ?? this.answeredAt,
      issueId: issueId ?? this.issueId,
      subAnswers: subAnswers ?? this.subAnswers,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userName,
    content,
    createdAt,
    answeredAt,
    issueId,
    subAnswers,
  ];
}
