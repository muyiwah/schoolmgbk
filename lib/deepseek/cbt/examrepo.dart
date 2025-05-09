// repositories/exam_repository.dart
import 'package:schmgtsystem/deepseek/cbt/data.dart';
import 'package:schmgtsystem/deepseek/cbt/model/exam.dart';

class ExamRepository {
  final List<Exam> _exams = [];
  final List<ExamResult> _results = [];

  // Initialize with dummy data if needed
  ExamRepository() {
    _exams.addAll(dummyExams);
  }

  List<Exam> getExams() => List.from(_exams);

  List<Exam> getTeacherExams(String teacherId) =>
      _exams.where((exam) => exam.creatorId == teacherId).toList();

  Future<void> addExam(Exam exam) async {
    _exams.add(exam);
  }

  Future<void> updateExam(Exam exam) async {
    final index = _exams.indexWhere((e) => e.id == exam.id);
    if (index != -1) {
      _exams[index] = exam;
    }
  }

  Future<void> deleteExam(String examId) async {
    _exams.removeWhere((e) => e.id == examId);
    // Also remove any results associated with this exam
    _results.removeWhere((r) => r.examId == examId);
  }

  Future<void> submitResult(ExamResult result) async {
    _results.add(result);
  }

  List<ExamResult> getStudentResults(String studentId) =>
      _results.where((r) => r.studentId == studentId).toList();
}
