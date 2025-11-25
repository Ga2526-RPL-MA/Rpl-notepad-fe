import 'package:rpl_notepad_fe/features/note/domain/entities/note.dart';
import 'package:rpl_notepad_fe/features/note/domain/repositories/note_repository.dart';

class GetNoteByIdUsecase {
  final NoteRepository repository;

  GetNoteByIdUsecase(this.repository);

  Future<Note> execute(int noteId) async {
    final noteDto = await repository.getNoteById(noteId);
    return noteDto.toEntity();
  }
}
