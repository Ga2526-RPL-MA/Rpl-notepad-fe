import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/di/injection.dart';
import 'package:rpl_notepad_fe/core/network/api_sevice.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_card.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/login_view_model.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/widgets/custom_input_field.dart';

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
    final cardHeight = isWeb ? MediaQuery.of(context).size.height * 1 : 571.0;

    return Consumer<LoginViewModel>(
      builder: (context, viewModel, _) {
        return CustomCard(
            width: cardWidth,
            height: cardHeight,
            cornerRadius: 13.43,
            child: Center(
              child: SingleChildScrollView(
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

                      // Error Message
                      if (viewModel.error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade400),
                          ),
                          child: Text(
                            viewModel.error!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Input Fields
                      Column(
                        children: [
                          SizedBox(
                            width: isWeb ? 500 : 300,
                            child: CustomInputField(
                              hintText: 'Masukkan Email',
                              iconPath: 'assets/icon/mail-icon.png',
                              controller: viewModel.emailController,
                            ),
                          ),
                          SizedBox(height: isWeb ? 20 : 12),
                          SizedBox(
                            width: isWeb ? 500 : 300,
                            child: CustomInputField(
                              hintText: 'Kata Sandi',
                              iconPath: 'assets/icon/key-icon.png',
                              isPassword: true,
                              controller: viewModel.passwordController,
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
                                    await viewModel.login();
                                    if (context.mounted &&
                                        viewModel.user != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Login berhasil!'),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: Size(
                                isWeb ? 246 : 160,
                                isWeb ? 56 : 40,
                              ),
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
                          const SizedBox(height: 10),

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
                                      onTap: () {},
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
                                  onPressed: () {},
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
            ),
          );
        },
      );
  }
}
