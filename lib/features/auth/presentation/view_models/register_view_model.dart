import 'package:flutter/material.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/register_dto.dart';
import 'package:rpl_notepad_fe/features/auth/data/dtos/register_response_dto.dart';
import 'package:rpl_notepad_fe/features/auth/domain/usecases/register_usecase.dart';
import 'base_auth_view_model.dart';

class RegisterViewModel extends BaseAuthViewModel {
  final RegisterUseCase _registerUseCase;
  final nameController = TextEditingController();
  final nrpController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

  RegisterResponseDto? _user;
  RegisterResponseDto? get user => _user;

  RegisterViewModel({required RegisterUseCase useCase})
    : _registerUseCase = useCase;

  // Field error states
  bool _isNameError = false;
  bool _isNrpError = false;
  bool _isEmailError = false;
  bool _isPasswordError = false;
  bool _isConfirmPasswordError = false;

  // Field error messages
  String? _nameErrorMsg;
  String? _nrpErrorMsg;
  String? _emailErrorMsg;
  String? _passwordErrorMsg;
  String? _confirmPasswordErrorMsg;

  // Getters
  bool get isNameError => _isNameError;
  bool get isNrpError => _isNrpError;
  bool get isEmailError => _isEmailError;
  bool get isPasswordError => _isPasswordError;
  bool get isConfirmPasswordError => _isConfirmPasswordError;

  String? get nameErrorMsg => _nameErrorMsg;
  String? get nrpErrorMsg => _nrpErrorMsg;
  String? get emailErrorMsg => _emailErrorMsg;
  String? get passwordErrorMsg => _passwordErrorMsg;
  String? get confirmPasswordErrorMsg => _confirmPasswordErrorMsg;

  // Regex patterns
  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  static final _nrpRegex = RegExp(
    r'^5053\d{6}$',
  ); // harus mulai 5053 dan total 10 digit
  static final _passwordUppercaseRegex = RegExp(r'[A-Z]');
  static final _passwordNumberRegex = RegExp(r'[0-9]');

  @override
  void dispose() {
    nameController.dispose();
    nrpController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    super.dispose();
  }

  // Clear all errors
  void _clearErrors() {
    clearError();
    _isNameError = false;
    _isNrpError = false;
    _isEmailError = false;
    _isPasswordError = false;
    _isConfirmPasswordError = false;

    _nameErrorMsg = null;
    _nrpErrorMsg = null;
    _emailErrorMsg = null;
    _passwordErrorMsg = null;
    _confirmPasswordErrorMsg = null;
  }

  // Validate all fields
  bool _validateFields() {
    _clearErrors();
    bool isValid = true;

    // Name
    if (nameController.text.trim().isEmpty) {
      _isNameError = true;
      _nameErrorMsg = 'Nama wajib diisi';
      isValid = false;
    }

    // NRP
    final nrp = nrpController.text.trim();
    if (nrp.isEmpty) {
      _isNrpError = true;
      _nrpErrorMsg = 'NRP wajib diisi';
      isValid = false;
    } else if (!_nrpRegex.hasMatch(nrp)) {
      _isNrpError = true;
      _nrpErrorMsg = 'NRP harus diawali 5053 dan terdiri dari 10 angka';
      isValid = false;
    }

    // Email
    final email = emailController.text.trim();
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
    final password = passwordController.text.trim();
    if (password.isEmpty) {
      _isPasswordError = true;
      _passwordErrorMsg = 'Password wajib diisi';
      isValid = false;
    } else if (password.length < 8) {
      _isPasswordError = true;
      _passwordErrorMsg = 'Password minimal 8 karakter';
      isValid = false;
    } else if (!_passwordUppercaseRegex.hasMatch(password)) {
      _isPasswordError = true;
      _passwordErrorMsg = 'Password harus mengandung huruf besar';
      isValid = false;
    } else if (!_passwordNumberRegex.hasMatch(password)) {
      _isPasswordError = true;
      _passwordErrorMsg = 'Password harus mengandung angka';
      isValid = false;
    }

    // Confirm Password
    final confirm = confirmpasswordController.text.trim();
    if (confirm.isEmpty) {
      _isConfirmPasswordError = true;
      _confirmPasswordErrorMsg = 'Konfirmasi password wajib diisi';
      isValid = false;
    } else if (password != confirm) {
      _isConfirmPasswordError = true;
      _confirmPasswordErrorMsg = 'Password dan konfirmasi tidak cocok';
      isValid = false;
    }

    notifyListeners();
    return isValid;
  }

  // Register Function
  Future<bool> register() async {
    if (!_validateFields()) return false;

    setLoading(true);
    clearError();

    try {
      final dto = RegisterDto(
        name: nameController.text.trim(),
        nrp: nrpController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      _user = await _registerUseCase.execute(dto);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }
}
