import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/user_profile.dart';

class MobileHeader extends StatelessWidget {
  final VoidCallback onMenuPressed;

  const MobileHeader({super.key, required this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, size: 24),
            onPressed: onMenuPressed,
          ),
          
          // User info and avatar
          UserProfile(
            name: 'Andina Pasha Rahmania',
            id: '505323101@student.its.ac.id',
            avatarSize: 40,
            avatarColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
