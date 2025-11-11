import 'package:equatable/equatable.dart';

class GetClassDto extends Equatable {
  final int id;
  final String name;
  final String lecturer;
  final String timetable; 
  final String room;
  final List<dynamic> students;
  final List<dynamic> tasks;

  const GetClassDto({
    required this.id,
    required this.name,
    required this.lecturer,
    required this.timetable,
    required this.room,
    required this.students,
    required this.tasks,
  });

  // Convert JSON to DTO
  factory GetClassDto.fromJson(Map<String, dynamic> json) {
    return GetClassDto(
      id: json['id'] as int,
      name: json['name'] as String,
      lecturer: json['lecturer'] as String,
      timetable: json['timetable'] as String, 
      room: json['room'] as String,
      students: json['students'] ?? [],
      tasks: json['tasks'] ?? [],
    );
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lecturer': lecturer,
    'timetable': timetable, 
    'room': room,
    'students': students,
    'tasks': tasks,
  };

  // Helper 
  String get displayTimetable => timetable;

  // Copy DTO
  GetClassDto copyWith({
    int? id,
    String? name,
    String? lecturer,
    String? timetable,
    String? room,
    List<dynamic>? students,
    List<dynamic>? tasks,
  }) {
    return GetClassDto(
      id: id ?? this.id,
      name: name ?? this.name,
      lecturer: lecturer ?? this.lecturer,
      timetable: timetable ?? this.timetable,
      room: room ?? this.room,
      students: students ?? this.students,
      tasks: tasks ?? this.tasks,
    );
  }

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
