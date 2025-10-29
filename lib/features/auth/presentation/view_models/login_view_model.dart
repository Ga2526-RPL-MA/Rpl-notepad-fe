import 'package:flutter/material.dart';
import '../../data/dtos/login_dto.dart';
import '../../data/dtos/login_response_dto.dart';
import '../../data/repositories/auth_repository_impl.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepositoryImpl _repository;

  LoginViewModel({AuthRepositoryImpl? repository})
      : _repository = repository ?? AuthRepositoryImpl();

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
      _user = await _repository.login(dto);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
