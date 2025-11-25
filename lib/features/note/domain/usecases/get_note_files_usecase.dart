import 'package:rpl_notepad_fe/features/note/domain/entities/note_file.dart';
import 'package:rpl_notepad_fe/features/note/domain/repositories/note_repository.dart';

class GetNoteFilesUsecase {
  final NoteRepository repository;

  GetNoteFilesUsecase(this.repository);

  Future<List<NoteFile>> execute(int noteId) async {
    final allNoteFilesDto = await repository.getNoteFiles();
    // Filter by noteId on client side
    final filteredFiles = allNoteFilesDto
        .where((dto) => dto.noteId == noteId)
        .map((dto) => dto.toEntity())
        .toList();
    return filteredFiles;
  }
}
