import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_card.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/login_view_model.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/user_profile.dart';
import '../../viewmodel/home_viewmodel.dart';

class WebHeader extends StatelessWidget {
  final HomeViewModel viewModel;

  const WebHeader({super.key, required this.viewModel});

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
            Expanded(
              child: CustomSearchBar(
                onSearch: (query) {
                  viewModel.searchTasks(query);
                },
              ),
            ),
            const SizedBox(width: 20),
            // Profile Section
            Consumer<LoginViewModel>(
              builder: (context, loginVM, _) {
                return UserProfile(
                  name: AuthService.userName ?? 'User',
                  email: AuthService.userEmail ?? 'user@example.com',
                  avatarSize: 40,
                  avatarColor: Color(0xFFD4C5F9),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
