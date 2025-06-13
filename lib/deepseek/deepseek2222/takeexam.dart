// // import 'dart:async';
// // import 'dart:convert';

// // import 'package:flutter/material.dart';
// // import 'package:flutter_quill/flutter_quill.dart' hide Text;
// // import 'package:flutter_quill/quill_delta.dart';
// // import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
// // import 'package:provider/provider.dart';

// // import '../../deepseek/deepseek2222/exammodel.dart';
// // import '../../deepseek/deepseek2222/ques_provider.dart';

// // class TakeExamScreen extends StatefulWidget {
// //   const TakeExamScreen({super.key});

// //   @override
// //   State<TakeExamScreen> createState() => _TakeExamScreenState();
// // }

// // class _TakeExamScreenState extends State<TakeExamScreen> {
// //   Timer? _timer;
// //   late Duration _remainingTime;
// //   final Map<String, String> _answers = {};
// //   int _currentQuestionIndex = 0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     final exam = context.read<QuestionProvider>().selectedExam;
// //     _remainingTime = exam.duration;
// //     _startTimer();
// //   }

// //   @override
// //   void dispose() {
// //     _timer?.cancel();
// //     super.dispose();
// //   }

// //   void _startTimer() {
// //     _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
// //       if (_remainingTime.inSeconds > 0) {
// //         setState(() {
// //           _remainingTime -= const Duration(seconds: 1);
// //         });
// //       } else {
// //         _timer?.cancel();
// //         _submitExam();
// //       }
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final exam = context.watch<QuestionProvider>().selectedExam;

// //     if (exam.questions.isEmpty) {
// //       return const Scaffold(
// //         body: Center(child: Text("No questions available.")),
// //       );
// //     }

// //     final currentQuestion = exam.questions[_currentQuestionIndex];
// //     final selectedOptionId = _answers[currentQuestion.id];

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('${exam.subject} Exam'),
// //         actions: [
// //           Padding(
// //             padding: const EdgeInsets.all(12.0),
// //             child: Center(
// //               child: Text(
// //                 '${_remainingTime.inMinutes}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
// //                 style: const TextStyle(
// //                   fontSize: 16,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             _buildProgressIndicator(exam),
// //             const SizedBox(height: 20),
// //             _buildQuestion(currentQuestion, exam),
// //             const SizedBox(height: 20),
// //             _buildOptions(currentQuestion, selectedOptionId),
// //             const Spacer(),
// //             _buildNavigation(exam),
// //           ],
// //         ),
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: _submitExam,
// //         child: const Icon(Icons.done),
// //       ),
// //     );
// //   }

// //   Widget _buildProgressIndicator(Exam exam) {
// //     return LinearProgressIndicator(
// //       value: (_currentQuestionIndex + 1) / exam.questions.length,
// //       minHeight: 8,
// //     );
// //   }

// //   Widget _buildQuestion(Question question, Exam exam) {
// //     final delta = Delta.fromJson(question.deltaJson);
// //     final controller = QuillController(
// //       document: Document.fromDelta(delta),
// //       selection: const TextSelection.collapsed(offset: 0),
// //     );

// //     return Card(
// //       elevation: 2,
// //       child: Padding(
// //         padding: const EdgeInsets.all(12.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               'Question ${_currentQuestionIndex + 1} of ${exam.questions.length}',
// //               style: Theme.of(context).textTheme.titleMedium,
// //             ),
// //             const Divider(),
// //             QuillEditor(
// //               controller: controller,
// //               focusNode: FocusNode(),
// //               scrollController: ScrollController(),
// //               config: const QuillEditorConfig(
// //                 showCursor: false,
// //                 padding: EdgeInsets.zero,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildOptions(Question question, String? selectedOptionId) {
// //     return Column(
// //       children:
// //           question.options.map((option) {
// //             return Card(
// //               child: RadioListTile<String>(
// //                 title: Text(option.text),
// //                 value: option.id,
// //                 groupValue: selectedOptionId,
// //                 onChanged: (value) {
// //                   setState(() {
// //                     _answers[question.id] = value!;
// //                   });
// //                 },
// //               ),
// //             );
// //           }).toList(),
// //     );
// //   }

// //   Widget _buildNavigation(Exam exam) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         ElevatedButton(
// //           onPressed:
// //               _currentQuestionIndex > 0
// //                   ? () {
// //                     setState(() {
// //                       _currentQuestionIndex--;
// //                     });
// //                   }
// //                   : null,
// //           child: const Text("Previous"),
// //         ),
// //         ElevatedButton(
// //           onPressed:
// //               _currentQuestionIndex < exam.questions.length - 1
// //                   ? () {
// //                     setState(() {
// //                       _currentQuestionIndex++;
// //                     });
// //                   }
// //                   : null,
// //           child: const Text("Next"),
// //         ),
// //       ],
// //     );
// //   }

// //   void _submitExam() {
// //     final exam = context.read<QuestionProvider>().selectedExam;
// //     int score = 0;

// //     for (final question in exam.questions) {
// //       if (_answers[question.id] == question.correctOptionId) {
// //         score++;
// //       }
// //     }

// //     final result = ExamResult(
// //       examId: exam.id,
// //       studentId: 'student123',
// //       studentName: 'John Doe',
// //       score: score,
// //       totalQuestions: exam.questions.length,
// //       answers: _answers,
// //     );

// //     print(result.toMap());

// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder:
// //           (_) => AlertDialog(
// //             title: const Text('Exam Submitted'),
// //             content: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Text('Score: $score / ${exam.questions.length}'),
// //                 Text(
// //                   'Percentage: ${(score / exam.questions.length * 100).toStringAsFixed(1)}%',
// //                 ),
// //                 const SizedBox(height: 10),
// //                 const Text('Thank you for completing the exam.'),
// //               ],
// //             ),
// //             actions: [
// //               TextButton(
// //                 onPressed: () {
// //                   Navigator.of(context).pop();
// //                   Navigator.of(context).pop();
// //                 },
// //                 child: const Text('OK'),
// //               ),
// //             ],
// //           ),
// //     );
// //   }
// // }

// // Full updated screen with new features:
// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' hide Text;
// import 'package:flutter_quill/quill_delta.dart';
// import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../deepseek/deepseek2222/exammodel.dart';
// import '../../deepseek/deepseek2222/ques_provider.dart';

// class TakeExamScreen extends StatefulWidget {
//   TakeExamScreen({super.key, required this.subject});
//   final String subject;

//   @override
//   State<TakeExamScreen> createState() => _TakeExamScreenState();
// }

// class _TakeExamScreenState extends State<TakeExamScreen> {
//   Timer? _timer;
//   late Duration _remainingTime;
//   Map<String, String> _answers = {};
//   int _currentQuestionIndex = 0;
//   Exam? exam;
//   final _switcherKey = GlobalKey();

//   @override
//   void didChangeDependencies() {
//     print('hererrer');
//     super.didChangeDependencies();
//     exam = Provider.of<QuestionProvider>(
//       context,
//     ).allExams.firstWhere((Exam exam) => exam.subject == widget.subject);
//     // final exam = context.read<QuestionProvider>().selectedExam;
//     _remainingTime = exam!.duration;
//     print(exam!.questions);
//     setState(() {});
//     _restoreProgress();
//     _startTimer();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   Future<void> _restoreProgress() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedIndex = prefs.getInt('questionIndex');
//     final savedAnswers = prefs.getString('savedAnswers');

//     setState(() {
//       if (savedIndex != null) _currentQuestionIndex = savedIndex;
//       if (savedAnswers != null) {
//         _answers = Map<String, String>.from(jsonDecode(savedAnswers));
//       }
//     });
//   }

//   Future<void> _saveProgress() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('questionIndex', _currentQuestionIndex);
//     await prefs.setString('savedAnswers', jsonEncode(_answers));
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (_remainingTime.inSeconds > 0) {
//         setState(() {
//           _remainingTime -= const Duration(seconds: 1);
//         });
//       } else {
//         _timer?.cancel();
//         _submitExam();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final exam = context.watch<QuestionProvider>().selectedExam;

//     if (exam!.questions.isEmpty) {
//       return Scaffold(
//         body: GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Center(child: Text("No questions available.")),
//         ),
//       );
//     }

//     final currentQuestion = exam!.questions[_currentQuestionIndex];
//     final selectedOptionId = _answers[currentQuestion.id];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${exam!.subject} Exam'),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Center(
//               child: Text(
//                 '${_remainingTime.inMinutes}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildProgressIndicator(exam!),
//             const SizedBox(height: 16),
//             Expanded(
//               child: AnimatedSwitcher(
//                 key: _switcherKey,
//                 duration: const Duration(milliseconds: 300),
//                 child: _buildQuestion(currentQuestion, selectedOptionId),
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildNavigation(exam!),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _submitExam,
//         child: const Icon(Icons.done),
//       ),
//     );
//   }

//   Widget _buildProgressIndicator(Exam exam) {
//     return LinearProgressIndicator(
//       value: (_currentQuestionIndex + 1) / exam.questions.length,
//       minHeight: 8,
//     );
//   }

//   Widget _buildQuestion(Question question, String? selectedOptionId) {
//     final delta = Delta.fromJson((question.deltaJson));
//     final controller = QuillController(
//       document: Document.fromDelta(delta),
//       selection: const TextSelection.collapsed(offset: 0),
//     );

//     return Card(
//       key: ValueKey(question.id),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: ListView(
//           children: [
//             Text(
//               'Question ${_currentQuestionIndex + 1}',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const Divider(),
//             QuillEditor(
//               controller: controller,
//               focusNode: FocusNode(),
//               scrollController: ScrollController(),
//               config: const QuillEditorConfig(
//                 showCursor: false,
//                 padding: EdgeInsets.zero,
//               ),
//             ),
//             if (question.mediaUrl != null && question.mediaUrl!.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 12),
//                 child: _buildMedia(question.mediaUrl!),
//               ),
//             if (question.mediaUrl != null && question.mediaUrl!.isNotEmpty)
//               const SizedBox(height: 16),
//             if (question.mediaUrl != null &&
//                 question.mediaUrl!.endsWith('.mp3'))
//               _buildAudioPlayer(question.mediaUrl!)
//             else if (question.mediaUrl != null)
//               Image.network(question.mediaUrl!),
//             const SizedBox(height: 20),
//             ...question.options.map(
//               (option) => Card(
//                 child: RadioListTile<String>(
//                   title: Text(option.text),
//                   value: option.id,
//                   groupValue: selectedOptionId,
//                   onChanged: (value) {
//                     setState(() {
//                       _answers[question.id] = value!;
//                       _saveProgress();
//                     });
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMedia(String url) {
//     final isImage =
//         url.endsWith('.png') || url.endsWith('.jpg') || url.endsWith('.jpeg');
//     final isAudio = url.endsWith('.mp3') || url.endsWith('.wav');
//     final isVideo = url.endsWith('.mp4') || url.endsWith('.mov');

//     if (isImage) {
//       return Image.network(url, fit: BoxFit.cover);
//     } else if (isAudio) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Audio:', style: TextStyle(fontWeight: FontWeight.bold)),
//           // SizedBox(
//           //   height: 60,
//           //   child: AudioPlayerWidget(
//           //     url: url,
//           //   ), // You'll need a widget like `just_audio`
//           // ),
//         ],
//       );
//     } else if (isVideo) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Video:', style: TextStyle(fontWeight: FontWeight.bold)),
//           // SizedBox(
//           //   height: 200,
//           //   child: VideoPlayerWidget(url: url), // Use `video_player` package
//           // ),
//         ],
//       );
//     }

//     return const SizedBox.shrink(); // fallback
//   }

//   Widget _buildAudioPlayer(String url) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Audio attached:"),
//         const SizedBox(height: 4),
//         Text(url, style: const TextStyle(color: Colors.blue)),
//         // You can integrate a real audio player (e.g., just_audio) here
//       ],
//     );
//   }

//   Widget _buildNavigation(Exam exam) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         ElevatedButton(
//           onPressed:
//               _currentQuestionIndex > 0
//                   ? () {
//                     setState(() {
//                       _currentQuestionIndex--;
//                       _saveProgress();
//                     });
//                   }
//                   : null,
//           child: const Text("Previous"),
//         ),
//         ElevatedButton(
//           onPressed:
//               _currentQuestionIndex < exam.questions.length - 1
//                   ? () {
//                     setState(() {
//                       _currentQuestionIndex++;
//                       _saveProgress();
//                     });
//                   }
//                   : null,
//           child: const Text("Next"),
//         ),
//       ],
//     );
//   }

//   void _submitExam() async {
//     final exam = context.read<QuestionProvider>().selectedExam;
//     int score = 0;

//     for (final question in exam.questions) {
//       if (_answers[question.id] == question.correctOptionId) {
//         score++;
//       }
//     }

//     final result = ExamResult(
//       examId: exam.id,
//       studentId: 'student123',
//       studentName: 'John Doe',
//       score: score,
//       totalQuestions: exam.questions.length,
//       answers: _answers,
//     );

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('questionIndex');
//     await prefs.remove('savedAnswers');

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (_) => AlertDialog(
//             title: const Text('Exam Submitted'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text('Score: $score / ${exam.questions.length}'),
//                 Text(
//                   'Percentage: ${(score / exam.questions.length * 100).toStringAsFixed(1)}%',
//                 ),
//                 const SizedBox(height: 10),
//                 const Text('Thank you for completing the exam.'),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//     );
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/quill_delta.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'exammodel.dart';
import '../../providers/ques_provider.dart';

class TakeExamScreen extends StatefulWidget {
  final String subject;
   final String studentId;
  const TakeExamScreen({super.key, required this.subject,
    required this.studentId,
  });

  @override
  State<TakeExamScreen> createState() => _TakeExamScreenState();
}

class _TakeExamScreenState extends State<TakeExamScreen> {
  Timer? _timer;
  late Duration _remainingTime;
  Map<String, String> _answers = {};
  int _currentQuestionIndex = 0;
  Exam? _exam;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeExam();
  }

  Future<void> _initializeExam() async {
    try {
      final provider = Provider.of<QuestionProvider>(context, listen: false);
      _exam = provider.allExams.firstWhere(
        (Exam exam) => exam.subject == widget.subject,
      );

      if (_exam != null) {
        _remainingTime = _exam!.duration;
        await _restoreProgress();
        _startTimer();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('questionIndex');
    final savedAnswers = prefs.getString('savedAnswers');

    setState(() {
      if (savedIndex != null) _currentQuestionIndex = savedIndex;
      if (savedAnswers != null) {
        _answers = Map<String, String>.from(jsonDecode(savedAnswers));
      }
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('questionIndex', _currentQuestionIndex);
    await prefs.setString('savedAnswers', jsonEncode(_answers));
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() => _remainingTime -= const Duration(seconds: 1));
      } else {
        _timer?.cancel();
        _submitExam();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_exam == null || _exam!.questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("No questions available."),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _exam!.questions[_currentQuestionIndex];
    final selectedOptionId = _answers[currentQuestion.id];

    return Scaffold(
      appBar: AppBar(
        title: Text('${_exam!.subject} Exam'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: Text(
                '${_remainingTime.inMinutes}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _exam!.questions.length,
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildQuestion(currentQuestion, selectedOptionId)),
            const SizedBox(height: 16),
            _buildNavigation(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitExam,
        child: const Icon(Icons.done),
      ),
    );
  }

  Widget _buildQuestion(Question question, String? selectedOptionId) {
    final delta = Delta.fromJson((question.deltaJson));
    final controller = QuillController(
      document: Document.fromDelta(delta),
      selection: const TextSelection.collapsed(offset: 0),
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${_exam!.questions.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(),
                  QuillEditor(
              controller: controller,
              focusNode: FocusNode(),
              scrollController: ScrollController(),
              config: const QuillEditorConfig(
                showCursor: false,
                padding: EdgeInsets.zero,
              ),
            ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...question.options.map(
            (option) => Card(
              child: RadioListTile<String>(
                title: Text(option.text),
                value: option.id,
                groupValue: selectedOptionId,
                onChanged: (value) {
                  setState(() {
                    _answers[question.id] = value!;
                    _saveProgress();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed:
              _currentQuestionIndex > 0
                  ? () {
                    setState(() {
                      _currentQuestionIndex--;
                      _saveProgress();
                    });
                  }
                  : null,
          child: const Text("Previous"),
        ),
        ElevatedButton(
          onPressed:
              _currentQuestionIndex < _exam!.questions.length - 1
                  ? () {
                    setState(() {
                      _currentQuestionIndex++;
                      _saveProgress();
                    });
                  }
                  : null,
          child: const Text("Next"),
        ),
      ],
    );
  }

  Future<void> _submitExam() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('questionIndex');
    await prefs.remove('savedAnswers');

    int score = 0;
    for (final question in _exam!.questions) {
      if (_answers[question.id] == question.correctOptionId) {
        score++;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text('Exam Submitted'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Score: $score / ${_exam!.questions.length}'),
                Text(
                  'Percentage: ${(score / _exam!.questions.length * 100).toStringAsFixed(1)}%',
                ),
                const SizedBox(height: 10),
                const Text('Thank you for completing the exam.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
