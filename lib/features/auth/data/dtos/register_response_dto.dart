import 'package:equatable/equatable.dart';

class RegisterResponseDto extends Equatable {
  final String message;
  final String name;
  final String nrp;
  final String email;

  const RegisterResponseDto({
    required this.message,
    required this.name,
    required this.nrp,
    required this.email,
  });

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) {
    return RegisterResponseDto(
      message: json['message'] as String,
      name: json['name'] as String,
      nrp: json['nrp'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'name': name, 'nrp': nrp, 'email': email};
  }

  @override
  List<Object?> get props => [message, name, nrp, email];
}
