import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/task_modal.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/task_filter_dropdown.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/task_item_widget.dart';
import '../../viewmodel/home_viewmodel.dart';

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
                  children: [const TaskFilterDropdown()],
                ),
                const SizedBox(height: 16),

                // Task List
                ...viewModel.tugas.asMap().entries.map(
                  (entry) => TaskItemWidget(
                    title: entry.value['title'] as String,
                    status: entry.value['status'] as String,
                    onStatusChanged: (newStatus) {
                      viewModel.updateTask(
                        entry.key,
                        entry.value['title'] as String,
                        newStatus,
                        entry.value['deadline'] as DateTime,
                        entry.value['description'] as String,
                      );
                    },
                    onTap: () {
                      _showEditTaskModal(context, entry.key, entry.value);
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
          onSave: (title, status, deadline, description) {
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
            widget.viewModel.updateTask(
              index,
              title,
              status,
              deadline,
              description,
            );
          },
          onDelete: () {
            widget.viewModel.deleteTask(index);
          },
          initialData: task,
        );
      },
    );
  }
}
