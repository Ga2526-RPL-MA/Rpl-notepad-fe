import 'package:flutter/material.dart';

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
                mainAxisSize: MainAxisSize.min,
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
                            const SizedBox(width: 12),
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
                                fontWeight: FontWeight.w400,
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
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
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
                          onPressed: () {},
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
