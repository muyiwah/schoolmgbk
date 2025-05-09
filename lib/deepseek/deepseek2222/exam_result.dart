import 'package:flutter/material.dart';
import 'package:schmgtsystem/deepseek/deepseek2222/exammodel.dart';

class ExamResultScreen extends StatelessWidget {
  final String examId;
  final String studentId;

  const ExamResultScreen({
    super.key,
    required this.examId,
    required this.studentId,
  });

  // Replace with your actual data fetching logic
  Future<ExamResult?> getStudentResult(String examId, String studentId) async {
    // Fetch from Firestore or local storage
    await Future.delayed(const Duration(milliseconds: 300));
    return ExamResult(
      examId: examId,
      studentId: studentId,
      studentName: "John Doe",
      score: 7,
      totalQuestions: 10,
      answers: {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Exam Result')),
      body: FutureBuilder<ExamResult?>(
        future: getStudentResult(examId, studentId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Student: ${result.studentName}",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  "Score: ${result.score}/${result.totalQuestions}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Text("Submitted At: ${result.submittedAt.toLocal()}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
