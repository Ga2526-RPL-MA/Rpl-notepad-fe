import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/features/home/presentation/viewmodel/home_viewmodel.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSearch;
  final Duration debounceDuration;

  const CustomSearchBar({
    Key? key,
    this.hintText = 'Cari catatan...',
    this.controller,
    this.onChanged,
    this.onSearch,
    this.debounceDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  Timer? _debounce;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(widget.debounceDuration, () {
      if (widget.onSearch != null) {
        widget.onSearch!(query);
      } else if (widget.onChanged != null) {
        widget.onChanged!(query);
      } else {
        // For backward compatibility, try to use HomeViewModel if available
        try {
          final viewModel = Provider.of<HomeViewModel>(context, listen: false);
          viewModel.searchTasks(query);
        } catch (e) {
          debugPrint('Error accessing HomeViewModel: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          filled: isWeb,
          fillColor: isWeb ? const Color(0xFFF1F3F4) : null,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: isWeb
                ? BorderSide.none
                : const BorderSide(color: Color(0xFF131927)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: isWeb
                ? BorderSide.none
                : const BorderSide(color: Color(0xFF131927)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: isWeb
                ? BorderSide.none
                : const BorderSide(color: Color(0xFF131927)),
          ),
        ),
      ),
    );
  }
}
