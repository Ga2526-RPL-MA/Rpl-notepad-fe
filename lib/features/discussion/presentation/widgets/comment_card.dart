import 'package:flutter/material.dart';

class CommentMessageCard extends StatefulWidget {
  final String name;
  final String message;
  final bool isOnline;
  final String? avatarUrl;

  const CommentMessageCard({
    super.key,
    required this.name,
    required this.message,
    this.isOnline = false,
    this.avatarUrl,
  });

  @override
  State<CommentMessageCard> createState() => _CommentMessageCardState();
}

class _CommentMessageCardState extends State<CommentMessageCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar and Message in a row with perfect alignment
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with center alignment
                Padding(
                  padding: const EdgeInsets.only(top: 12, right: 8, left: 4),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4C5F9),
                          shape: BoxShape.circle,
                        ),
                        child: widget.avatarUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  widget.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.person, size: 24);
                                  },
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 24,
                                color: Colors.white,
                              ),
                      ),
                      if (widget.isOnline)
                        Positioned(
                          bottom: -1,
                          left: -1,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF34C759),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Message container
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECF8EF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Message
                        Text(widget.message),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Action buttons
          Padding(
            padding: const EdgeInsets.only(left: 52, top: 2),
            child: Row(
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      top: 2,
                      bottom: 2,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Jawab',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Text(
                  '•',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    height: 1,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      top: 2,
                      bottom: 2,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Lihat Jawaban',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
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
