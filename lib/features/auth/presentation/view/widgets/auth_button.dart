import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final Color backgroundColor; //  ElevatedButton
  final double borderRadius;
  final double fontSize;
  final Color textColor;
  final bool isOutlined; // true = OutlinedButton
  final Color? borderColor; //  OutlinedButton
  final double? borderWidth; //  OutlinedButton

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.fontSize,
    required this.textColor,
    this.backgroundColor = Colors.transparent, // default
    this.isOutlined = false,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            side: BorderSide(
              color: borderColor ?? Colors.white,
              width: borderWidth ?? 2,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize, color: textColor),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      );
    }
  }
}
