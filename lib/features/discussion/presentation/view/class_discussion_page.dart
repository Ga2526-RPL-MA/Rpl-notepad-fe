import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/core/widgets/menu_drawer.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/widgets/discussion_input_form.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/view/chat_detail_page.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/widgets/class_message_card.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/viewmodel/class_discussion_viewmodel.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_card.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/user_profile.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/login_view_model.dart';
import 'package:rpl_notepad_fe/core/widgets/loading_overlay.dart';
import 'package:rpl_notepad_fe/core/widgets/mobile_header.dart';
import 'package:rpl_notepad_fe/core/widgets/toast_notification.dart';

class ClassDiscussionPage extends StatefulWidget {
  final int classId;
  final String className;

  const ClassDiscussionPage({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<ClassDiscussionPage> createState() => _ClassDiscussionPageState();
}

class _ClassDiscussionPageState extends State<ClassDiscussionPage> {
  final TextEditingController _issueController = TextEditingController();
  @override
  void didUpdateWidget(ClassDiscussionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.classId != oldWidget.classId) {
      final viewModel = Provider.of<ClassDiscussionViewModel>(
        context,
        listen: false,
      );
      viewModel.setClassId(widget.classId);
      viewModel.fetchIssues();
    }
  }

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  void _toggleAddForm() {
    final viewModel = Provider.of<ClassDiscussionViewModel>(
      context,
      listen: false,
    );
    viewModel.toggleAddForm();
    if (!viewModel.showAddForm) {
      _issueController.clear();
    }
  }

  Future<void> _handlePostIssue() async {
    if (_issueController.text.trim().isEmpty) return;

    try {
      final viewModel = Provider.of<ClassDiscussionViewModel>(
        context,
        listen: false,
      );
      final success = await viewModel.createIssue(
        widget.classId,
        _issueController.text.trim(),
      );

      if (success && mounted) {
        showAppToast(
          context,
          message: 'Diskusi berhasil dibuat',
          type: AppToastType.success,
          duration: const Duration(seconds: 2),
        );
        _issueController.clear();
      }
    } catch (e) {
      if (mounted) {
        showAppToast(
          context,
          message:
              'Gagal membuat diskusi${e.toString().isNotEmpty ? ': ${e.toString()}' : ''}',
          type: AppToastType.error,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;

    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = ClassDiscussionViewModel();
        viewModel.setClassId(widget.classId);
        if (viewModel.issues.isEmpty) {
          viewModel.fetchIssues();
        }
        return viewModel;
      },
      child: Scaffold(
        drawer: !isWeb
            ? MenuDrawer(currentPage: 'diskusi', onPageChanged: (page) {})
            : null,
        body: Consumer<ClassDiscussionViewModel>(
          builder: (context, viewModel, child) {
            if (isWeb) {
              return Stack(
                children: [
                  GradientBackground(
                    child: SafeArea(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Sidebar
                          MenuDrawer(
                            currentPage: 'diskusi',
                            onPageChanged: (page) {},
                          ),
                          const SizedBox(width: 20),

                          // Main content
                          Expanded(
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                // Header Card
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: CustomCard(
                                    color: Colors.white,
                                    width: double.infinity,
                                    height: 100,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: CustomSearchBar(
                                            hintText: 'Cari diskusi...',
                                            onChanged: (query) {
                                              final viewModel =
                                                  Provider.of<
                                                    ClassDiscussionViewModel
                                                  >(context, listen: false);
                                              viewModel.searchIssues(query);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Consumer<LoginViewModel>(
                                          builder: (context, loginVM, _) {
                                            return UserProfile(
                                              name:
                                                  AuthService
                                                          .userName
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? AuthService.userName!
                                                  : 'User',
                                              email:
                                                  AuthService
                                                          .userEmail
                                                          ?.isNotEmpty ==
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

                                // Fixed Title
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                      const SizedBox(width: 16),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(
                                                '/note/${Uri.encodeComponent(widget.className)}',
                                                arguments: widget.classId,
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF256533,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              minimumSize: const Size(0, 40),
                                            ),
                                            child: const Text(
                                              'Catatan',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            onPressed: _toggleAddForm,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              minimumSize: const Size(0, 40),
                                            ),
                                            icon: Icon(
                                              viewModel.showAddForm
                                                  ? Icons.close
                                                  : Icons.add,
                                              size: 20,
                                            ),
                                            label: Text(
                                              viewModel.showAddForm
                                                  ? 'Batal'
                                                  : 'Tambah',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Fixed Input Form
                                if (viewModel.showAddForm)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: DiscussionInputForm(
                                      controller: _issueController,
                                      onPostPressed: _handlePostIssue,
                                      onCancelPressed: _toggleAddForm,
                                      isVisible: viewModel.showAddForm,
                                      maxLines: 6,
                                      minHeight: 180,
                                    ),
                                  ),

                                // Content Area
                                Expanded(
                                  child: ListView(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16.0),
                                        width: double.infinity,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            const SizedBox(height: 0),

                                            // Issues
                                            if (viewModel.issues.isEmpty &&
                                                !viewModel.showAddForm)
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  top: 32.0,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Tidak ada diskusi',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            else
                                              ...viewModel.issues
                                                  .map(
                                                    (issue) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 16.0,
                                                          ),
                                                      child: SizedBox(
                                                        width: double.infinity,
                                                        child: ClassMessageCard(
                                                          key: ValueKey(
                                                            issue.id,
                                                          ),
                                                          issue: issue,
                                                          replyCount: viewModel
                                                              .getReplyCount(
                                                                issue.id,
                                                              ),
                                                          onTap: () {
                                                            _showMessageDetail(
                                                              context,
                                                              issue.userName,
                                                              issue.content,
                                                              issue.id,
                                                              false,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (viewModel.isLoading) const LoadingOverlay(),
                ],
              );
            }

            // Mobile
            return Stack(
              children: [
                GradientBackground(
                  child: SafeArea(
                    child: viewModel.errorMessage != null
                        ? Center(child: Text(viewModel.errorMessage!))
                        : _buildContent(viewModel),
                  ),
                ),
                if (viewModel.isLoading) const LoadingOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(ClassDiscussionViewModel viewModel) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: Column(
            children: [
              // Header row
              MobileHeader(
                hintText: 'Cari diskusi...',
                onChanged: (query) {
                  viewModel.searchIssues(query);
                },
              ),
              const SizedBox(height: 16),
              // Second row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Class name
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
                  const SizedBox(width: 16),
                  // Catatan and Tambah buttons
                  Row(
                    children: [
                      // Catatan button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            '/note/${Uri.encodeComponent(widget.className)}',
                            arguments: widget.classId,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF256533),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text(
                          'Catatan',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tambah button
                      ElevatedButton.icon(
                        onPressed: _toggleAddForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          minimumSize: const Size(0, 36),
                        ),
                        icon: Icon(
                          viewModel.showAddForm ? Icons.close : Icons.add,
                          size: 16,
                        ),
                        label: Text(
                          viewModel.showAddForm ? 'Batal' : 'Tambah',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Add form
              DiscussionInputForm(
                controller: _issueController,
                onPostPressed: _handlePostIssue,
                onCancelPressed: _toggleAddForm,
                isVisible: viewModel.showAddForm,
              ),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
            child: Column(
              children: [
                if (viewModel.issues.isEmpty && !viewModel.showAddForm)
                  const Padding(
                    padding: EdgeInsets.only(top: 32.0),
                    child: Center(
                      child: Text(
                        'Tidak ada diskusi',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                // Issues list
                if (viewModel.issues.isNotEmpty)
                  ...viewModel.issues
                      .map(
                        (issue) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ClassMessageCard(
                            key: ValueKey(issue.id),
                            issue: issue,
                            replyCount: viewModel.getReplyCount(issue.id),
                            onTap: () {
                              _showMessageDetail(
                                context,
                                issue.userName,
                                issue.content,
                                issue.id,
                                false,
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showMessageDetail(
    BuildContext context,
    String name,
    String message,
    int issueId,
    bool isOnline,
  ) async {
    final viewModel = Provider.of<ClassDiscussionViewModel>(
      context,
      listen: false,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(
          issueId: issueId,
          className: widget.className,
          message: message,
          userName: name,
          isOnline: isOnline,
        ),
      ),
    );

    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      viewModel.fetchIssues();
    }
  }
}
