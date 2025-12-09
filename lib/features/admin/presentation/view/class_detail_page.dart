import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_card.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_modal.dart';
import 'package:rpl_notepad_fe/core/widgets/loading_overlay.dart';
import 'package:rpl_notepad_fe/core/widgets/menu_drawer.dart';
import 'package:rpl_notepad_fe/core/widgets/toast_notification.dart';
import 'package:rpl_notepad_fe/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/get_all_users_usecase.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/viewmodel/class_detail_view_model.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/widgets/dropdown_add_user.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/widgets/student_list_table.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/viewmodel/login_view_model.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/user_profile.dart';

import 'package:rpl_notepad_fe/features/admin/domain/usecases/add_user_to_class_usecase.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/delete_user_from_class_usecase.dart';
import 'package:rpl_notepad_fe/features/admin/domain/usecases/get_users_by_class_usecase.dart';

class ClassDetailPage extends StatefulWidget {
  final int classId;
  final String className;
  final String classTime;
  final String classRoom;

  const ClassDetailPage({
    super.key,
    required this.classId,
    required this.className,
    required this.classTime,
    required this.classRoom,
  });

  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClassDetailViewModel(
        getAllUsersUseCase: GetAllUsersUseCase(AdminRepositoryImpl()),
        getUsersByClassUseCase: GetUsersByClassUseCase(AdminRepositoryImpl()),
        addUserToClassUseCase: AddUserToClassUseCase(AdminRepositoryImpl()),
        deleteUserFromClassUseCase: DeleteUserFromClassUseCase(
          AdminRepositoryImpl(),
        ),
      ),
      child: _ClassDetailPageContent(
        classId: widget.classId,
        className: widget.className,
        classTime: widget.classTime,
        classRoom: widget.classRoom,
      ),
    );
  }
}

class _ClassDetailPageContent extends StatefulWidget {
  final int classId;
  final String className;
  final String classTime;
  final String classRoom;

  const _ClassDetailPageContent({
    required this.classId,
    required this.className,
    required this.classTime,
    required this.classRoom,
  });

  @override
  State<_ClassDetailPageContent> createState() =>
      _ClassDetailPageContentState();
}

class _ClassDetailPageContentState extends State<_ClassDetailPageContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassDetailViewModel>().fetchClassStudents(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          GradientBackground(
            child: isWeb
                ? _buildWebLayout(context, screenHeight)
                : _buildMobileLayout(context, screenHeight),
          ),
          Consumer<ClassDetailViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isProcessing ||
                  (viewModel.isLoading && viewModel.classStudents.isEmpty)) {
                return const LoadingOverlay();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, double screenHeight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MenuDrawer(
          mode: 'admin',
          currentPage: 'detail_kelas',
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
                  child: _buildClassDetails(context),
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
            'Detail Kelas',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _buildClassDetails(context),
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
            child: Row(
              children: [
                Expanded(
                  child: Consumer<ClassDetailViewModel>(
                    builder: (context, viewModel, _) {
                      return CustomSearchBar(
                        onChanged: (value) {
                          viewModel.updateSearchQuery(value);
                        },
                        hintText: 'Cari Mahasiswa',
                      );
                    },
                  ),
                ),
              ],
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

  Widget _buildClassDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: CustomCard(
          color: Colors.white,
          width: double.infinity,
          height: 700,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.className,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownAddUser(
                  className: widget.className,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 24),
                Consumer<ClassDetailViewModel>(
                  builder: (context, viewModel, _) {
                    return StudentListTable(
                      students: viewModel.filteredStudents,
                      isSearching: viewModel.isSearching,
                      onDelete: (student) {
                        int actualUserId = student.id;
                        if (student.id == 0 && student.nrp.isNotEmpty) {
                          final masterUser = viewModel.users.firstWhere(
                            (u) => u.nrp == student.nrp,
                            orElse: () => student,
                          );
                          actualUserId = masterUser.id;
                        }

                        CustomModal.show(
                          context,
                          title: 'Konfirmasi Hapus',
                          message:
                              'Apakah Anda yakin ingin menghapus ${student.name} dari kelas ini?',
                          primaryButtonText: 'Hapus',
                          secondaryButtonText: 'Batal',
                          onPrimaryPressed: () {
                            Navigator.pop(context);
                            viewModel.removeUserFromClass(actualUserId).then((
                              _,
                            ) {
                              if (viewModel.error == null) {
                                showAppToast(
                                  context,
                                  title: 'Berhasil',
                                  message:
                                      'Berhasil menghapus mahasiswa ${student.name} dari kelas ${widget.className}',
                                  type: AppToastType.success,
                                );
                              } else {
                                showAppToast(
                                  context,
                                  title: 'Gagal',
                                  message:
                                      'Gagal menghapus mahasiswa: ${viewModel.error}',
                                  type: AppToastType.error,
                                );
                              }
                            });
                          },
                          onSecondaryPressed: () {
                            Navigator.pop(context);
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
      ),
    );
  }
}
