import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/add_task_modal.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/task_item_widget.dart';
import '../../viewmodel/home_viewmodel.dart';

class WebContentArea extends StatelessWidget {
  final HomeViewModel viewModel;

  const WebContentArea({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tugas Kuliah',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _showAddTaskModal(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Tambah',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Task List
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.tugas.length,
              itemBuilder: (context, index) {
                final task = viewModel.tugas[index];
                return TaskItemWidget(
                  title: task['title'] as String,
                  status: task['status'] as String,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddTaskModal(
          parentContext: context,
          onSave: (title, status, deadline, description) {
            // Handle task saving
            viewModel.addTask(title, status, deadline, description);
          },
        );
      },
    );
  }
}
