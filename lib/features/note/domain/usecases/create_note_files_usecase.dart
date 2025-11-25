import 'package:file_picker/file_picker.dart';
import 'package:rpl_notepad_fe/features/note/domain/repositories/note_repository.dart';

class CreateNoteFilesUsecase {
  final NoteRepository repository;

  CreateNoteFilesUsecase(this.repository);

  Future<void> execute({
    required int noteId,
    required List<PlatformFile> files,
  }) async {
    await repository.createNoteFiles(noteId: noteId, files: files);
  }
}
