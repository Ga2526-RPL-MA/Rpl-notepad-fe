import 'package:rpl_notepad_fe/features/note/data/dtos/get_note_dto.dart';
import 'package:rpl_notepad_fe/features/note/data/dtos/get_note_file_dto.dart';

import 'package:file_picker/file_picker.dart';

abstract class NoteRepository {
  // Note
  Future<List<GetNoteDto>> getNotes();
  Future<GetNoteDto> getNoteById(int noteId);
  Future<GetNoteDto> createNote({required int weekId, String? content});
  Future<void> updateNote({required int noteId, String? content});
  Future<void> deleteNote(int noteId);

  // NoteFile
  Future<List<GetNoteFileDto>> getNoteFiles();
  Future<void> createNoteFiles({
    required int noteId,
    required List<PlatformFile> files,
  });
  Future<void> updateNoteFile({
    required int fileId,
    required int noteId,
    required dynamic file,
  });
  Future<void> deleteNoteFile(int fileId);
}
