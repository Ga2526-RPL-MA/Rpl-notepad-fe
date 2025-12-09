import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/user_dto.dart';

class StudentListTable extends StatelessWidget {
  final List<UserDto> students;
  final void Function(UserDto student)? onDelete;
  final bool isSearching;

  const StudentListTable({
    super.key,
    required this.students,
    this.onDelete,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            isSearching ? 'Tidak ditemukan' : 'Belum ada mahasiswa',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontFamily: 'Inter',
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(80),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(2),
          4: FixedColumnWidth(100),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          // Header
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F6FA),
              border: Border(bottom: BorderSide.none),
            ),
            children: [
              _buildHeaderCell('No'),
              _buildHeaderCell('Nama'),
              _buildHeaderCell('NRP'),
              _buildHeaderCell('Email'),
              _buildHeaderCell('Aksi'),
            ],
          ),
          // Data
          ...students.asMap().entries.map((entry) {
            final index = entry.key;
            final student = entry.value;
            return _buildDataRow(index + 1, student);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0XFF5A607F),
          fontSize: 14,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  TableRow _buildDataRow(int no, UserDto student) {
    const baseStyle = TextStyle(
      color: Color(0xFF131523),
      fontFamily: 'Inter',
      fontSize: 14,
    );

    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            no.toString(),
            style: baseStyle.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            student.name,
            style: baseStyle.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(student.nrp, style: baseStyle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(student.email, style: baseStyle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: () {
              if (onDelete != null) {
                onDelete!(student);
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }
}
