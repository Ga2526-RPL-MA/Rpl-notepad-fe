import 'package:rpl_notepad_fe/features/note/domain/repositories/week_repository.dart';

class UpdateWeekUsecase {
  final WeekRepository repository;

  UpdateWeekUsecase(this.repository);

  Future<void> execute({required int weekId, required int week}) async {
    await repository.updateWeek(weekId: weekId, week: week);
  }
}
