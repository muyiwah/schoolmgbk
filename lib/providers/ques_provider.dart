// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'exammodel.dart';

// class QuestionProvider extends ChangeNotifier {
//   List<Question> _questions = [];

//   List<Question> get questions => _questions;

//   void saveQuestion(int index, Question question) {
//     if (index < _questions.length) {
//       _questions[index] = question;
//     } else {
//       _questions.add(question);
//     }
//     _selectedExam.questions = List.from(_questions); // make a fresh copy
//     notifyListeners();
//   }

//   void clearAll() {
//     _questions.clear();
//     notifyListeners();
//   }

//   Exam _selectedExam =Exam(examType: '', className: '', subject: '', term: '', academicYear: '', duration: Duration(), questions: [],teacherId: '');

//   Exam get selectedExam => _selectedExam;

//   void setExam(Exam exam) {
//     _selectedExam = exam;
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import '../deepseek/deepseek2222/exammodel.dart';

class QuestionProvider extends ChangeNotifier {
  Exam _selectedExam = Exam(
    examType: '',
    className: '',
    subject: '',
    term: '',
    academicYear: '',
    duration: Duration(),
    questions: [],
    teacherId: '',
  );

  List<Question> _questions = [];

  List<Question> get questions => _questions;
  List<Exam> _allExams = [];
  List<Exam> get allExams => _allExams;
  Exam get selectedExam => _selectedExam;

   void setExam(Exam exam) {
    _selectedExam = exam;
    // Check if exam already exists before adding
    if (!_allExams.any((e) => e.id == exam.id)) {
      _allExams.add(exam);
    }
    _questions = List<Question>.from(exam.questions);
    notifyListeners();
  }

  void saveQuestion(int index, Question question, String subject) {
    if (index < _questions.length) {
      _questions[index] = question;
    } else {
      _questions.add(question);
    }

    // Update the exam in _allExams
    final examIndex = _allExams.indexWhere((exam) => exam.subject == subject);
    if (examIndex != -1) {
      _allExams[examIndex] = _allExams[examIndex].copyWith(
        questions: List<Question>.from(_questions),
      );
      notifyListeners();
    }
  }

  void clearAll() {
    _questions.clear();
    _selectedExam = _selectedExam.copyWith(questions: []);
    notifyListeners();
  }
}
