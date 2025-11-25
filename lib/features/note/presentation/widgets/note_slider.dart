import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/features/note/presentation/viewmodel/note_viewmodel.dart';
import 'package:rpl_notepad_fe/features/note/presentation/widgets/note_detail_bottom_sheet.dart';

class NoteSlider extends StatelessWidget {
  final ScrollController controller;
  final int currentIndex;
  final void Function(int index) onIndexChanged;
  final double noteCardWidth;
  final double noteCardGap;

  const NoteSlider({
    super.key,
    required this.controller,
    required this.currentIndex,
    required this.onIndexChanged,
    this.noteCardWidth = 230,
    this.noteCardGap = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteViewModel>(
      builder: (context, noteVM, child) {
        final notes = noteVM.notes;
        if (notes.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Belum ada catatan',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 18),
          child: SizedBox(
            height: 180,
            child: Row(
              children: [
                Visibility(
                  visible: currentIndex > 0,
                  maintainSize: true,
                  maintainState: true,
                  maintainAnimation: true,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, size: 32),
                    onPressed: () {
                      final int next = (currentIndex - 1).clamp(
                        0,
                        notes.length - 1,
                      );
                      final extent = noteCardWidth + noteCardGap;
                      final target = (next * extent).clamp(
                        0.0,
                        controller.position.maxScrollExtent,
                      );
                      controller.animateTo(
                        target,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                      );
                      onIndexChanged(next);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                Expanded(
                  child: NotificationListener<ScrollEndNotification>(
                    onNotification: (notification) {
                      if (notification.dragDetails == null) return false;
                      if (!controller.hasClients) return false;
                      final extent = noteCardWidth + noteCardGap;
                      if (extent <= 0) return false;
                      final raw = controller.offset / extent;
                      int snapIndex = raw.round();
                      snapIndex = snapIndex.clamp(0, notes.length - 1);
                      final target = snapIndex * extent;
                      if ((controller.offset - target).abs() < 1.0) {
                        onIndexChanged(snapIndex);
                        return false;
                      }
                      controller.animateTo(
                        target.clamp(0.0, controller.position.maxScrollExtent),
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                      );
                      onIndexChanged(snapIndex);
                      return false;
                    },
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: controller,
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: const Color(0XFFE7F0FF),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                              ),
                              builder: (ctx) {
                                return NoteDetailBottomSheet(note: note);
                              },
                            );
                          },
                          child: Container(
                            width: noteCardWidth,
                            margin: EdgeInsets.only(
                              right: index == notes.length - 1
                                  ? 0
                                  : noteCardGap,
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
                                  const Text(
                                    'Catatan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    note.userName ?? 'Anonymous',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Inter',
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: currentIndex < notes.length - 1,
                  maintainSize: true,
                  maintainState: true,
                  maintainAnimation: true,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right, size: 32),
                    onPressed: () {
                      final int next = (currentIndex + 1).clamp(
                        0,
                        notes.length - 1,
                      );
                      final extent = noteCardWidth + noteCardGap;
                      final target = (next * extent).clamp(
                        0.0,
                        controller.position.maxScrollExtent,
                      );
                      controller.animateTo(
                        target,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                      );
                      onIndexChanged(next);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
