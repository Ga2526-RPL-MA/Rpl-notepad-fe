import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/core/utils/pdf_handler.dart';
import 'package:rpl_notepad_fe/core/widgets/loading_overlay.dart';
import 'package:rpl_notepad_fe/core/widgets/toast_notification.dart';
import 'package:rpl_notepad_fe/features/note/domain/entities/note.dart';
import 'package:rpl_notepad_fe/features/note/presentation/view/pdf_viewer_screen.dart';
import 'package:rpl_notepad_fe/features/note/presentation/viewmodel/note_viewmodel.dart';

class NoteDetailBottomSheet extends StatefulWidget {
  final Note note;
  final NoteViewModel noteViewModel;

  const NoteDetailBottomSheet({
    super.key,
    required this.note,
    required this.noteViewModel,
  });

  @override
  State<NoteDetailBottomSheet> createState() => _NoteDetailBottomSheetState();
}

class _NoteDetailBottomSheetState extends State<NoteDetailBottomSheet> {
  late Note _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  bool _isOwner() {
    final current = AuthService.userName;
    if (current == null || current.isEmpty) return false;
    return _note.userName == current;
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final controller = TextEditingController(text: _note.content ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Catatan'),
          content: TextField(
            controller: controller,
            maxLines: 6,
            decoration: const InputDecoration(hintText: 'Tulis catatan...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    final newContent = controller.text.trim();
    OverlayEntry? overlay;
    try {
      if (context.mounted) {
        final overlayState = Overlay.of(context, rootOverlay: true);
        overlay = OverlayEntry(builder: (_) => const LoadingOverlay());
        overlayState.insert(overlay);
      }

      await widget.noteViewModel.updateNote(
        noteId: _note.id,
        content: newContent,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        showAppToast(
          context,
          message: 'Catatan berhasil diperbarui',
          type: AppToastType.success,
          duration: const Duration(seconds: 2),
        );
      }
    } finally {
      overlay?.remove();
    }
  }

  Future<void> _confirmDeleteFile(BuildContext context, int fileId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Hapus File'),
          content: const Text('Yakin ingin menghapus file ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    OverlayEntry? overlay;
    bool success = false;
    try {
      if (context.mounted) {
        final overlayState = Overlay.of(context, rootOverlay: true);
        overlay = OverlayEntry(builder: (_) => const LoadingOverlay());
        overlayState.insert(overlay);
      }

      success = await widget.noteViewModel.deleteNoteFile(fileId);

      // Refresh local note from latest data
      final latest = widget.noteViewModel.allNotes
          .where((n) => n.id == _note.id)
          .toList();
      if (latest.isNotEmpty && mounted) {
        setState(() {
          _note = latest.first;
        });
      }

      if (context.mounted) {
        showAppToast(
          context,
          message: success
              ? 'File berhasil dihapus'
              : 'Gagal menghapus file. Coba lagi.',
          type: success ? AppToastType.success : AppToastType.error,
          duration: const Duration(seconds: 2),
        );
      }
    } finally {
      overlay?.remove();
    }
  }

  Future<void> _addFiles(BuildContext context) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      allowMultiple: true,
      withData: true,
    );

    if (res == null || res.files.isEmpty) {
      return;
    }

    final picked = res.files
        .where((f) => (f.extension?.toLowerCase() == 'pdf'))
        .toList();

    if (picked.isEmpty) {
      showAppToast(
        context,
        message: 'Tidak ada PDF yang dipilih',
        type: AppToastType.info,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (picked.length > 5) {
      showAppToast(
        context,
        message: 'Maksimal 5 PDF. Diambil 5 pertama.',
        type: AppToastType.warning,
        duration: const Duration(seconds: 3),
      );
    }

    final limited = picked.take(5).toList();

    OverlayEntry? overlay;
    bool success = false;
    try {
      if (context.mounted) {
        final overlayState = Overlay.of(context);
        overlay = OverlayEntry(builder: (_) => const LoadingOverlay());
        overlayState.insert(overlay);
      }

      success = await widget.noteViewModel.addFilesToNote(
        noteId: _note.id,
        files: limited,
      );

      if (context.mounted && success) {
        // Refresh local note from latest data
        final latest = widget.noteViewModel.allNotes
            .where((n) => n.id == _note.id)
            .toList();
        if (latest.isNotEmpty) {
          setState(() {
            _note = latest.first;
          });
        }
        showAppToast(
          context,
          message: 'File berhasil ditambahkan',
          type: AppToastType.success,
          duration: const Duration(seconds: 2),
        );
      }
    } finally {
      overlay?.remove();
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Hapus Catatan'),
          content: const Text('Yakin ingin menghapus catatan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    OverlayEntry? overlay;
    bool success = false;
    try {
      if (context.mounted) {
        final overlayState = Overlay.of(context);
        overlay = OverlayEntry(builder: (_) => const LoadingOverlay());
        overlayState.insert(overlay);
      }

      success = await widget.noteViewModel.deleteNote(_note.id);

      if (context.mounted) {
        Navigator.of(context).pop();
        showAppToast(
          context,
          message: success
              ? 'Catatan berhasil dihapus'
              : 'Gagal menghapus catatan. Coba lagi.',
          type: success ? AppToastType.success : AppToastType.error,
          duration: const Duration(seconds: 2),
        );
      }
    } finally {
      overlay?.remove();
    }
  }

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
      if (!(await file.exists()) || (await file.length()) == 0) {
        throw Exception('Gagal mengunduh file PDF');
      }

      overlay?.remove();

      await Future.delayed(const Duration(milliseconds: 100));

      if (!ctx.mounted) return;

      await Navigator.of(ctx).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(filePath: path, fileName: safeName),
        ),
      );
    } catch (e) {
      overlay?.remove();
      if (ctx.mounted) {
        ScaffoldMessenger.of(
          ctx,
        ).showSnackBar(SnackBar(content: Text('Gagal membuka PDF: $e')));
      }
    }
  }

  void _openPdfInNewTab(String url) {
    openPdfUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _isOwner();
    if (kIsWeb) {
      final size = MediaQuery.of(context).size;
      final panelWidth = size.width * 0.5;

      Widget content = Material(
        color: Colors.transparent,
        child: Container(
          height: size.height,
          width: panelWidth,
          decoration: const BoxDecoration(
            color: Color(0xFFE7F0FF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(-2, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
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
                          'Catatan : ${_note.userName ?? 'Anonymous'}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      if (isOwner) ...[
                        IconButton(
                          tooltip: 'Edit Catatan',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showEditDialog(context),
                        ),
                        IconButton(
                          tooltip: 'Hapus Catatan',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDelete(context),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
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
                              if (_note.noteFiles.isNotEmpty) ...[
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _note.noteFiles.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (ctx2, i) {
                                    // Di dalam itemBuilder ListView.separated (WEB)
                                    final f = _note.noteFiles[i];
                                    final url = f.url ?? '';
                                    final name = 'Lampiran ${i + 1}';

                                    print(
                                      'DEBUG NOTE FILE (web) -> id=${f.id}, url=$url',
                                    );

                                    if (url.isEmpty) {
                                      print(
                                        'WARNING: Empty URL for note file id=${f.id}',
                                      );
                                    }
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Stack(
                                        children: [
                                          ListTile(
                                            contentPadding:
                                                const EdgeInsets.only(
                                                  right: 40,
                                                ),
                                            leading: const Icon(
                                              Icons.picture_as_pdf,
                                              color: Colors.red,
                                            ),
                                            title: Text(
                                              name,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            onTap: () async {
                                              if (url.isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "URL tidak tersedia",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              _openPdfInNewTab(url);
                                            },
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  constraints:
                                                      const BoxConstraints(),
                                                  icon: const Icon(
                                                    Icons.open_in_new,
                                                    size: 16,
                                                  ),
                                                  onPressed: () async {
                                                    _openPdfInNewTab(url);
                                                  },
                                                ),
                                                if (isOwner)
                                                  IconButton(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    constraints:
                                                        const BoxConstraints(),
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                      size: 16,
                                                    ),
                                                    onPressed: () {
                                                      _confirmDeleteFile(
                                                        context,
                                                        f.id,
                                                      );
                                                    },
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                              ],
                              if (isOwner)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: () => _addFiles(context),
                                    icon: const Icon(
                                      Icons.attach_file,
                                      size: 18,
                                    ),
                                    label: const Text('Tambah PDF'),
                                  ),
                                ),
                              if ((_note.content?.trim().isNotEmpty ?? false))
                                Text(
                                  _note.content!,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      return Align(alignment: Alignment.centerRight, child: content);
    }

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
                    'Catatan : ${_note.userName ?? 'Anonymous'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                if (isOwner) ...[
                  IconButton(
                    tooltip: 'Edit Catatan',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditDialog(context),
                  ),
                  IconButton(
                    tooltip: 'Hapus Catatan',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
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
                      if (_note.noteFiles.isNotEmpty) ...[
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _note.noteFiles.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx2, i) {
                            final f = _note.noteFiles[i];
                            final url = f.url ?? '';
                            final name = 'Lampiran ${i + 1}';

                            print(
                              'DEBUG NOTE FILE (mobile) -> id=${f.id}, url=$url',
                            );

                            if (url.isEmpty) {
                              print(
                                'WARNING: Empty URL for note file id=${f.id}',
                              );
                            }

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
                                      if (url.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("URL tidak tersedia"),
                                          ),
                                        );
                                        return;
                                      }

                                      await _openPdfFromUrl(context, url, name);
                                    },
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          padding: const EdgeInsets.all(8),
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(
                                            Icons.open_in_new,
                                            size: 16,
                                          ),
                                          onPressed: () async {
                                            if (kIsWeb) {
                                              _openPdfInNewTab(url);
                                              return;
                                            }

                                            await _openPdfFromUrl(
                                              context,
                                              url,
                                              name,
                                            );
                                          },
                                        ),
                                        if (isOwner)
                                          IconButton(
                                            padding: const EdgeInsets.all(8),
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 16,
                                            ),
                                            onPressed: () {
                                              _confirmDeleteFile(context, f.id);
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (isOwner)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => _addFiles(context),
                            icon: const Icon(Icons.attach_file, size: 18),
                            label: const Text('Tambah PDF'),
                          ),
                        ),
                      if ((_note.content?.trim().isNotEmpty ?? false))
                        Text(
                          _note.content!,
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
