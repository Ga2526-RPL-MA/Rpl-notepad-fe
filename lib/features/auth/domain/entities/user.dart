import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String nrp;
  final String email;
  final String? password;  
  final String role;
  final List<dynamic> classes;
  final List<dynamic> tasks;
  final List<dynamic> refreshTokens;

  const User({
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

  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  bool get isAdmin => role == 'admin';

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