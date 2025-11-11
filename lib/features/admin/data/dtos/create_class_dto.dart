import 'package:equatable/equatable.dart';

class CreateClassDto extends Equatable {
  final String name;
  final String lecturer;
  final String timetable;
  final String room;

  const CreateClassDto({
    required this.name,
    required this.lecturer,
    required this.timetable,
    required this.room,
  });

  factory CreateClassDto.fromJson(Map<String, dynamic> json) {
    return CreateClassDto(
      name: json['name'] as String,
      lecturer: json['lecturer'] as String,
      timetable: json['timetable'] as String,
      room: json['room'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'lecturer': lecturer,
    'timetable': timetable,
    'room': room,
  };

  CreateClassDto copyWith({
    String? name,
    String? lecturer,
    String? timetable,
    String? room,
  }) {
    return CreateClassDto(
      name: name ?? this.name,
      lecturer: lecturer ?? this.lecturer,
      timetable: timetable ?? this.timetable,
      room: room ?? this.room,
    );
  }

  @override
  List<Object?> get props => [name, lecturer, timetable, room];
}
