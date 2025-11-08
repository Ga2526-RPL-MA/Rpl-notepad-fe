import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/login_view_model.dart';
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
          Consumer<LoginViewModel>(
            builder: (context, loginVM, _) {
              return UserProfile(
                name: AuthService.userName ?? 'User',
                email: AuthService.userEmail ?? 'user@example.com',
                avatarSize: 40,
                avatarColor: Colors.blue,
              );
            },
          ),
        ],
      ),
    );
  }
}