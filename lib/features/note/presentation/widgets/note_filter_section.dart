import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/features/note/presentation/viewmodel/week_viewmodel.dart';

class NoteFilterSection extends StatelessWidget {
  final String filterWeekLabel;
  final bool myNotesOnly;
  final void Function(int? weekId, String label) onFilterWeekSelected;
  final ValueChanged<bool> onMyNotesOnlyChanged;
  final Widget notesSlider;

  const NoteFilterSection({
    super.key,
    required this.filterWeekLabel,
    required this.myNotesOnly,
    required this.onFilterWeekSelected,
    required this.onMyNotesOnlyChanged,
    required this.notesSlider,
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
                            border: Border.all(color: const Color(0xFF131927)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Consumer<WeekViewModel>(
                            builder: (context, weekVM, child) {
                              final weeks = weekVM.weeks;
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                ),
                                child: DropdownButton<String>(
                                  value: filterWeekLabel,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  dropdownColor: Colors.white,
                                  items: [
                                    const DropdownMenuItem(
                                      value: 'Semua',
                                      child: Text('Semua'),
                                    ),
                                    ...weeks.map((week) {
                                      return DropdownMenuItem(
                                        value: 'Minggu ${week.week}',
                                        child: Text('Minggu ${week.week}'),
                                      );
                                    }),
                                  ],
                                  onChanged: (newValue) {
                                    if (newValue == 'Semua') {
                                      onFilterWeekSelected(null, 'Semua');
                                    } else {
                                      final weekNum = int.tryParse(
                                        newValue?.replaceAll('Minggu ', '') ??
                                            '',
                                      );
                                      final selectedWeek = weeks.firstWhere(
                                        (w) => w.week == weekNum,
                                      );
                                      onFilterWeekSelected(
                                        selectedWeek.id,
                                        'Minggu ${selectedWeek.week}',
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: myNotesOnly,
                    onChanged: (value) {
                      if (value != null) {
                        onMyNotesOnlyChanged(value);
                      }
                    },
                  ),
                  const Text('Catatan Saya'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          notesSlider,
        ],
      ),
    );
  }
}
