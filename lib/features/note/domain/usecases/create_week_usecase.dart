import 'package:rpl_notepad_fe/features/note/domain/repositories/week_repository.dart';

class CreateWeekUsecase {
  final WeekRepository repository;

  CreateWeekUsecase(this.repository);

  Future<void> execute({required int week, required int classId}) async {
    await repository.createWeek(week: week, classId: classId);
  }
}
