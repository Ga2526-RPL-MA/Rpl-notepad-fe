import 'package:equatable/equatable.dart';

class CreateWeekDto extends Equatable {
  final int week;
  final int classId;

  const CreateWeekDto({required this.week, required this.classId});

  // Convert JSON to DTO
  factory CreateWeekDto.fromJson(Map<String, dynamic> json) {
    return CreateWeekDto(
      week: json['week'] as int,
      classId: json['classId'] as int,
    );
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() => {'week': week, 'classId': classId};

  // Copy DTO
  CreateWeekDto copyWith({int? week, int? classId}) {
    return CreateWeekDto(
      week: week ?? this.week,
      classId: classId ?? this.classId,
    );
  }

  @override
  List<Object?> get props => [week, classId];
}
