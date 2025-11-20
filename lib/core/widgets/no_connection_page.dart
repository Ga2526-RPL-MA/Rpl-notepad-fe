import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:rpl_notepad_fe/core/router/navigation_service.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/main.dart';

class NoConnectionPage extends StatefulWidget {
  const NoConnectionPage({Key? key}) : super(key: key);

  @override
  State<NoConnectionPage> createState() => _NoConnectionPageState();
}

class _NoConnectionPageState extends State<NoConnectionPage> {
  bool _loading = false;

  Future<bool> _hasInternet() async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      final res = await dio.get('https://www.gstatic.com/generate_204');
      return res.statusCode == 204 || res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onRetry() async {
    if (_loading) return;
    setState(() => _loading = true);
    final ok = await _hasInternet();
    setState(() => _loading = false);
    if (ok) {
      final route = AuthService.isLoggedIn ? '/home' : '/login';
      final nav = navigatorKey.currentState;
      if (nav != null) {
        nav.pushNamedAndRemoveUntil(route, (r) => false);
      } else {
        runApp(const MyApp());
      }
    } else {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon/no-connection-icon.png',
              width: 190,
              height: 190,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'Ups! Kamu sedang offline.',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Coba periksa koneksi internetmu, ya.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0XFF4D5461),
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0XFF4D5461),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.refresh, size: 20, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          "Ulangi",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
