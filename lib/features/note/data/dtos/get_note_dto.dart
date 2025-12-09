import 'package:equatable/equatable.dart';
import 'package:rpl_notepad_fe/features/note/data/dtos/get_note_file_dto.dart';
import '../../domain/entities/note.dart';

class GetNoteDto extends Equatable {
  final int id;
  final String? userName;
  final String? content;
  final int weekId;
  final int? weekNumber;
  final List<GetNoteFileDto> noteFiles;

  const GetNoteDto({
    required this.id,
    this.userName,
    this.content,
    required this.weekId,
    this.weekNumber,
    this.noteFiles = const [],
  });

  // Convert JSON to DTO
  factory GetNoteDto.fromJson(Map<String, dynamic> json) {
    // Parse week number - handle both Map and int formats
    int? weekNumber;
    if (json['week'] != null) {
      if (json['week'] is Map) {
        weekNumber = json['week']['week'] as int?;
      } else if (json['week'] is int) {
        weekNumber = json['week'] as int;
      }
    }
    
    return GetNoteDto(
      id: json['id'] as int,
      userName: json['userName'] as String?,
      content: json['content'] as String?,
      weekId: json['weekId'] as int,
      weekNumber: weekNumber,
      noteFiles:
          (json['noteFiles'] as List<dynamic>?)
              ?.map(
                (noteFile) =>
                    GetNoteFileDto.fromJson(noteFile as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'content': content,
    'weekId': weekId,
    'weekNumber': weekNumber,
    'noteFiles': noteFiles.map((noteFile) => noteFile.toJson()).toList(),
  };

  // Convert DTO to Entity
  Note toEntity() {
    return Note(
      id: id,
      userName: userName,
      content: content,
      weekId: weekId,
      weekNumber: weekNumber,
      noteFiles: noteFiles.map((dto) => dto.toEntity()).toList(),
    );
  }

  // Convert Entity to DTO
  factory GetNoteDto.fromEntity(Note entity) {
    return GetNoteDto(
      id: entity.id,
      userName: entity.userName,
      content: entity.content,
      weekId: entity.weekId,
      weekNumber: entity.weekNumber,
      noteFiles: entity.noteFiles
          .map((noteFile) => GetNoteFileDto.fromEntity(noteFile))
          .toList(),
    );
  }

  // Copy DTO
  GetNoteDto copyWith({
    int? id,
    String? userName,
    String? content,
    int? weekId,
    int? weekNumber,
    List<GetNoteFileDto>? noteFiles,
  }) {
    return GetNoteDto(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      weekId: weekId ?? this.weekId,
      weekNumber: weekNumber ?? this.weekNumber,
      noteFiles: noteFiles ?? this.noteFiles,
    );
  }

  @override
  List<Object?> get props => [id, userName, content, weekId, weekNumber, noteFiles];
}
