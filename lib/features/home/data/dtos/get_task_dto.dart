import 'package:equatable/equatable.dart';
import 'package:rpl_notepad_fe/features/auth/domain/entities/user.dart';
import 'package:rpl_notepad_fe/features/discussion/domain/entities/class.dart';

class GetTaskDto extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String? dueDate;
  final String status;
  final int userId;
  final int classId;
  final ClassModel class_;
  final User user;

  const GetTaskDto({
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

  factory GetTaskDto.fromJson(Map<String, dynamic> json) {
    final dynamic cls = json['class'];
    final Map<String, dynamic>? classData =
        cls is Map ? Map<String, dynamic>.from(cls) : null;

    final dynamic usr = json['user'];
    final Map<String, dynamic>? userData =
        usr is Map ? Map<String, dynamic>.from(usr) : null;

    final int parsedClassId = (json['classId'] as int?) ?? (classData?['id'] as int?) ?? 0;
    final int parsedUserId = (json['userId'] as int?) ?? (userData?['id'] as int?) ?? 0;

    DateTime timetable;
    final dynamic timetableRaw = classData?['timetable'];
    if (timetableRaw is String) {
      timetable = DateTime.parse(timetableRaw);
    } else {
      timetable = DateTime.fromMillisecondsSinceEpoch(0);
    }

    return GetTaskDto(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['dueDate'] as String?,
      status: json['status'] as String? ?? 'ongoing',
      userId: parsedUserId,
      classId: parsedClassId,
      class_: ClassModel(
        id: parsedClassId,
        name: (classData?['name'] as String?) ?? '',
        lecturer: (classData?['lecturer'] as String?) ?? '',
        timetable: timetable,
        room: (classData?['room'] as String?) ?? '',
        students: const [],
        tasks: const [],
      ),
      user: User(
        id: parsedUserId,
        email: (userData?['email'] as String?) ?? '',
        name: (userData?['name'] as String?) ?? '',
        nrp: (userData?['nrp'] as String?) ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'dueDate': dueDate,
      'status': status,
      'userId': userId,
      'classId': classId,
      'class': {
        'id': class_.id,
        'name': class_.name,
        'lecturer': class_.lecturer,
        'timetable': class_.timetable.toIso8601String(),
        'room': class_.room,
      },
      'user': {
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'nrp': user.nrp,
      },
    };
  }

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

  GetTaskDto copyWith({
    int? id,
    String? title,
    String? description,
    String? dueDate,
    String? status,
    int? userId,
    int? classId,
    ClassModel? class_,
    User? user,
  }) {
    return GetTaskDto(
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