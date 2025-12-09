import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/utils/pdf_handler.dart';
import 'package:rpl_notepad_fe/features/note/presentation/view/pdf_viewer_screen.dart';
import 'package:rpl_notepad_fe/features/note/presentation/viewmodel/week_viewmodel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NoteInputCard extends StatelessWidget {
  final String inputWeekLabel;
  final void Function(int? weekId, String label) onWeekSelected;
  final List<PlatformFile> selectedPdfs;
  final void Function(int index) onRemovePdf;
  final TextEditingController textController;
  final VoidCallback onSaveNote;
  final Future<void> Function() onPickPdfs;

  const NoteInputCard({
    super.key,
    required this.inputWeekLabel,
    required this.onWeekSelected,
    required this.selectedPdfs,
    required this.onRemovePdf,
    required this.textController,
    required this.onSaveNote,
    required this.onPickPdfs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Consumer<WeekViewModel>(
              builder: (context, weekVM, child) {
                final weeks = weekVM.weeks;
                return Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF131927)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                    ),
                    child: DropdownButton<String>(
                      value:
                          inputWeekLabel == 'Pilih Minggu' ||
                              !weeks.any(
                                (w) => 'Minggu ${w.week}' == inputWeekLabel,
                              )
                          ? null
                          : inputWeekLabel,
                      hint: const Text('Pilih Minggu'),
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: Colors.white,
                      items: weeks.map((week) {
                        return DropdownMenuItem(
                          value: 'Minggu ${week.week}',
                          child: Text('Minggu ${week.week}'),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          final weekNum = int.tryParse(
                            newValue.replaceAll('Minggu ', ''),
                          );
                          final selectedWeek = weeks.firstWhere(
                            (w) => w.week == weekNum,
                          );
                          onWeekSelected(
                            selectedWeek.id,
                            'Minggu ${selectedWeek.week}',
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFBFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x4D9EA2AE), width: 1),
            ),
            child: Column(
              children: [
                if (selectedPdfs.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 100),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: selectedPdfs.length,
                        itemBuilder: (context, index) {
                          final file = selectedPdfs[index];
                          return Stack(
                            children: [
                              ListTile(
                                onTap: () async {
                                  if (kIsWeb) {
                                    if (file.bytes != null) {
                                      openPdfBytes(file.bytes!);
                                    }
                                    return;
                                  }

                                  if (file.path != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfViewerScreen(
                                          filePath: file.path!,
                                          fileName: file.name,
                                        ),
                                      ),
                                    );
                                  }
                                },

                                contentPadding: const EdgeInsets.only(
                                  right: 40,
                                ),
                                leading: const Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                ),
                                title: Text(
                                  file.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () => onRemovePdf(index),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Expanded(
                  child: TextField(
                    controller: textController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: 'Tulis catatan disini...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: onSaveNote,
                icon: const Icon(Icons.save),
                label: const Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onPickPdfs,
                icon: const Icon(Icons.folder_open),
                label: const Text('Pilih File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8ACEFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
