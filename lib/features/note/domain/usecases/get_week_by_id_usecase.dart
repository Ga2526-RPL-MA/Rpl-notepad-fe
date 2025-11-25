import 'package:rpl_notepad_fe/features/note/domain/entities/week.dart';
import 'package:rpl_notepad_fe/features/note/domain/repositories/week_repository.dart';

class GetWeekByIdUsecase {
  final WeekRepository repository;

  GetWeekByIdUsecase(this.repository);

  Future<Week> execute(int weekId) async {
    final weekDto = await repository.getWeekById(weekId);
    return weekDto.toEntity();
  }
}
