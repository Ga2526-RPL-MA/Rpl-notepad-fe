import 'package:flutter/material.dart';
import '../../../../../../core/widgets/menu_drawer.dart';

class DiscussionWebLayout extends StatelessWidget {
  final double screenHeight;
  final Widget child;
  final String currentPage;
  final Function(String) onPageChanged;

  const DiscussionWebLayout({
    super.key,
    required this.screenHeight,
    required this.child,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar
        MenuDrawer(
          currentPage: currentPage,
          onPageChanged: onPageChanged,
        ),
        const SizedBox(width: 20),
        
        // Main content
        Expanded(
          child: child,
        ),
      ],
    );
  }
}
