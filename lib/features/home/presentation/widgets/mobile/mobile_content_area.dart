import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/task_modal.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/task_filter_dropdown.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/task_item_widget.dart';
import 'package:rpl_notepad_fe/features/home/presentation/viewmodel/home_viewmodel.dart';

class MobileContentArea extends StatefulWidget {
  final HomeViewModel viewModel;
  final bool isWeb;

  const MobileContentArea({
    super.key,
    required this.viewModel,
    required this.isWeb,
  });

  @override
  State<MobileContentArea> createState() => _MobileContentAreaState();
}

class _MobileContentAreaState extends State<MobileContentArea> {
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
          return Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Search bar for mobile
                const CustomSearchBar(),
                const SizedBox(height: 24),
                // Title
                Text(
                  'Tugas Kuliah',
                  style: TextStyle(
                    fontSize: widget.isWeb ? 26 : 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Dropdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [TaskFilterDropdown()],
                ),
                const SizedBox(height: 24),
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
                  const Center(child: Text('Tidak ada tugas yang tersedia'))
                else
                  ...viewModel.tasks.map(
                    (task) => TaskItemWidget(
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
                    ),
                  ),
                // Add Task Button (Mobile)
                const SizedBox(height: 24),
                _buildAddButton(context),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 134,
        height: 38,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => _showAddTaskModal(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add, size: 16, color: Colors.white),
              SizedBox(width: 6),
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
