// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:schmgtsystem/deepseek/deepseek2222/exammodel.dart';
// import 'package:schmgtsystem/deepseek/deepseek2222/exanlist.dart';
// import 'package:schmgtsystem/deepseek/deepseek2222/ques_provider.dart';
// import 'package:schmgtsystem/deepseek/deepseek2222/questionsetup.dart';
// import 'package:schmgtsystem/deepseek/deepseek2222/takeexam.dart';

// class ExamSetupScreen extends StatefulWidget {
//   const ExamSetupScreen({super.key});

//   @override
//   State<ExamSetupScreen> createState() => _ExamSetupScreenState();
// }

// class _ExamSetupScreenState extends State<ExamSetupScreen> {
//   final _formKey = GlobalKey<FormState>();

//   String? _examType;
//   String? _className;
//   String? _subject;
//   String? _term;
//   String? _academicYear;
//   int _durationMinutes = 60;

//   final List<String> examTypes = ['Quiz', 'Mid-Term', 'Final'];
//   final List<String> classes = ['JSS1', 'JSS2', 'JSS3', 'SS1', 'SS2', 'SS3'];
//   final List<String> subjects = [
//     'Mathematics',
//     'English',
//     'Physics',
//     'Chemistry',
//     'Biology',
//     'Geography',
//   ];
//   final List<String> terms = ['First Term', 'Second Term', 'Third Term'];
//   final List<String> academicYears = ['2022/2023', '2023/2024', '2024/2025'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Create New Exam')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               _buildDropdown(
//                 label: 'Exam Type',
//                 value: _examType,
//                 items: examTypes,
//                 onChanged: (val) => setState(() => _examType = val),
//                 validatorMsg: 'Please select exam type',
//               ),
//               const SizedBox(height: 16),
//               _buildDropdown(
//                 label: 'Class',
//                 value: _className,
//                 items: classes,
//                 onChanged: (val) => setState(() => _className = val),
//                 validatorMsg: 'Please select class',
//               ),
//               const SizedBox(height: 16),
//               _buildDropdown(
//                 label: 'Subject',
//                 value: _subject,
//                 items: subjects,
//                 onChanged: (val) => setState(() => _subject = val),
//                 validatorMsg: 'Please select subject',
//               ),
//               const SizedBox(height: 16),
//               _buildDropdown(
//                 label: 'Term',
//                 value: _term,
//                 items: terms,
//                 onChanged: (val) => setState(() => _term = val),
//                 validatorMsg: 'Please select term',
//               ),
//               const SizedBox(height: 16),
//               _buildDropdown(
//                 label: 'Academic Year',
//                 value: _academicYear,
//                 items: academicYears,
//                 onChanged: (val) => setState(() => _academicYear = val),
//                 validatorMsg: 'Please select academic year',
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 decoration: const InputDecoration(
//                   labelText: 'Duration (minutes)',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//                 initialValue: _durationMinutes.toString(),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter duration';
//                   }
//                   final minutes = int.tryParse(value);
//                   if (minutes == null || minutes <= 0) {
//                     return 'Please enter a valid duration';
//                   }
//                   return null;
//                 },
//                 onChanged: (value) {
//                   _durationMinutes = int.tryParse(value) ?? 60;
//                 },
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: saveExam,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: const Text('Save Exam'),
//                 ),
//               ),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _proceedToQuestions,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: const Text('Proceed to Questions'),
//                 ),
//               ),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ExamListScreen(studentId: '124'),
//                         // TakeExamScreen(),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: const Text('Exam list'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown({
//     required String label,
//     required String? value,
//     required List<String> items,
//     required Function(String?) onChanged,
//     required String validatorMsg,
//   }) {
//     return DropdownButtonFormField<String>(
//       decoration: InputDecoration(
//         labelText: label,
//         border: const OutlineInputBorder(),
//       ),
//       value: value,
//       items:
//           items
//               .map((item) => DropdownMenuItem(value: item, child: Text(item)))
//               .toList(),
//       onChanged: onChanged,
//       validator: (val) => val == null ? validatorMsg : null,
//     );
//   }

//   saveExam() {
//     if (_formKey.currentState!.validate()) {
//       Provider.of<QuestionProvider>(context,listen: false).setExam(
//         Exam(
//           examType: _examType.toString(),
//           className: _className.toString(),
//           subject: _subject.toString(),
//           term: _term.toString(),
//           academicYear: _academicYear.toString(),
//           duration: Duration(minutes: _durationMinutes),
//           questions: [],
//           teacherId: '',
//         ),
//       );
//     }
//   }

//   void _proceedToQuestions() {
//     if (_formKey.currentState!.validate()) {
//       // Provider.of<QuestionProvider>(context).setExam(
//       //   Exam(
//       //     examType: _examType.toString(),
//       //     className: _className.toString(),
//       //     subject: _subject.toString(),
//       //     term: _term.toString(),
//       //     academicYear: _academicYear.toString(),
//       //     duration: Duration(minutes: _durationMinutes),
//       //     questions: [],
//       //     teacherId: '',
//       //   ),
//       // );
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder:
//               (_) => QuestionSetupScreen(
//                 examType: _examType!,
//                 className: _className!,
//                 subject: _subject!,
//                 term: _term!,
//                 academicYear: _academicYear!,
//                 duration: Duration(minutes: _durationMinutes),
//               ),
//         ),
//       );
//     }
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schmgtsystem/deepseek/deepseek2222/exanlist.dart';
import 'exammodel.dart';
import '../../providers/ques_provider.dart';
import 'questionsetup.dart';

class ExamSetupScreen extends StatefulWidget {
  const ExamSetupScreen({super.key});

  @override
  State<ExamSetupScreen> createState() => _ExamSetupScreenState();
}

class _ExamSetupScreenState extends State<ExamSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _examType;
  String? _className;
  String? _subject;
  String? _term;
  String? _academicYear;
  int _durationMinutes = 60;

  final List<String> examTypes = ['Quiz', 'Mid-Term', 'Final'];
  final List<String> classes = ['JSS1', 'JSS2', 'JSS3', 'SS1', 'SS2', 'SS3'];
  final List<String> subjects = [
    'Mathematics',
    'English',
    'Physics',
    'Chemistry',
    'Biology',
    'Geography',
  ];
  final List<String> terms = ['First Term', 'Second Term', 'Third Term'];
  final List<String> academicYears = ['2022/2023', '2023/2024', '2024/2025'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Exam')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDropdown(
                label: 'Exam Type',
                value: _examType,
                items: examTypes,
                onChanged: (val) => setState(() => _examType = val),
                validatorMsg: 'Please select exam type',
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Class',
                value: _className,
                items: classes,
                onChanged: (val) => setState(() => _className = val),
                validatorMsg: 'Please select class',
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Subject',
                value: _subject,
                items: subjects,
                onChanged: (val) => setState(() => _subject = val),
                validatorMsg: 'Please select subject',
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Term',
                value: _term,
                items: terms,
                onChanged: (val) => setState(() => _term = val),
                validatorMsg: 'Please select term',
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: 'Academic Year',
                value: _academicYear,
                items: academicYears,
                onChanged: (val) => setState(() => _academicYear = val),
                validatorMsg: 'Please select academic year',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                initialValue: _durationMinutes.toString(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter duration';
                  }
                  final minutes = int.tryParse(value);
                  if (minutes == null || minutes <= 0) {
                    return 'Please enter a valid duration';
                  }
                  return null;
                },
                onChanged: (value) {
                  _durationMinutes = int.tryParse(value) ?? 60;
                },
              ),
              // const SizedBox(height: 24),
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: saveExam,
              //     child: const Text('Save Exam'),
              //   ),
              // ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _proceedToQuestions,
                  child: const Text('Proceed to Questions'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExamListScreen(),
                      ),
                    );
                  },
                  child: const Text('Exam list'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String validatorMsg,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: value,
      items:
          items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? validatorMsg : null,
    );
  }

  void saveExam() {
    if (_formKey.currentState!.validate()) {
      final newExam = Exam(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        examType: _examType!,
        className: _className!,
        subject: _subject!,
        term: _term!,
        academicYear: _academicYear!,
        duration: Duration(minutes: _durationMinutes),
        questions: [],
        teacherId: 'teacher123',
        teacherName: 'Teacher Name',
      );

      Provider.of<QuestionProvider>(context, listen: false).setExam(newExam);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Exam saved successfully')));
    }
  }

  void _proceedToQuestions() {
    if (_formKey.currentState!.validate()) {
      final exam = Exam(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        examType: _examType!,
        className: _className!,
        subject: _subject!,
        term: _term!,
        academicYear: _academicYear!,
        duration: Duration(minutes: _durationMinutes),
        questions: [],
        teacherId: 'teacher123',
        teacherName: 'Teacher Name',
      );

      Provider.of<QuestionProvider>(context, listen: false).setExam(exam);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => QuestionSetupScreen(
                examType: _examType!,
                className: _className!,
                subject: _subject!,
                term: _term!,
                academicYear: _academicYear!,
                duration: Duration(minutes: _durationMinutes),
              ),
        ),
      );
    }
  }
}
