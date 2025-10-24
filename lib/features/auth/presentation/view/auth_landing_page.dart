import 'package:flutter/material.dart';
import 'widgets/auth_black_overlay.dart';
import 'login_page.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_background.dart';

class AuthLandingPage extends StatelessWidget {
  const AuthLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          const BackgroundImage(),

          // Black Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BlackBlurOverlay(
              height: screenHeight * 0.58,
              blurSigma: 2,
              opacity: 0.58,
            ),
          ),

          // Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.65,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 98),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Text(
                    'Selamat datang di\nRPL Notepad',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                  const Text(
                    'Eksplorasi catatan dan ide dari sesama mahasiswa RPL.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                    ),
                  ),

                  const Spacer(),
                  Center(
                    child: Column(
                      children: [
                        // Button Login
                        AuthButton(
                          text: 'Masuk',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          width: 265,
                          height: 55,
                          backgroundColor: const Color(0xFF308242),
                          borderRadius: 14,
                          fontSize: 20,
                          textColor: Colors.white,
                        ),

                        const SizedBox(height: 20),
                        // Button Register
                        AuthButton(
                          text: 'Daftar Akun',
                          onPressed: () {},
                          width: 265,
                          height: 55,
                          borderRadius: 14,
                          fontSize: 20,
                          textColor: Colors.white,
                          isOutlined: true,
                          borderColor: Colors.white,
                          borderWidth: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
