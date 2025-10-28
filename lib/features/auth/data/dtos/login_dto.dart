import 'package:equatable/equatable.dart';

class LoginDto extends Equatable {
  final String email;
  final String password;

  const LoginDto({
    required this.email,
    required this.password,
  });

  // Convert JSON to DTO
  factory LoginDto.fromJson(Map<String, dynamic> json) => LoginDto(
        email: json['email'] as String,
        password: json['password'] as String,
      );

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };

  // Creating a copy with some fields changed
  LoginDto copyWith({
    String? email,
    String? password,
  }) {
    return LoginDto(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [email, password];
}
