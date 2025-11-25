import 'package:equatable/equatable.dart';
import '../../domain/entities/note_file.dart';

class GetNoteFileDto extends Equatable {
  final int id;
  final String? filePath;
  final int noteId;

  const GetNoteFileDto({required this.id, this.filePath, required this.noteId});

  // Convert JSON to DTO
  factory GetNoteFileDto.fromJson(Map<String, dynamic> json) {
    return GetNoteFileDto(
      id: json['id'] as int,
      filePath: json['filePath'] as String?,
      noteId: json['noteId'] as int,
    );
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'filePath': filePath,
    'noteId': noteId,
  };

  // Convert DTO to Entity
  NoteFile toEntity() {
    return NoteFile(id: id, filePath: filePath, noteId: noteId);
  }

  // Convert Entity to DTO
  factory GetNoteFileDto.fromEntity(NoteFile entity) {
    return GetNoteFileDto(
      id: entity.id,
      filePath: entity.filePath,
      noteId: entity.noteId,
    );
  }

  // Copy DTO
  GetNoteFileDto copyWith({int? id, String? filePath, int? noteId}) {
    return GetNoteFileDto(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      noteId: noteId ?? this.noteId,
    );
  }

  @override
  List<Object?> get props => [id, filePath, noteId];
}
