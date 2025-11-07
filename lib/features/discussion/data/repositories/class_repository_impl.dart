import 'package:rpl_notepad_fe/core/network/api_endpoint.dart';
import 'package:rpl_notepad_fe/core/network/api_service.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/getclass_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/class_repository.dart';

class ClassRepositoryImpl implements ClassRepository {
  final ApiService _api;

  ClassRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  @override
  Future<List<GetClassDto>> getClasses() async {
    try {
      final response = await _api.get(APIEndpoint.getClasses.path);

      final List<dynamic> data = response;

      return data.map((e) => GetClassDto.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
