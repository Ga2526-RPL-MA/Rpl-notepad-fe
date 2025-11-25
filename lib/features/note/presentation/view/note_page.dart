import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/di/injection.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rpl_notepad_fe/core/widgets/mobile_header.dart';
import 'package:rpl_notepad_fe/core/widgets/loading_overlay.dart';
import 'package:rpl_notepad_fe/features/note/presentation/viewmodel/note_viewmodel.dart';
import 'package:rpl_notepad_fe/features/note/presentation/viewmodel/week_viewmodel.dart';
import 'package:rpl_notepad_fe/features/note/presentation/widgets/note_input_card.dart';
import 'package:rpl_notepad_fe/features/note/presentation/widgets/note_filter_section.dart';
import 'package:rpl_notepad_fe/features/note/presentation/widgets/note_slider.dart';

class NotePage extends StatefulWidget {
  final int classId;
  final String className;

  const NotePage({Key? key, required this.classId, required this.className})
    : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _notesScrollController = ScrollController();
  int _currentNoteIndex = 0;
  static const double _noteCardWidth = 230;
  static const double _noteCardGap = 8;
  List<PlatformFile> _selectedPdfs = [];
  bool _showOverlay = false;

  late final NoteViewModel _noteViewModel;
  late final WeekViewModel _weekViewModel;
  int? _inputWeekId;
  String _inputWeekLabel = 'Pilih Minggu';

  String _filterWeekLabel = 'Semua';

  @override
  void initState() {
    super.initState();
    _noteViewModel = getIt<NoteViewModel>();
    _weekViewModel = getIt<WeekViewModel>();

    _weekViewModel.setClassId(widget.classId);
    Future.microtask(() async {
      if (!mounted) return;
      setState(() => _showOverlay = true);
      try {
        await Future.wait([
          _weekViewModel.fetchWeeks(),
          _noteViewModel.fetchNotes(),
        ]);
      } finally {
        if (mounted) setState(() => _showOverlay = false);
      }
    });

    _notesScrollController.addListener(() {
      final double extent = _noteCardWidth + _noteCardGap;
      if (extent <= 0) return;
      final notesList = _noteViewModel.notes;
      final int idx = (_notesScrollController.offset / extent).round();
      if (idx != _currentNoteIndex && idx >= 0 && idx < notesList.length) {
        setState(() => _currentNoteIndex = idx);
      }
    });
  }

  void _onInputWeekSelected(int? weekId, String label) {
    setState(() {
      _inputWeekId = weekId;
      _inputWeekLabel = label;
    });
  }

  void _onFilterWeekSelected(int? weekId, String label) {
    if (_filterWeekLabel == label) return;

    setState(() {
      _filterWeekLabel = label;
    });

    _noteViewModel.setWeekId(weekId);
    () async {
      setState(() => _showOverlay = true);
      try {
        await _noteViewModel.fetchNotes();
      } finally {
        if (mounted) setState(() => _showOverlay = false);
      }
    }();
  }

  Future<void> _saveNote() async {
    if (_textController.text.trim().isEmpty && _selectedPdfs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan tidak boleh kosong')),
      );
      return;
    }

    if (_inputWeekId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minggu terlebih dahulu')),
      );
      return;
    }

    setState(() => _showOverlay = true);
    final success = await _noteViewModel.createNote(
      weekId: _inputWeekId!,
      content: _textController.text.trim(),
      filePaths: _selectedPdfs
          .map((f) => f.path)
          .where((p) => p != null && p.isNotEmpty)
          .cast<String>()
          .toList(),
    );
    if (mounted) setState(() => _showOverlay = false);

    if (success && mounted) {
      _textController.clear();
      setState(() {
        _selectedPdfs = [];
        _inputWeekId = null;
        _inputWeekLabel = 'Pilih Minggu';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan berhasil disimpan')),
      );
      _noteViewModel.fetchNotes();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _noteViewModel.errorMessage ?? 'Gagal menyimpan catatan',
          ),
        ),
      );
    }
  }

  Future<void> _pickPdfs() async {
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
        const SnackBar(content: Text('Tidak ada PDF yang dipilih')),
      );
      return;
    }
    if (picked.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 5 PDF. Diambil 5 pertama.')),
      );
      setState(() {
        _selectedPdfs = picked.take(5).toList();
      });
    } else {
      setState(() {
        _selectedPdfs = List.from(picked);
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_selectedPdfs.length} PDF dipilih')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _noteViewModel),
        ChangeNotifierProvider.value(value: _weekViewModel),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            GradientBackground(child: SafeArea(child: buildBody())),
            if (_showOverlay) const LoadingOverlay(),
          ],
        ),
      ),
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
            Text(
              '${widget.className} / Catatan',
              style: const TextStyle(
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
    return NoteInputCard(
      inputWeekLabel: _inputWeekLabel,
      onWeekSelected: _onInputWeekSelected,
      selectedPdfs: _selectedPdfs,
      onRemovePdf: (index) => setState(() => _selectedPdfs.removeAt(index)),
      textController: _textController,
      onSaveNote: _saveNote,
      onPickPdfs: _pickPdfs,
    );
  }

  Widget buildFilterSection() {
    return NoteFilterSection(
      filterWeekLabel: _filterWeekLabel,
      onFilterWeekSelected: _onFilterWeekSelected,
      notesSlider: buildNotesSlider(),
    );
  }

  Widget buildNotesSlider() {
    return NoteSlider(
      controller: _notesScrollController,
      currentIndex: _currentNoteIndex,
      onIndexChanged: (next) {
        setState(() => _currentNoteIndex = next);
      },
      noteCardWidth: _noteCardWidth,
      noteCardGap: _noteCardGap,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _notesScrollController.dispose();
    super.dispose();
  }
}
