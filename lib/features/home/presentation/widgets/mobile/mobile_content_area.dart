import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/add_task_modal.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/task_item_widget.dart';
import '../../viewmodel/home_viewmodel.dart';

class MobileContentArea extends StatelessWidget {
  final HomeViewModel viewModel;
  final bool isWeb;

  const MobileContentArea({
    super.key,
    required this.viewModel,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
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
              fontSize: isWeb ? 26 : 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          
          // Task List
          ...viewModel.tugas.map((item) => TaskItemWidget(
                title: item['title'] as String,
                status: item['status'] as String,
              )),
              
          // Add Task Button (Mobile)
          const SizedBox(height: 24),
          _buildAddButton(context),
          const SizedBox(height: 24),
        ],
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
}
