import 'package:flutter/material.dart';

class CommentInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSendPressed;
  final String hintText;
  final String? replyingTo;
  final VoidCallback? onCancelReply;
  final int? answerId;
  const CommentInputField({
    super.key,
    required this.controller,
    required this.isSubmitting,
    required this.onSendPressed,
    this.hintText = 'Tulis komentar...',
    this.replyingTo,
    this.onCancelReply,
    this.answerId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: answerId != null ? 'Balas komentar...' : hintText,
                    hintStyle: const TextStyle(overflow: TextOverflow.ellipsis),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF9EA2AE),
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF9EA2AE),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF9EA2AE),
                        width: 1.5,
                      ),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(
                      20.0,
                      (replyingTo != null || answerId != null) ? 56.0 : 16.0,
                      60.0,
                      16.0,
                    ),
                    constraints: const BoxConstraints(
                      maxWidth: double.infinity,
                    ),
                    isCollapsed: true,
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.black,
                        size: 22,
                      ),
                      onPressed: isSubmitting ? null : onSendPressed,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  maxLines: 1,
                ),
                // Label Menjawab
                if (replyingTo != null || answerId != null)
                  Positioned(
                    left: 12,
                    right: 60,
                    top: 12,
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F0FF).withOpacity(0.48),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              replyingTo != null
                                  ? 'Menjawab $replyingTo'
                                  : 'Membalas komentar...',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (onCancelReply != null) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: onCancelReply,
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
