import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final double size;
  final String? imageUrl;
  final Color? backgroundColor;
  final IconData? icon;
  final Color? iconColor;
  final bool showOnlineIndicator;
  final Color onlineIndicatorColor;

  const ProfileAvatar({
    super.key,
    this.size = 40,
    this.imageUrl,
    this.backgroundColor,
    this.icon = Icons.person,
    this.iconColor,
    this.showOnlineIndicator = true,
    this.onlineIndicatorColor = const Color(0xFF43B75D),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor ?? Colors.white,
            size: size * 0.5,
          ),
        ),
        if (showOnlineIndicator)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: onlineIndicatorColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: size * 0.05,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
