class CreateTaskDto {
  final String title;
  final String status;
  final DateTime? dueDate;
  final String? description;
  final int classId;
  final int userId;

  const CreateTaskDto({
    required this.title,
    this.status = 'ongoing',
    this.dueDate,
    this.description,
    required this.classId,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'status': status,
      'dueDate': dueDate?.toIso8601String(),
      'description': description,
      'classId': classId,
      'userId': userId,
    }..removeWhere((key, value) => value == null);
  }

  factory CreateTaskDto.fromJson(Map<String, dynamic> json) {
    return CreateTaskDto(
      title: json['title'] as String,
      status: json['status'] as String? ?? 'ongoing',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      description: json['description'] as String?,
      classId: json['classId'] as int,
      userId: json['userId'] as int,
    );
  }
}
