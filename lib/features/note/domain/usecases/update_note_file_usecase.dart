import 'package:rpl_notepad_fe/features/note/domain/repositories/note_repository.dart';

class UpdateNoteFileUsecase {
  final NoteRepository repository;

  UpdateNoteFileUsecase(this.repository);

  Future<void> execute({
    required int fileId,
    required int noteId,
    required dynamic file,
  }) async {
    await repository.updateNoteFile(fileId: fileId, noteId: noteId, file: file);
  }
}
