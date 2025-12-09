import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_card.dart';
import 'package:rpl_notepad_fe/core/widgets/menu_drawer.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/custom_search_bar.dart';
import 'package:rpl_notepad_fe/features/home/presentation/widgets/user_profile.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/viewmodel/login_view_model.dart';

class DiscussionAdminPage extends StatefulWidget {
  const DiscussionAdminPage({super.key});

  @override
  State<DiscussionAdminPage> createState() => _DiscussionAdminPageState();
}

class _DiscussionAdminPageState extends State<DiscussionAdminPage> {
  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 800;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GradientBackground(
        child: isWeb
            ? _buildWebLayout(context, screenHeight)
            : _buildMobileLayout(context, screenHeight),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, double screenHeight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MenuDrawer(
          mode: 'admin',
          currentPage: 'diskusi', // Update this based on your menu structure
          onPageChanged: (page) {
            if (page == 'beranda') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/admin',
                (route) => false,
              );
            } else if (page == 'tambah_kelas') {
              Navigator.pushNamed(context, '/admin/add-class');
            }
          },
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildHeader(context),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: _buildDiscussionContent(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, double screenHeight) {
    return Column(
      children: [
        AppBar(
          title: const Text(
            'Diskusi Admin',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _buildDiscussionContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return CustomCard(
      color: Colors.white,
      width: double.infinity,
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CustomSearchBar(
              onChanged: (value) {},
              hintText: 'Cari diskusi...',
            ),
          ),
          const SizedBox(width: 20),
          Consumer<LoginViewModel>(
            builder: (context, loginVM, _) {
              return UserProfile(
                name: AuthService.userName?.isNotEmpty == true
                    ? AuthService.userName!
                    : 'Admin',
                email: AuthService.userEmail?.isNotEmpty == true
                    ? AuthService.userEmail!
                    : 'admin@example.com',
                avatarSize: 40,
                avatarColor: const Color(0xFFD4C5F9),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: CustomCard(
          color: Colors.white,
          width: double.infinity,
          height: 700,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Diskusi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 20),
                // TODO
                Expanded(
                  child: Center(
                    child: Text(
                      'Daftar diskusi akan muncul di sini',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
