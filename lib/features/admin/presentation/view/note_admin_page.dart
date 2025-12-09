import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/di/injection.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_card.dart';
import 'package:rpl_notepad_fe/core/widgets/loading_overlay.dart';
import 'package:rpl_notepad_fe/core/widgets/menu_drawer.dart';
import 'package:rpl_notepad_fe/core/widgets/toast_notification.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/viewmodel/note_admin_view_model.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/widgets/dropdown_filter_class.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/widgets/note_list_table.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/viewmodel/login_view_model.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/usecases/get_class_usecase.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/user_profile.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/delete_note_file_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/delete_note_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/delete_note_without_files_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/get_notes_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/get_weeks_usecase.dart';
import 'package:rpl_notepad_fe/features/note/domain/usecases/update_note_usecase.dart';

class NoteAdminPage extends StatelessWidget {
  const NoteAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoteAdminViewModel(
        getNotesUsecase: getIt<GetNotesUsecase>(),
        getWeeksUsecase: getIt<GetWeeksUsecase>(),
        getClassesUseCase: getIt<GetclassUsecase>(),
      )..fetchNotes(),
      child: Consumer<NoteAdminViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              const _NoteAdminPageContent(),
              if (viewModel.isLoading) const LoadingOverlay(),
            ],
          );
        },
      ),
    );
  }
}

class _NoteAdminPageContent extends StatelessWidget {
  const _NoteAdminPageContent();

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;
    final viewModel = Provider.of<NoteAdminViewModel>(context);

    if (isWeb) {
      return Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MenuDrawer(
                  currentPage: 'catatan',
                  onPageChanged: (_) {},
                  mode: 'admin',
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Header card with search and profile
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomCard(
                          color: Colors.white,
                          width: double.infinity,
                          height: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Consumer<NoteAdminViewModel>(
                                  builder: (context, viewModel, _) {
                                    return CustomSearchBar(
                                      hintText: 'Cari catatan...',
                                      onChanged: (query) {
                                        viewModel.updateSearchQuery(query);
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                              Consumer<LoginViewModel>(
                                builder: (context, loginVM, _) {
                                  return UserProfile(
                                    name:
                                        AuthService.userName?.isNotEmpty == true
                                        ? AuthService.userName!
                                        : 'User',
                                    email:
                                        AuthService.userEmail?.isNotEmpty ==
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
                      // Notes table
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomCard(
                            color: Colors.white,
                            width: double.infinity,
                            height: 620,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  const Text(
                                    'Catatan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Dropdown filter
                                  DropdownFilterClass(
                                    classes: viewModel.classes,
                                    selectedClass: viewModel.selectedClass,
                                    isLoading: viewModel.isLoading,
                                    onChanged: (classDto) {
                                      viewModel.setSelectedClass(classDto);
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: _buildNoteContent(
                                      context,
                                      viewModel,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Mobile layout
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catatan',
          style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Inter'),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: MenuDrawer(
        currentPage: 'catatan',
        onPageChanged: (_) {},
        mode: 'admin',
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CustomCard(
              color: Colors.white,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Catatan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dropdown filter
                    DropdownFilterClass(
                      classes: viewModel.classes,
                      selectedClass: viewModel.selectedClass,
                      isLoading: viewModel.isLoading,
                      onChanged: (classDto) {
                        viewModel.setSelectedClass(classDto);
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(child: _buildNoteContent(context, viewModel)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteContent(BuildContext context, NoteAdminViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(
          viewModel.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return SingleChildScrollView(
      child: NoteListTable(
        notes: viewModel.notes,
        isSearching: viewModel.isSearching,
        onDelete: (note) {
          _showDeleteModal(context, note, viewModel);
        },
      ),
    );
  }

  void _showDeleteModal(
    BuildContext context,
    dynamic note,
    NoteAdminViewModel viewModel,
  ) {
    // Check what content exists
    final bool hasText = note.content != null && note.content!.isNotEmpty;
    final bool hasFiles = note.noteFiles.isNotEmpty;

    bool deleteText = false;
    bool deleteFile = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: const Color(0xFFF9FAFB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 320),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Apakah Anda Yakin?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pastikan anda mengecek kembali',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Checkbox options
                    if (hasText)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Teks',
                            style: TextStyle(fontSize: 14, fontFamily: 'Inter'),
                          ),
                          Checkbox(
                            value: deleteText,
                            activeColor: Colors.black,
                            checkColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            onChanged: (value) {
                              setState(() {
                                deleteText = value ?? false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),

                    if (hasFiles)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'File',
                            style: TextStyle(fontSize: 14, fontFamily: 'Inter'),
                          ),
                          Checkbox(
                            value: deleteFile,
                            activeColor: Colors.black,
                            checkColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            onChanged: (value) {
                              setState(() {
                                deleteFile = value ?? false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 24),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEE443F),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: (deleteText || deleteFile)
                                ? () async {
                                    Navigator.pop(dialogContext);

                                    // Show loading overlay
                                    OverlayEntry? overlay;
                                    try {
                                      if (context.mounted) {
                                        final overlayState = Overlay.of(
                                          context,
                                          rootOverlay: true,
                                        );
                                        overlay = OverlayEntry(
                                          builder: (_) =>
                                              const LoadingOverlay(),
                                        );
                                        overlayState.insert(overlay);
                                      }

                                      if (deleteText && deleteFile) {
                                        // Delete both text and files - use PATCH endpoint
                                        final deleteUseCase =
                                            getIt<DeleteNoteUsecase>();
                                        await deleteUseCase.execute(note.id);
                                      } else if (deleteText) {
                                        if (note.noteFiles.isEmpty) {
                                          // Delete text-only note - use DELETE endpoint
                                          final deleteUseCase =
                                              getIt<
                                                DeleteNoteWithoutFilesUsecase
                                              >();
                                          await deleteUseCase.execute(note.id);
                                        } else {
                                          // Note has files, just clear the text content
                                          final updateUseCase =
                                              getIt<UpdateNoteUsecase>();
                                          await updateUseCase.execute(
                                            noteId: note.id,
                                            content: '',
                                          );
                                        }
                                      } else if (deleteFile) {
                                        // Delete files only
                                        final deleteFileUseCase =
                                            getIt<DeleteNoteFileUsecase>();

                                        for (final file in note.noteFiles) {
                                          await deleteFileUseCase.execute(
                                            file.id,
                                          );
                                        }

                                        // If text is empty after deleting files, delete the note
                                        if (note.content == null ||
                                            note.content!.trim().isEmpty) {
                                          final deleteUseCase =
                                              getIt<
                                                DeleteNoteWithoutFilesUsecase
                                              >();
                                          await deleteUseCase.execute(note.id);
                                        }
                                      }

                                      // Refresh list
                                      await viewModel.fetchNotes();

                                      overlay?.remove();
                                      overlay = null;

                                      await Future.delayed(
                                        const Duration(milliseconds: 100),
                                      );

                                      if (context.mounted) {
                                        showAppToast(
                                          context,
                                          title: 'Berhasil',
                                          message:
                                              'Berhasil menghapus item terpilih',
                                          type: AppToastType.success,
                                        );
                                      }
                                    } catch (e) {
                                      // Remove overlay first before showing error toast
                                      overlay?.remove();
                                      overlay = null;

                                      // Small delay to ensure overlay is removed before showing toast
                                      await Future.delayed(
                                        const Duration(milliseconds: 100),
                                      );

                                      if (context.mounted) {
                                        showAppToast(
                                          context,
                                          title: 'Gagal',
                                          message: 'Gagal menghapus: $e',
                                          type: AppToastType.error,
                                        );
                                      }
                                      return; // Exit early to prevent showing success toast
                                    } finally {
                                      overlay?.remove();
                                    }
                                  }
                                : null,
                            child: const Text(
                              'Hapus',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
