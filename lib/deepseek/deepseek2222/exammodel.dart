// // models/exam_model.dart
// import 'package:uuid/uuid.dart';

// class Exam {
//   final String id;
//   final String examType;
//   final String className;
//   final String subject;
//   final String term;
//   final String academicYear;
//   final Duration duration;
//    List<Question> questions;
//   final DateTime createdAt;
//   final String? attachmentUrl;

//   Exam({
//     required this.examType,
//     required this.className,
//     required this.subject,
//     required this.term,
//     required this.academicYear,
//     required this.duration,
//     required this.questions,
//     this.attachmentUrl,
//     String? id,
//     DateTime? createdAt,
//   }) : id = id ?? const Uuid().v4(),
//        createdAt = createdAt ?? DateTime.now();

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'examType': examType,
//       'className': className,
//       'subject': subject,
//       'term': term,
//       'academicYear': academicYear,
//       'durationInMinutes': duration.inMinutes,
//       'questions': questions.map((q) => q.toMap()).toList(),
//       'createdAt': createdAt.toIso8601String(),
//       'attachmentUrl': attachmentUrl,
//     };
//   }

//   factory Exam.fromMap(Map<String, dynamic> map) {
//     return Exam(
//       id: map['id'],
//       examType: map['examType'],
//       className: map['className'],
//       subject: map['subject'],
//       term: map['term'],
//       academicYear: map['academicYear'],
//       duration: Duration(minutes: map['durationInMinutes']),
//       questions: List<Question>.from(
//         map['questions']?.map((x) => Question.fromMap(x)) ?? [],
//       ),
//       createdAt: DateTime.parse(map['createdAt']),
//       attachmentUrl: map['attachmentUrl'],
//     );
//   }
// }

// class Question {
//   final String id;
//   final String questionText;
//   final List<Option> options;
//   final String correctOptionId;
//   final List<dynamic> deltaJson;

//   Question({
//     required this.questionText,
//     required this.options,
//     required this.correctOptionId,
//     required this.deltaJson,
//     String? id,
//   }) : id = id ?? const Uuid().v4();

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'questionText': questionText,
//       'options': options.map((o) => o.toMap()).toList(),
//       'correctOptionId': correctOptionId,
//       'deltaJson': deltaJson, // ✅ Store raw JSON list
//     };
//   }

//   factory Question.fromMap(Map<String, dynamic> map) {
//     return Question(
//       id: map['id'],
//       questionText: map['questionText'],
//       options: List<Option>.from(map['options']?.map((x) => Option.fromMap(x))),
//       correctOptionId: map['correctOptionId'],
//       deltaJson: map['deltaJson'] ?? [], // ✅ Read raw JSON list
//     );
//   }
// }

// class Option {
//   final String id;
//   final String text;

//   Option({required this.text, String? id}) : id = id ?? const Uuid().v4();

//   Map<String, dynamic> toMap() {
//     return {'id': id, 'text': text};
//   }

//   factory Option.fromMap(Map<String, dynamic> map) {
//     return Option(id: map['id'], text: map['text']);
//   }
// }

// class ExamResult {
//   final String id;
//   final String examId;
//   final String studentId;
//   final String studentName;
//   final int score;
//   final int totalQuestions;
//   final DateTime submittedAt;
//   final Map<String, String> answers; // questionId -> selectedOptionId

//   ExamResult({
//     required this.examId,
//     required this.studentId,
//     required this.studentName,
//     required this.score,
//     required this.totalQuestions,
//     required this.answers,
//     String? id,
//     DateTime? submittedAt,
//   }) : id = id ?? const Uuid().v4(),
//        submittedAt = submittedAt ?? DateTime.now();

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'examId': examId,
//       'studentId': studentId,
//       'studentName': studentName,
//       'score': score,
//       'totalQuestions': totalQuestions,
//       'submittedAt': submittedAt.toIso8601String(),
//       'answers': answers,
//     };
//   }

//   factory ExamResult.fromMap(Map<String, dynamic> map) {
//     return ExamResult(
//       id: map['id'],
//       examId: map['examId'],
//       studentId: map['studentId'],
//       studentName: map['studentName'],
//       score: map['score'],
//       totalQuestions: map['totalQuestions'],
//       answers: Map<String, String>.from(map['answers']),
//       submittedAt: DateTime.parse(map['submittedAt']),
//     );
//   }
// }


import 'package:uuid/uuid.dart';

/// Model representing an Exam with a list of questions and metadata.
class Exam {
  final String id;
  final String examType;
  final String className;
  final String subject;
  final String term;
  final String academicYear;
  final Duration duration;
   List<Question> questions;
  final DateTime createdAt;
  final String? attachmentUrl;
   final String teacherId;
  final String? teacherName;

  Exam({
    required this.examType,
    required this.className,
    required this.subject,
    required this.term,
    required this.academicYear,
    required this.duration,
    required this.questions,
        required this.teacherId,
    this.teacherName,
    this.attachmentUrl,
    String? id,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'examType': examType,
      'className': className,
      'subject': subject,
      'term': term,
      'academicYear': academicYear,
      'durationInMinutes': duration.inMinutes,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'attachmentUrl': attachmentUrl,
        'teacherId': teacherId,
      'teacherName': teacherName,
    };
  }

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'],
      examType: map['examType'],
      className: map['className'],
      subject: map['subject'],
      term: map['term'],
      academicYear: map['academicYear'],
      duration: Duration(minutes: map['durationInMinutes']),
      questions: List<Question>.from(
        (map['questions'] ?? []).map((x) => Question.fromMap(x)),
      ),
      createdAt: DateTime.parse(map['createdAt']),
      attachmentUrl: map['attachmentUrl'],
        teacherId: map['teacherId'],
      teacherName: map['teacherName'],
    );
  }

  Exam copyWith({
    String? id,
    String? examType,
    String? className,
    String? subject,
    String? term,
    String? academicYear,
    Duration? duration,
    List<Question>? questions,
    DateTime? createdAt,
    String? attachmentUrl,
    String? teacherId,
    String? teacherName,
  }) {
    return Exam(
      id: id ?? this.id,
      examType: examType ?? this.examType,
      className: className ?? this.className,
      subject: subject ?? this.subject,
      term: term ?? this.term,
      academicYear: academicYear ?? this.academicYear,
      duration: duration ?? this.duration,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
    );
  }
}

/// Model representing a single Question within an exam.
class Question {
  final String id;
  final String questionText;
  final List<Option> options;
  final String correctOptionId;
  final List<dynamic> deltaJson; // Quill rich text JSON
  final String? mediaUrl; // Image, audio, or video URL (optional)
  final String? mediaType; 
  Question({
    required this.questionText,
    required this.options,
    required this.correctOptionId,
    required this.deltaJson,
    this.mediaUrl,
      this.mediaType,
    String? id,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options.map((o) => o.toMap()).toList(),
      'correctOptionId': correctOptionId,
      'deltaJson': deltaJson,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      questionText: map['questionText'],
      options: List<Option>.from(
        (map['options'] ?? []).map((x) => Option.fromMap(x)),
      ),
      correctOptionId: map['correctOptionId'],
      deltaJson: map['deltaJson'] ?? [],
     mediaUrl: map['mediaUrl'],
      mediaType: map['mediaType'],
    );
  }

  // In your exammodel.dart
  factory Question.empty() => Question(
    questionText: '',
    deltaJson: [],
    options: [],
    correctOptionId: '',
  );
}



/// Model representing an option in a multiple-choice question.
class Option {
  final String id;
  final String text;

  Option({required this.text, String? id}) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text};
  }

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(id: map['id'], text: map['text']);
  }
}

/// Model for storing a student's result for a given exam.
class ExamResult {
  final String id;
  final String examId;
  final String studentId;
  final String studentName;
  final int score;
  final int totalQuestions;
  final DateTime submittedAt;
  final Map<String, String> answers; // questionId -> selectedOptionId

  ExamResult({
    required this.examId,
    required this.studentId,
    required this.studentName,
    required this.score,
    required this.totalQuestions,
    required this.answers,
    String? id,
    DateTime? submittedAt,
  }) : id = id ?? const Uuid().v4(),
       submittedAt = submittedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'examId': examId,
      'studentId': studentId,
      'studentName': studentName,
      'score': score,
      'totalQuestions': totalQuestions,
      'submittedAt': submittedAt.toIso8601String(),
      'answers': answers,
    };
  }

  factory ExamResult.fromMap(Map<String, dynamic> map) {
    return ExamResult(
      id: map['id'],
      examId: map['examId'],
      studentId: map['studentId'],
      studentName: map['studentName'],
      score: map['score'],
      totalQuestions: map['totalQuestions'],
      answers: Map<String, String>.from(map['answers']),
      submittedAt: DateTime.parse(map['submittedAt']),
    );
  }
}
class StudentAttempt {
  final String id;
  final String examId;
  final String studentId;
  final DateTime startedAt;
  final DateTime? submittedAt;
  final Map<String, String> answers;

  StudentAttempt({
    required this.examId,
    required this.studentId,
    required this.startedAt,
    required this.answers,
    this.submittedAt,
    String? id,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'examId': examId,
      'studentId': studentId,
      'startedAt': startedAt.toIso8601String(),
      'submittedAt': submittedAt?.toIso8601String(),
      'answers': answers,
    };
  }

  factory StudentAttempt.fromMap(Map<String, dynamic> map) {
    return StudentAttempt(
      id: map['id'],
      examId: map['examId'],
      studentId: map['studentId'],
      startedAt: DateTime.parse(map['startedAt']),
      submittedAt:
          map['submittedAt'] != null
              ? DateTime.parse(map['submittedAt'])
              : null,
      answers: Map<String, String>.from(map['answers']),
    );
  }
}
