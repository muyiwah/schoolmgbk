// models/exam.dart
import 'package:uuid/uuid.dart';

class Exam {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int durationMinutes;
  final List<Question> questions;
  final String creatorId;

  Exam({
    String? id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.durationMinutes,
    required this.questions,
    required this.creatorId,
  }) : id = id ?? const Uuid().v4();
}

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<String> options;
  final String correctAnswer;
  final int points;

  Question({
    String? id,
    required this.text,
    required this.type,
    required this.options,
    required this.correctAnswer,
    this.points = 1,
  }) : id = id ?? const Uuid().v4();
}

enum QuestionType { multipleChoice, trueFalse, shortAnswer }

class ExamResult {
  final String id;
  final String examId;
  final String studentId;
  final Map<String, String> answers;
  final DateTime submittedAt;
  final int score;
  final int totalPossible;

  ExamResult({
    String? id,
    required this.examId,
    required this.studentId,
    required this.answers,
    required this.submittedAt,
    required this.score,
    required this.totalPossible,
  }) : id = id ?? const Uuid().v4();
}
