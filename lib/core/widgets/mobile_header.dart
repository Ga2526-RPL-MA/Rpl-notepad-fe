import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';

class MobileHeader extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;

  const MobileHeader({
    super.key,
    required this.hintText,
    this.onChanged,
    this.onSearch,
    this.onBackPressed,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CustomSearchBar(
                hintText: hintText,
                onChanged: onChanged,
                onSearch: onSearch, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}