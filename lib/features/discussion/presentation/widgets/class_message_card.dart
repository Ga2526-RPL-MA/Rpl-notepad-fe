import 'package:flutter/material.dart';
import 'dart:math';
import 'comment_card.dart';
import 'comment_text_field.dart';

class ChatMessageCard extends StatefulWidget {
  final String name;
  final String message;
  final int replyCount;
  final bool isOnline;
  final VoidCallback? onTap;
  final bool showFullMessage;
  final int maxPreviewLength = 100;
  final List<Map<String, dynamic>> comments;
  final TextEditingController? commentController;
  final VoidCallback? onCommentSubmitted;

  const ChatMessageCard({
    super.key,
    required this.name,
    required this.message,
    this.replyCount = 0,
    this.isOnline = false,
    this.showFullMessage = false,
    this.onTap,
    this.comments = const [],
    this.commentController,
    this.onCommentSubmitted,
  });

  @override
  State<ChatMessageCard> createState() => _ChatMessageCardState();
}

class _ChatMessageCardState extends State<ChatMessageCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            //  Header 
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4C5F9),
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (widget.isOnline)
                      Positioned(
                        bottom: 1,
                        left: 1,
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            //  Message 
            StatefulBuilder(
              builder: (context, setState) {
                final shouldShowFullText =
                    widget.showFullMessage ||
                    isExpanded ||
                    widget.message.length <= widget.maxPreviewLength;

                final displayText = shouldShowFullText
                    ? widget.message
                    : '${widget.message.substring(0, min(widget.message.length, widget.maxPreviewLength))}...';

                return RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      height: 1.5,
                      fontFamily: 'Inter',
                    ),
                    children: [
                      TextSpan(text: displayText),
                      if (widget.message.length > widget.maxPreviewLength &&
                          !widget.showFullMessage)
                        const TextSpan(text: ' '),
                      if (!shouldShowFullText &&
                          widget.message.length > widget.maxPreviewLength)
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = true;
                              });
                            },
                            child: const Text(
                              'Selengkapnya',
                              style: TextStyle(
                                color: Color(0xFF43B75D),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else if (widget.message.length >
                              widget.maxPreviewLength &&
                          isExpanded)
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = false;
                              });
                            },
                            child: const Text(
                              'Lebih sedikit',
                              style: TextStyle(
                                color: Color(0xFF43B75D),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 12),
            const Divider(color: Color(0xFF9EA2AE), thickness: 1),

            if (widget.replyCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.replyCount} Jawaban',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            //Comment
            if (widget.comments.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...widget.comments.map(
                (comment) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CommentMessageCard(
                    name: comment['name'] ?? 'User',
                    message: comment['message'] ?? '',
                    isOnline: comment['isOnline'] ?? false,
                    avatarUrl: comment['avatarUrl'],
                  ),
                ),
              ),
            ],

            //  Comment Input 
            if (widget.commentController != null &&
                widget.onCommentSubmitted != null) ...[
              const SizedBox(height: 24),
              const Spacer(), 
              CommentTextField(
                controller: widget.commentController!,
                onSend: widget.onCommentSubmitted!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
