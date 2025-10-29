import 'package:equatable/equatable.dart';

class LoginResponseDto extends Equatable {
  final String message;
  final String nrp;
  final String accessToken;
  final String refreshToken;

  const LoginResponseDto({
    required this.message,
    required this.nrp,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      message: json['message'] as String,
      nrp: json['nrp'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'nrp': nrp,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  @override
  List<Object?> get props => [message, nrp, accessToken, refreshToken];
}
