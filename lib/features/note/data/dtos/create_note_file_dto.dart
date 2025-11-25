import 'package:equatable/equatable.dart';

class CreateNoteFileDto extends Equatable {
  final int noteId;
  final List<String> filePaths;

  const CreateNoteFileDto({required this.noteId, required this.filePaths});

  // Convert JSON to DTO
  factory CreateNoteFileDto.fromJson(Map<String, dynamic> json) {
    return CreateNoteFileDto(
      noteId: json['noteId'] as int,
      filePaths:
          (json['filePaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {'noteId': noteId, 'filePaths': filePaths};

  @override
  List<Object?> get props => [noteId, filePaths];
}
