import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/core/widgets/menu_drawer.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/widgets/discussion_input_form.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/view/chat_detail_page.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/widgets/class_message_card.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/viewmodel/class_discussion_viewmodel.dart';

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
  final ClassDiscussionViewModel _viewModel = ClassDiscussionViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.setClassId(widget.classId);
    if (_viewModel.issues.isEmpty) {
      _viewModel.fetchIssues();
    }
  }

  @override
  void didUpdateWidget(ClassDiscussionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.classId != oldWidget.classId) {
      _viewModel.setClassId(widget.classId);
      _viewModel.fetchIssues();
    }
  }

  @override
  void dispose() {
    _issueController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _toggleAddForm() {
    _viewModel.toggleAddForm();
    if (!_viewModel.showAddForm) {
      _issueController.clear();
    }
  }

  Future<void> _handlePostIssue() async {
    if (_issueController.text.trim().isEmpty) return;

    try {
      final success = await _viewModel.createIssue(
        widget.classId,
        _issueController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Diskusi berhasil dibuat'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
        _issueController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat diskusi: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        drawer: MenuDrawer(currentPage: 'diskusi', onPageChanged: (page) {}),
        body: Consumer<ClassDiscussionViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                GradientBackground(
                  child: SafeArea(
                    child: viewModel.errorMessage != null
                        ? Center(child: Text(viewModel.errorMessage!))
                        : _buildContent(viewModel),
                  ),
                ),
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
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
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    // Search bar
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: CustomSearchBar(hintText: 'Cari diskusi...'),
                      ),
                    ),
                    // Menu button
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.black),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
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
                  // Tambah button
                  ElevatedButton.icon(
                    onPressed: _toggleAddForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    icon: Icon(
                      viewModel.showAddForm ? Icons.close : Icons.add,
                      size: 20,
                    ),
                    label: Text(viewModel.showAddForm ? 'Batal' : 'Tambah'),
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
      _viewModel.fetchIssues();
    }
  }
}
