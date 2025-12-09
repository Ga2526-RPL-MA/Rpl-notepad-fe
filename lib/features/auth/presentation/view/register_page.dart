import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpl_notepad_fe/core/di/injection.dart';
import 'package:rpl_notepad_fe/core/network/api_service.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_background.dart';
import 'package:rpl_notepad_fe/core/widgets/custom_card.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/viewmodel/register_view_model.dart';
import 'package:rpl_notepad_fe/features/auth/presentation/widgets/custom_input_field.dart';
import 'package:rpl_notepad_fe/core/widgets/error_modal.dart';

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
    final screenSize = MediaQuery.of(context).size;
    final viewportHeight = MediaQuery.of(context).size.height;
    final isWeb = screenSize.width > 600;
    final cardWidth = isWeb ? screenSize.width * 0.5 : 370.0;
    final cardHeight = viewportHeight;

    return Consumer<RegisterViewModel>(
      builder: (context, viewModel, _) {
        return Stack(
          children: [
            CustomCard(
              width: cardWidth,
              height: cardHeight,
              cornerRadius: 13.43,
              child: Padding(
                padding: EdgeInsets.zero,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? cardWidth * 0.1 : 20,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
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

                    // Input Fields
                    Column(
                      children: [
                        SizedBox(
                          width: isWeb ? 500 : 300,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomInputField(
                                hintText: 'Nama',
                                iconPath: 'assets/icon/name-icon.png',
                                controller: viewModel.nameController,
                              ),
                              if (viewModel.isNameError)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    top: 4.0,
                                  ),
                                  child: Text(
                                    viewModel.nameErrorMsg ?? '',
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
                        SizedBox(
                          width: isWeb ? 500 : 300,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomInputField(
                                hintText: 'NRP',
                                iconPath: 'assets/icon/nrp-icon.png',
                                controller: viewModel.nrpController,
                              ),
                              if (viewModel.isNrpError)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    top: 4.0,
                                  ),
                                  child: Text(
                                    viewModel.nrpErrorMsg ?? '',
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
                        SizedBox(height: isWeb ? 20 : 12),
                        SizedBox(
                          width: isWeb ? 500 : 300,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomInputField(
                                hintText: 'Ulangi Kata Sandi',
                                iconPath: 'assets/icon/key-icon.png',
                                isPassword: true,
                                controller: viewModel.confirmpasswordController,
                              ),
                              if (viewModel.isConfirmPasswordError)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    top: 4.0,
                                  ),
                                  child: Text(
                                    viewModel.confirmPasswordErrorMsg ?? '',
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
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: isWeb ? 246 : 160,
                            height: isWeb ? 56 : 40,
                            child: ElevatedButton(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () async {
                                      try {
                                        await viewModel.register();
                                        if (context.mounted) {
                                          if (viewModel.user != null) {
                                            // Show success message
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Daftar berhasil!',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            // Navigate to login
                                            if (context.mounted) {
                                              Navigator.pushNamedAndRemoveUntil(
                                                context,
                                                '/login',
                                                (route) => false,
                                              );
                                            }
                                          } else if (viewModel.error != null) {
                                            context.showErrorModal(
                                              title: 'Gagal Mendaftar',
                                              message: viewModel.error!,
                                              buttonText: 'Tutup',
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          context.showErrorModal(
                                            message: e.toString().replaceAll(
                                              'Exception: ',
                                              '',
                                            ),
                                            buttonText: 'Tutup',
                                          );
                                        }
                                      }
                                    },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 24),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        );
      },
    );
  }
}