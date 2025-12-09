import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_card.dart';
import 'package:rpl_notepad_fe/core/widgets/menu_drawer.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/viewmodel/login_view_model.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/sub_answer.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/viewmodel/chat_detail_viewmodel.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/user_profile.dart';
import '../widgets/class_message_card.dart';
import '../widgets/comment_card.dart';
import '../widgets/comment_input_field.dart';
import 'package:rpl_notepad_fe/core/widgets/loading_overlay.dart';
import 'package:rpl_notepad_fe/core/widgets/toast_notification.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_modal.dart';
import 'package:rpl_notepad_fe/core/di/injection.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/delete_issue_usecase.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/delete_answer_usecase.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/delete_sub_answer_usecase.dart';

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
    if (content.isEmpty) {
      showAppToast(
        context,
        message: 'Isi komentar tidak boleh kosong',
        type: AppToastType.warning,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    await _viewModel.sendComment(content);

    if (_viewModel.errorMessage == null) {
      // Success
      _commentController.clear();
      showAppToast(
        context,
        message: 'Komentar terkirim',
        type: AppToastType.success,
        duration: const Duration(seconds: 2),
      );
    } else {
      // Error
      showAppToast(
        context,
        message: _viewModel.errorMessage ?? 'Gagal mengirim komentar',
        type: AppToastType.error,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainIssue = _viewModel.getMainIssue();
    final isWeb = MediaQuery.of(context).size.width > 800;

    if (isWeb) {
      return Scaffold(
        body: Stack(
          children: [
            GradientBackground(
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sidebar
                    MenuDrawer(currentPage: 'diskusi', onPageChanged: (_) {}),
                    const SizedBox(width: 20),
                    // Main content
                    Expanded(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Header card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CustomCard(
                              color: Colors.white,
                              width: double.infinity,
                              height: 100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: CustomSearchBar(
                                      hintText: 'Cari diskusi...',
                                      onSearch: (query) {
                                        _viewModel.searchAnswers(query);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Consumer<LoginViewModel>(
                                    builder: (context, loginVM, _) {
                                      return UserProfile(
                                        name:
                                            AuthService.userName?.isNotEmpty ==
                                                true
                                            ? AuthService.userName!
                                            : 'User',
                                        email:
                                            AuthService.userEmail?.isNotEmpty ==
                                                true
                                            ? AuthService.userEmail!
                                            : 'user@example.com',
                                        avatarSize: 40,
                                        avatarColor: Color(0xFFD4C5F9),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Class name and back button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    } else {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pushNamedAndRemoveUntil(
                                        '/discussion',
                                        (route) => false,
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
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
                          const SizedBox(height: 12),
                          // Content area
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: ClassMessageCard(
                                issue: mainIssue,
                                showReplyCount: false,
                                forceFullContent: true,
                                showDeleteButton: AuthService.isAdmin,
                                onDelete: () async {
                                  CustomModal.show(
                                    context,
                                    title: 'Konfirmasi Hapus',
                                    message: 'Apakah Anda yakin ingin menghapus diskusi ini?',
                                    primaryButtonText: 'Hapus',
                                    secondaryButtonText: 'Batal',
                                    onPrimaryPressed: () async {
                                      Navigator.pop(context);
                                      
                                      try {
                                        final deleteUseCase = getIt<DeleteIssueUseCase>();
                                        await deleteUseCase(widget.issueId);
                                        
                                        if (mounted) {
                                          Navigator.of(context).pop(true); // Return true to indicate deletion
                                          showAppToast(
                                            context,
                                            title: 'Berhasil',
                                            message: 'Diskusi berhasil dihapus',
                                            type: AppToastType.success,
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          showAppToast(
                                            context,
                                            title: 'Gagal',
                                            message: 'Gagal menghapus diskusi: $e',
                                            type: AppToastType.error,
                                          );
                                        }
                                      }
                                    },
                                    onSecondaryPressed: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                                contentPadding: const EdgeInsets.fromLTRB(
                                  32,
                                  32,
                                  32,
                                  12,
                                ),
                                answersWidget: Expanded(
                                  child: Builder(
                                    builder: (context) {
                                      if (_viewModel.errorMessage != null) {
                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(
                                              _viewModel.errorMessage!,
                                              style: const TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                  
                                   
                                      final answersForIssue = _viewModel.answers
                                          .where(
                                            (a) => a.issueId == widget.issueId,
                                          )
                                          .toList();


                                      // Show message when there are no answers
                                      if (answersForIssue.isEmpty) {
                                        return const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Text(
                                              'Belum ada jawaban untuk diskusi ini',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontStyle: FontStyle.italic,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      return ListView.builder(
                                        padding: const EdgeInsets.fromLTRB(
                                          0,
                                          8,
                                          8,
                                          8,
                                        ),
                                        itemCount: answersForIssue.length,
                                        itemBuilder: (context, index) {
                                          final answer = answersForIssue[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12.0,
                                            ),
                                            child: CommentMessageCard(
                                              name: answer.userName,
                                              message: answer.content,
                                              answerId: answer.id,
                                              isOnline: false,
                                              onReplyPressed:
                                                  _handleReplyPressed,
                                              showDeleteButton: AuthService.isAdmin,
                                              onDeleteAnswer: () {
                                                final parentContext = context;
                                                CustomModal.show(
                                                  context,
                                                  title: 'Konfirmasi Hapus',
                                                  message: 'Apakah Anda yakin ingin menghapus komentar ini?',
                                                  primaryButtonText: 'Hapus',
                                                  secondaryButtonText: 'Batal',
                                                  onPrimaryPressed: () async {
                                                    Navigator.pop(context);
                                                    
                                                    // Wait for modal to close completely
                                                    await Future.delayed(const Duration(milliseconds: 300));
                                                    
                                                    try {
                                                      final deleteUseCase = getIt<DeleteAnswerUseCase>();
                                                      await deleteUseCase(answer.id);
                                                      if (mounted) {
                                                        await _viewModel.loadAnswers();
                                                        if (mounted) {
                                                          showAppToast(
                                                            parentContext,
                                                            title: 'Berhasil',
                                                            message: 'Komentar berhasil dihapus',
                                                            type: AppToastType.success,
                                                          );
                                                        }
                                                      }
                                                    } catch (e) {
                                                      if (mounted) {
                                                        showAppToast(
                                                          parentContext,
                                                          title: 'Gagal',
                                                          message: 'Gagal menghapus komentar: $e',
                                                          type: AppToastType.error,
                                                        );
                                                      }
                                                    }
                                                  },
                                                  onSecondaryPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                );
                                              },
                                              onDeleteSubAnswer: (subAnswerId) {
                                                final parentContext = context;
                                                CustomModal.show(
                                                  context,
                                                  title: 'Konfirmasi Hapus',
                                                  message: 'Apakah Anda yakin ingin menghapus balasan ini?',
                                                  primaryButtonText: 'Hapus',
                                                  secondaryButtonText: 'Batal',
                                                  onPrimaryPressed: () async {
                                                    Navigator.pop(context);
                                                    
                                                    // Wait for modal to close completely
                                                    await Future.delayed(const Duration(milliseconds: 300));
                                                    
                                                    try {
                                                      final deleteUseCase = getIt<DeleteSubAnswerUseCase>();
                                                      await deleteUseCase(subAnswerId);
                                                      if (mounted) {
                                                        await _viewModel.loadAnswers();
                                                        if (mounted) {
                                                          showAppToast(
                                                            parentContext,
                                                            title: 'Berhasil',
                                                            message: 'Balasan berhasil dihapus',
                                                            type: AppToastType.success,
                                                          );
                                                        }
                                                      }
                                                    } catch (e) {
                                                      if (mounted) {
                                                        showAppToast(
                                                          parentContext,
                                                          title: 'Gagal',
                                                          message: 'Gagal menghapus balasan: $e',
                                                          type: AppToastType.error,
                                                        );
                                                      }
                                                    }
                                                  },
                                                  onSecondaryPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                );
                                              },
                                              initialSubAnswers: answer
                                                  .subAnswers
                                                  .map(
                                                    (sub) => SubAnswer(
                                                      id: sub.id,
                                                      userName: sub.userName,
                                                      content: sub.content,
                                                      answeredAt:
                                                          sub.answeredAt,
                                                      answerId: sub.answerId,
                                                    ),
                                                  )
                                                  .toList(),
                                              isExpanded:
                                                  _viewModel.expandedAnswerId ==
                                                  answer.id,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: CommentInputField(
                                controller: _commentController,
                                isSubmitting: _viewModel.isSubmitting,
                                onSendPressed: _handleSendComment,
                                replyingTo: _viewModel.replyingToName,
                                onCancelReply: _handleCancelReply,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_viewModel.isLoading) const LoadingOverlay(),
          ],
        ),
      );
    }

    // Mobile
    return Scaffold(
      drawer: const Drawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          GradientBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // Header section
                  Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                    child: Column(
                      children: [
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
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                ),
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: CustomSearchBar(
                                    hintText: 'Cari diskusi...',
                                    onSearch: (query) {
                                      _viewModel.searchAnswers(
                                        query,
                                      ); // ✅ CONNECT KE VIEWMODEL
                                    },
                                  ),
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
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: ClassMessageCard(
                              issue: mainIssue,
                              showReplyCount: false,
                              forceFullContent: true,
                              showDeleteButton: AuthService.isAdmin,
                              onDelete: () async {
                                CustomModal.show(
                                  context,
                                  title: 'Konfirmasi Hapus',
                                  message: 'Apakah Anda yakin ingin menghapus diskusi ini?',
                                  primaryButtonText: 'Hapus',
                                  secondaryButtonText: 'Batal',
                                  onPrimaryPressed: () async {
                                    Navigator.pop(context);
                                    
                                    try {
                                      final deleteUseCase = getIt<DeleteIssueUseCase>();
                                      await deleteUseCase(widget.issueId);
                                      
                                      if (mounted) {
                                        Navigator.of(context).pop(true); // Return true to indicate deletion
                                        showAppToast(
                                          context,
                                          title: 'Berhasil',
                                          message: 'Diskusi berhasil dihapus',
                                          type: AppToastType.success,
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        showAppToast(
                                          context,
                                          title: 'Gagal',
                                          message: 'Gagal menghapus diskusi: $e',
                                          type: AppToastType.error,
                                        );
                                      }
                                    }
                                  },
                                  onSecondaryPressed: () {
                                    Navigator.pop(context);
                                  },
                                );
                              },
                              contentPadding: const EdgeInsets.fromLTRB(
                                32,
                                32,
                                32,
                                12,
                              ),
                              answersWidget: Expanded(
                                child: Builder(
                                  builder: (context) {
                                    if (_viewModel.errorMessage != null) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            _viewModel.errorMessage!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    final answersForIssue = _viewModel.answers
                                        .where(
                                          (a) => a.issueId == widget.issueId,
                                        )
                                        .toList();
                                    if (answersForIssue.isEmpty) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text(
                                            'Belum ada jawaban untuk diskusi ini',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    final safeBottom = MediaQuery.of(
                                      context,
                                    ).padding.bottom;
                                    final keyboardInset = MediaQuery.of(
                                      context,
                                    ).viewInsets.bottom;
                                    final bottomPadding =
                                        safeBottom +
                                        16.0 +
                                        (keyboardInset > 0 ? keyboardInset : 0);

                                    return ListView.builder(
                                      padding: EdgeInsets.fromLTRB(
                                        0,
                                        8,
                                        8,
                                        bottomPadding,
                                      ),
                                      keyboardDismissBehavior:
                                          ScrollViewKeyboardDismissBehavior
                                              .onDrag,
                                      itemCount: answersForIssue.length,
                                      itemBuilder: (context, index) {
                                        final answer = answersForIssue[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12.0,
                                          ),
                                          child: CommentMessageCard(
                                            name: answer.userName,
                                            message: answer.content,
                                            answerId: answer.id,
                                            isOnline: false,
                                            onReplyPressed: _handleReplyPressed,
                                            showDeleteButton: AuthService.isAdmin,
                                            onDeleteAnswer: () {
                                              final parentContext = context;
                                              CustomModal.show(
                                                context,
                                                title: 'Konfirmasi Hapus',
                                                message: 'Apakah Anda yakin ingin menghapus komentar ini?',
                                                primaryButtonText: 'Hapus',
                                                secondaryButtonText: 'Batal',
                                                onPrimaryPressed: () async {
                                                  Navigator.pop(context);
                                                  
                                                  // Wait for modal to close completely
                                                  await Future.delayed(const Duration(milliseconds: 300));
                                                  
                                                  try {
                                                    final deleteUseCase = getIt<DeleteAnswerUseCase>();
                                                    await deleteUseCase(answer.id);
                                                    if (mounted) {
                                                      await _viewModel.loadAnswers();
                                                      if (mounted) {
                                                        showAppToast(
                                                          parentContext,
                                                          title: 'Berhasil',
                                                          message: 'Komentar berhasil dihapus',
                                                          type: AppToastType.success,
                                                        );
                                                      }
                                                    }
                                                  } catch (e) {
                                                    if (mounted) {
                                                      showAppToast(
                                                        parentContext,
                                                        title: 'Gagal',
                                                        message: 'Gagal menghapus komentar: $e',
                                                        type: AppToastType.error,
                                                      );
                                                    }
                                                  }
                                                },
                                                onSecondaryPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                            onDeleteSubAnswer: (subAnswerId) {
                                              final parentContext = context;
                                              CustomModal.show(
                                                context,
                                                title: 'Konfirmasi Hapus',
                                                message: 'Apakah Anda yakin ingin menghapus balasan ini?',
                                                primaryButtonText: 'Hapus',
                                                secondaryButtonText: 'Batal',
                                                onPrimaryPressed: () async {
                                                  Navigator.pop(context);
                                                  
                                                  // Wait for modal to close completely
                                                  await Future.delayed(const Duration(milliseconds: 300));
                                                  
                                                  try {
                                                    final deleteUseCase = getIt<DeleteSubAnswerUseCase>();
                                                    await deleteUseCase(subAnswerId);
                                                    if (mounted) {
                                                      await _viewModel.loadAnswers();
                                                      if (mounted) {
                                                        showAppToast(
                                                          parentContext,
                                                          title: 'Berhasil',
                                                          message: 'Balasan berhasil dihapus',
                                                          type: AppToastType.success,
                                                        );
                                                      }
                                                    }
                                                  } catch (e) {
                                                    if (mounted) {
                                                      showAppToast(
                                                        parentContext,
                                                        title: 'Gagal',
                                                        message: 'Gagal menghapus balasan: $e',
                                                        type: AppToastType.error,
                                                      );
                                                    }
                                                  }
                                                },
                                                onSecondaryPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              );
                                            },
                                            initialSubAnswers: answer.subAnswers
                                                .map(
                                                  (sub) => SubAnswer(
                                                    id: sub.id,
                                                    userName: sub.userName,
                                                    content: sub.content,
                                                    answeredAt: sub.answeredAt,
                                                    answerId: sub.answerId,
                                                  ),
                                                )
                                                .toList(),
                                            isExpanded:
                                                _viewModel.expandedAnswerId ==
                                                answer.id,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: CommentInputField(
                            controller: _commentController,
                            isSubmitting: _viewModel.isSubmitting,
                            onSendPressed: _handleSendComment,
                            replyingTo: _viewModel.replyingToName,
                            onCancelReply: _handleCancelReply,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_viewModel.isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }
}
