import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'exammodel.dart';
import 'exam_result.dart';
import 'ques_provider.dart';
import 'takeexam.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  final TextEditingController _studentIdController = TextEditingController();
  String? _enteredStudentId;
  bool _showIdInput = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExams();
    });
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _loadExams() async {
    final provider = Provider.of<QuestionProvider>(context, listen: false);
    setState(() {});
  }

  void _submitStudentId() {
    if (_studentIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your student ID')),
      );
      return;
    }
    setState(() {
      _enteredStudentId = _studentIdController.text.trim();
      _showIdInput = false;
    });
  }

  void _changeStudentId() {
    setState(() {
      _enteredStudentId = null;
      _showIdInput = true;
      _studentIdController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final exams = Provider.of<QuestionProvider>(context).allExams;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Exams'),
        actions: [
          if (_enteredStudentId != null)
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: _changeStudentId,
              tooltip: 'Change Student ID',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_showIdInput)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Enter your Student ID',
                      border: OutlineInputBorder(),
                      hintText: 'e.g. STU12345',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitStudentId,
                    child: const Text('Submit ID'),
                  ),
                ],
              ),
            ),
          if (!_showIdInput && exams.isEmpty)
            const Center(child: Text('No exams available')),
          if (!_showIdInput && exams.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final exam = exams[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    child: ListTile(
                      title: Text('${exam.subject} - ${exam.className}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (exam.teacherName != null)
                            Text('Teacher: ${exam.teacherName}'),
                          Text('Duration: ${exam.duration.inMinutes} min'),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'Take Exam') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => TakeExamScreen(
                                      subject: exam.subject,
                                      studentId: _enteredStudentId!,
                                    ),
                              ),
                            );
                          } else if (value == 'View Result') {
                            if (exam.id.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ExamResultScreen(
                                        examId: exam.id,
                                        studentId: _enteredStudentId!,
                                      ),
                                ),
                              );
                            }
                          }
                        },
                        itemBuilder:
                            (_) => const [
                              PopupMenuItem(
                                value: 'Take Exam',
                                child: Text('Take Exam'),
                              ),
                              PopupMenuItem(
                                value: 'View Result',
                                child: Text('View Result'),
                              ),
                            ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
