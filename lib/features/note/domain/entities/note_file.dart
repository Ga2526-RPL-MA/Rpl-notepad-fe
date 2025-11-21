import 'package:equatable/equatable.dart';

class NoteFile extends Equatable {
  final int id;
  final String? filePath;
  final int noteId;

  const NoteFile({required this.id, this.filePath, required this.noteId});

  @override
  List<Object?> get props => [id, filePath, noteId];
}
