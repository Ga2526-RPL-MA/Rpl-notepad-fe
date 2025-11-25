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
import 'package:rpl_notepad_fe/core/widgets/menu_drawer.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_card.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/user_profile.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/login_view_model.dart';

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

    if (AuthService.isTokenExpired) {
      Future.microtask(() async {
        try {
          await AuthService.clearToken();
        } catch (_) {}
        if (!mounted) return;
        final loginVM = Provider.of<LoginViewModel>(context, listen: false);
        loginVM.reset();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        });
      });
      return;
    }
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
      double extent = _noteCardWidth + _noteCardGap;
      final size = MediaQuery.of(context).size;
      final bool isWeb = size.width > 800;
      if (isWeb && _notesScrollController.hasClients) {
        const visibleCount = 4;
        final gap = _noteCardGap;
        final viewport = _notesScrollController.position.viewportDimension;
        final cardWidth = (viewport - gap * (visibleCount - 1)) / visibleCount;
        extent = cardWidth + gap;
      }
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
      selectedFiles: _selectedPdfs,
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
      withData: true,
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
    final isWeb = MediaQuery.of(context).size.width > 800;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _noteViewModel),
        ChangeNotifierProvider.value(value: _weekViewModel),
      ],
      child: Scaffold(
        drawer: !isWeb
            ? MenuDrawer(currentPage: 'diskusi', onPageChanged: (p) {})
            : null,
        body: Stack(
          children: [
            if (isWeb)
              GradientBackground(
                child: SafeArea(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sidebar
                      MenuDrawer(currentPage: 'diskusi', onPageChanged: (p) {}),
                      const SizedBox(width: 20),

                      // Main content
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            // Header Card
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: CustomCard(
                                color: Colors.white,
                                width: double.infinity,
                                height: 100,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Expanded(
                                      child: CustomSearchBar(
                                        hintText: 'Cari catatan...',
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Consumer<LoginViewModel>(
                                      builder: (context, loginVM, _) {
                                        return UserProfile(
                                          name:
                                              AuthService
                                                      .userName
                                                      ?.isNotEmpty ==
                                                  true
                                              ? AuthService.userName!
                                              : 'User',
                                          email:
                                              AuthService
                                                      .userEmail
                                                      ?.isNotEmpty ==
                                                  true
                                              ? AuthService.userEmail!
                                              : 'user@example.com',
                                          avatarSize: 40,
                                          avatarColor: const Color(0xFFD4C5F9),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Fixed Title
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      } else {
                                        Navigator.of(
                                          context,
                                          rootNavigator: true,
                                        ).pushNamedAndRemoveUntil(
                                          '/discussion',
                                          (route) => false,
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${widget.className} / Catatan',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Inter',
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Content Area
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                children: [
                                  buildInputCard(),
                                  const SizedBox(height: 24),
                                  buildFilterSection(),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
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
