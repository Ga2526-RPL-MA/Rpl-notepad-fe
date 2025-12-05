import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteDraft {
  final String? content;
  final int? weekId;
  final String? weekLabel;
  final List<PlatformFile> files;

  NoteDraft({
    this.content,
    this.weekId,
    this.weekLabel,
    List<PlatformFile>? files,
  }) : files = files ?? const [];
}

class NoteDraftHelper {
  static String _contentKey(int classId) => 'note_draft_content_$classId';
  static String _weekIdKey(int classId) => 'note_draft_weekId_$classId';
  static String _weekLabelKey(int classId) => 'note_draft_weekLabel_$classId';
  static String _filesKey(int classId) => 'note_draft_files_$classId';

  static Future<NoteDraft> loadDraft(int classId) async {
    final prefs = await SharedPreferences.getInstance();

    final content = prefs.getString(_contentKey(classId));
    final weekId = prefs.getInt(_weekIdKey(classId));
    final weekLabel = prefs.getString(_weekLabelKey(classId));
    final filesJson = prefs.getString(_filesKey(classId));

    List<PlatformFile> files = [];

    if (filesJson != null && filesJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(filesJson);
        files = decoded
            .whereType<Map<String, dynamic>>()
            .map((file) {
              final path = file['path'] as String?;
              final name = file['name'] as String? ?? '';
              final size = file['size'] as int?;
              if (path == null) return null;
              final fileName = name.isNotEmpty ? name : _fileNameFromPath(path);
              return PlatformFile(name: fileName, path: path, size: size ?? 0);
            })
            .whereType<PlatformFile>()
            .toList();
      } catch (_) {}
    }

    return NoteDraft(
      content: content,
      weekId: weekId,
      weekLabel: weekLabel,
      files: files,
    );
  }

  static Future<void> saveDraft({
    required int classId,
    required String content,
    required int? weekId,
    required String weekLabel,
    required List<PlatformFile> files,
  }) async {
    if (content.trim().isEmpty && weekId == null && files.isEmpty) {
      await clearDraft(classId);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_contentKey(classId), content);

    if (weekId != null) {
      await prefs.setInt(_weekIdKey(classId), weekId);
      await prefs.setString(_weekLabelKey(classId), weekLabel);
    } else {
      await prefs.remove(_weekIdKey(classId));
      await prefs.remove(_weekLabelKey(classId));
    }

    if (files.isNotEmpty) {
      final serialized = files
          .where((f) => f.path != null)
          .map((f) => {'path': f.path, 'name': f.name, 'size': f.size})
          .toList();
      if (serialized.isNotEmpty) {
        await prefs.setString(_filesKey(classId), jsonEncode(serialized));
      } else {
        await prefs.remove(_filesKey(classId));
      }
    } else {
      await prefs.remove(_filesKey(classId));
    }
  }

  static Future<void> clearDraft(int classId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_contentKey(classId));
    await prefs.remove(_weekIdKey(classId));
    await prefs.remove(_weekLabelKey(classId));
    await prefs.remove(_filesKey(classId));
  }

  static String _fileNameFromPath(String path) {
    final segments = path.split(RegExp(r'[\\/]+'));
    if (segments.isEmpty) return path;
    return segments.last;
  }
}
