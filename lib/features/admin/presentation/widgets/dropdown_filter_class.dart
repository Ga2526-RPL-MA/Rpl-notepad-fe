import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/discussion/data/dtos/get_class_dto.dart';

class DropdownFilterClass extends StatefulWidget {
  final List<GetClassDto> classes;
  final GetClassDto? selectedClass;
  final ValueChanged<GetClassDto?> onChanged;
  final bool isLoading;

  const DropdownFilterClass({
    super.key,
    required this.classes,
    required this.onChanged,
    this.selectedClass,
    this.isLoading = false,
  });

  static const primaryColor = Color(0xFF43B75D);
  static const borderColor = Color(0xFF256533);

  @override
  State<DropdownFilterClass> createState() => _DropdownFilterClassState();
}

class _DropdownFilterClassState extends State<DropdownFilterClass> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

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
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
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
                width: _calculateDropdownWidth(),
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _buildDropdownContent(),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  double _calculateDropdownWidth() {
    double maxWidth = 200.0; // Minimum width
    const textStyle = TextStyle(fontSize: 14);

    for (final classItem in widget.classes) {
      final text = classItem.name;
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
    return maxWidth + 80.0;
  }

  Widget _buildDropdownContent() {
    if (widget.isLoading && widget.classes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.classes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Tidak ada kelas'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: widget.classes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          final isSelected = widget.selectedClass == null;
          return InkWell(
            onTap: () {
              widget.onChanged(null);
              _closeDropdown();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: isSelected ? DropdownFilterClass.primaryColor.withOpacity(0.1) : Colors.transparent,
              child: Row(
                children: [
                  Image.asset(
                    'assets/icon/star_icon.png',
                    width: 20,
                    height: 20,
                    color: const Color(0xFF9EA2AE),
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.list,
                      color: Color(0xFF9EA2AE),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Semua Kelas',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Class items
        final classItem = widget.classes[index - 1];
        final isSelected = widget.selectedClass?.id == classItem.id;
        
        return InkWell(
          onTap: () {
            widget.onChanged(classItem);
            _closeDropdown();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: isSelected ? DropdownFilterClass.primaryColor.withOpacity(0.1) : Colors.transparent,
            child: Row(
              children: [
                Image.asset(
                  'assets/icon/star_icon.png',
                  width: 20,
                  height: 20,
                  color: const Color(0xFF9EA2AE),
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.class_,
                    color: Color(0xFF9EA2AE),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    classItem.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dropdownWidth = _calculateDropdownWidth();
    
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          width: dropdownWidth,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DropdownFilterClass.borderColor, width: 1),
            color: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icon/star_icon.png',
                width: 20,
                height: 20,
                color: DropdownFilterClass.primaryColor,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.filter_list,
                  color: DropdownFilterClass.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.isLoading && widget.classes.isEmpty 
                      ? 'Memuat...' 
                      : widget.selectedClass?.name ?? 'Semua Kelas',
                  style: const TextStyle(
                    color: DropdownFilterClass.primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: DropdownFilterClass.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
