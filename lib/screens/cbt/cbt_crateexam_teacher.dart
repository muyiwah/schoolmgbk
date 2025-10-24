import 'package:flutter/material.dart';


class CBTExamCreatorPage extends StatefulWidget {
  const CBTExamCreatorPage({super.key});

  @override
  State<CBTExamCreatorPage> createState() => _CBTExamCreatorPageState();
}

class _CBTExamCreatorPageState extends State<CBTExamCreatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _examTitleController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _durationController = TextEditingController(text: '45');

  String _selectedSubject = 'Select Subject';
  String _selectedClass = 'Select Class';
  String _selectedTerm = 'Select Term';
  String _selectedAcademicYear = '2024/2025';

  int _currentStep = 0;
  List<ExamQuestion> _questions = [];
  bool _showQuestionSuccess = false;

  @override
  void initState() {
    super.initState();
    _examTitleController.text = 'Midterm Test - Algebra';
    _instructionsController.text = 'Enter exam instructions for students...';

    // Add sample questions
    _questions = [
      ExamQuestion(
        id: 1,
        type: QuestionType.multipleChoice,
        text: 'What is the square root of 144?',
        marks: 5,
        difficulty: Difficulty.easy,
        options: ['10', '12', '14', '16'],
        correctAnswer: 1,
      ),
      ExamQuestion(
        id: 2,
        type: QuestionType.trueFalse,
        text: '',
        marks: 3,
        difficulty: Difficulty.easy,
      ),
      ExamQuestion(
        id: 3,
        type: QuestionType.essay,
        text: '',
        marks: 10,
        difficulty: Difficulty.easy,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.school, color: Colors.blue),
        title: const Text(
          'CBT Exam Creator',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExamSetupSection(),
            const SizedBox(height: 32),
            _buildAddQuestionsSection(),
            const SizedBox(height: 32),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildExamSetupSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Exam Setup',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          'Subject',
                          _selectedSubject,
                          [
                            'Select Subject',
                            'Mathematics',
                            'English',
                            'Science',
                          ],
                          (value) => setState(() => _selectedSubject = value!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          'Class',
                          _selectedClass,
                          [
                            'Select Class',
                            'JSS 1',
                            'JSS 2',
                            'JSS 3',
                            'SS 1',
                            'SS 2',
                            'SS 3',
                          ],
                          (value) => setState(() => _selectedClass = value!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          'Term',
                          _selectedTerm,
                          [
                            'Select Term',
                            'First Term',
                            'Second Term',
                            'Third Term',
                          ],
                          (value) => setState(() => _selectedTerm = value!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          'Academic Year',
                          _selectedAcademicYear,
                          ['2024/2025', '2023/2024', '2022/2023'],
                          (value) =>
                              setState(() => _selectedAcademicYear = value!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextFieldWithLabel(
                          'Exam Title',
                          _examTitleController,
                          'e.g., Midterm Test - Algebra',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextFieldWithLabel(
                          'Duration (minutes)',
                          _durationController,
                          '45',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTextFieldWithLabel(
                    'Instructions',
                    _instructionsController,
                    'Enter exam instructions for students...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 1;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save & Continue to Questions'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddQuestionsSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Add Questions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add new question logic
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Question'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildQuestionsOverview()),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _buildQuestionEditor()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsOverview() {
    int totalMarks = _questions.fold(
      0,
      (sum, question) => sum + question.marks,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Questions Overview',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          '${_questions.length} Questions',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ..._questions.map((question) => _buildQuestionOverviewItem(question)),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Questions:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              '${_questions.length}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Marks:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              '$totalMarks',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionOverviewItem(ExamQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${question.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                '${question.marks} marks',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            question.type.displayName,
            style: const TextStyle(fontSize: 11, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionEditor() {
    if (_questions.isEmpty) return const SizedBox();

    ExamQuestion currentQuestion =
        _questions[0]; // Show first question for demo

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Question 1',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 16),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.copy_outlined, size: 16),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 16),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDropdown('Question Type', 'Multiple Choice', [
                'Multiple Choice',
                'True/False',
                'Essay',
              ], (value) {}),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: _buildTextFieldWithLabel(
                'Marks',
                TextEditingController(text: '5'),
                '5',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown('Difficulty', 'Easy', [
                'Easy',
                'Medium',
                'Hard',
              ], (value) {}),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextFieldWithLabel(
          'Question Text',
          TextEditingController(text: currentQuestion.text),
          'Enter your question here...',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const Text(
          'Options',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...currentQuestion.options.asMap().entries.map((entry) {
          int index = entry.key;
          String option = entry.value;
          return _buildOptionField(
            String.fromCharCode(65 + index),
            option,
            index == currentQuestion.correctAnswer,
          );
        }),
        const SizedBox(height: 16),
        _buildAttachmentSection(),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showQuestionSuccess = true;
            });
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                _showQuestionSuccess = false;
              });
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Save Question'),
        ),
        if (_showQuestionSuccess) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text(
                  'Question saved successfully!',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Another Question'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionField(String label, String value, bool isCorrect) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Radio<bool>(
            value: true,
            groupValue: isCorrect,
            onChanged: (value) {},
            activeColor: Colors.blue,
          ),
          Text('$label.', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: TextEditingController(text: value),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachments (Optional)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[300]!,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_upload_outlined,
                color: Colors.grey,
                size: 32,
              ),
              const SizedBox(height: 8),
              const Text(
                'Drag and drop files here or click to browse',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Supports: JPG, PNG, PDF, MP3, MP4',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        Text(
          'Auto-saved 2 minutes ago',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.schedule, color: Colors.grey, size: 16),
        Text(
          'Session expires in 45:32',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[700],
            side: BorderSide(color: Colors.grey[300]!),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Save as Draft'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Preview Exam'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Submit Exam'),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          value: value,
          onChanged: onChanged,
          items:
              items.map((item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldWithLabel(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            isDense: maxLines == 1,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _examTitleController.dispose();
    _instructionsController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}

// Models
class ExamQuestion {
  final int id;
  final QuestionType type;
  final String text;
  final int marks;
  final Difficulty difficulty;
  final List<String> options;
  final int correctAnswer;

  ExamQuestion({
    required this.id,
    required this.type,
    required this.text,
    required this.marks,
    required this.difficulty,
    this.options = const [],
    this.correctAnswer = 0,
  });
}

enum QuestionType {
  multipleChoice,
  trueFalse,
  essay;

  String get displayName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.trueFalse:
        return 'True/False';
      case QuestionType.essay:
        return 'Essay';
    }
  }
}

enum Difficulty {
  easy,
  medium,
  hard;

  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }
}
