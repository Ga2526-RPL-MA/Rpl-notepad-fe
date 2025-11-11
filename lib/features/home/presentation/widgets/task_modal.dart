import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_modal.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/getclass_dto.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/repositories/class_repository.dart';
import 'package:rpl_notepad_fe/features/discussion/data/repositories/class_repository_impl.dart';
import 'package:rpl_notepad_fe/core/network/api_service.dart';

String formatDateTime(DateTime dateTime) {
  initializeDateFormatting('id_ID', null);
  return DateFormat('EEEE, d MMMM y, HH:mm', 'id_ID').format(dateTime) + ' WIB';
}

class AddTaskModal extends StatefulWidget {
  final BuildContext parentContext;
  final Function(String, String, DateTime, String, String) onSave;
  final VoidCallback? onDelete;
  final Map<String, dynamic>? initialData;

  const AddTaskModal({
    super.key,
    required this.parentContext,
    required this.onSave,
    this.onDelete,
    this.initialData,
  });

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _deadline;
  String? _selectedClassId;
  late final ClassRepository _classRepository;
  static List<GetClassDto> _cachedClasses = [];
  List<GetClassDto> _classes = [];
  bool _isLoading = true;
  bool _isDropdownFocused = false;

  @override
  void initState() {
    super.initState();
    _classRepository = ClassRepositoryImpl(api: ApiService());

    _titleController = TextEditingController(
      text: widget.initialData?['title'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialData?['description'] ?? '',
    );

    if (widget.initialData?['classId'] != null) {
      _selectedClassId = widget.initialData!['classId'].toString();
    }
    _deadline =
        widget.initialData?['deadline'] ??
        DateTime.now().add(const Duration(days: 1));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchClasses();
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_deadline),
      );

      if (pickedTime != null) {
        final combined = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          _deadline = combined;
        });
      } else {
        final combined = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _deadline.hour,
          _deadline.minute,
        );
        setState(() {
          _deadline = combined;
        });
      }
    }
  }

  Future<void> _fetchClasses() async {
    if (_cachedClasses.isNotEmpty) {
      if (mounted) {
        setState(() {
          _classes = _cachedClasses;
          _isLoading = false;
        });
      }
      return;
    }

    if (_classes.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final classes = await _classRepository.getClasses();
      if (mounted) {
        setState(() {
          _cachedClasses = classes;
          _classes = classes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat daftar kelas')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(color: Colors.transparent),
          ),
        ),
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(widget.parentContext).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                Navigator.of(widget.parentContext).pop(),
                          ),
                        ],
                      ),
                      if (widget.initialData == null)
                        const Text(
                          'Tambah Tugas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Nama Tugas
                      Text(
                        'Nama Tugas',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama tugas',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color(0xFF6A766C),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama tugas tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Deadline
                      Text(
                        'Tenggat waktu',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        readOnly: true,
                        onTap: _selectDate,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Pilih tanggal & jam',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color(0xFF6A766C),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF131927),
                            size: 20,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                            maxWidth: 40,
                          ),
                        ),
                        controller: TextEditingController(
                          text: formatDateTime(_deadline),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Kelas
                      Text(
                        'Kelas',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: _isDropdownFocused
                              ? Border.all(
                                  color: const Color(0xFF6A766C),
                                  width: 2,
                                )
                              : Border.all(
                                  color: const Color(0xFFE0E0E0),
                                  width: 1,
                                ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : _classes.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Text('Tidak ada kelas tersedia'),
                              )
                            : Focus(
                                onFocusChange: (hasFocus) {
                                  setState(() {
                                    _isDropdownFocused = hasFocus;
                                  });
                                },
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedClassId,
                                    isExpanded: true,
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF131927),
                                    ),
                                    dropdownColor: Colors.white,
                                    hint: const Text(
                                      'Pilih kelas',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                    items: _classes.map((classItem) {
                                      return DropdownMenuItem<String>(
                                        value: classItem.id.toString(),
                                        child: Text(classItem.name),
                                      );
                                    }).toList(),
                                    onChanged: (value) => setState(
                                      () => _selectedClassId = value,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      const SizedBox(height: 16),
                      Text(
                        'Deskripsi',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Masukkan deskripsi tugas',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Color(0xFF6A766C),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Buttons Column
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Save Button
                            SizedBox(
                              width: 160,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    widget.onSave(
                                      _titleController.text,
                                      widget.initialData?['status'] ??
                                          'ongoing',
                                      _deadline,
                                      _descriptionController.text,
                                      _selectedClassId ?? '',
                                    );
                                    Navigator.of(widget.parentContext).pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0XFF212936),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                child: const Text(
                                  'Simpan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            ),

                            // Delete Button
                            if (widget.onDelete != null) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: 160,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final shouldDelete =
                                        await CustomModal.show<bool>(
                                          widget.parentContext,
                                          title: 'Apakah anda yakin?',
                                          message:
                                              'Pastikan lagi kembali sebelum dihapus',
                                          primaryButtonText: 'Hapus',
                                          secondaryButtonText: 'Batal',
                                          onPrimaryPressed: () => Navigator.pop(
                                            widget.parentContext,
                                            true,
                                          ),
                                          onSecondaryPressed: () =>
                                              Navigator.pop(
                                                widget.parentContext,
                                                false,
                                              ),
                                        );

                                    if (shouldDelete == true &&
                                        widget.onDelete != null) {
                                      widget.onDelete!();
                                      Navigator.of(widget.parentContext).pop();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEE443F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/icon/trash-icon.png',
                                        width: 18,
                                        height: 18,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Hapus',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
