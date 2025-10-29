import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final String hintText;
  final String iconPath;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomInputField({
    super.key,
    required this.hintText,
    required this.iconPath,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      style: TextStyle(
        fontSize: isWeb ? 16 : 13,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        fillColor: Colors.transparent,
        filled: true,
        contentPadding: isWeb
            ? const EdgeInsets.symmetric(vertical: 20, horizontal: 20)
            : const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        prefixIcon: Padding(
          padding: isWeb
              ? const EdgeInsets.all(20.0)
              : const EdgeInsets.all(12.0),
          child: Image.asset(
            widget.iconPath,
            width: isWeb ? 28 : 20,
            height: isWeb ? 28 : 20,
          ),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Image.asset(
                  _obscureText
                      ? 'assets/icon/eye-off-icon.png'
                      : 'assets/icon/eye-on-icon.png',
                  width: isWeb ? 28 : 20,
                  height: isWeb ? 28 : 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.grey,
            width: isWeb ? 2.0 : 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        ),
      ),
    );
  }
}