import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_card.dart';
import 'package:rpl_notepad_fe/core/widgets/menu_drawer.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_modal.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/login_view_model.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/user_profile.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_class_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/viewmodel/discussion_viewmodel.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/viewmodel/add_class_view_model.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/widgets/class_form_fields.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/widgets/class_actions.dart';
import 'package:rpl_notepad_fe/core/widgets/toast_notification.dart';

class AddClassPage extends StatefulWidget {
  final GetClassDto? initialClass;
  final bool showDelete;

  const AddClassPage({super.key, this.initialClass, this.showDelete = false});

  @override
  State<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<AddClassViewModel>();
      if (widget.initialClass == null) {
        vm.reset();
      } else {
        vm.initFrom(widget.initialClass);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final vm = context.read<AddClassViewModel>();
      if (widget.initialClass != null && !vm.hasChanges) {
        if (!mounted) return;
        showAppToast(
          context,
          message: 'Tidak ada perubahan untuk disimpan',
          type: AppToastType.warning,
          duration: const Duration(seconds: 2),
        );
        return;
      }
      final ok = await vm.submit(existingClassId: widget.initialClass?.id);
      if (!mounted) return;
      if (ok) {
        showAppToast(
          context,
          message: widget.initialClass != null
              ? 'Kelas berhasil diperbarui'
              : 'Kelas berhasil ditambahkan',
          type: AppToastType.success,
          duration: const Duration(seconds: 2),
        );
        try {
          final dvm = context.read<DiscussionViewModel>();
          await dvm.loadClasses();
        } catch (_) {}
        if (widget.initialClass != null) {
          final popped = await Navigator.maybePop(context, true);
          if (!popped && mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/admin',
              (route) => false,
            );
          }
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/admin',
            (route) => false,
          );
        }
      } else {
        showAppToast(
          context,
          message: widget.initialClass != null
              ? 'Gagal memperbarui kelas${vm.error != null && vm.error!.isNotEmpty ? ': ${vm.error}' : ''}'
              : 'Gagal menambahkan kelas${vm.error != null && vm.error!.isNotEmpty ? ': ${vm.error}' : ''}',
          type: AppToastType.error,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorStyle = TextStyle(color: const Color(0xFFEE443F), fontSize: 12);
    final isWeb = MediaQuery.of(context).size.width > 800;
    final screenHeight = MediaQuery.of(context).size.height;
    final isEditing = widget.initialClass != null;
    final vm = context.watch<AddClassViewModel>();

    return Scaffold(
      body: GradientBackground(
        child: isWeb
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MenuDrawer(
                    mode: 'admin',
                    currentPage: 'tambah_kelas',
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
                          child: SizedBox(
                            width: double.infinity,
                            child: CustomCard(
                              color: Colors.white,
                              width: double.infinity,
                              height: 100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Expanded(child: CustomSearchBar()),
                                  const SizedBox(width: 20),
                                  Consumer<LoginViewModel>(
                                    builder: (context, loginVM, _) {
                                      return UserProfile(
                                        name:
                                            AuthService.userName?.isNotEmpty ==
                                                true
                                            ? AuthService.userName!
                                            : 'Admin',
                                        email:
                                            AuthService.userEmail?.isNotEmpty ==
                                                true
                                            ? AuthService.userEmail!
                                            : 'admin@example.com',
                                        avatarSize: 40,
                                        avatarColor: const Color(0xFFD4C5F9),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              CustomCard(
                                color: Colors.white,
                                width: double.infinity,
                                flexible: true,
                                minHeight: screenHeight * 0.81,
                                child: Form(
                                  key: _formKey,
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isEditing
                                              ? 'Edit Kelas'
                                              : 'Tambah Kelas',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        ClassFormFields(errorStyle: errorStyle),
                                        const SizedBox(height: 32),
                                        ClassActions(
                                          isEditing: isEditing,
                                          showDelete: widget.showDelete,
                                          classId: widget.initialClass?.id,
                                          onSubmit: _submitForm,
                                        ),
                                      ],
                                    ),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          currentPage: 'tambah_kelas',
                                          onPageChanged: (page) {
                                            if (page == 'beranda') {
                                              Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                '/admin',
                                                (route) => false,
                                              );
                                            } else if (page == 'tambah_kelas') {
                                              Navigator.pushNamed(
                                                context,
                                                '/admin/add-class',
                                              );
                                            }
                                          },
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
                              Consumer<LoginViewModel>(
                                builder: (context, loginVM, _) {
                                  return UserProfile(
                                    name:
                                        AuthService.userName?.isNotEmpty == true
                                        ? AuthService.userName!
                                        : 'Admin',
                                    email:
                                        AuthService.userEmail?.isNotEmpty ==
                                            true
                                        ? AuthService.userEmail!
                                        : 'admin@example.com',
                                    avatarColor: const Color(0xFFD4C5F9),
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
                            child: SingleChildScrollView(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CustomSearchBar(
                                      hintText: 'Cari kelas...',
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      isEditing ? 'Edit Kelas' : 'Tambah Kelas',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    const Text(
                                      'Nama Kelas',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF4D5461),
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: vm.nameController,
                                      style: const TextStyle(
                                        fontFamily: 'Arial',
                                        color: Colors.black,
                                      ),
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(
                                          0xFFD9D9D9,
                                        ).withOpacity(0.23),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                        errorStyle: errorStyle,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Nama kelas tidak boleh kosong';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),
                                    const Text(
                                      'Nama Pengajar / Dosen',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF4D5461),
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: vm.lecturerController,
                                      style: const TextStyle(
                                        fontFamily: 'Arial',
                                        color: Colors.black,
                                      ),
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(
                                          0xFFD9D9D9,
                                        ).withOpacity(0.23),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                        errorStyle: errorStyle,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Nama pengajar tidak boleh kosong';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),
                                    const Text(
                                      'Ruangan Kelas',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF4D5461),
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: vm.roomController,
                                      style: const TextStyle(
                                        fontFamily: 'Arial',
                                        color: Colors.black,
                                      ),
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(
                                          0xFFD9D9D9,
                                        ).withOpacity(0.23),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                        errorStyle: errorStyle,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ruangan kelas tidak boleh kosong';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),
                                    const Text(
                                      'Jadwal Kelas',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF4D5461),
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: vm.scheduleController,
                                      style: const TextStyle(
                                        fontFamily: 'Arial',
                                        color: Colors.black,
                                      ),
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        hintText: 'Contoh: Senin 08.00 - 10.00',
                                        filled: true,
                                        fillColor: const Color(
                                          0xFFD9D9D9,
                                        ).withOpacity(0.23),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                        errorStyle: errorStyle,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Jadwal kelas tidak boleh kosong';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 24),
                                    Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: SizedBox(
                                              width: 200,
                                              height: 48,
                                              child: ElevatedButton(
                                                onPressed: vm.isLoading
                                                    ? null
                                                    : _submitForm,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFF212936,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                child: vm.isLoading
                                                    ? const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.white),
                                                        ),
                                                      )
                                                    : const Text(
                                                        'Simpan',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                          if (widget.showDelete &&
                                              isEditing) ...[
                                            const SizedBox(height: 12),
                                            Align(
                                              alignment: Alignment.center,
                                              child: SizedBox(
                                                width: 200,
                                                height: 48,
                                                child: ElevatedButton(
                                                  onPressed: vm.isLoading
                                                      ? null
                                                      : () async {
                                                          final confirm = await CustomModal.show<bool>(
                                                            context,
                                                            title:
                                                                'Apakah anda yakin?',
                                                            message:
                                                                'Pastikan lagi kembali sebelum dihapus',
                                                            primaryButtonText:
                                                                'Hapus',
                                                            secondaryButtonText:
                                                                'Batal',
                                                            onPrimaryPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                      true,
                                                                    ),
                                                            onSecondaryPressed:
                                                                () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                      false,
                                                                    ),
                                                            barrierDismissible:
                                                                false,
                                                          );
                                                          if (confirm == true) {
                                                            final ok = await vm
                                                                .delete(
                                                                  widget
                                                                      .initialClass!
                                                                      .id,
                                                                );
                                                            if (!mounted)
                                                              return;
                                                            if (ok) {
                                                              showAppToast(
                                                                context,
                                                                message:
                                                                    'Kelas berhasil dihapus',
                                                                type:
                                                                    AppToastType
                                                                        .success,
                                                                duration:
                                                                    const Duration(
                                                                      seconds:
                                                                          2,
                                                                    ),
                                                              );
                                                              try {
                                                                final dvm = context
                                                                    .read<
                                                                      DiscussionViewModel
                                                                    >();
                                                                await dvm
                                                                    .loadClasses();
                                                              } catch (_) {}
                                                              final popped =
                                                                  await Navigator.maybePop(
                                                                    context,
                                                                    true,
                                                                  );
                                                              if (!popped &&
                                                                  mounted) {
                                                                Navigator.pushNamedAndRemoveUntil(
                                                                  context,
                                                                  '/admin',
                                                                  (route) =>
                                                                      false,
                                                                );
                                                              }
                                                            } else {
                                                              showAppToast(
                                                                context,
                                                                message:
                                                                    'Gagal menghapus kelas${vm.error != null && vm.error!.isNotEmpty ? ': ${vm.error}' : ''}',
                                                                type:
                                                                    AppToastType
                                                                        .error,
                                                                duration:
                                                                    const Duration(
                                                                      seconds:
                                                                          3,
                                                                    ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFEE443F),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Image.asset(
                                                        'assets/icon/trash-icon.png',
                                                        width: 18,
                                                        height: 18,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      const Text(
                                                        'Hapus',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
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
  }
}
