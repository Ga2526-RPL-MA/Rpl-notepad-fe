import 'package:equatable/equatable.dart';

class LogoutResponseDto extends Equatable {
  final String message;

  const LogoutResponseDto({required this.message});

  // Convert JSON to DTO
  factory LogoutResponseDto.fromJson(Map<String, dynamic> json) =>
      LogoutResponseDto(message: json['message'] as String);

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {'message': message};

  @override
  List<Object?> get props => [message];
}
