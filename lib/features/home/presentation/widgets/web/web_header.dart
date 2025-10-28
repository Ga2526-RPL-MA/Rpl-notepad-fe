import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/user_profile.dart';
import '../../../../../../core/widgets/custom_card.dart';
import '../../viewmodel/home_viewmodel.dart';

class WebHeader extends StatelessWidget {
  final HomeViewModel viewModel;

  const WebHeader({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomCard(
        color: Colors.white,
        width: double.infinity,
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search Bar
            const Expanded(
              child: CustomSearchBar(),
            ),
            const SizedBox(width: 20),
            
            // Profile Section
            UserProfile(
              name: 'Andina Pasha Rahmania',
              id: '505323101@student.its.ac.id',
              avatarSize: 40,
              avatarColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
