import 'package:rpl_notepad_fe/core/network/api_endpoint.dart';
import 'package:rpl_notepad_fe/core/network/api_service.dart';
import 'package:rpl_notepad_fe/features/note/data/dtos/create_week_dto.dart';
import 'package:rpl_notepad_fe/features/note/data/dtos/get_week_dto.dart';
import 'package:rpl_notepad_fe/features/note/domain/repositories/week_repository.dart';

class WeekRepositoryImpl implements WeekRepository {
  final ApiService _api;

  WeekRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  @override
  Future<List<GetWeekDto>> getWeeks() async {
    try {
      print('WeekRepositoryImpl: fetching weeks...');
      final response = await _api.get(APIEndpoint.getWeeks.path);
      print('WeekRepositoryImpl: raw response type: ${response.runtimeType}');

      if (response is List) {
        final weeks = response
            .map((item) {
              try {
                if (item == null) return null;
                // Safely cast to Map<String, dynamic>
                final json = Map<String, dynamic>.from(item as Map);
                return GetWeekDto.fromJson(json);
              } catch (e) {
                print(
                  'WeekRepositoryImpl: Error parsing item: $item. Error: $e',
                );
                return null;
              }
            })
            .where((item) => item != null)
            .cast<GetWeekDto>()
            .toList();

        print('WeekRepositoryImpl: successfully parsed ${weeks.length} weeks');
        return weeks;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('WeekRepositoryImpl: Error in getWeeks: $e');
      rethrow;
    }
  }

  @override
  Future<GetWeekDto> getWeekById(int weekId) async {
    try {
      final response = await _api.get(
        '${APIEndpoint.getWeekById.path}/$weekId',
      );
      if (response != null) {
        return GetWeekDto.fromJson(response);
      } else {
        throw Exception('Invalid response format or week not found');
      }
    } catch (e) {
      print('Error in getWeekById: $e');
      rethrow;
    }
  }

  @override
  Future<CreateWeekDto> createWeek({
    required int week,
    required int classId,
  }) async {
    try {
      final dto = CreateWeekDto(week: week, classId: classId);

      final response = await _api.post(
        APIEndpoint.createWeek.path,
        data: dto.toJson(),
      );

      if (response != null) {
        return CreateWeekDto.fromJson(response);
      } else {
        throw Exception('Failed to create week: Invalid response from server');
      }
    } catch (e) {
      print('Error in createWeek: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateWeek({required int weekId, required int week}) async {
    try {
      await _api.put(
        '${APIEndpoint.updateWeek.path}/$weekId',
        data: {'week': week},
      );
    } catch (e) {
      print('Error in updateWeek: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteWeek(int weekId) async {
    try {
      await _api.delete('${APIEndpoint.deleteWeek.path}/$weekId');
    } catch (e) {
      print('Error in deleteWeek: $e');
      rethrow;
    }
  }
}
