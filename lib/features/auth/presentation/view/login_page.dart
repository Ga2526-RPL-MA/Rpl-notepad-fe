import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view/widgets/custom_input_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE7F0FF), Color(0xFFD3E3E1), Color(0xFFD3E3E1)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SizedBox(
              width: 370,
              height: 571,
              child: Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(13.43)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // Avatar
                      CircleAvatar(
                        radius: 59 / 2,
                        backgroundColor: Colors.transparent,
                        backgroundImage: const AssetImage(
                          'assets/images/user-circle.png',
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Welcome text
                      const Text(
                        'Selamat Datang di RPL Notepad',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Eksplorasi catatan dan ide dari sesama mahasiswa RPL.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Input fields
                      Column(
                        children: const [
                          SizedBox(
                            width: 300,
                            child: CustomInputField(
                              hintText: 'Masukkan Email',
                              iconPath: 'assets/images/mail.png',
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: 300,
                            child: CustomInputField(
                              hintText: 'Kata Sandi',
                              iconPath: 'assets/images/key-alt.png',
                              isPassword: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              fixedSize: const Size(110, 33),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text(
                              'Masuk',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                              fixedSize: const Size(110, 33),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text(
                              'Daftar',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
