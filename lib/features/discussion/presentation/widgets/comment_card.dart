import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/sub_answer.dart';

class CommentMessageCard extends StatefulWidget {
  final String name;
  final String message;
  final bool isOnline;
  final String? avatarUrl;
  final int answerId;
  final List<SubAnswer>? initialSubAnswers;
  final Function(String, int) onReplyPressed;
  final bool isExpanded;

  const CommentMessageCard({
    super.key,
    required this.name,
    required this.message,
    required this.answerId,
    this.isOnline = false,
    this.avatarUrl,
    this.initialSubAnswers,
    required this.onReplyPressed,
    this.isExpanded = false,
  });

  @override
  State<CommentMessageCard> createState() => _CommentMessageCardState();
}

class _CommentMessageCardState extends State<CommentMessageCard> {
  late List<SubAnswer> _subAnswers;
  bool _isLoading = false;
  late bool _showSubAnswers;

  @override
  void initState() {
    super.initState();
    _subAnswers = widget.initialSubAnswers ?? [];
    _showSubAnswers = widget.isExpanded;
  }

  @override
  void didUpdateWidget(CommentMessageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSubAnswers != null &&
        widget.initialSubAnswers != oldWidget.initialSubAnswers) {
      setState(() {
        _subAnswers = widget.initialSubAnswers!;
      });
    }
  }

  Future<void> _loadSubAnswers() async {
    if (_subAnswers.isNotEmpty) {
      setState(() {
        _showSubAnswers = !_showSubAnswers;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {} catch (e) {
      debugPrint('Error loading sub-answers: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleReplyButtonPressed() {
    widget.onReplyPressed(widget.name, widget.answerId);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main message card
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
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
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
                    onPressed: _handleReplyButtonPressed,
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
                  if (_subAnswers.isNotEmpty || _showSubAnswers) ...[
                    const Text(
                      '•',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        height: 1,
                      ),
                    ),
                  ],
                  if (_subAnswers.isNotEmpty || _showSubAnswers)
                    TextButton(
                      onPressed: _loadSubAnswers,
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
                      child: Text(
                        _showSubAnswers ? 'Sembunyikan' : 'Lihat Jawaban',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ),
            // Sub-answers section
            if (_showSubAnswers && _subAnswers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 52, top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _subAnswers
                      .map((subAnswer) => _buildSubAnswerCard(subAnswer))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubAnswerCard(SubAnswer subAnswer) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile avatar 
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 8, left: 4),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFD4C5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 24, color: Colors.white),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD2D5DB),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subAnswer.userName,
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
                  Text(subAnswer.content, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
