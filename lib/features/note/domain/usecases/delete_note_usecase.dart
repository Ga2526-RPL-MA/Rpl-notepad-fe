import 'package:rpl_notepad_fe/features/note/domain/repositories/note_repository.dart';

class DeleteNoteUsecase {
  final NoteRepository repository;

  DeleteNoteUsecase(this.repository);

  Future<void> execute(int noteId) async {
    await repository.deleteNote(noteId);
  }
}
