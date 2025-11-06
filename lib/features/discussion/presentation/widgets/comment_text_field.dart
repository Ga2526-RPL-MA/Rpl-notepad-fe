import 'package:flutter/material.dart';

class CommentTextField extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSend;

  const CommentTextField({Key? key, this.controller, this.onSend})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Color(0xFF9EA2AE), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Tulis Komentar....',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: onSend,
              icon: Icon(Icons.send, color: Colors.grey.shade700, size: 28),
              padding: EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
