import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view/login_page.dart';

class MenuDrawer extends StatelessWidget {
  final String currentPage; 
  final Function(String) onPageChanged;

  const MenuDrawer({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
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
          onPageChanged(pageKey);
          Navigator.of(context).pop();
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
                color: currentPage == pageKey ? Colors.white : const Color(0xFF4D5461),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: currentPage == pageKey ? Colors.white : const Color(0xFF4D5461),
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
      child: Container(
        margin: isWeb ? const EdgeInsets.all(20) : null,
        decoration: BoxDecoration(
          color: isWeb ? const Color(0x80FFFFFF) : Colors.grey,
          borderRadius: isWeb ? BorderRadius.circular(20) : null,
        ),
        child: ClipRRect(
          borderRadius: isWeb ? BorderRadius.circular(20) : BorderRadius.zero,
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
                      Row(
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
                      if (!isWeb)
                        IconButton(
                          icon: Image.asset(
                            'assets/icon/menu-icon.png',
                            width: 24,
                            height: 24,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.grey, height: 1, thickness: 0.2),
                  const SizedBox(height: 16),

                  // Menu Items
                  menuItem(
                    label: 'Beranda',
                    iconPath: 'assets/icon/home-icon.png',
                    pageKey: 'beranda',
                  ),
                  const SizedBox(height: 16),
                  menuItem(
                    label: 'Tugas selesai',
                    iconPath: 'assets/icon/task-icon.png',
                    pageKey: 'tugas_selesai',
                  ),
                  const SizedBox(height: 16),
                  menuItem(
                    label: 'Diskusi',
                    iconPath: 'assets/icon/discussion-icon.png',
                    pageKey: 'diskusi',
                  ),
                  const Spacer(),

                  // Button Keluar
                  Center(
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
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
