import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/register_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/register_response_dto.dart';
import 'package:rpl_notepad_fe/features/auth/domain/usecases/register_usecase.dart';

class RegisterViewModel extends ChangeNotifier{
  final RegisterUseCase _registerUseCase;

  RegisterViewModel({required RegisterUseCase useCase})
      : _registerUseCase = useCase;

  // Controllers 
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nrpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();

  // State UI
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  RegisterResponseDto? _user;
  RegisterResponseDto? get user => _user;

  String? _error;
  String? get error => _error;

  // Register Function
  Future<void> register() async {
    final name = nameController.text.trim();
    final nrp = nrpController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || nrp.isEmpty || email.isEmpty || password.isEmpty) {
      _error = 'Semua field wajib diisi';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dto = RegisterDto(
        name: name,
        nrp: nrp,
        email: email,
        password: password,
      );
      _user = await _registerUseCase.execute(dto);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
