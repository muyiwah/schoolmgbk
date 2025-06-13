// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' hide Text;
// import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
// import 'package:provider/provider.dart';
// import 'exammodel.dart';
// import 'ques_provider.dart';

// class EditExamQuestionsScreen extends StatefulWidget {
//   final Exam exam;

//   const EditExamQuestionsScreen({super.key, required this.exam});

//   @override
//   State<EditExamQuestionsScreen> createState() =>
//       _EditExamQuestionsScreenState();
// }

// class _EditExamQuestionsScreenState extends State<EditExamQuestionsScreen> {
//   late QuillController _questionController;
//   final List<TextEditingController> _optionControllers = [];
//   late Question _currentQuestion;
//   String? _correctOptionId;
//   int _currentQuestionIndex = 0;
//   bool _isNewQuestion = false;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.exam.questions.isNotEmpty) {
//       _loadQuestion(0);
//     } else {
//       _initializeNewQuestion();
//     }
//   }

//   @override
//   void dispose() {
//     _questionController.dispose();
//     for (var c in _optionControllers) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   void _loadQuestion(int index) {
//     setState(() {
//       _currentQuestionIndex = index;
//       _currentQuestion = widget.exam.questions[index];
//       _isNewQuestion = false;
//     });

//     _questionController = QuillController(
//       document: Document.fromJson(_currentQuestion.deltaJson),
//       selection: const TextSelection.collapsed(offset: 0),
//     );

//     _optionControllers.forEach((c) => c.dispose());
//     _optionControllers.clear();

//     for (var option in _currentQuestion.options) {
//       _optionControllers.add(TextEditingController(text: option.text));
//     }

//     _correctOptionId = _currentQuestion.correctOptionId;
//   }

//   void _initializeNewQuestion() {
//     setState(() {
//       _currentQuestionIndex = widget.exam.questions.length;
//       _isNewQuestion = true;
//     });

//     _questionController = QuillController(
//       document: Document(),
//       selection: const TextSelection.collapsed(offset: 0),
//     );

//     _optionControllers.forEach((c) => c.dispose());
//     _optionControllers.clear();
//     _addOption();
//     _addOption();
//     _correctOptionId = null;
//   }

//   void _addOption() {
//     setState(() => _optionControllers.add(TextEditingController()));
//   }

//   void _removeOption(int index) {
//     setState(() {
//       if (_correctOptionId == 'opt${index + 1}') _correctOptionId = null;
//       _optionControllers[index].dispose();
//       _optionControllers.removeAt(index);
//     });
//   }

//   void _saveQuestion() {
//     if (_optionControllers.length < 2 || _correctOptionId == null) {
//       _showMessage(
//         'Please provide at least 2 options and select the correct one.',
//       );
//       return;
//     }

//     final plainText = _questionController.document.toPlainText().trim();
//     final delta = _questionController.document.toDelta().toJson();
//     if (plainText.isEmpty) {
//       _showMessage('Please enter the question text.');
//       return;
//     }

//     final options =
//         _optionControllers
//             .asMap()
//             .entries
//             .map(
//               (e) => Option(id: 'opt${e.key + 1}', text: e.value.text.trim()),
//             )
//             .toList();

//     final question = Question(
//       questionText: plainText,
//       deltaJson: delta,
//       options: options,
//       correctOptionId: _correctOptionId!,
//     );

//     Provider.of<QuestionProvider>(
//       context,
//       listen: false,
//     ).saveQuestion(_currentQuestionIndex, question, widget.exam.subject);

//     _showMessage('Question saved successfully');

//     if (_isNewQuestion) {
//       widget.exam.questions.add(question);
//       _loadQuestion(_currentQuestionIndex);
//     } else {
//       widget.exam.questions[_currentQuestionIndex] = question;
//     }
//   }

//   void _deleteQuestion() {
//     if (widget.exam.questions.isEmpty) return;

//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Delete Question'),
//             content: const Text(
//               'Are you sure you want to delete this question?',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   widget.exam.questions.removeAt(_currentQuestionIndex);
//                   // Provider.of<QuestionProvider>(
//                   //   context,
//                   //   listen: false,
//                   // ).saveQuestion(
//                   //   _currentQuestionIndex,
//                   //   Question(),
//                   //   widget.exam.subject,
//                   // );

//                   if (widget.exam.questions.isEmpty) {
//                     _initializeNewQuestion();
//                   } else {
//                     _loadQuestion(
//                       _currentQuestionIndex >= widget.exam.questions.length
//                           ? widget.exam.questions.length - 1
//                           : _currentQuestionIndex,
//                     );
//                   }
//                   Navigator.pop(context);
//                   _showMessage('Question deleted');
//                 },
//                 child: const Text('Delete'),
//               ),
//             ],
//           ),
//     );
//   }

//   void _showMessage(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   Widget _buildOptionInput(int index) {
//     final id = 'opt${index + 1}';
//     return Row(
//       children: [
//         Radio<String>(
//           value: id,
//           groupValue: _correctOptionId,
//           onChanged: (value) => setState(() => _correctOptionId = value),
//         ),
//         Expanded(
//           child: TextField(
//             controller: _optionControllers[index],
//             decoration: InputDecoration(
//               labelText: 'Option ${index + 1}',
//               suffixIcon: IconButton(
//                 icon: const Icon(Icons.clear),
//                 onPressed: () => _removeOption(index),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit ${widget.exam.subject} Questions'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _saveQuestion,
//             tooltip: 'Save Question',
//           ),
//           if (!_isNewQuestion)
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: _deleteQuestion,
//               tooltip: 'Delete Question',
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Card(
//               child: ListTile(
//                 title: Text(
//                   '${widget.exam.examType} for ${widget.exam.className}',
//                 ),
//                 subtitle: Text(
//                   '${widget.exam.subject} | ${widget.exam.term} Term | ${widget.exam.academicYear}\n'
//                   'Duration: ${widget.exam.duration.inMinutes} minutes | '
//                   'Questions: ${widget.exam.questions.length}',
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Question ${_currentQuestionIndex + 1} of ${widget.exam.questions.length + (_isNewQuestion ? 1 : 0)}',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 DropdownButton<int>(
//                   value: _currentQuestionIndex,
//                   items: [
//                     ...widget.exam.questions.asMap().entries.map(
//                       (e) => DropdownMenuItem(
//                         value: e.key,
//                         child: Text('Question ${e.key + 1}'),
//                       ),
//                     ),
//                     if (_isNewQuestion)
//                       const DropdownMenuItem(
//                         value: -1,
//                         child: Text('New Question'),
//                       ),
//                   ],
//                   onChanged: (value) {
//                     if (value == -1) {
//                       _initializeNewQuestion();
//                     } else {
//                       _loadQuestion(value!);
//                     }
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             QuillSimpleToolbar(
//               controller: _questionController,
//               config: QuillSimpleToolbarConfig(
//                 embedButtons: FlutterQuillEmbeds.toolbarButtons(),
//               ),
//             ),
//             Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: QuillEditor(
//                 scrollController: ScrollController(),
//                 controller: _questionController,
//                 focusNode: FocusNode(),
//                 config: QuillEditorConfig(
//                   padding: const EdgeInsets.all(8),
//                   autoFocus: true,
//                   expands: false,
//                   embedBuilders: FlutterQuillEmbeds.defaultEditorBuilders(),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Options:',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             ..._optionControllers.asMap().keys.map(_buildOptionInput).toList(),
//             const SizedBox(height: 10),
//             ElevatedButton.icon(
//               onPressed: _addOption,
//               icon: const Icon(Icons.add),
//               label: const Text('Add Option'),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ElevatedButton(
//                   onPressed:
//                       _currentQuestionIndex > 0 || _isNewQuestion
//                           ? () {
//                             if (_isNewQuestion && _currentQuestionIndex > 0) {
//                               _loadQuestion(_currentQuestionIndex - 1);
//                             } else if (_currentQuestionIndex > 0) {
//                               _loadQuestion(_currentQuestionIndex - 1);
//                             }
//                           }
//                           : null,
//                   child: const Text('Previous'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_currentQuestionIndex <
//                         widget.exam.questions.length - 1) {
//                       _loadQuestion(_currentQuestionIndex + 1);
//                     } else {
//                       _initializeNewQuestion();
//                     }
//                   },
//                   child: const Text('Next'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Finish Editing'),
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _initializeNewQuestion,
//         tooltip: 'Add New Question',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:provider/provider.dart';
import 'exammodel.dart';
import '../../providers/ques_provider.dart';

class EditExamQuestionsScreen extends StatefulWidget {
  final Exam exam;

  const EditExamQuestionsScreen({super.key, required this.exam});

  @override
  State<EditExamQuestionsScreen> createState() =>
      _EditExamQuestionsScreenState();
}

class _EditExamQuestionsScreenState extends State<EditExamQuestionsScreen> {
  late QuillController _questionController;
  final List<TextEditingController> _optionControllers = [];
  late Question _currentQuestion;
  String? _correctOptionId;
  int _currentQuestionIndex = 0;
  bool _isNewQuestion = false;

  @override
  void initState() {
    super.initState();
    if (widget.exam.questions.isNotEmpty) {
      _loadQuestion(0);
    } else {
      _initializeNewQuestion();
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _loadQuestion(int index) {
    setState(() {
      _currentQuestionIndex = index;
      _currentQuestion = widget.exam.questions[index];
      _isNewQuestion = false;
    });

    _questionController = QuillController(
      document: Document.fromJson(_currentQuestion.deltaJson),
      selection: const TextSelection.collapsed(offset: 0),
    );

    for (var c in _optionControllers) {
      c.dispose();
    }
    _optionControllers.clear();

    for (var option in _currentQuestion.options) {
      _optionControllers.add(TextEditingController(text: option.text));
    }

    _correctOptionId = _currentQuestion.correctOptionId;
  }

  void _loadQuestionAfterInsert(int index) {
    setState(() {
      _currentQuestionIndex = index;
      _currentQuestion = widget.exam.questions[index];
      _isNewQuestion = false;
    });

    // _questionController = QuillController(
    //   document: Document.fromJson(_currentQuestion.deltaJson),
    //   selection: const TextSelection.collapsed(offset: 0),
    // );

    for (var c in _optionControllers) {
      c.dispose();
    }
    _optionControllers.clear();

    for (var option in _currentQuestion.options) {
      _optionControllers.add(TextEditingController(text: option.text));
    }

    _correctOptionId = _currentQuestion.correctOptionId;
  }

  // void _initializeNewQuestion() {
  //   setState(() {
  //     _currentQuestionIndex = widget.exam.questions.length;
  //     _isNewQuestion = true;
  //     _currentQuestion = Question(
  //       questionText: ' ',
  //       options: [],
  //       correctOptionId: '',
  //       deltaJson: [],
  //     );
  //     // Initialize empty question
  //   });

  //   _questionController = QuillController(
  //     document: Document(),
  //     selection: const TextSelection.collapsed(offset: 0),
  //   );

  //   for (var c in _optionControllers) {
  //     c.dispose();
  //   }
  //   _optionControllers.clear();
  //   _addOption();
  //   _addOption();
  //   _correctOptionId = null;
  // }

  // void _insertNewQuestion() {
  //   // Save current question if it's not new
  //   if (!_isNewQuestion) {
  //     _saveQuestion();
  //   }

  //   // Create a new empty question at current position + 1
  //   final newQuestion = Question(
  //     questionText: '',
  //     options: [],
  //     correctOptionId: '',
  //     deltaJson: [],
  //   );
  //   widget.exam.questions.insert(_currentQuestionIndex + 1, newQuestion);
  //   widget.exam.questions.forEach((e) => print(e.questionText));
  //   // Load the newly inserted question
  //   _loadQuestion(_currentQuestionIndex + 1);
  // }
void _insertNewQuestion() {
    // Save current question if it's not new and has content
    if (!_isNewQuestion &&
        _questionController.document.toPlainText().trim().isNotEmpty) {
      _saveQuestion();
    }

    // Create a completely new empty question
    final newQuestion =
        Question.empty(); // Make sure you have this empty constructor

    // Insert at current position + 1
    widget.exam.questions.insert(_currentQuestionIndex + 1, newQuestion);

    // Load the new question and clear all fields
    _loadQuestion(_currentQuestionIndex + 1);

    // Force clear all fields
    _questionController = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );

    // Clear options
    for (var c in _optionControllers) {
      c.dispose();
    }
    _optionControllers.clear();
    _addOption();
    _addOption();
    _correctOptionId = null;

    setState(() {
      _isNewQuestion = true;
    });
  }

void _initializeNewQuestion() {
  setState(() {
      _currentQuestionIndex = widget.exam.questions.length;
      _isNewQuestion = true;
      _currentQuestion = Question.empty();
    });

    // Clear the editor
    _questionController = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );

    // Clear options
    for (var c in _optionControllers) {
      c.dispose();
    }
    _optionControllers.clear();

    // Add two default empty options
    _addOption();
    _addOption();
    _correctOptionId = null;
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

  void _saveQuestion() {
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
    ).saveQuestion(_currentQuestionIndex, question, widget.exam.subject);

    if (_isNewQuestion) {
      widget.exam.questions.add(question);
      _loadQuestion(_currentQuestionIndex);
    } else {
      widget.exam.questions[_currentQuestionIndex] = question;
    }

    _showMessage('Question saved successfully');
  }

  void _deleteCurrentQuestion() {
    if (widget.exam.questions.isEmpty) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Question'),
            content: const Text(
              'Are you sure you want to delete this question?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  widget.exam.questions.removeAt(_currentQuestionIndex);
                  // Provider.of<QuestionProvider>(
                  //   context,
                  //   listen: false,
                  // ).deleteQuestion(_currentQuestionIndex, widget.exam.subject);

                  if (widget.exam.questions.isEmpty) {
                    _initializeNewQuestion();
                  } else {
                    final newIndex =
                        _currentQuestionIndex >= widget.exam.questions.length
                            ? widget.exam.questions.length - 1
                            : _currentQuestionIndex;
                    _loadQuestion(newIndex);
                  }
                  Navigator.pop(context);
                  _showMessage('Question deleted');
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildOptionInput(int index) {
    final id = 'opt${index + 1}';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
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
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () => _removeOption(index),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions =
        widget.exam.questions.length + (_isNewQuestion ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.exam.subject} Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveQuestion,
            tooltip: 'Save Question',
          ),
          if (!_isNewQuestion)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCurrentQuestion,
              tooltip: 'Delete Question',
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _insertNewQuestion,
            tooltip: 'Insert New Question',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exam info card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.exam.examType} for ${widget.exam.className}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.exam.subject} | ${widget.exam.term} Term | ${widget.exam.academicYear}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Duration: ${widget.exam.duration.inMinutes} minutes | '
                      'Questions: ${widget.exam.questions.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Question navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentQuestionIndex + 1} of $totalQuestions',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                DropdownButton<int>(
                  value:
                      _currentQuestionIndex >= widget.exam.questions.length
                          ? -1
                          : _currentQuestionIndex,
                  items: [
                    ...widget.exam.questions.asMap().entries.map(
                      (e) => DropdownMenuItem(
                        value: e.key,
                        child: Text('Question ${e.key + 1}'),
                      ),
                    ),
                    if (_isNewQuestion)
                      const DropdownMenuItem(
                        value: -1,
                        child: Text('New Question'),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == -1) {
                      _initializeNewQuestion();
                    } else {
                      _loadQuestion(value!);
                    }
                  },
                ),
                // DropdownButton<int>(
                //   value: _currentQuestionIndex,
                //   items: [
                //     ...widget.exam.questions.asMap().entries.map(
                //       (e) => DropdownMenuItem(
                //         value: e.key,
                //         child: Text('Question ${e.key + 1}'),
                //       ),
                //     ),
                //     if (_isNewQuestion)
                //       const DropdownMenuItem(
                //         value: -1,
                //         child: Text('New Question'),
                //       ),
                //   ],
                //   onChanged: (value) {
                //     if (value == -1) {
                //       _initializeNewQuestion();
                //     } else {
                //       _loadQuestion(value!);
                //     }
                //   },
                // ),
              ],
            ),
            const SizedBox(height: 20),

            // Question editor
            Card(
              elevation: 2,
              child: Column(
                children: [
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
                        embedBuilders:
                            FlutterQuillEmbeds.defaultEditorBuilders(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Options section
            const Text(
              'Options:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ..._optionControllers.asMap().keys.map(_buildOptionInput).toList(),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Option'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 20),

            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed:
                      _currentQuestionIndex > 0 || _isNewQuestion
                          ? () {
                            if (_isNewQuestion && _currentQuestionIndex > 0) {
                              _loadQuestion(_currentQuestionIndex - 1);
                            } else if (_currentQuestionIndex > 0) {
                              _loadQuestion(_currentQuestionIndex - 1);
                            }
                          }
                          : null,
                  child: const Text('Previous'),
                ),
              // In your build method, update the Next button:
              ElevatedButton(
                  onPressed: () {
                    if (_currentQuestionIndex <
                        widget.exam.questions.length - 1) {
                      _loadQuestion(_currentQuestionIndex + 1);
                    } else {
                      _initializeNewQuestion();
                    }
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Finish button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Save any unsaved changes before exiting
                  if (_isNewQuestion &&
                      _questionController.document
                          .toPlainText()
                          .trim()
                          .isNotEmpty) {
                    _saveQuestion();
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Finish Editing'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _insertNewQuestion,
        tooltip: 'Insert New Question',
        child: const Icon(Icons.add),
      ),
    );
  }
}
