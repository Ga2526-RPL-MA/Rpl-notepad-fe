import 'package:equatable/equatable.dart';
import 'package:rpl_notepad_fe/features/note/domain/entities/note.dart';

class Week extends Equatable {
  final int id;
  final int week;
  final int classId;
  final List<Note> notes;

  const Week({
    required this.id,
    required this.week,
    required this.classId,
    this.notes = const [],
  });

  @override
  List<Object?> get props => [id, week, classId, notes];
}
