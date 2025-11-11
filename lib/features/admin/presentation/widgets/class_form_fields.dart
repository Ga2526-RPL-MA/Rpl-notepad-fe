import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/features/admin/presentation/viewmodel/add_class_view_model.dart';

class ClassFormFields extends StatelessWidget {
  final TextStyle errorStyle;
  const ClassFormFields({required this.errorStyle});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddClassViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            fillColor: const Color(0xFFD9D9D9).withOpacity(0.23),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
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
            fillColor: const Color(0xFFD9D9D9).withOpacity(0.23),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
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
            fillColor: const Color(0xFFD9D9D9).withOpacity(0.23),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
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
            fillColor: const Color(0xFFD9D9D9).withOpacity(0.23),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
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
      ],
    );
  }
}