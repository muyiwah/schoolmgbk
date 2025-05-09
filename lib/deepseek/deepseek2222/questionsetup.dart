// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' hide Text;
// import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
// import 'package:schmgtsystem/deepseek/deepseek2222/exammodel.dart';
// import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
// import 'package:schmgtsystem/deepseek/deepseek2222/ques_provider.dart'; // 👈 This
// import 'package:provider/provider.dart';

// class QuestionSetupScreen extends StatefulWidget {
//   final String examType;
//   final String className;
//   final String subject;
//   final String term;
//   final String academicYear;
//   final Duration duration;

//   const QuestionSetupScreen({
//     super.key,
//     required this.examType,
//     required this.className,
//     required this.subject,
//     required this.term,
//     required this.academicYear,
//     required this.duration,
//   });

//   @override
//   State<QuestionSetupScreen> createState() => _QuestionSetupScreenState();
// }

// class _QuestionSetupScreenState extends State<QuestionSetupScreen> {
//   final List<Question> _questions = [];
//   String? _attachmentUrl;
//   late QuillController _questionController;
//   final List<TextEditingController> _optionControllers = [];
//   String? _correctOptionId;
//   int _currentQuestionIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _initializeController();
//     _addNewQuestion();
//   }

//   void _initializeController() {
//     _questionController = QuillController(
//       document: Document(),
//       selection: const TextSelection.collapsed(offset: 0),
//     );
//   }

//   void _addNewQuestion() {
//     _clearCurrentQuestion();
//     _questions.add(
//       Question(
//         questionText: '',
//         options: [],
//         correctOptionId: '',
//         deltaJson: '',
//       ),
//     );
//     _currentQuestionIndex = _questions.length - 1;
//   }

//   @override
//   void dispose() {
//     _questionController.dispose();
//     for (var controller in _optionControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Set Exam Questions'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.upload_file),
//             onPressed: _uploadAttachment,
//             tooltip: 'Upload Attachment',
//           ),
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _saveCurrentQuestion,
//             tooltip: 'Save Exam',
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildExamInfoCard(),
//             const SizedBox(height: 20),
//             _buildQuestionNumberIndicator(),
//             const SizedBox(height: 20),
//             _buildQuestionEditor(),
//             const SizedBox(height: 20),
//             _buildOptionsSection(),
//             const SizedBox(height: 20),
//             _buildNavigationButtons(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildExamInfoCard() {
//     return Card(
//       child: ListTile(
//         title: Text('${widget.examType} for ${widget.className}'),
//         subtitle: Text(
//           '${widget.subject} | ${widget.term} Term | ${widget.academicYear}\nDuration: ${widget.duration.inMinutes} minutes',
//         ),
//       ),
//     );
//   }

//   Widget _buildQuestionNumberIndicator() {
//     return Text(
//       'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
//       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//     );
//   }

//   Widget _buildQuestionEditor() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Question Text:',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         Card(
//           child: Column(
//             children: [
//               QuillSimpleToolbar(
//                 controller: _questionController,
//                 config: QuillSimpleToolbarConfig(
//                   embedButtons: FlutterQuillEmbeds.toolbarButtons(),
//                 ),
//               ),
//               Container(
//                 height: 200,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: QuillEditor(
//                   scrollController: ScrollController(),
//                   controller: _questionController,
//                   focusNode: FocusNode(),
//                   config: QuillEditorConfig(
//                     padding: const EdgeInsets.all(8),
//                     autoFocus: true,
//                     expands: false,
//                     embedBuilders:
//                         FlutterQuillEmbeds.defaultEditorBuilders(), // ✅ CORRECT METHOD
//                   ),
//                 ),
//                 // QuillEditor(
//                 //   controller: _questionController,
//                 //   focusNode: FocusNode(),
//                 //   scrollController: ScrollController(),
//                 //   // scrollable: true,
//                 //   // autoFocus: false,
//                 //   // readOnly: false,
//                 //   // expands: false,
//                 //   // padding: const EdgeInsets.all(8),
//                 //   // embedBuilders: FlutterQuillEmbeds.builders(),

//                 // ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOptionsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         ..._optionControllers.asMap().entries.map((entry) {
//           final index = entry.key;
//           final controller = entry.value;
//           final optionId = 'opt${index + 1}';
//           return Row(
//             children: [
//               Radio<String>(
//                 value: optionId,
//                 groupValue: _correctOptionId,
//                 onChanged: (value) {
//                   setState(() => _correctOptionId = value);
//                 },
//               ),
//               Expanded(
//                 child: TextField(
//                   controller: controller,
//                   decoration: InputDecoration(
//                     labelText: 'Option ${index + 1}',
//                     suffixIcon: IconButton(
//                       icon: const Icon(Icons.clear),
//                       onPressed: () => _removeOption(index),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         }),
//         const SizedBox(height: 10),
//         ElevatedButton.icon(
//           onPressed: _addOption,
//           icon: const Icon(Icons.add),
//           label: const Text('Add Option'),
//         ),
//       ],
//     );
//   }

//   Widget _buildNavigationButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         ElevatedButton(
//           onPressed: _currentQuestionIndex > 0 ? _goToPreviousQuestion : null,
//           child: const Text('Previous'),
//         ),
//         ElevatedButton(onPressed: _goToNextQuestion, child: const Text('Next')),
//       ],
//     );
//   }

//   void _addOption() {
//     setState(() {
//       _optionControllers.add(TextEditingController());
//     });
//   }

//   void _removeOption(int index) {
//     setState(() {
//       _optionControllers[index].dispose();
//       _optionControllers.removeAt(index);
//       if (_correctOptionId == 'opt${index + 1}') {
//         _correctOptionId = null;
//       }
//     });
//   }

//   void _clearCurrentQuestion() {
//     _questionController = QuillController(
//       document: Document(),
//       selection: const TextSelection.collapsed(offset: 0),
//     );
//     for (var controller in _optionControllers) {
//       controller.dispose();
//     }
//     _optionControllers.clear();
//     _correctOptionId = null;
//     _addOption();
//     _addOption();
//   }

//   void _goToPreviousQuestion() {
//     if (_currentQuestionIndex > 0) {
//       _saveCurrentQuestion();
//       _loadQuestion(_currentQuestionIndex - 1);
//     }
//   }

//   void _goToNextQuestion() {
//     _saveCurrentQuestion();
//     if (_currentQuestionIndex < _questions.length - 1) {
//       _loadQuestion(_currentQuestionIndex + 1);
//     } else {
//       _addNewQuestion();
//     }
//   }

//   void _loadQuestion(int index) {
//     setState(() {
//       _currentQuestionIndex = index;
//       final question = _questions[index];
//       _questionController = QuillController(
//         document: Document()..insert(0, question.questionText),
//         selection: const TextSelection.collapsed(offset: 0),
//       );

//       for (var controller in _optionControllers) {
//         controller.dispose();
//       }
//       _optionControllers.clear();
//       for (var option in question.options) {
//         _optionControllers.add(TextEditingController(text: option.text));
//       }
//       _correctOptionId = question.correctOptionId;
//     });
//   }

//   // void _saveCurrentQuestion() {
//   //   if (_optionControllers.length < 2) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text('Please add at least 2 options')),
//   //     );
//   //     return;
//   //   }

//   //   if (_correctOptionId == null) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text('Please select the correct option')),
//   //     );
//   //     return;
//   //   }

//   //   final questionText = _questionController.document.toPlainText().trim();
//   //   if (questionText.isEmpty) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text('Please enter the question text')),
//   //     );
//   //     return;
//   //   }

//   //   final options =
//   //       _optionControllers.asMap().entries.map((entry) {
//   //         final index = entry.key;
//   //         final controller = entry.value;
//   //         return Option(id: 'opt${index + 1}', text: controller.text.trim());
//   //       }).toList();

//   //   final correctOptionIndex = int.parse(_correctOptionId!.substring(3)) - 1;
//   //   final correctOptionId = options[correctOptionIndex].id;

//   //   final question = Question(
//   //     questionText: questionText,
//   //     options: options,
//   //     correctOptionId: correctOptionId,
//   //      deltaJson: ''
//   //   );

//   //   setState(() {
//   //     _questions[_currentQuestionIndex] = question;
//   //   });

//   //   ScaffoldMessenger.of(
//   //     context,
//   //   ).showSnackBar(const SnackBar(content: Text('Question saved')));
//   // }

//   void _uploadAttachment() {
//     // Implement file/image upload if needed
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Upload feature not implemented')),
//     );
//   }

//   void _saveCurrentQuestion() {
//     if (_optionControllers.length < 2) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please add at least 2 options')),
//       );
//       return;
//     }

//     if (_correctOptionId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select the correct option')),
//       );
//       return;
//     }

//     final plainText = _questionController.document.toPlainText().trim();
//     final deltaJson = _questionController.document.toDelta().toJson();

//     if (plainText.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter the question text')),
//       );
//       return;
//     }
//     print(deltaJson);
//     final options =
//         _optionControllers.asMap().entries.map((entry) {
//           final index = entry.key;
//           final controller = entry.value;
//           return Option(id: 'opt${index + 1}', text: controller.text.trim());
//         }).toList();

//     final correctOptionIndex = int.parse(_correctOptionId!.substring(3)) - 1;
//     final correctOptionId = options[correctOptionIndex].id;

//     final question = Question(
//       questionText: plainText,
//       deltaJson: deltaJson.toString(),
//       options: options,
//       correctOptionId: correctOptionId,
//     );

//     Provider.of<QuestionProvider>(
//       context,
//       listen: false,
//     ).saveQuestion(_currentQuestionIndex, question);

//     setState(() {
//       if (_currentQuestionIndex >= _questions.length) {
//         _questions.add(question);
//       } else {
//         _questions[_currentQuestionIndex] = question;
//       }
//     });

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Question saved')));
//   }
// }


// Refactored QuestionSetupScreen
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:provider/provider.dart';

import 'package:schmgtsystem/deepseek/deepseek2222/exammodel.dart';
import 'package:schmgtsystem/deepseek/deepseek2222/ques_provider.dart';

class QuestionSetupScreen extends StatefulWidget {
  final String examType;
  final String className;
  final String subject;
  final String term;
  final String academicYear;
  final Duration duration;

  const QuestionSetupScreen({
    super.key,
    required this.examType,
    required this.className,
    required this.subject,
    required this.term,
    required this.academicYear,
    required this.duration,
  });

  @override
  State<QuestionSetupScreen> createState() => _QuestionSetupScreenState();
}

class _QuestionSetupScreenState extends State<QuestionSetupScreen> {
  late QuillController _questionController;
  final List<TextEditingController> _optionControllers = [];
  final List<Question> _questions = [];
  String? _correctOptionId;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeNewQuestion();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _initializeNewQuestion() {
    _questionController = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _optionControllers.clear();
    _correctOptionId = null;
    _addOption();
    _addOption();
  }

  void _addOption() {
    setState(() => _optionControllers.add(TextEditingController()));
  }

  void _removeOption(int index) {
    setState(() {
      if (_correctOptionId == 'opt${index + 1}') _correctOptionId = null;
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  void _goToQuestion(int index) {
    _saveCurrentQuestion();
    final question = _questions[index];
    _questionController = QuillController(
      document: Document.fromJson(question.deltaJson),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _optionControllers.forEach((c) => c.dispose());
    _optionControllers.clear();
    for (var o in question.options) {
      _optionControllers.add(TextEditingController(text: o.text));
    }
    setState(() {
      _currentQuestionIndex = index;
      _correctOptionId = question.correctOptionId;
    });
  }

  void _saveCurrentQuestion() {
    if (_optionControllers.length < 2 || _correctOptionId == null) {
      _showMessage(
        'Please provide at least 2 options and select the correct one.',
      );
      return;
    }

    final plainText = _questionController.document.toPlainText().trim();
    final delta = _questionController.document.toDelta().toJson();
    if (plainText.isEmpty) {
      _showMessage('Please enter the question text.');
      return;
    }

    final options =
        _optionControllers
            .asMap()
            .entries
            .map(
              (e) => Option(id: 'opt${e.key + 1}', text: e.value.text.trim()),
            )
            .toList();

    final question = Question(
      questionText: plainText,
      deltaJson: delta,
      options: options,
      correctOptionId: _correctOptionId!,
    );

    Provider.of<QuestionProvider>(
      context,
      listen: false,
    ).saveQuestion(_currentQuestionIndex, question,widget.subject);

    if (_currentQuestionIndex < _questions.length) {
      _questions[_currentQuestionIndex] = question;
    } else {
      _questions.add(question);
    }

    _showMessage('Question saved.');
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildOptionInput(int index) {
    final id = 'opt${index + 1}';
    return Row(
      children: [
        Radio<String>(
          value: id,
          groupValue: _correctOptionId,
          onChanged: (value) => setState(() => _correctOptionId = value),
        ),
        Expanded(
          child: TextField(
            controller: _optionControllers[index],
            decoration: InputDecoration(
              labelText: 'Option ${index + 1}',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _removeOption(index),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Exam Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => _showMessage('Upload feature not implemented.'),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCurrentQuestion,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                title: Text('${widget.examType} for ${widget.className}'),
                subtitle: Text(
                  '${widget.subject} | ${widget.term} Term | ${widget.academicYear}\nDuration: ${widget.duration.inMinutes} minutes',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            QuillSimpleToolbar(
              controller: _questionController,
              config: QuillSimpleToolbarConfig(
                embedButtons: FlutterQuillEmbeds.toolbarButtons(),
              ),
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: QuillEditor(
                scrollController: ScrollController(),
                controller: _questionController,
                focusNode: FocusNode(),
                config: QuillEditorConfig(
                  padding: const EdgeInsets.all(8),
                  autoFocus: true,
                  expands: false,
                  embedBuilders: FlutterQuillEmbeds.defaultEditorBuilders(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Options:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._optionControllers.asMap().keys.map(_buildOptionInput).toList(),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add),
              label: const Text('Add Option'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed:
                      _currentQuestionIndex > 0
                          ? () => _goToQuestion(_currentQuestionIndex - 1)
                          : null,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _saveCurrentQuestion();
                    if (_currentQuestionIndex < _questions.length - 1) {
                      _goToQuestion(_currentQuestionIndex + 1);
                    } else {
                      _initializeNewQuestion();
                      setState(() => _currentQuestionIndex = _questions.length);
                    }
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
