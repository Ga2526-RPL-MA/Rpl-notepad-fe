import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_modal.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/logout_dto.dart';
import 'package:rpl_notepad_fe/features/auth/domain/usecases/logout_usecase.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view/login_page.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/login_view_model.dart';

class MenuDrawer extends StatelessWidget {
  final String currentPage;
  final Function(String) onPageChanged;
  final String mode; // 'user' or 'admin'

  const MenuDrawer({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
    this.mode = 'user',
  });

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    final width = isWeb ? 393.0 : MediaQuery.of(context).size.width * 0.75;

    Widget menuItem({
      required String label,
      required String iconPath,
      required String pageKey,
    }) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();

          if (currentPage == pageKey) return;

          onPageChanged(pageKey);
          if (mode == 'admin') {
            if (pageKey == 'beranda') {
              Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
            } else if (pageKey == 'tambah_kelas') {
              Navigator.pushNamed(context, '/admin/add-class');
            }
          } else {
            if (pageKey == 'diskusi') {
              Navigator.pushReplacementNamed(context, '/discussion');
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: currentPage == pageKey ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Image.asset(
                iconPath,
                width: 22,
                height: 22,
                color: currentPage == pageKey
                    ? Colors.white
                    : const Color(0xFF4D5461),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: currentPage == pageKey
                        ? Colors.white
                        : const Color(0xFF4D5461),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Drawer(
      width: width,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: isWeb ? BorderRadius.circular(20) : BorderRadius.zero,
        child: Container(
          margin: isWeb
              ? const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20)
              : null,
          decoration: BoxDecoration(
            color: const Color(0x8AFFFFFF),
            borderRadius: isWeb ? BorderRadius.circular(20) : null,
          ),
          child: SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo + Title + Close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              width: 70,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'RPL Notepad',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isWeb)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: IconButton(
                            icon: Image.asset(
                              'assets/icon/menu-icon.png',
                              width: 24,
                              height: 24,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.grey, height: 1, thickness: 0.2),
                  const SizedBox(height: 16),

                  // Menu Items
                  if (mode == 'admin')
                    ...[
                      menuItem(
                        label: 'Beranda',
                        iconPath: 'assets/icon/home-icon.png',
                        pageKey: 'beranda',
                      ),
                      const SizedBox(height: 16),
                      menuItem(
                        label: 'Tambah Kelas',
                        iconPath: 'assets/icon/add-class-icon.png',
                        pageKey: 'tambah_kelas',
                      ),
                    ]
                  else
                    ...[
                      menuItem(
                        label: 'Beranda',
                        iconPath: 'assets/icon/home-icon.png',
                        pageKey: 'beranda',
                      ),
                      const SizedBox(height: 16),
                      menuItem(
                        label: 'Diskusi',
                        iconPath: 'assets/icon/discussion-icon.png',
                        pageKey: 'diskusi',
                      ),
                    ],
                  const Spacer(),

                  // Button Keluar
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16, top: 16),
                    child: Center(
                      child: SizedBox(
                        width: 160,
                        height: 42,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF394050)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final shouldLogout = await CustomModal.show<bool>(
                              context,
                              title: 'Apakah anda yakin?',
                              message: 'Pastikan lagi kembali sebelum keluar',
                              primaryButtonText: 'Keluar',
                              secondaryButtonText: 'Batal',
                              onPrimaryPressed: () =>
                                  Navigator.pop(context, true),
                              onSecondaryPressed: () =>
                                  Navigator.pop(context, false),
                            );

                            if (shouldLogout == true) {
                              try {
                                await AuthService.clearToken();

                                final loginVM = Provider.of<LoginViewModel>(
                                  context,
                                  listen: false,
                                );
                                loginVM.reset();

                                // Navigate to login page
                                if (!context.mounted) return;
                                Navigator.of(context, rootNavigator: true)
                                    .pushNamedAndRemoveUntil(
                                  '/login',
                                  (route) => false,
                                );

                                // Logout
                                final token = await AuthService.token;
                                if (token != null && token.isNotEmpty) {
                                  try {
                                    final logoutDto = LogoutDto(
                                      refreshToken: token,
                                    );
                                    final logoutUseCase = LogoutUseCase(
                                      loginVM.loginUseCase.repository,
                                    );
                                    await logoutUseCase.execute(logoutDto);
                                  } catch (e) {
                                    debugPrint(
                                      'API Logout failed (non-critical): $e',
                                    );
                                  }
                                }
                              } catch (e) {
                                debugPrint('Logout error: $e');
                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              }
                            }
                          },
                          child: const Text(
                            'Keluar',
                            style: TextStyle(
                              color: Color(0xFF394050),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
