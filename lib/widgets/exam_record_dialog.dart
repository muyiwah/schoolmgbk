import 'package:flutter/material.dart';
import 'package:schmgtsystem/constants/appcolor.dart';

class ExamRecordDialog extends StatefulWidget {
  const ExamRecordDialog({Key? key}) : super(key: key);

  @override
  State<ExamRecordDialog> createState() => _ExamRecordDialogState();
}

class _ExamRecordDialogState extends State<ExamRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _scoreController = TextEditingController();
  final _remarksController = TextEditingController();

  String? selectedStudent;
  String? selectedClass;
  String? selectedSubject;
  String? selectedGrade;

  // Sample data - replace with your actual data
  final List<String> students = [
    'John Doe',
    'Jane Smith',
    'Michael Johnson',
    'Emily Davis',
    'David Wilson',
    'Sarah Brown',
    'Chris Taylor',
    'Lisa Anderson',
  ];

  final List<String> classes = [
    'Grade 9A',
    'Grade 9B',
    'Grade 10A',
    'Grade 10B',
    'Grade 11A',
    'Grade 11B',
    'Grade 12A',
    'Grade 12B',
  ];

  final List<String> subjects = [
    'Mathematics',
    'English Language',
    'Physics',
    'Chemistry',
    'Biology',
    'History',
    'Geography',
    'Computer Science',
  ];

  final List<String> grades = ['A+', 'A', 'B+', 'B', 'C+', 'C', 'D+', 'D', 'F'];

  @override
  void dispose() {
    _scoreController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
        color:Colors.white,
        ),
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.assignment_add,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Examination Record',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              'Enter student examination details',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: Colors.grey.shade600),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Student Name Dropdown
                  _buildDropdownField(
                    label: 'Student Name',
                    value: selectedStudent,
                    items: students,
                    icon: Icons.person,
                    onChanged:
                        (value) => setState(() => selectedStudent = value),
                  ),
                  const SizedBox(height: 16),

                  // Class and Subject Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Class',
                          value: selectedClass,
                          items: classes,
                          icon: Icons.class_,
                          onChanged:
                              (value) => setState(() => selectedClass = value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Subject',
                          value: selectedSubject,
                          items: subjects,
                          icon: Icons.book,
                          onChanged:
                              (value) =>
                                  setState(() => selectedSubject = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Score and Grade Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextFormField(
                          controller: _scoreController,
                          label: 'Score',
                          icon: Icons.score,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter score';
                            }
                            final score = double.tryParse(value);
                            if (score == null || score < 0 || score > 100) {
                              return 'Enter valid score (0-100)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Grade',
                          value: selectedGrade,
                          items: grades,
                          icon: Icons.grade,
                          onChanged:
                              (value) => setState(() => selectedGrade = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Remarks Field
                  _buildTextFormField(
                    controller: _remarksController,
                    label: 'Remarks',
                    icon: Icons.comment,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter remarks';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveExamRecord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Save Record',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          hint: Text(
            'Select $label',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: Colors.grey.shade600),
          ),
          validator: validator,
        ),
      ],
    );
  }

  void _saveExamRecord() {
    if (_formKey.currentState!.validate()) {
      // Create exam record object
      final examRecord = {
        'student': selectedStudent,
        'class': selectedClass,
        'subject': selectedSubject,
        'score': double.parse(_scoreController.text),
        'grade': selectedGrade,
        'remarks': _remarksController.text,
        'timestamp': DateTime.now(),
      };

      // TODO: Save to database or state management
      print('Exam Record: $examRecord');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Examination record saved successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Close dialog
      Navigator.of(context).pop(examRecord);
    }
  }
}

// Usage example:
void showExamRecordDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const ExamRecordDialog();
    },
  );
}
