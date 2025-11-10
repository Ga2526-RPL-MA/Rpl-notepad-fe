import 'package:flutter/material.dart';
import 'dart:math';
import '../../domain/entities/issue.dart';

class ClassMessageCard extends StatefulWidget {
  final Issue issue;
  final VoidCallback? onTap;
  final bool showReplyCount;
  final Widget? answersWidget;

  const ClassMessageCard({
    super.key,
    required this.issue,
    this.onTap,
    this.showReplyCount = true,
    this.answersWidget,
  });

  @override
  State<ClassMessageCard> createState() => _ClassMessageCardState();
}

class _ClassMessageCardState extends State<ClassMessageCard> {
  bool isExpanded = false;
  final int maxPreviewLength = 100;

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;

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
          children: [
            // Header
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
                      child: Center(
                        child: Text(
                          issue.userName.isNotEmpty
                              ? issue.userName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Status online 
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
                    issue.userName,
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

            // Long Message
            StatefulBuilder(
              builder: (context, setState) {
                final shouldShowFullText =
                    isExpanded || issue.content.length <= maxPreviewLength;

                final displayText = shouldShowFullText
                    ? issue.content
                    : '${issue.content.substring(0, min(issue.content.length, maxPreviewLength))}...';

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
                      if (issue.content.length > maxPreviewLength)
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: Text(
                              isExpanded ? ' Lebih sedikit' : ' Selengkapnya',
                              style: const TextStyle(
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

            // Reply count
            if (widget.showReplyCount)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${issue.answers.fold<int>(0, (total, answer) => total + 1 + answer.subAnswers.length)} jawaban',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),

            // Answers widget
            if (widget.answersWidget != null) widget.answersWidget!,
          ],
        ),
      ),
    );
  }
}
