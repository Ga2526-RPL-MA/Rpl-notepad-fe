import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/core/services/auth_service.dart';
import '../../data/dtos/login_dto.dart';
import '../../data/dtos/login_response_dto.dart';
import '../../domain/usecases/login_usecase.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginUseCase _loginUseCase;

  LoginViewModel({required LoginUseCase useCase}) : _loginUseCase = useCase;

  LoginUseCase get loginUseCase => _loginUseCase;

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State UI
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  LoginResponseDto? _user;
  LoginResponseDto? get user => _user;

  String? _error;
  String? get error => _error;

  // Login Function
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _error = 'Email dan password wajib diisi';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dto = LoginDto(email: email, password: password);
      _user = await _loginUseCase.execute(dto);

      // Save token after successful login
      if (_user?.accessToken != null) {
        await AuthService.saveToken(_user!.accessToken);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _user = null;
    _error = null;
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }
}
