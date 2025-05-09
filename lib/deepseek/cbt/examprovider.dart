// providers/exam_provider.dart
import 'package:flutter/material.dart';
import 'package:schmgtsystem/deepseek/cbt/model/exam.dart';

class ExamProvider with ChangeNotifier {
  List<Exam> _exams = [];
  List<Exam> _teacherExams = [];
  List<ExamResult> _studentResults = [];
  bool _isLoading = false;

  // In-memory storage
  final List<Exam> _allExams = [];
  final List<ExamResult> _allResults = [];

  List<Exam> get exams => _exams;
  List<Exam> get teacherExams => _teacherExams;
  List<ExamResult> get studentResults => _studentResults;
  bool get isLoading => _isLoading;

  Future<void> loadExams() async {
    _setLoading(true);
    try {
      _exams = List.from(_allExams); // Create a copy
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTeacherExams(String teacherId) async {
    _setLoading(true);
    try {
      _teacherExams =
          _allExams.where((exam) => exam.creatorId == teacherId).toList();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStudentResults(String studentId) async {
    _setLoading(true);
    try {
      _studentResults =
          _allResults.where((result) => result.studentId == studentId).toList();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addExam(Exam exam) async {
    _setLoading(true);
    try {
      _allExams.add(exam);
      await loadTeacherExams(exam.creatorId);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateExam(Exam exam) async {
    _setLoading(true);
    try {
      final index = _allExams.indexWhere((e) => e.id == exam.id);
      if (index != -1) {
        _allExams[index] = exam;
      }
      await loadTeacherExams(exam.creatorId);
      await loadExams();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteExam(String examId) async {
    _setLoading(true);
    try {
      final exam = _teacherExams.firstWhere((e) => e.id == examId);
      _allExams.removeWhere((e) => e.id == examId);
      // Also remove any results associated with this exam
      _allResults.removeWhere((r) => r.examId == examId);
      await loadTeacherExams(exam.creatorId);
      await loadExams();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> submitExamResult(ExamResult result) async {
    _setLoading(true);
    try {
      _allResults.add(result);
      await loadStudentResults(result.studentId);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Helper method to initialize with dummy data if needed
  void initializeWithDummyData(List<Exam> dummyExams) {
    _allExams.addAll(dummyExams);
    notifyListeners();
  }
}
