import 'package:equatable/equatable.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/class.dart';
import 'package:rpl_notepad_fe/features/note/domain/entities/note_file.dart';

class Note extends Equatable {
  final int id;
  final String? content;
  final int week;
  final int classId;
  final ClassModel classRef;
  final List<NoteFile> noteFiles;

  const Note({
    required this.id,
    this.content,
    required this.week,
    required this.classId,
    required this.classRef,
    required this.noteFiles,
  });

  @override
  List<Object?> get props => [id, content, week, classId, classRef, noteFiles];
}

