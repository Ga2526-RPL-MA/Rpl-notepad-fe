import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/task_modal.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/task_filter_dropdown.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/task_item_widget.dart';
import 'package:rpl_notepad_fe/features/home/presentation/viewmodel/home_viewmodel.dart';

class WebContentArea extends StatefulWidget {
  final HomeViewModel viewModel;
  final bool isWeb;

  const WebContentArea({super.key, required this.viewModel, this.isWeb = true});

  @override
  State<WebContentArea> createState() => _WebContentAreaState();
}

class _WebContentAreaState extends State<WebContentArea> {
  @override
  void initState() {
    super.initState();
    // Fetch tasks when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.viewModel,
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
                      'Daftar Tugas',
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
                  child: Column(
                    children: [
                      if (viewModel.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (viewModel.error != null)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                viewModel.error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => viewModel.fetchTasks(),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      else if (viewModel.tasks.isEmpty)
                        const Center(
                          child: Text('Tidak ada tugas yang tersedia'),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: viewModel.tasks.length,
                            itemBuilder: (context, index) {
                              final task = viewModel.tasks[index];
                              return TaskItemWidget(
                                task: task,
                                onStatusChanged: (newStatus) {
                                  viewModel.updateTask(
                                    viewModel.tasks.indexOf(task),
                                    task.title,
                                    newStatus,
                                    task.dueDate ?? DateTime.now(),
                                    task.description ?? '',
                                    classId: task.classId,
                                  );
                                },
                                onTap: () {
                                  _showEditTaskModal(
                                    context,
                                    viewModel.tasks.indexOf(task),
                                    {
                                      'title': task.title,
                                      'status': task.status,
                                      'deadline': task.dueDate,
                                      'description': task.description,
                                      'classId': task.classId,
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                    ],
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
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddTaskModal(
          parentContext: context,
          onSave: (title, status, deadline, description, classId) {
            viewModel.addTask(
              title,
              status,
              deadline,
              description,
              classId: int.tryParse(classId),
            );
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
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddTaskModal(
          parentContext: context,
          onSave: (title, status, deadline, description, classId) {
            viewModel.updateTask(
              index,
              title,
              status,
              deadline,
              description,
              classId: int.tryParse(classId) ?? task['classId'] ?? 1,
            );
          },
          onDelete: () {
            viewModel.deleteTask(index);
          },
          initialData: task,
        );
      },
    );
  }
}
