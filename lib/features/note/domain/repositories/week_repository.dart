import 'package:rpl_notepad_fe/features/note/data/dtos/create_week_dto.dart';
import 'package:rpl_notepad_fe/features/note/data/dtos/get_week_dto.dart';

abstract class WeekRepository {
  Future<List<GetWeekDto>> getWeeks();
  Future<GetWeekDto> getWeekById(int weekId);
  Future<CreateWeekDto> createWeek({required int week, required int classId});
  Future<void> updateWeek({required int weekId, required int week});
  Future<void> deleteWeek(int weekId);
}
