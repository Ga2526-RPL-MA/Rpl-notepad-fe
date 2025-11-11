import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_modal.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/viewmodel/add_class_view_model.dart';
import 'package:rpl_notepad_fe/features/discussion/presentation/viewmodel/discussion_viewmodel.dart';

class ClassActions extends StatelessWidget {
  final bool isEditing;
  final bool showDelete;
  final int? classId;
  final VoidCallback onSubmit;

  const ClassActions({
    required this.isEditing,
    required this.showDelete,
    required this.classId,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddClassViewModel>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 146,
          height: 48,
          child: ElevatedButton(
            onPressed: vm.isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF212936),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: vm.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        if (showDelete && isEditing && classId != null) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 146,
            height: 48,
            child: ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      final confirm = await CustomModal.show<bool>(
                        context,
                        title: 'Apakah anda yakin?',
                        message: 'Pastikan lagi kembali sebelum dihapus',
                        primaryButtonText: 'Hapus',
                        secondaryButtonText: 'Batal',
                        onPrimaryPressed: () => Navigator.pop(context, true),
                        onSecondaryPressed: () => Navigator.pop(context, false),
                        barrierDismissible: false,
                      );
                      if (confirm == true) {
                        final ok = await vm.delete(classId!);
                        if (!context.mounted) return;
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kelas berhasil dihapus'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          try {
                            final dvm = context.read<DiscussionViewModel>();
                            await dvm.loadClasses();
                          } catch (_) {}
                          final popped = await Navigator.maybePop(context, true);
                          if (!popped && context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/admin',
                              (route) => false,
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal menghapus kelas: ${vm.error ?? ''}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEE443F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
