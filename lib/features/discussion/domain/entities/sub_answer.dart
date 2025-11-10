import 'package:equatable/equatable.dart';

class SubAnswer extends Equatable {
  final int id;
  final String userName;
  final String content;
  final DateTime answeredAt;
  final int answerId;

  const SubAnswer({
    required this.id,
    required this.userName,
    required this.content,
    required this.answeredAt,
    required this.answerId,
  });

  @override
  List<Object?> get props => [
        id,
        userName,
        content,
        answeredAt,
        answerId,
      ];
}
