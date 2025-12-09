import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    final isWideLayout = MediaQuery.of(context).size.width > 800;

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
                      final step = isWideLayout ? 4 : 1;
                      final int next = (currentIndex - step).clamp(
                        0,
                        notes.length - 1,
                      );
                      double extent;
                      if (isWideLayout && controller.hasClients) {
                        const visibleCount = 4;
                        final gap = noteCardGap;
                        final viewport = controller.position.viewportDimension;
                        final cardWidth =
                            (viewport - gap * (visibleCount - 1)) /
                            visibleCount;
                        extent = cardWidth + gap;
                      } else {
                        extent = noteCardWidth + noteCardGap;
                      }
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final visibleCount = isWideLayout ? 4 : 1;
                      final gap = noteCardGap;
                      final double cardWidth = isWideLayout
                          ? ((constraints.maxWidth - gap * (visibleCount - 1)) /
                                visibleCount)
                          : noteCardWidth;

                      double extent() => cardWidth + gap;

                      return NotificationListener<ScrollEndNotification>(
                        onNotification: (notification) {
                          if (notification.dragDetails == null) return false;
                          if (!controller.hasClients) return false;
                          final double e = extent();
                          if (e <= 0) return false;
                          final raw = controller.offset / e;
                          int snapIndex = raw.round();
                          snapIndex = snapIndex.clamp(0, notes.length - 1);
                          final target = snapIndex * e;
                          if ((controller.offset - target).abs() < 1.0) {
                            onIndexChanged(snapIndex);
                            return false;
                          }
                          controller.animateTo(
                            target.clamp(
                              0.0,
                              controller.position.maxScrollExtent,
                            ),
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                          );
                          onIndexChanged(snapIndex);
                          return false;
                        },
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          controller: controller,
                          padding: EdgeInsets.only(
                            right: isWideLayout
                                ? (visibleCount - 1) * (cardWidth + gap)
                                : 0,
                          ),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return GestureDetector(
                              onTap: () {
                                if (kIsWeb) {
                                  showGeneralDialog(
                                    context: context,
                                    barrierLabel: 'Note Detail',
                                    barrierDismissible: true,
                                    barrierColor: Colors.black.withOpacity(0.3),
                                    transitionDuration: const Duration(
                                      milliseconds: 250,
                                    ),
                                    pageBuilder: (ctx, anim1, anim2) {
                                      return Align(
                                        alignment: Alignment.centerRight,
                                        child: NoteDetailBottomSheet(
                                          note: note,
                                          noteViewModel: noteVM,
                                        ),
                                      );
                                    },
                                    transitionBuilder:
                                        (ctx, anim, secondaryAnim, child) {
                                          final offsetTween =
                                              Tween<Offset>(
                                                begin: const Offset(1, 0),
                                                end: Offset.zero,
                                              ).chain(
                                                CurveTween(
                                                  curve: Curves.easeOutCubic,
                                                ),
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
                                    backgroundColor: const Color(0XFFE7F0FF),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10),
                                      ),
                                    ),
                                    builder: (ctx) {
                                      return NoteDetailBottomSheet(
                                        note: note,
                                        noteViewModel: noteVM,
                                      );
                                    },
                                  );
                                }
                              },
                              child: Container(
                                width: cardWidth,
                                margin: EdgeInsets.only(
                                  right: index == notes.length - 1 ? 0 : gap,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFE6F4FF),
                                      Color(0xFF256533),
                                    ],
                                    stops: [0.51, 1.0],
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                      );
                    },
                  ),
                ),
                Visibility(
                  visible: !isWideLayout
                      ? currentIndex < notes.length - 1
                      : (currentIndex + 4) < notes.length,
                  maintainSize: true,
                  maintainState: true,
                  maintainAnimation: true,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right, size: 32),
                    onPressed: () {
                      final step = isWideLayout ? 4 : 1;
                      final int next = (currentIndex + step).clamp(
                        0,
                        notes.length - 1,
                      );
                      double extent;
                      if (isWideLayout && controller.hasClients) {
                        const visibleCount = 4;
                        final gap = noteCardGap;
                        final viewport = controller.position.viewportDimension;
                        final cardWidth =
                            (viewport - gap * (visibleCount - 1)) /
                            visibleCount;
                        extent = cardWidth + gap;
                      } else {
                        extent = noteCardWidth + noteCardGap;
                      }
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
