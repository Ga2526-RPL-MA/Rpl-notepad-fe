import 'package:equatable/equatable.dart';
import 'package:rpl_notepad_fe/features/note/data/dtos/get_note_dto.dart';
import '../../domain/entities/week.dart';

class GetWeekDto extends Equatable {
  final int id;
  final int week;
  final int classId;
  final List<GetNoteDto> notes;

  const GetWeekDto({
    required this.id,
    required this.week,
    required this.classId,
    this.notes = const [],
  });

  // Convert JSON to DTO
  factory GetWeekDto.fromJson(Map<String, dynamic> json) {
    return GetWeekDto(
      id: json['id'] as int,
      week: json['week'] as int,
      classId: json['classId'] as int,
      notes:
          (json['notes'] as List<dynamic>?)
              ?.map((note) => GetNoteDto.fromJson(note as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'week': week,
    'classId': classId,
    'notes': notes.map((note) => note.toJson()).toList(),
  };

  // Convert DTO to Entity
  Week toEntity() {
    return Week(
      id: id,
      week: week,
      classId: classId,
      notes: notes.map((dto) => dto.toEntity()).toList(),
    );
  }

  // Convert Entity to DTO
  factory GetWeekDto.fromEntity(Week entity) {
    return GetWeekDto(
      id: entity.id,
      week: entity.week,
      classId: entity.classId,
      notes: entity.notes.map((note) => GetNoteDto.fromEntity(note)).toList(),
    );
  }

  // Copy DTO
  GetWeekDto copyWith({
    int? id,
    int? week,
    int? classId,
    List<GetNoteDto>? notes,
  }) {
    return GetWeekDto(
      id: id ?? this.id,
      week: week ?? this.week,
      classId: classId ?? this.classId,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, week, classId, notes];
}
