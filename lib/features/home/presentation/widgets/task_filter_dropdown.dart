import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/home_viewmodel.dart';

class TaskFilterDropdown extends StatelessWidget {
  const TaskFilterDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    final filters = [
      {'value': 'all', 'label': 'Semua'},
      {'value': 'ongoing', 'label': 'Belum Selesai'},
      {'value': 'completed', 'label': 'Selesai'},
    ];

    String getCurrentLabel() {
      return filters.firstWhere(
        (f) => f['value'] == viewModel.currentFilter,
        orElse: () => filters[0],
      )['label']!;
    }

    return PopupMenuButton<String>(
      onSelected: (value) {
        viewModel.setFilter(value);
      },
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      itemBuilder: (BuildContext context) {
        return filters.map((filter) {
          return PopupMenuItem<String>(
            value: filter['value'],
            child: Text(
              filter['label']!,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                color: Colors.black87,
              ),
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF131927), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              getCurrentLabel(),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}
