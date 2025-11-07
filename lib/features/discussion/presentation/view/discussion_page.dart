import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/viewmodel/discussion_view_model.dart';
import '../../../../core/widgets/custom_background.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/menu_drawer.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../features/auth/presentation/view_models/login_view_model.dart';
import '../../../../features/home/presentation/widgets/custom_search_bar.dart';
import '../../../../features/home/presentation/widgets/user_profile.dart';
import '../widgets/class_card.dart';
import '../widgets/web/discussion_web_layout.dart';

class DiscussionPage extends StatelessWidget {
  const DiscussionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isWeb) {
      return Scaffold(
        body: GradientBackground(
          child: DiscussionWebLayout(
            screenHeight: screenHeight,
            currentPage: 'diskusi',
            onPageChanged: (page) {
              if (page == 'beranda' || page == 'tugas_selesai') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                  arguments: page == 'tugas_selesai' ? {'tab': 'completed'} : null,
                );
              }
            },
            child: _DiscussionView(key: const ValueKey('discussion-view')),
          ),
        ),
      );
    } else {
      return _DiscussionView(key: const ValueKey('discussion-view'));
    }
  }
}

class _DiscussionView extends StatefulWidget {
  const _DiscussionView({super.key});

  @override
  State<_DiscussionView> createState() => _DiscussionViewState();
}

class _DiscussionViewState extends State<_DiscussionView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<DiscussionViewModel>();

      if (viewModel.classes.isEmpty) {
        viewModel.loadClasses();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DiscussionViewModel>();

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Text(
          viewModel.error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header 
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Menu Button Mobile
                      if (MediaQuery.of(context).size.width <= 800)
                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            size: 24,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: '',
                              barrierColor: Colors.black26,
                              transitionDuration: const Duration(
                                milliseconds: 250,
                              ),
                              pageBuilder: (_, __, ___) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.75,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(4, 0),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                      child: MenuDrawer(
                                        currentPage: 'diskusi',
                                        onPageChanged: (page) async {
                                          Navigator.pop(context);
                                          await Future.delayed(
                                            const Duration(milliseconds: 200),
                                          );

                                          if (page == 'beranda' ||
                                              page == 'tugas_selesai') {
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              '/home',
                                              (route) => false,
                                              arguments: page == 'tugas_selesai'
                                                  ? {'tab': 'completed'}
                                                  : null,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                              transitionBuilder: (_, anim, __, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(-1, 0),
                                    end: Offset.zero,
                                  ).animate(anim),
                                  child: child,
                                );
                              },
                            );
                          },
                        ),
                      const Spacer(),

                      // User Profile
                      Consumer<LoginViewModel>(
                        builder: (context, loginVM, _) {
                          return UserProfile(
                            name: AuthService.userName?.isNotEmpty == true
                                ? AuthService.userName!
                                : 'User',
                            email: AuthService.userEmail?.isNotEmpty == true
                                ? AuthService.userEmail!
                                : 'user@example.com',
                            avatarColor: Colors.blue,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomSearchBar(
                          hintText: 'Cari kelas...',
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Pilih Kelas Diskusi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isWeb = constraints.maxWidth > 800;

                              if (!isWeb) {
                                return ListView.builder(
                                  itemCount: viewModel.classes.length,
                                  itemBuilder: (context, index) {
                                    final classDto = viewModel.classes[index];
                                    final item = viewModel.getClassData(
                                      classDto,
                                      index,
                                    );
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12.0,
                                      ),
                                      child: ClassCard(
                                        iconPath: item['iconPath'],
                                        className: item['className'],
                                        classTime: item['classTime'],
                                        classRoom: item['classRoom'],
                                        cardBackgroundColor:
                                            item['cardBackgroundColor'],
                                        cardOutlineColor:
                                            item['cardOutlineColor'],
                                      ),
                                    );
                                  },
                                );
                              }

                              //  web view 
                              return GridView.builder(
                                padding: const EdgeInsets.all(16.0),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16.0,
                                      mainAxisSpacing: 16.0,
                                      childAspectRatio: 3.0,
                                    ),
                                itemCount: viewModel.classes.length,
                                itemBuilder: (context, index) {
                                  final classDto = viewModel.classes[index];
                                  final item = viewModel.getClassData(
                                    classDto,
                                    index,
                                  );
                                  return ClassCard(
                                    iconPath: item['iconPath'],
                                    className: item['className'],
                                    classTime: item['classTime'],
                                    classRoom: item['classRoom'],
                                    cardBackgroundColor:
                                        item['cardBackgroundColor'],
                                    cardOutlineColor: item['cardOutlineColor'],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
