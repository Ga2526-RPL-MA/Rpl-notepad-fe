import 'package:rpl_notepad_fe/core/network/api_endpoint.dart';
import 'package:rpl_notepad_fe/core/network/api_service.dart';
import 'package:rpl_notepad_fe/features/note/data/dtos/create_note_dto.dart';
import 'package:rpl_notepad_fe/features/note/data/dtos/get_note_dto.dart';
import 'package:rpl_notepad_fe/features/note/data/dtos/get_note_file_dto.dart';
import 'package:rpl_notepad_fe/features/note/domain/repositories/note_repository.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class NoteRepositoryImpl implements NoteRepository {
  final ApiService _api;

  NoteRepositoryImpl({ApiService? api}) : _api = api ?? ApiService();

  @override
  Future<List<GetNoteDto>> getNotes() async {
    try {
      final response = await _api.get(APIEndpoint.getNotes.path);
      if (response is List) {
        return response.map((e) => GetNoteDto.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error in getNotes: $e');
      rethrow;
    }
  }

  @override
  Future<GetNoteDto> getNoteById(int noteId) async {
    try {
      final response = await _api.get('${APIEndpoint.getNotes.path}/$noteId');
      if (response != null) {
        return GetNoteDto.fromJson(response);
      } else {
        throw Exception('Invalid response format or note not found');
      }
    } catch (e) {
      print('Error in getNoteById: $e');
      rethrow;
    }
  }

  @override
  Future<List<GetNoteFileDto>> getNoteFiles() async {
    try {
      final response = await _api.get(APIEndpoint.getNoteFiles.path);
      if (response is List) {
        return response
            .map((e) => GetNoteFileDto.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Invalid response format for note files');
      }
    } catch (e) {
      print('Error in getNoteFiles: $e');
      rethrow;
    }
  }

  @override
  Future<void> createNoteFiles({
    required int noteId,
    required List<PlatformFile> files,
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('noteId', noteId.toString()));
      for (final pf in files) {
        if (pf.bytes != null) {
          formData.files.add(
            MapEntry(
              'pdfs',
              MultipartFile.fromBytes(pf.bytes!, filename: pf.name),
            ),
          );
        } else if (pf.path != null) {
          formData.files.add(
            MapEntry(
              'pdfs',
              await MultipartFile.fromFile(pf.path!, filename: pf.name),
            ),
          );
        }
      }

      await _api.post(
        APIEndpoint.createNoteFile.path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } catch (e) {
      print('Error in createNoteFiles: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateNoteFile({
    required int fileId,
    required int noteId,
    required dynamic file,
  }) async {
    try {
      // Note: This is a placeholder for file upload
      final formData = {
        'noteId': noteId,
        // File would be added to FormData in actual implementation
      };

      await _api.put(
        '${APIEndpoint.updateNoteFile.path}/$fileId',
        data: formData,
      );
    } catch (e) {
      print('Error in updateNoteFile: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNoteFile(int fileId) async {
    try {
      await _api.delete('${APIEndpoint.deleteNoteFile.path}/$fileId');
    } catch (e) {
      print('Error in deleteNoteFile: $e');
      rethrow;
    }
  }

  @override
  Future<GetNoteDto> createNote({required int weekId, String? content}) async {
    try {
      final dto = CreateNoteDto(weekId: weekId, content: content);

      final response = await _api.post(
        APIEndpoint.createNote.path,
        data: dto.toJson(),
      );

      if (response != null) {
        return GetNoteDto.fromJson(response);
      } else {
        throw Exception('Failed to create note: Invalid response from server');
      }
    } catch (e) {
      print('Error in createNote: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateNote({required int noteId, String? content}) async {
    try {
      await _api.put(
        '${APIEndpoint.updateNote.path}/$noteId',
        data: {'content': content},
      );
    } catch (e) {
      print('Error in updateNote: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNote(int noteId) async {
    try {
      await _api.delete('${APIEndpoint.deleteNote.path}/$noteId');
    } catch (e) {
      print('Error in deleteNote: $e');
      rethrow;
    }
  }
}
