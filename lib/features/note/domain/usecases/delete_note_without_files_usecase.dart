import 'package:rpl_notepad_fe/features/note/domain/repositories/note_repository.dart';

class DeleteNoteWithoutFilesUsecase {
  final NoteRepository _repository;

  DeleteNoteWithoutFilesUsecase(this._repository);

  Future<void> execute(int noteId) async {
    return await _repository.deleteNoteWithoutFiles(noteId);
  }
}
