import 'package:rpl_notepad_fe/features/note/domain/repositories/note_repository.dart';
import 'package:rpl_notepad_fe/features/note/data/dtos/get_note_dto.dart';

class CreateNoteUsecase {
  final NoteRepository repository;

  CreateNoteUsecase(this.repository);

  Future<GetNoteDto> execute({required int weekId, String? content}) async {
    return repository.createNote(weekId: weekId, content: content);
  }
}
