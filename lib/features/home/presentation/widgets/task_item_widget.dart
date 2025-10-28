import 'package:flutter/material.dart';

class TaskItemWidget extends StatelessWidget {
  final String title;
  final String status;
  final VoidCallback? onTap;

  const TaskItemWidget({
    Key? key,
    required this.title,
    required this.status,
    this.onTap,
  }) : super(key: key);

  Color getBackgroundColor() {
    switch (status) {
      case 'in_progress':
        return const Color(0xFFECF8EF);
      case 'pending':
        return Colors.white;
      case 'completed':
        return const Color(0xFF6A766C);
      default:
        return Colors.white;
    }
  }

  Color getTextColor() {
    return status == 'completed' ? Colors.white : Colors.black;
  }

  IconData getIconData() {
    switch (status) {
      case 'in_progress':
      case 'pending':
        return Icons.radio_button_unchecked;
      case 'completed':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  Color getIconColor() {
    if (status == 'in_progress') return const Color(0xFF69C57D);
    if (status == 'completed') return Colors.white;
    return Color(0xFF6D717F);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: status != 'completed'
              ? Border.all(
                  color: status == 'in_progress'
                      ? const Color(0xFF43B75D)
                      : Colors.black,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(getIconData(), color: getIconColor(), size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: getTextColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
