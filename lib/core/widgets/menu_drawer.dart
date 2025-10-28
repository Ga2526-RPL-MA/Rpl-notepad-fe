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
    final width = MediaQuery.of(context).size.width * 0.75;
    return Drawer(
      width: width,
      backgroundColor: Colors.transparent,
      child: Container(
        color: Colors.grey,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          const SizedBox(width: 8),
                          Text(
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
                Divider(color: Colors.grey, height: 1, thickness: 0.2),
                const SizedBox(height: 16),
                // Beranda
                GestureDetector(
                  onTap: () {
                    onPageChanged('beranda');
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: currentPage == 'beranda'
                          ? Colors.black
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icon/home-icon.png',
                          width: 22,
                          height: 22,
                          color: currentPage == 'beranda'
                              ? Colors.white
                              : const Color(0xFF4D5461),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Beranda',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: currentPage == 'beranda'
                                  ? Colors.white
                                  : const Color(0xFF4D5461),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Tugas Selesai
                GestureDetector(
                  onTap: () {
                    onPageChanged('tugas_selesai');
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: currentPage == 'tugas_selesai'
                          ? Colors.black
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icon/task-icon.png',
                          width: 22,
                          height: 22,
                          color: currentPage == 'tugas_selesai'
                              ? Colors.white
                              : const Color(0xFF4D5461),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tugas selesai',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: currentPage == 'tugas_selesai'
                                  ? Colors.white
                                  : const Color(0xFF4D5461),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Diskusi
                GestureDetector(
                  onTap: () {
                    onPageChanged('diskusi');
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: currentPage == 'diskusi'
                          ? Colors.black
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icon/discussion-icon.png',
                          width: 22,
                          height: 22,
                          color: currentPage == 'diskusi'
                              ? Colors.white
                              : const Color(0xFF4D5461),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Diskusi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: currentPage == 'diskusi'
                                  ? Colors.white
                                  : const Color(0xFF4D5461),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 286),
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
    );
  }
}
