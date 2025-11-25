import 'package:rpl_notepad_fe/features/note/domain/repositories/week_repository.dart';

class DeleteWeekUsecase {
  final WeekRepository repository;

  DeleteWeekUsecase(this.repository);

  Future<void> execute(int weekId) async {
    await repository.deleteWeek(weekId);
  }
}
