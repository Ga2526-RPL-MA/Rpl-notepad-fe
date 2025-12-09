import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_modal.dart';
import 'package:rpl_notepad_fe/core/widgets/toast_notification.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/viewmodel/class_detail_view_model.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/user_dto.dart';

class DropdownAddUser extends StatefulWidget {
  final ValueChanged<UserDto?> onChanged;
  final String className;

  const DropdownAddUser({
    super.key, 
    required this.onChanged,
    required this.className,
  });

  static const primaryColor = Color(0xFF43B75D);
  static const borderColor = Color(0xFF256533);

  @override
  State<DropdownAddUser> createState() => _DropdownAddUserState();
}

class _DropdownAddUserState extends State<DropdownAddUser> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassDetailViewModel>().fetchUsers();
    });
  }

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    final parentContext = context;
    final viewModel = context.read<ClassDetailViewModel>();
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => ChangeNotifierProvider.value(
        value: viewModel,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeDropdown,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),
            // Dropdown list
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 5.0),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: Container(
                  width: size.width,
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Consumer<ClassDetailViewModel>(
                    builder: (context, viewModel, child) {
                    if (viewModel.isLoading && viewModel.users.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (viewModel.users.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Tidak ada mahasiswa'),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: viewModel.users.length,
                      itemBuilder: (context, index) {
                        final user = viewModel.users[index];
                        final isSelected = viewModel.classStudents.any((s) {
                          if (s.id == user.id) return true;
                          if (s.id == 0 && s.nrp == user.nrp) return true;
                          return false;
                        });
                        
                        if (index == 0) {
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Star Icon
                              Image.asset(
                                'assets/icon/star_icon.png',
                                width: 20,
                                height: 20,
                                color: const Color(0xFF9EA2AE),
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.person,
                                  color: Color(0xFF9EA2AE),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Name
                              Expanded(
                                child: Text(
                                  '${user.nrp} ${user.name}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              // Checkbox 
                              InkWell(
                                onTap: () {
                                  if (isSelected) {
                                    // Show confirmation before removing
                                    _closeDropdown();
                                      CustomModal.show(
                                        parentContext,
                                        title: 'Konfirmasi Hapus',
                                        message: 'Apakah Anda yakin ingin menghapus ${user.name} dari kelas ini?',
                                        primaryButtonText: 'Hapus',
                                        secondaryButtonText: 'Batal',
                                        onPrimaryPressed: () {
                                          Navigator.pop(parentContext);
                                          viewModel.removeUserFromClass(user.id).then((_) {
                                            if (viewModel.error == null) {
                                              showAppToast(
                                                parentContext,
                                                title: 'Berhasil',
                                                message: 'Berhasil menghapus mahasiswa ${user.name} dari kelas ${widget.className}',
                                                type: AppToastType.success,
                                              );
                                            } else {
                                              showAppToast(
                                                parentContext,
                                                title: 'Gagal',
                                                message: 'Gagal menghapus mahasiswa: ${viewModel.error}',
                                                type: AppToastType.error,
                                              );
                                            }
                                          });
                                        },
                                        onSecondaryPressed: () {
                                          Navigator.pop(parentContext);
                                        },
                                      );
                                  } else {
                                      viewModel.addUserToClass(user.id).then((_) {
                                        if (viewModel.error == null) {
                                          showAppToast(
                                            parentContext,
                                            title: 'Berhasil',
                                            message: 'Berhasil menambahkan mahasiswa ${user.name} ke kelas ${widget.className}',
                                            type: AppToastType.success,
                                          );
                                        } else {
                                          showAppToast(
                                            parentContext,
                                            title: 'Gagal',
                                            message: 'Gagal menambahkan mahasiswa: ${viewModel.error}',
                                            type: AppToastType.error,
                                          );
                                        }
                                      });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: DropdownAddUser.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isOpen = false;
    });
  }

  double _calculateDropdownWidth(List<UserDto> users) {
    double maxWidth = 200.0; // Minimum width
    const textStyle = TextStyle(fontSize: 14);

    for (final user in users) {
      final text = '${user.nrp} ${user.name}';
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      );
      textPainter.layout();
      if (textPainter.width > maxWidth) {
        maxWidth = textPainter.width;
      }
    }
    return maxWidth + 100.0; 
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClassDetailViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.error != null) {
          return Text('Error: ${viewModel.error}',
              style: const TextStyle(color: Colors.red));
        }

        if (viewModel.isLoading && _isOpen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _isOpen) {
              _closeDropdown();
            }
          });
        }

        final dropdownWidth = _calculateDropdownWidth(viewModel.users);
        
        return CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              width: dropdownWidth,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: DropdownAddUser.borderColor, width: 1),
                color: Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  Image.asset(
                    'assets/icon/star_icon.png',
                    width: 20,
                    height: 20,
                    color: DropdownAddUser.primaryColor,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person_add,
                      color: DropdownAddUser.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      viewModel.isLoading && viewModel.users.isEmpty ? 'Memuat...' : 'Pilih Mahasiswa',
                      style: const TextStyle(
                        color: DropdownAddUser.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: DropdownAddUser.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
