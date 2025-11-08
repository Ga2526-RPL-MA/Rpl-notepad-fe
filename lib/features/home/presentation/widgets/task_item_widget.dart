import 'package:flutter/material.dart';

class TaskItemWidget extends StatelessWidget {
  final String title;
  final String status;
  final VoidCallback? onTap;
  final ValueChanged<String>? onStatusChanged;

  const TaskItemWidget({
    Key? key,
    required this.title,
    required this.status,
    this.onTap,
    this.onStatusChanged,
  }) : super(key: key);

  Color getBackgroundColor() {
    switch (status) {
      case 'ongoing':
        return const Color(0xFFECF8EF);
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
      case 'ongoing':
        return Icons.radio_button_unchecked;
      case 'completed':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  Color getIconColor() {
    if (status == 'ongoing') return const Color(0xFF69C57D);
    if (status == 'completed') return Colors.white;
    return Color(0xFF6D717F);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: status != 'completed'
              ? Border.all(
                  color: status == 'ongoing'
                      ? const Color(0xFF43B75D)
                      : Colors.black,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onStatusChanged != null ? () {
                    final newStatus = status == 'ongoing' ? 'completed' : 'ongoing';
                    onStatusChanged!(newStatus);
                  } : null,
                  child: Icon(getIconData(), color: getIconColor(), size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
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
