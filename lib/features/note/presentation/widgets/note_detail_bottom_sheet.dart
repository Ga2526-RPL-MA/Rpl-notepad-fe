import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rpl_notepad_fe/core/widgets/loading_overlay.dart';
import 'package:rpl_notepad_fe/features/note/domain/entities/note.dart';
import 'package:rpl_notepad_fe/features/note/presentation/view/pdf_viewer_screen.dart';

class NoteDetailBottomSheet extends StatelessWidget {
  final Note note;

  const NoteDetailBottomSheet({super.key, required this.note});

  Future<void> _openPdfFromUrl(
    BuildContext ctx,
    String url,
    String fileName,
  ) async {
    OverlayEntry? overlay;
    try {
      if (ctx.mounted) {
        final overlayState = Overlay.of(ctx);
        overlay = OverlayEntry(builder: (_) => const LoadingOverlay());
        overlayState.insert(overlay);
      }

      final dio = Dio(
        BaseOptions(
          followRedirects: true,
          headers: {'Accept': 'application/octet-stream, application/pdf, */*'},
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          validateStatus: (code) => code != null && code < 400,
        ),
      );

      final dir = await getTemporaryDirectory();
      final safeName = fileName.isNotEmpty ? fileName : 'file.pdf';
      final path =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_$safeName';

      await dio.download(
        url,
        path,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      final file = File(path);
      final exists = await file.exists();
      final length = exists ? await file.length() : 0;

      if (!exists || length == 0) {
        throw Exception('Gagal mengunduh file PDF');
      }

      if (ctx.mounted) {
        overlay?.remove();
        overlay = null;
      }

      await Future.delayed(const Duration(milliseconds: 100));

      if (!ctx.mounted) return;
      await Navigator.of(ctx).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(filePath: path, fileName: safeName),
        ),
      );
    } on DioException catch (e) {
      if (ctx.mounted) {
        overlay?.remove();
        overlay = null;
      }

      String errorMsg = 'Gagal mengunduh PDF';
      if (e.response?.statusCode != null) {
        errorMsg += ' (HTTP ${e.response!.statusCode})';
      }

      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (ctx.mounted) {
        overlay?.remove();
        overlay = null;
      }

      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka PDF: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      overlay?.remove();
      overlay = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Catatan : ${note.userName ?? 'Anonymous'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 420,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (note.noteFiles.isNotEmpty) ...[
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: note.noteFiles.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx2, i) {
                            final f = note.noteFiles[i];
                            final path = (f.filePath ?? '').trim();
                            final segments = path
                                .split(RegExp(r'[\\/]+'))
                                .where((s) => s.isNotEmpty)
                                .toList();
                            final name = segments.isEmpty
                                ? 'Lampiran ${i + 1}'
                                : segments.last;
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(
                                children: [
                                  ListTile(
                                    contentPadding: const EdgeInsets.only(
                                      right: 40,
                                    ),
                                    leading: const Icon(
                                      Icons.picture_as_pdf,
                                      color: Colors.red,
                                    ),
                                    title: Text(
                                      name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    onTap: () async {
                                      if (path.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Path kosong'),
                                          ),
                                        );
                                        return;
                                      }
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Membuka lampiran...'),
                                          duration: Duration(milliseconds: 800),
                                        ),
                                      );
                                      if (path.startsWith('http')) {
                                        await _openPdfFromUrl(
                                          context,
                                          path,
                                          name,
                                        );
                                      } else {
                                        const supabaseBase =
                                            'https://qpmbyhqiflwnosxlgzfe.supabase.co/storage/v1/object/public';
                                        const bucket = 'notes';
                                        final url =
                                            '$supabaseBase/$bucket/$path';
                                        await _openPdfFromUrl(
                                          context,
                                          url,
                                          name,
                                        );
                                      }
                                    },
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      padding: const EdgeInsets.all(8),
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.open_in_new,
                                        size: 16,
                                      ),
                                      onPressed: () async {
                                        if (path.isEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('Path kosong'),
                                            ),
                                          );
                                          return;
                                        }
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Membuka lampiran...',
                                            ),
                                            duration: Duration(
                                              milliseconds: 800,
                                            ),
                                          ),
                                        );
                                        if (path.startsWith('http')) {
                                          await _openPdfFromUrl(
                                            context,
                                            path,
                                            name,
                                          );
                                        } else {
                                          const supabaseBase =
                                              'https://qpmbyhqiflwnosxlgzfe.supabase.co/storage/v1/object/public';
                                          const bucket = 'notes';
                                          final url =
                                              '$supabaseBase/$bucket/$path';
                                          await _openPdfFromUrl(
                                            context,
                                            url,
                                            name,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      if ((note.content?.trim().isNotEmpty ?? false))
                        Text(
                          note.content!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF131927),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
