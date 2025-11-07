import 'package:equatable/equatable.dart';

class ClassModel extends Equatable {
  final int id;
  final String name;
  final String lecturer;
  final DateTime timetable;
  final String room;
  final List<UserClassModel> students;
  final List<TaskModel> tasks;

  const ClassModel({
    required this.id,
    required this.name,
    required this.lecturer,
    required this.timetable,
    required this.room,
    required this.students,
    required this.tasks,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    lecturer,
    timetable,
    room,
    students,
    tasks,
  ];
}

class UserClassModel extends Equatable {
  final int id;
  final int userId;
  final int classId;

  const UserClassModel({
    required this.id,
    required this.userId,
    required this.classId,
  });

  @override
  List<Object?> get props => [id, userId, classId];
}

class TaskModel extends Equatable {
  final int id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String status;
  final int userId;
  final int classId;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.status,
    required this.userId,
    required this.classId,
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
  ];
}
