import 'package:equatable/equatable.dart';

class RegisterDto extends Equatable {
  final String name;
  final String nrp;
  final String email;
  final String password;

  const RegisterDto({
    required this.name,
    required this.nrp,
    required this.email,
    required this.password,
  });

  // Convert JSON to DTO
  factory RegisterDto.fromJson(Map<String, dynamic> json) => RegisterDto(
        name: json['name'] as String,
        nrp: json['nrp'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
      );

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {
        'name': name,
        'nrp': nrp,
        'email': email,
        'password': password,
      };

  // Creating a copy 
  RegisterDto copyWith({
    String? name,
    String? nrp,
    String? email,
    String? password,
  }) {
    return RegisterDto(
      name: name ?? this.name,
      nrp: nrp ?? this.nrp,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [name, nrp, email, password];
}