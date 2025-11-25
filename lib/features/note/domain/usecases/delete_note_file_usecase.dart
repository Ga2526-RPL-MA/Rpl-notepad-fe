import 'package:rpl_notepad_fe/features/note/domain/repositories/note_repository.dart';

class DeleteNoteFileUsecase {
  final NoteRepository repository;

  DeleteNoteFileUsecase(this.repository);

  Future<void> execute(int fileId) async {
    await repository.deleteNoteFile(fileId);
  }
}
