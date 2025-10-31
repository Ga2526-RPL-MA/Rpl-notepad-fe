import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/login_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/login_response_dto.dart';
import 'package:rpl_notepad_fe/features/auth/domain/usecases/login_usecase.dart';
import 'base_auth_view_model.dart';

class LoginViewModel extends BaseAuthViewModel {
  final LoginUseCase _loginUseCase;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginResponseDto? _user;
  LoginResponseDto? get user => _user;

  LoginViewModel({required LoginUseCase useCase}) : _loginUseCase = useCase;

  // Field error states
  bool _isEmailError = false;
  bool _isPasswordError = false;

  // Field error messages
  String? _emailErrorMsg;
  String? _passwordErrorMsg;

  // Getters
  bool get isEmailError => _isEmailError;
  bool get isPasswordError => _isPasswordError;

  String? get emailErrorMsg => _emailErrorMsg;
  String? get passwordErrorMsg => _passwordErrorMsg;

  // Regex patterns
  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  // Clear all errors
  void _clearErrors() {
    clearError();
    _isEmailError = false;
    _isPasswordError = false;
    _emailErrorMsg = null;
    _passwordErrorMsg = null;
  }

  // Validate all fields
  bool _validateFields() {
    _clearErrors();
    bool isValid = true;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Email
    if (email.isEmpty) {
      _isEmailError = true;
      _emailErrorMsg = 'Email wajib diisi';
      isValid = false;
    } else if (!_emailRegex.hasMatch(email)) {
      _isEmailError = true;
      _emailErrorMsg = 'Format email tidak valid';
      isValid = false;
    }

    // Password
    if (password.isEmpty) {
      _isPasswordError = true;
      _passwordErrorMsg = 'Kata sandi wajib diisi';
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Login Function
  Future<bool> login() async {
    if (!_validateFields()) return false;

    setLoading(true);

    try {
      final dto = LoginDto(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      _user = await _loginUseCase.execute(dto);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }
}
