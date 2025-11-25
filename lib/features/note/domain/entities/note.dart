import 'package:equatable/equatable.dart';
import 'package:rpl_notepad_fe/features/note/domain/entities/note_file.dart';

class Note extends Equatable {
  final int id;
  final String? userName;
  final String? content;
  final int weekId;
  final List<NoteFile> noteFiles;

  const Note({
    required this.id,
    this.userName,
    this.content,
    required this.weekId,
    this.noteFiles = const [],
  });

  @override
  List<Object?> get props => [id, userName, content, weekId, noteFiles];
}
