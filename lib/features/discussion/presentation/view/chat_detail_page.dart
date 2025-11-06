import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_background.dart';
import '../widgets/class_message_card.dart';

class ChatDetailPage extends StatefulWidget {
  final String name;
  final String message;
  final bool isOnline;

  const ChatDetailPage({
    super.key,
    required this.name,
    required this.message,
    this.isOnline = false,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _commentController = TextEditingController();

  void _handleSendComment() {
    final comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      print('Sending comment: $comment');
      _commentController.clear();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GradientBackground(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: ChatMessageCard(
                  name: widget.name,
                  message: widget.message,
                  isOnline: widget.isOnline,
                  showFullMessage: true,
                  commentController: _commentController,
                  onCommentSubmitted: _handleSendComment,
                  comments: [
                    {
                      'name': 'User Name',
                      'message': 'This is a sample comment',
                      'isOnline': true,
                      'avatarUrl': null,
                    },
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
