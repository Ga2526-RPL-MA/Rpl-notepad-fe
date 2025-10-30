import 'package:equatable/equatable.dart';

class LogoutDto extends Equatable {
  final String refreshToken;

  const LogoutDto({required this.refreshToken});

  // Convert JSON to DTO
  factory LogoutDto.fromJson(Map<String, dynamic> json) =>
      LogoutDto(refreshToken: json['refreshToken'] as String);

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};

  // Creating a copy
  LogoutDto copyWith({String? refreshToken}) {
    return LogoutDto(refreshToken: refreshToken ?? this.refreshToken);
  }

  @override
  List<Object?> get props => [refreshToken];
}
