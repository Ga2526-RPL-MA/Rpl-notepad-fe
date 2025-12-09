import 'package:equatable/equatable.dart';
import 'package:rpl_notepad_fe/features/auth/domain/entities/user.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/class.dart';

class Task extends Equatable {
  final int id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String status;
  final int userId;
  final int classId;
  final ClassModel class_;
  final User user;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.status = 'ongoing',
    required this.userId,
    required this.classId,
    required this.class_,
    required this.user,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dueDate,
        status,
        userId,
        classId,
        class_,
        user,
      ];

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    int? userId,
    int? classId,
    ClassModel? class_,
    User? user,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      classId: classId ?? this.classId,
      class_: class_ ?? this.class_,
      user: user ?? this.user,
    );
  }
}
