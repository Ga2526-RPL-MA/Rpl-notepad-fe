import 'package:equatable/equatable.dart';

class NoteFile extends Equatable {
  final int id;
  final String? filePath;
  final int noteId;
  final String? url;

  const NoteFile({
    required this.id,
    this.filePath,
    required this.noteId,
    this.url,
  });

  @override
  List<Object?> get props => [id, filePath, noteId, url];
}
