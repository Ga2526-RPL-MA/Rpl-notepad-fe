import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rpl_notepad_fe/core/services/auth_service.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  String _fallbackRoute() {
    if (!AuthService.isLoggedIn) return '/login';
    return AuthService.isAdmin ? '/admin' : '/home';
  }

  @override
  Widget build(BuildContext context) {
    final route = _fallbackRoute();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8EEF4), Color(0xFFD9F2E3)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF000000), Color(0xFF666666)],
                      stops: [0.0, 0.74],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: const Text(
                    '404',
                    style: TextStyle(
                      fontSize: 205,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Halaman tidak ditemukan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: Color(0XFF4D5461),
                  ),
                ),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Maaf, halaman yang Anda cari tidak tersedia atau tidak dapat ditemukan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0XFF6D717F),
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFF4D5461),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  onPressed: () {
                    if (kIsWeb) {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(route, (route) => false);
                    } else {
                      Navigator.of(context).pushReplacementNamed(route);
                    }
                  },
                  icon: const Icon(Icons.home_rounded, size: 20),
                  label: const Text(
                    'Kembali Ke Halaman',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
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
