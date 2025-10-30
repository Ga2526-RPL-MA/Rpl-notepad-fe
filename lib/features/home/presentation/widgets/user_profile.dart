import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/profile_avatar.dart';

class UserProfile extends StatelessWidget {
  final String name;
  final String id;
  final double avatarSize;
  final Color? avatarColor;
  final bool showOnlineIndicator;
  final Color onlineIndicatorColor;

  const UserProfile({
    super.key,
    required this.name,
    required this.id,
    this.avatarSize = 40,
    this.avatarColor,
    this.showOnlineIndicator = true,
    this.onlineIndicatorColor = const Color(0xFF43B75D),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              id,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        ProfileAvatar(
          size: avatarSize,
          backgroundColor: avatarColor,
          showOnlineIndicator: showOnlineIndicator,
          onlineIndicatorColor: onlineIndicatorColor,
        ),
      ],
    );
  }
}
