import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rpl_notepad_fe/core/utils/pdf_handler.dart';
import 'package:rpl_notepad_fe/features/note/domain/entities/note.dart';

class NoteListTable extends StatelessWidget {
  final List<Note> notes;
  final Function(Note) onDelete;

  const NoteListTable({
    super.key,
    required this.notes,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Belum ada catatan',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontFamily: 'Inter',
            ),
          ),
        ),
      );
    }

    // Sort notes by week number
    final sortedNotes = List<Note>.from(notes);
    sortedNotes.sort((a, b) {
      final aWeek = a.weekNumber ?? a.weekId;
      final bWeek = b.weekNumber ?? b.weekId;
      return aWeek.compareTo(bWeek);
    });

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(80),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(1.5),
          3: FixedColumnWidth(120),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F6FA),
              border: Border(bottom: BorderSide.none),
            ),
            children: [
              _buildHeaderCell('No'),
              _buildHeaderCell('Nama'),
              _buildHeaderCell('Catatan'),
              _buildHeaderCell('Aksi'),
            ],
          ),
          // Data
          ...sortedNotes.asMap().entries.map((entry) {
            final index = entry.key;
            final note = entry.value;
            return _buildDataRow(context, index + 1, note);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0XFF5A607F),
          fontSize: 14,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  TableRow _buildDataRow(BuildContext context, int no, Note note) {
    const baseStyle = TextStyle(
      color: Color(0xFF131523),
      fontFamily: 'Inter',
      fontSize: 14,
    );

    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            no.toString(),
            style: baseStyle.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            note.userName ?? 'Tanpa nama',
            style: baseStyle.copyWith(fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Clickable week text to show note detail
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: GestureDetector(
            onTap: () => _showNoteDetail(context, note),
            child: Text(
              'Minggu ${note.weekNumber}',
              style: baseStyle.copyWith(
                color: const Color(0xFF006AB5),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE443F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => onDelete(note),
            icon: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/icon/trash-icon.png',
                width: 16,
                height: 16,
              ),
            ),
            label: const Text(
              'Hapus',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  void _showNoteDetail(BuildContext context, Note note) {
    if (kIsWeb) {
      showGeneralDialog(
        context: context,
        barrierLabel: 'Note Detail',
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.3),
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (ctx, anim1, anim2) {
          return Align(
            alignment: Alignment.centerRight,
            child: _NoteDetailPanel(note: note),
          );
        },
        transitionBuilder: (ctx, anim, secondaryAnim, child) {
          final offsetTween = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(
            CurveTween(curve: Curves.easeOutCubic),
          );
          return SlideTransition(
            position: anim.drive(offsetTween),
            child: child,
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFFE7F0FF),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        builder: (ctx) {
          return _NoteDetailPanel(note: note, isMobile: true);
        },
      );
    }
  }
}

// Read-only note detail panel for admin view
class _NoteDetailPanel extends StatelessWidget {
  final Note note;
  final bool isMobile;

  const _NoteDetailPanel({
    required this.note,
    this.isMobile = false,
  });

  void _openPdf(BuildContext context, String url) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL tidak tersedia')),
      );
      return;
    }
    // Open PDF in new tab (web) using pdf_handler
    openPdfUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
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
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (ctx2, i) {
                              final f = note.noteFiles[i];
                              final url = f.url ?? '';
                              final name = 'Lampiran ${i + 1}';
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  onTap: () => _openPdf(context, url),
                                  leading: const Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.red,
                                  ),
                                  title: Text(
                                    name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.open_in_new, size: 18),
                                    onPressed: () => _openPdf(context, url),
                                  ),
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
                        if (note.noteFiles.isEmpty && (note.content?.trim().isEmpty ?? true))
                          const Text(
                            'Tidak ada konten',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
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

    // Web layout
    final size = MediaQuery.of(context).size;
    final panelWidth = size.width * 0.5;

    return Material(
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
                            if (note.noteFiles.isNotEmpty) ...[
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: note.noteFiles.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (ctx2, i) {
                                  final f = note.noteFiles[i];
                                  final url = f.url ?? '';
                                  final name = 'Lampiran ${i + 1}';
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListTile(
                                      onTap: () => _openPdf(context, url),
                                      leading: const Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.red,
                                      ),
                                      title: Text(
                                        name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.open_in_new, size: 18),
                                        onPressed: () => _openPdf(context, url),
                                      ),
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
                            if (note.noteFiles.isEmpty && (note.content?.trim().isEmpty ?? true))
                              const Text(
                                'Tidak ada konten',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
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
  }
}
