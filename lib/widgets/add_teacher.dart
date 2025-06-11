import 'package:flutter/material.dart';

class AssignNewTeacherDialog extends StatefulWidget {
  const AssignNewTeacherDialog({Key? key}) : super(key: key);

  @override
  State<AssignNewTeacherDialog> createState() => _AssignNewTeacherDialogState();
}

class _AssignNewTeacherDialogState extends State<AssignNewTeacherDialog> {
  String? selectedTeacher;
  Set<String> selectedClasses = {};
  Set<String> selectedSubjects = {};
  DateTime? assignmentStartDate;

  final List<String> teachers = [
    'John Smith',
    'Sarah Johnson',
    'Michael Brown',
    'Emily Davis',
    'David Wilson',
  ];

  final List<String> classes = [
    'JSS1A',
    'JSS1B',
    'JSS2A',
    'JSS2B',
    'SS1A',
    'SS1B',
  ];

  final List<String> subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Geography',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Assign New Teacher',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),

            // Divider
            Container(height: 1, color: Colors.grey.shade200),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Choose a Teacher Section
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6366f1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Choose a Teacher',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6366f1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedTeacher,
                        hint: Text(
                          'Select a teacher...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey.shade600,
                        ),
                        items:
                            teachers.map((teacher) {
                              return DropdownMenuItem(
                                value: teacher,
                                child: Text(
                                  teacher,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTeacher = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Assign to Classes Section
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8b5cf6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Assign to Classes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF8b5cf6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildClassCheckboxes(),
                  const SizedBox(height: 24),

                  // Subjects to Teach Section
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFF06b6d4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_book,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Subjects to Teach',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF06b6d4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSubjectCheckboxes(),
                  const SizedBox(height: 24),

                  // Assignment Start Date Section
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10b981),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Assignment Start Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF10b981),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '(Optional)',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            assignmentStartDate != null
                                ? '${assignmentStartDate!.month.toString().padLeft(2, '0')}/${assignmentStartDate!.day.toString().padLeft(2, '0')}/${assignmentStartDate!.year}'
                                : 'mm/dd/yyyy',
                            style: TextStyle(
                              color:
                                  assignmentStartDate != null
                                      ? Colors.black87
                                      : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _canAssign() ? _assignTeacher : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366f1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_add, size: 16),
                            const SizedBox(width: 6),
                            const Text(
                              'Assign Teacher',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCheckboxes() {
    return Column(
      children: [
        // First row: JSS1A, JSS1B, JSS2A
        Row(
          children: [
            Expanded(child: _buildCheckboxItem('JSS1A', selectedClasses)),
            Expanded(child: _buildCheckboxItem('JSS1B', selectedClasses)),
            Expanded(child: _buildCheckboxItem('JSS2A', selectedClasses)),
          ],
        ),
        const SizedBox(height: 12),
        // Second row: JSS2B, SS1A, SS1B
        Row(
          children: [
            Expanded(child: _buildCheckboxItem('JSS2B', selectedClasses)),
            Expanded(child: _buildCheckboxItem('SS1A', selectedClasses)),
            Expanded(child: _buildCheckboxItem('SS1B', selectedClasses)),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectCheckboxes() {
    return Column(
      children: [
        // First row: Mathematics, Physics
        Row(
          children: [
            Expanded(
              child: _buildSubjectCheckboxItem('Mathematics', Icons.calculate),
            ),
            Expanded(
              child: _buildSubjectCheckboxItem('Physics', Icons.science),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Second row: Chemistry, Biology
        Row(
          children: [
            Expanded(
              child: _buildSubjectCheckboxItem('Chemistry', Icons.biotech),
            ),
            Expanded(
              child: _buildSubjectCheckboxItem('Biology', Icons.local_florist),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Third row: English, Geography
        Row(
          children: [
            Expanded(child: _buildSubjectCheckboxItem('English', Icons.book)),
            Expanded(
              child: _buildSubjectCheckboxItem('Geography', Icons.public),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckboxItem(String item, Set<String> selectedSet) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: Checkbox(
              shape: OvalBorder(),
              value: selectedSet.contains(item),
              onChanged: (value) {
                setState(() {
                  if (value ?? false) {
                    selectedSet.add(item);
                  } else {
                    selectedSet.remove(item);
                  }
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              activeColor: const Color(0xFF6366f1),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCheckboxItem(String subject, IconData icon) {
    return Container(
       decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(right: 16),
      padding: EdgeInsets.all(6),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: Checkbox(
              shape: OvalBorder(),
              value: selectedSubjects.contains(subject),
              onChanged: (value) {
                setState(() {
                  if (value ?? false) {
                    selectedSubjects.add(subject);
                  } else {
                    selectedSubjects.remove(subject);
                  }
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              activeColor: const Color(0xFF6366f1),
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: _getSubjectIconColor(subject)),
          const SizedBox(width: 6),
          Text(
            subject,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Color _getSubjectIconColor(String subject) {
    switch (subject) {
      case 'Mathematics':
        return const Color(0xFF3b82f6); // Blue
      case 'Physics':
        return const Color(0xFF8b5cf6); // Purple
      case 'Chemistry':
        return const Color(0xFF06b6d4); // Cyan
      case 'Biology':
        return const Color(0xFF10b981); // Green
      case 'English':
        return const Color(0xFFf59e0b); // Yellow/Orange
      case 'Geography':
        return const Color(0xFF06b6d4); // Cyan
      default:
        return Colors.grey;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: assignmentStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != assignmentStartDate) {
      setState(() {
        assignmentStartDate = picked;
      });
    }
  }

  bool _canAssign() {
    return selectedTeacher != null &&
        selectedClasses.isNotEmpty &&
        selectedSubjects.isNotEmpty;
  }

  void _assignTeacher() {
    final assignment = {
      'teacher': selectedTeacher,
      'classes': selectedClasses.toList(),
      'subjects': selectedSubjects.toList(),
      'startDate': assignmentStartDate,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Teacher ${selectedTeacher} assigned successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop(assignment);
  }
}

// Example usage
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Management'),
        backgroundColor: const Color(0xFF6366f1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AssignNewTeacherDialog(),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366f1),
            foregroundColor: Colors.white,
          ),
          child: const Text('Assign New Teacher'),
        ),
      ),
    );
  }
}
