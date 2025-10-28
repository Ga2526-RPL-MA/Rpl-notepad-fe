import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({
    Key? key,
    this.controller,
    this.hintText = 'Cari',
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: isWeb,
          fillColor: isWeb ? const Color(0xFFF1F3F4) : null,
          hintText: hintText,
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
