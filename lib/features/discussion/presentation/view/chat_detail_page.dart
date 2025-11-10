import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/sub_answer.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/viewmodel/chat_detail_viewmodel.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import '../widgets/class_message_card.dart';
import '../widgets/comment_card.dart';
import '../widgets/comment_input_field.dart';

class ChatDetailPage extends StatefulWidget {
  final int issueId;
  final String className;
  final String message;
  final String userName;
  final bool isOnline;

  const ChatDetailPage({
    super.key,
    required this.issueId,
    required this.className,
    required this.message,
    required this.userName,
    this.isOnline = false,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  late ChatDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ChatDetailViewModel(
      issueId: widget.issueId,
      userName: widget.userName,
      message: widget.message,
      className: widget.className,
    );
    _viewModel.addListener(_onViewModelChange);
    _loadData();
  }

  Future<void> _loadData() async {
    await _viewModel.loadAnswers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute? route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      _loadData();
    }
  }

  void _onViewModelChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _viewModel.removeListener(_onViewModelChange);
    _viewModel.dispose();
    super.dispose();
  }

  void _handleReplyPressed(String name, int answerId) {
    _viewModel.handleReplyPressed(name, answerId);
  }

  void _handleCancelReply() {
    _viewModel.cancelReply();
  }

  Future<void> _handleSendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    await _viewModel.sendComment(content);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final mainIssue = _viewModel.getMainIssue();

    return Scaffold(
      drawer: const Drawer(),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: Column(
                  children: [
                    // Header row
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          // Back button
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          // Search bar
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: CustomSearchBar(
                                hintText: 'Cari diskusi...',
                              ),
                            ),
                          ),
                          // Menu button
                          Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.menu, color: Colors.black),
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Class name
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.className,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main content area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8.0),
                        ClassMessageCard(
                          issue: mainIssue,
                          showReplyCount: false,
                          answersWidget: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height * 0.5,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Answers section
                                    if (_viewModel.isLoading)
                                      const Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    else if (_viewModel.errorMessage != null)
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          _viewModel.errorMessage!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    else if (_viewModel.answers.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          'Belum ada jawaban untuk diskusi ini',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      )
                                    else
                                      // Display answers
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          0,
                                          8.0,
                                          8.0,
                                          16.0,
                                        ),
                                        child: Column(
                                          children: _viewModel.answers
                                              .where(
                                                (answer) =>
                                                    answer.issueId ==
                                                    widget.issueId,
                                              )
                                              .toList()
                                              .reversed
                                              .map(
                                                (answer) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 12.0,
                                                      ),
                                                  child: CommentMessageCard(
                                                    name: answer.userName,
                                                    message: answer.content,
                                                    answerId: answer.id,
                                                    isOnline: false,
                                                    onReplyPressed:
                                                        _handleReplyPressed,
                                                    initialSubAnswers: answer
                                                        .subAnswers
                                                        .map(
                                                          (sub) => SubAnswer(
                                                            id: sub.id,
                                                            userName:
                                                                sub.userName,
                                                            content:
                                                                sub.content,
                                                            answeredAt:
                                                                sub.answeredAt,
                                                            answerId:
                                                                sub.answerId,
                                                          ),
                                                        )
                                                        .toList(),
                                                    isExpanded:
                                                        _viewModel
                                                            .expandedAnswerId ==
                                                        answer.id,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Input field
                              CommentInputField(
                                controller: _commentController,
                                isSubmitting: _viewModel.isSubmitting,
                                onSendPressed: _handleSendComment,
                                replyingTo: _viewModel.replyingToName,
                                onCancelReply: _handleCancelReply,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
