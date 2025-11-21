import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rpl_notepad_fe/core/widgets/mobile_header.dart';

class NotePage extends StatefulWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _textController = TextEditingController();
  String selectedFilter = 'Semua';
  final ScrollController _notesScrollController = ScrollController();
  int _currentNoteIndex = 0;
  static const double _noteCardWidth = 230;
  static const double _noteCardGap = 8;
  List<PlatformFile> _selectedPdfs = [];

  final List<Map<String, String>> notes = [
    {'title': 'Andina Pasha Rahmania', 'subtitle': 'Catatan'},
    {'title': 'Andina Pasha Rahmania', 'subtitle': 'Catatan'},
    {'title': 'Andina Pasha Rahmania', 'subtitle': 'Catatan'},
    {'title': 'Andina Pasha Rahmania', 'subtitle': 'Catatan'},
    {'title': 'Andina Pasha Rahmania', 'subtitle': 'Catatan'},
  ];

  @override
  void initState() {
    super.initState();
    _notesScrollController.addListener(() {
      final double extent = _noteCardWidth + _noteCardGap;
      if (extent <= 0) return;
      final int idx = (_notesScrollController.offset / extent).round();
      if (idx != _currentNoteIndex && idx >= 0 && idx < notes.length) {
        setState(() => _currentNoteIndex = idx);
      }
    });
  }

  void _scrollToNoteIndex(int index) {
    final double extent = _noteCardWidth + _noteCardGap;
    final double target = (index * extent).clamp(
      0.0,
      _notesScrollController.position.maxScrollExtent,
    );
    _notesScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(child: SafeArea(child: buildBody())),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MobileHeader(hintText: 'Cari catatan...'),
            const SizedBox(height: 16),
            const Text(
              'Evolusi Perangkat Lunak / Catatan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 20),
            buildInputCard(),
            const SizedBox(height: 24),
            buildFilterSection(),
          ],
        ),
      ),
    );
  }

  Widget buildInputCard() {
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
          Container(
            height: 400,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFBFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x4D9EA2AE), width: 1),
            ),
            child: TextField(
              controller: _textController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Tulis disini',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
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
                onPressed: () async {
                  final res = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: const ['pdf'],
                    allowMultiple: true,
                    withData: false,
                  );
                  if (!mounted) return;
                  if (res == null) return;
                  final picked = res.files
                      .where((f) => (f.extension?.toLowerCase() == 'pdf'))
                      .toList();
                  if (picked.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tidak ada PDF yang dipilih'),
                      ),
                    );
                    return;
                  }
                  if (picked.length > 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Maksimal 5 PDF. Diambil 5 pertama.'),
                      ),
                    );
                  }
                  setState(() {
                    _selectedPdfs = picked.take(5).toList();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${_selectedPdfs.length} PDF dipilih'),
                    ),
                  );
                },
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

  Widget buildFilterSection() {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double boxWidth = (constraints.maxWidth * 0.7).clamp(
                      260.0,
                      460.0,
                    );
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: boxWidth,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF131927)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: selectedFilter,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: ['Semua'].map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedFilter = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          buildNotesSlider(),
        ],
      ),
    );
  }

  Widget buildNotesSlider() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 18),
      child: SizedBox(
        height: 180,
        child: Row(
          children: [
            Visibility(
              visible: _currentNoteIndex > 0,
              maintainSize: true,
              maintainState: true,
              maintainAnimation: true,
              child: IconButton(
                icon: const Icon(Icons.chevron_left, size: 32),
                onPressed: () {
                  final int next = (_currentNoteIndex - 1).clamp(
                    0,
                    notes.length - 1,
                  );
                  setState(() => _currentNoteIndex = next);
                  _scrollToNoteIndex(next);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                controller: _notesScrollController,
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return Container(
                    width: _noteCardWidth,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : _noteCardGap,
                      right: index == notes.length - 1 ? 0 : _noteCardGap,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFE6F4FF), Color(0xFF256533)],
                        stops: [0.51, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            note['subtitle']!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            note['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Visibility(
              visible: _currentNoteIndex < notes.length - 1,
              maintainSize: true,
              maintainState: true,
              maintainAnimation: true,
              child: IconButton(
                icon: const Icon(Icons.chevron_right, size: 32),
                onPressed: () {
                  final int next = (_currentNoteIndex + 1).clamp(
                    0,
                    notes.length - 1,
                  );
                  setState(() => _currentNoteIndex = next);
                  _scrollToNoteIndex(next);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _notesScrollController.dispose();
    super.dispose();
  }
}
