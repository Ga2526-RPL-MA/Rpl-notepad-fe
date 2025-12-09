import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/issue.dart';

class DiscussionListTable extends StatelessWidget {
  final List<Issue> issues;
  final Function(Issue) onDetail;

  const DiscussionListTable({
    super.key,
    required this.issues,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Belum ada diskusi',
            style: TextStyle(
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
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(60), // No
          1: FlexColumnWidth(2), // Nama
          2: FlexColumnWidth(1.5), // NRP
          3: FlexColumnWidth(3), // Pertanyaan
          4: FixedColumnWidth(100), // Aksi
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
              _buildHeaderCell('Pertanyaan'),
              _buildHeaderCell('Aksi'),
            ],
          ),
          // Data Rows
          ...issues.asMap().entries.map((entry) {
            final index = entry.key;
            final issue = entry.value;
            return _buildDataRow(index + 1, issue);
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Text(
        text,
        textAlign: text == 'No' || text == 'Aksi' ? TextAlign.center : TextAlign.left,
        style: const TextStyle(
          color: Color(0XFF5A607F),
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TableRow _buildDataRow(int no, Issue issue) {
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Text(
            no.toString(),
            textAlign: TextAlign.center,
            style: baseStyle.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            issue.userName,
            style: baseStyle.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            issue.nrp,
            style: baseStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            issue.content,
            style: baseStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF131927),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => onDetail(issue),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Detail', style: TextStyle(fontSize: 12)),
            ),
          ),
        ),
      ],
    );
  }
}
