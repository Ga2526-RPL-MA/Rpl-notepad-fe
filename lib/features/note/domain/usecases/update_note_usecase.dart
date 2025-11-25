import 'package:rpl_notepad_fe/features/note/domain/repositories/note_repository.dart';

class UpdateNoteUsecase {
  final NoteRepository repository;

  UpdateNoteUsecase(this.repository);

  Future<void> execute({required int noteId, String? content}) async {
    await repository.updateNote(noteId: noteId, content: content);
  }
}
