import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color backgroundColor;
  final Color textColor;

  const UserAvatar({
    Key? key,
    required this.initials,
    this.size = 40,
    this.backgroundColor = const Color(0xFF212936),
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials[0].toUpperCase() : 'U',
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
