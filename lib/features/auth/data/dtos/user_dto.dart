import 'package:equatable/equatable.dart';
import '../../domain/entitites/user.dart';

class UserDto extends Equatable {
  final int id;
  final String name;
  final String nrp;
  final String email;
  final String? password;
  final String role;
  final List<dynamic> classes;
  final List<dynamic> tasks;
  final List<dynamic> refreshTokens;

  const UserDto({
    required this.id,
    required this.name,
    required this.nrp,
    required this.email,
    this.password,
    this.role = 'user',
    this.classes = const [],
    this.tasks = const [],
    this.refreshTokens = const [],
  });

  // Convert JSON to DTO
  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json['id'] as int,
        name: json['name'] as String,
        nrp: json['nrp'] as String,
        email: json['email'] as String,
        password: json['password'] as String?,
        role: (json['role'] as String?) ?? 'user',
        classes: (json['classes'] as List<dynamic>?) ?? [],
        tasks: (json['tasks'] as List<dynamic>?) ?? [],
        refreshTokens: (json['refreshTokens'] as List<dynamic>?) ?? [],
      );

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nrp': nrp,
        'email': email,
        if (password != null) 'password': password,
        'role': role,
        'classes': classes,
        'tasks': tasks,
        'refreshTokens': refreshTokens,
      };

  // Convert DTO to Domain Entity
  User toEntity() => User(
        id: id,
        name: name,
        nrp: nrp,
        email: email,
        password: password,
        role: role,
        classes: classes,
        tasks: tasks,
        refreshTokens: refreshTokens,
      );

  // Create DTO from Domain Entity
  factory UserDto.fromEntity(User user) => UserDto(
        id: user.id,
        name: user.name,
        nrp: user.nrp,
        email: user.email,
        password: user.password,
        role: user.role,
        classes: user.classes,
        tasks: user.tasks,
        refreshTokens: user.refreshTokens,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        nrp,
        email,
        role,
        classes,
        tasks,
        refreshTokens,
      ];
}
