import 'package:rpl_notepad_fe/core/network/api_endpoint.dart';
import 'package:rpl_notepad_fe/core/network/api_service.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/create_issue_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_answer_dto.dart';
import '../dtos/get_subanswer_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_issue_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/issue_repository.dart';

class IssueRepositoryImpl implements IssueRepository {
  final ApiService _api;

  IssueRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  @override
  Future<List<GetIssueDto>> getIssues() async {
    try {
      final response = await _api.get(APIEndpoint.getIssues.path);
      if (response is List) {
        return response.map((e) => GetIssueDto.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error in getIssues: $e');
      rethrow;
    }
  }

  @override
  Future<List<GetAnswerDto>> getAnswers(int issueId) async {
    try {
      final response = await _api.get('${APIEndpoint.getIssues.path}/$issueId');
      if (response != null && response['answers'] is List) {
        final answers = response['answers'] as List;
        return answers
            .map((e) => GetAnswerDto.fromJson(e, currentIssueId: issueId))
            .toList();
      } else {
        throw Exception('Invalid response format or no answers found');
      }
    } catch (e) {
      print('Error in getAnswers: $e');
      rethrow;
    }
  }

  @override
  Future<GetAnswerDto> addAnswer({
    required int issueId,
    required String content,
  }) async {
    try {
      final response = await _api.post(
        APIEndpoint.postAnswer.path,  
        data: {
          'content': content,
          'issueId': issueId,
        },
      );

      if (response != null) {
        return GetAnswerDto.fromJson(response);
      } else {
        throw Exception('Failed to add answer: Invalid response from server');
      }
    } catch (e) {
      print('Error in addAnswer: $e');
      rethrow;
    }
  }

  @override
  Future<CreateIssueDto> createIssue({
    required int classId,
    required String content,
  }) async {
    try {
      final dto = CreateIssueDto(classId: classId, content: content);

      final response = await _api.post(
        APIEndpoint.postIssues.path,
        data: dto.toJson(),
      );

      if (response != null) {
        return CreateIssueDto.fromJson(response);
      } else {
        throw Exception('Failed to create issue: Invalid response from server');
      }
    } catch (e) {
      print('Error in createIssue: $e');
      rethrow;
    }
  }

  @override
  Future<List<GetSubAnswerDto>> getSubAnswers(int answerId) async {
    try {
      final response = await _api.get('${APIEndpoint.postAnswer.path}/$answerId/sub-answers');
      
      if (response is List) {
        return response
            .map((e) => GetSubAnswerDto.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Invalid response format for sub-answers');
      }
    } catch (e) {
      print('Error in getSubAnswers: $e');
      rethrow;
    }
  }

  @override
  Future<GetSubAnswerDto> addSubAnswer({
    required int answerId,
    required String content,
  }) async {
    try {
      final response = await _api.post(
        APIEndpoint.postSubAnswer.path,
        data: {
          'content': content,
          'answerId': answerId,
        },
      );

      if (response != null) {
        return GetSubAnswerDto.fromJson(response);
      } else {
        throw Exception('Failed to add sub-answer: Invalid response from server');
      }
    } catch (e) {
      print('Error in addSubAnswer: $e');
      rethrow;
    }
  }


  Future<List<GetIssueDto>> searchIssues(String query) async {
    try {
      final response = await _api.get('${APIEndpoint.searchIssue.path}/$query');
      
      if (response is List) {
        return response
            .map((e) => GetIssueDto.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Invalid response format for issues');
      }
    } catch (e) {
      print('Error in searchIssues: $e');
      rethrow;
    }
  }
}
