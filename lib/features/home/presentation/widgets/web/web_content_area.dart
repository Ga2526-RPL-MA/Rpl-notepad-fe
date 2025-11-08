import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/task_modal.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/task_filter_dropdown.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/task_item_widget.dart';
import '../../viewmodel/home_viewmodel.dart';

class WebContentArea extends StatelessWidget {
  final HomeViewModel viewModel;
  final bool isWeb;

  const WebContentArea({
    super.key,
    required this.viewModel,
    this.isWeb = true,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title, Filter, and Add Button
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
                    Row(
                      children: [
                        // Filter Dropdown
                        const TaskFilterDropdown(),
                        const SizedBox(width: 16),
                        // Add Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
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
                  ],
                ),
                const SizedBox(height: 16),

                // Task List
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.tugas.length,
                    itemBuilder: (context, index) {
                      final task = viewModel.tugas[index];
                      return TaskItemWidget(
                        title: task['title'] as String,
                        status: task['status'] as String,
                        onStatusChanged: (newStatus) {
                          viewModel.updateTask(
                            index,
                            task['title'] as String,
                            newStatus,
                            task['deadline'] as DateTime,
                            task['description'] as String,
                          );
                        },
                        onTap: () {
                          _showEditTaskModal(context, index, task);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
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
            final viewModel = Provider.of<HomeViewModel>(
              context,
              listen: false,
            );
            viewModel.addTask(title, status, deadline, description);
          },
        );
      },
    );
  }

  void _showEditTaskModal(
    BuildContext context,
    int index,
    Map<String, dynamic> task,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddTaskModal(
          parentContext: context,
          onSave: (title, status, deadline, description) {
            final viewModel = Provider.of<HomeViewModel>(
              context,
              listen: false,
            );
            viewModel.updateTask(index, title, status, deadline, description);
          },
          onDelete: () {
            final viewModel = Provider.of<HomeViewModel>(
              context,
              listen: false,
            );
            viewModel.deleteTask(index);
          },
          initialData: task,
        );
      },
    );
  }
}