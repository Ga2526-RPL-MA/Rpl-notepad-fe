import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_card.dart';
import 'package:rpl_notepad_fe/core/widgets/menu_drawer.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/user_profile.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/login_view_model.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/viewmodel/discussion_viewmodel.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/widgets/class_card.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/view/add_class_page.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/viewmodel/admin_dashboard_view_model.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late final AdminDashboardViewModel _avm;
  @override
  void initState() {
    super.initState();
    _avm = AdminDashboardViewModel(
      discussionVM: context.read<DiscussionViewModel>(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _avm.init();
    });
  }

  @override
  void dispose() {
    _avm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;
    final screenHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider<AdminDashboardViewModel>.value(
      value: _avm,
      child: Builder(
        builder: (context) {
          final avm = context.watch<AdminDashboardViewModel>();
          if (avm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (avm.error != null) {
            return Scaffold(
              body: Center(
                child: Text(
                  avm.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          return Scaffold(
            body: GradientBackground(
              child: isWeb
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MenuDrawer(
                          mode: 'admin',
                          currentPage: 'beranda',
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
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
                                            onChanged: avm.setSearch,
                                            hintText: 'Cari kelas...'
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
                                                  : 'Admin',
                                              email:
                                                  AuthService
                                                          .userEmail
                                                          ?.isNotEmpty ==
                                                      true
                                                  ? AuthService.userEmail!
                                                  : 'admin@example.com',
                                              avatarSize: 40,
                                              avatarColor: const Color(
                                                0xFFD4C5F9,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  children: [
                                    CustomCard(
                                      color: Colors.white,
                                      width: double.infinity,
                                      flexible: true,
                                      minHeight: screenHeight * 0.81,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Daftar Kelas',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            LayoutBuilder(
                                              builder: (context, constraints) {
                                                return GridView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  padding: const EdgeInsets.all(
                                                    16.0,
                                                  ),
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 2,
                                                        crossAxisSpacing: 16.0,
                                                        mainAxisSpacing: 16.0,
                                                        childAspectRatio: 3.0,
                                                      ),
                                                  itemCount: avm.classes.length,
                                                  itemBuilder: (context, index) {
                                                    final classDto =
                                                        avm.classes[index];
                                                    final item = avm
                                                        .getClassData(
                                                          classDto,
                                                          index,
                                                        );
                                                    return ClassCard(
                                                      iconPath:
                                                          item['iconPath'],
                                                      className:
                                                          item['className'],
                                                      classTime:
                                                          item['classTime'],
                                                      classRoom:
                                                          item['classRoom'],
                                                      cardBackgroundColor:
                                                          item['cardBackgroundColor'],
                                                      cardOutlineColor:
                                                          item['cardOutlineColor'],
                                                      onTap: () async {
                                                        final result =
                                                            await Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    AddClassPage(
                                                                      initialClass:
                                                                          classDto,
                                                                      showDelete:
                                                                          true,
                                                                    ),
                                                              ),
                                                            );
                                                        if (result == true) {
                                                          await avm.refresh();
                                                        }
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
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
                    )
                  : SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
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
                                              child: MenuDrawer(
                                                mode: 'admin',
                                                currentPage: 'beranda',
                                                onPageChanged: (_) {},
                                              ),
                                            );
                                          },
                                          transitionBuilder:
                                              (_, anim, __, child) {
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
                                    Consumer<LoginViewModel>(
                                      builder: (context, loginVM, _) {
                                        return UserProfile(
                                          name:
                                              AuthService
                                                      .userName
                                                      ?.isNotEmpty ==
                                                  true
                                              ? AuthService.userName!
                                              : 'Admin',
                                          email:
                                              AuthService
                                                      .userEmail
                                                      ?.isNotEmpty ==
                                                  true
                                              ? AuthService.userEmail!
                                              : 'admin@example.com',
                                          avatarColor: Color(0xFFD4C5F9),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomSearchBar(
                                        hintText: 'Cari kelas...',
                                        onChanged: avm.setSearch,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Daftar Kelas',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: avm.classes.length,
                                          itemBuilder: (context, index) {
                                            final classDto = avm.classes[index];
                                            final item = avm.getClassData(
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
                                                onTap: () async {
                                                  final result =
                                                      await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              AddClassPage(
                                                                initialClass:
                                                                    classDto,
                                                                showDelete:
                                                                    true,
                                                              ),
                                                        ),
                                                      );
                                                  if (result == true) {
                                                    await avm.refresh();
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
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
