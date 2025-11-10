import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/home/domain/entities/task.dart';

class TaskItemWidget extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<String>? onStatusChanged;

  const TaskItemWidget({
    Key? key,
    required this.task,
    this.onTap,
    this.onStatusChanged,
  }) : super(key: key);

  Color getBackgroundColor() {
    switch (task.status) {
      case 'ongoing':
        return const Color(0xFFECF8EF);
      case 'completed':
        return const Color(0xFF6A766C);
      default:
        return Colors.white;
    }
  }

  Color getTextColor() {
    return task.status == 'completed' ? Colors.white : Colors.black;
  }

  IconData getIconData() {
    return task.status == 'completed'
        ? Icons.check_circle_outline_rounded
        : Icons.radio_button_unchecked;
  }

  Color getIconColor() {
    if (task.status == 'ongoing') return const Color(0xFF69C57D);
    if (task.status == 'completed') return Colors.white;
    return const Color(0xFF6D717F);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: task.status != 'completed' 
            ? Border.all(color: const Color(0xFF43B75D), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (onStatusChanged != null)
                  GestureDetector(
                    onTap: () {
                      final newStatus = task.status == 'completed'
                          ? 'ongoing'
                          : 'completed';
                      onStatusChanged?.call(newStatus);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        getIconData(),
                        color: getIconColor(),
                        size: 24,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: getTextColor(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
