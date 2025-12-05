import 'package:rpl_notepad_fe/features/note/domain/entities/note.dart';
import 'package:rpl_notepad_fe/features/note/domain/entities/note_file.dart';
import 'package:rpl_notepad_fe/features/note/domain/repositories/note_repository.dart';

class GetNotesUsecase {
  final NoteRepository repository;

  GetNotesUsecase(this.repository);

  Future<List<Note>> execute() async {
    final notesDto = await repository.getNotes();

    // Fetch all note files once
    final allNoteFilesDto = await repository.getNoteFiles();

    final notes = notesDto.map((dto) {
      // Filter note files for this specific note
      final noteFilesForThisNote = allNoteFilesDto
          .where((nf) => nf.noteId == dto.id)
          .map(
            (nf) =>
                NoteFile(id: nf.id, filePath: nf.filePath, noteId: nf.noteId),
          )
          .toList();

      return Note(
        id: dto.id,
        userName: dto.userName,
        content: dto.content,
        weekId: dto.weekId,
        noteFiles: noteFilesForThisNote,
      );
    }).toList();

    return notes;
  }

  Future<List<Note>> search(String query) async {
    final notesDto = await repository.searchNotes(query);

    // Fetch all note files once
    final allNoteFilesDto = await repository.getNoteFiles();

    final notes = notesDto.map((dto) {
      // Filter note files for this specific note
      final noteFilesForThisNote = allNoteFilesDto
          .where((nf) => nf.noteId == dto.id)
          .map(
            (nf) =>
                NoteFile(id: nf.id, filePath: nf.filePath, noteId: nf.noteId),
          )
          .toList();

      return Note(
        id: dto.id,
        userName: dto.userName,
        content: dto.content,
        weekId: dto.weekId,
        noteFiles: noteFilesForThisNote,
      );
    }).toList();

    return notes;
  }
}
