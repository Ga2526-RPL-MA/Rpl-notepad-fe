import 'package:equatable/equatable.dart';
import '../../domain/entities/note_file.dart';

class GetNoteFileDto extends Equatable {
  final int id;
  final String? filePath;
  final int noteId;
  final String? url;

  const GetNoteFileDto({
    required this.id,
    this.filePath,
    required this.noteId,
    this.url,
  });

  // Convert JSON to DTO
  factory GetNoteFileDto.fromJson(Map<String, dynamic> json) {
    return GetNoteFileDto(
      id: json['id'] as int,
      filePath: json['filePath'] as String?,
      noteId: json['noteId'] as int,
      url: json['url'] as String?,
    );
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'filePath': filePath,
    'noteId': noteId,
    'url': url,
  };

  // Convert DTO to Entity
  NoteFile toEntity() {
    return NoteFile(id: id, filePath: filePath, noteId: noteId, url: url);
  }

  // Convert Entity to DTO
  factory GetNoteFileDto.fromEntity(NoteFile entity) {
    return GetNoteFileDto(
      id: entity.id,
      filePath: entity.filePath,
      noteId: entity.noteId,
      url: entity.url,
    );
  }

  // Copy DTO
  GetNoteFileDto copyWith({
    int? id,
    String? filePath,
    int? noteId,
    String? url,
  }) {
    return GetNoteFileDto(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      noteId: noteId ?? this.noteId,
      url: url ?? this.url,
    );
  }

  @override
  List<Object?> get props => [id, filePath, noteId, url];
}
