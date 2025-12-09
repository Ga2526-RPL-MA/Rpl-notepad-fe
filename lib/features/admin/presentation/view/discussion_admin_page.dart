import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/di/injection.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_card.dart';
import 'package:rpl_notepad_fe/core/widgets/loading_overlay.dart';
import 'package:rpl_notepad_fe/core/widgets/menu_drawer.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/get_all_users_usecase.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/get_issues_usecase.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/viewmodel/discussion_admin_view_model.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/widgets/discussion_list_table.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/view/chat_detail_page.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/user_profile.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/viewmodel/login_view_model.dart';

class DiscussionAdminPage extends StatefulWidget {
  const DiscussionAdminPage({super.key});

  @override
  State<DiscussionAdminPage> createState() => _DiscussionAdminPageState();
}

class _DiscussionAdminPageState extends State<DiscussionAdminPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DiscussionAdminViewModel(
        getIssuesUseCase: getIt<GetIssuesUseCase>(),
        getAllUsersUseCase: getIt<GetAllUsersUseCase>(),
      )..fetchIssues(),
      child: Consumer<DiscussionAdminViewModel>(
        builder: (context, viewModel, _) {
          return Stack(
            children: [
              const _DiscussionAdminPageContent(),
              if (viewModel.isLoading) const LoadingOverlay(),
            ],
          );
        },
      ),
    );
  }
}

class _DiscussionAdminPageContent extends StatelessWidget {
  const _DiscussionAdminPageContent();

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GradientBackground(
        child: isWeb
            ? _buildWebLayout(context, screenHeight)
            : _buildMobileLayout(context, screenHeight),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, double screenHeight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MenuDrawer(
          mode: 'admin',
          currentPage: 'diskusi',
          onPageChanged: (page) {
            if (page == 'beranda') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/admin',
                (route) => false,
              );
            } else if (page == 'tambah_kelas') {
              Navigator.pushNamed(context, '/admin/add-class');
            }
          },
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildHeader(context),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: _buildDiscussionContent(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, double screenHeight) {
    return Column(
      children: [
        AppBar(
          title: const Text(
            'Diskusi Kembali ke Dashboard Admin',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _buildDiscussionContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return CustomCard(
      color: Colors.white,
      width: double.infinity,
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CustomSearchBar(
              onChanged: (value) {},
              hintText: 'Cari diskusi...',
            ),
          ),
          const SizedBox(width: 20),
          Consumer<LoginViewModel>(
            builder: (context, loginVM, _) {
              return UserProfile(
                name: AuthService.userName?.isNotEmpty == true
                    ? AuthService.userName!
                    : 'Admin',
                email: AuthService.userEmail?.isNotEmpty == true
                    ? AuthService.userEmail!
                    : 'admin@example.com',
                avatarSize: 40,
                avatarColor: const Color(0xFFD4C5F9),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: CustomCard(
        color: Colors.white,
        width: double.infinity,
        height: 620,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Diskusi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<DiscussionAdminViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.error != null) {
                      return Center(
                        child: Text(
                          'Error: ${viewModel.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      child: DiscussionListTable(
                        issues: viewModel.issues,
                        onDetail: (issue) async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailPage(
                                issueId: issue.id,
                                className: 'Kembali ke Dashboard Admin',
                                message: issue.content,
                                userName: issue.userName,
                              ),
                            ),
                          );
                          
                          // Refresh data if issue was deleted
                          if (result == true) {
                            viewModel.fetchIssues();
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
