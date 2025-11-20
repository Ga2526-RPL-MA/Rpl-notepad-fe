import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/di/injection.dart';
import 'package:rpl_notepad_fe/core/network/api_service.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_card.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/login_view_model.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/widgets/custom_input_field.dart';
import 'package:rpl_notepad_fe/core/widgets/error_modal.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: isWeb
              ? Row(
                  children: [
                    Expanded(child: Container()),
                    Expanded(child: Center(child: _buildLoginCard(context))),
                  ],
                )
              : Center(child: _buildLoginCard(context)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getIt<ApiService>().alice.showInspector();
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.bug_report, color: Colors.white),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    final cardWidth = isWeb ? MediaQuery.of(context).size.width / 2 : 370.0;
    final cardHeight = isWeb ? MediaQuery.of(context).size.height : 591.0;

    return Consumer<LoginViewModel>(
      builder: (context, viewModel, _) {
        return CustomCard(
          width: cardWidth,
          height: cardHeight,
          cornerRadius: 13.43,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? cardWidth * 0.1 : 20,
                vertical: 40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  SizedBox(
                    width: isWeb ? 105 : 59,
                    height: isWeb ? 105 : 59,
                    child: CircleAvatar(
                      radius: isWeb ? 52.5 : 29.5,
                      backgroundColor: Colors.transparent,
                      backgroundImage: const AssetImage(
                        'assets/icon/user-icon.png',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Welcome Text
                  Text(
                    'Selamat Datang di RPL Notepad',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isWeb ? 24 : 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Eksplorasi catatan dan ide dari sesama mahasiswa RPL.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isWeb ? 14 : 11,
                      color: Colors.grey,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Input Fields
                  Column(
                    children: [
                      // Email Field
                      SizedBox(
                        width: isWeb ? 500 : 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomInputField(
                              hintText: 'Email',
                              iconPath: 'assets/icon/mail-icon.png',
                              controller: viewModel.emailController,
                            ),
                            if (viewModel.isEmailError)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  top: 4.0,
                                ),
                                child: Text(
                                  viewModel.emailErrorMsg ?? '',
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: isWeb ? 20 : 12),

                      // Password Field
                      SizedBox(
                        width: isWeb ? 500 : 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomInputField(
                              hintText: 'Kata Sandi',
                              iconPath: 'assets/icon/key-icon.png',
                              isPassword: true,
                              controller: viewModel.passwordController,
                            ),
                            if (viewModel.isPasswordError)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  top: 4.0,
                                ),
                                child: Text(
                                  viewModel.passwordErrorMsg ?? '',

                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Buttons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                final success = await viewModel.login();
                                if (context.mounted) {
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Login berhasil!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    final targetRoute = AuthService.isAdmin
                                        ? '/admin'
                                        : '/home';
                                    Navigator.pushReplacementNamed(
                                      context,
                                      targetRoute,
                                    );
                                  } else if (viewModel.error != null) {
                                    context.showErrorModal(
                                      title: 'Gagal Login',
                                      message: viewModel.error!,
                                      buttonText: 'Tutup',
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(isWeb ? 246 : 160, isWeb ? 56 : 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: TextStyle(
                            fontSize: isWeb ? 16 : 13,
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: viewModel.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Masuk',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isWeb ? 16 : null,
                                ),
                              ),
                      ),

                      SizedBox(height: isWeb ? 22 : 16),

                      // Button Daftar
                      isWeb
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Belum punya akun? ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF212936),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/register');
                                  },
                                  child: const Text(
                                    'Daftar disini',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1C4D27),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Inter",
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : OutlinedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                minimumSize: const Size(160, 40),
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
        );
      },
    );
  }
}
