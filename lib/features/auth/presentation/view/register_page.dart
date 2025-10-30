import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/di/injection.dart';
import 'package:rpl_notepad_fe/core/network/api_sevice.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_card.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/view_models/register_view_model.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/widgets/custom_input_field.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: isWeb
              ? Row(
                  children: [
                    Expanded(child: Center(child: _buildLoginCard(context))),
                    Expanded(child: Container()),
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
    final cardHeight = isWeb ? MediaQuery.of(context).size.height * 1 : 671.0;

    return Consumer<RegisterViewModel>(
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
                      fontSize: isWeb ? 14 : 10,
                      color: Color(0xFF979797),
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
                          hintText: 'Nama',
                          iconPath: 'assets/icon/name-icon.png',
                          controller: viewModel.nameController,
                        ),
                      ),
                      SizedBox(height: isWeb ? 20 : 12),
                      SizedBox(
                        width: isWeb ? 500 : 300,
                        child: CustomInputField(
                          hintText: 'NRP',
                          iconPath: 'assets/icon/nrp-icon.png',
                          controller: viewModel.nrpController,
                        ),
                      ),
                      SizedBox(height: isWeb ? 20 : 12),
                      SizedBox(
                        width: isWeb ? 500 : 300,
                        child: CustomInputField(
                          hintText: 'Email',
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
                      SizedBox(height: isWeb ? 20 : 12),
                      SizedBox(
                        width: isWeb ? 500 : 300,
                        child: CustomInputField(
                          hintText: 'Ulangi Kata Sandi',
                          iconPath: 'assets/icon/key-icon.png',
                          isPassword: true,
                          controller: viewModel.confirmpasswordController,
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
                                await viewModel.register();
                                if (context.mounted && viewModel.user != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Daftar berhasil!'),
                                    ),
                                  );
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
                                'Daftar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isWeb ? 16 : null,
                                ),
                              ),
                      ),
                      const SizedBox(height: 10),
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
