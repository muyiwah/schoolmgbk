import 'package:collection/collection.dart';

import 'package:flutter/material.dart';

class Student {
  final String name;
  final String studentId;
  final String grade;
  final StudentStatus status;
  final String avatarUrl;

  Student({
    required this.name,
    required this.studentId,
    required this.grade,
    required this.status,
    required this.avatarUrl,
  });
}

enum StudentStatus { sent, pending, failed }

class ReportCardStudentList extends StatefulWidget {
  ReportCardStudentList({super.key, required this.navigateTo});
  Null Function() navigateTo;

  @override
  _ReportCardStudentListState createState() => _ReportCardStudentListState();
}

class _ReportCardStudentListState extends State<ReportCardStudentList> {
  String selectedClass = 'Grade 1 - Excellence';
  String searchQuery = '';
  List<bool> selectedStudents = [];

  final List<String> classes = [
    'Grade 1 - Excellence',
    'Grade 2 - Loyal',
    'Grade 3 - Bookwarm',
    'Grade 4 - Bright',
  ];

  final List<Student> students = [
    Student(
      name: 'James Okoro',
      studentId: 'STU/2025/021',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.sent,
      avatarUrl: 'assets/avatars/james.jpg',
    ),
    Student(
      name: 'Sarah Johnson',
      studentId: 'STU/2025/022',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.pending,
      avatarUrl: 'assets/avatars/sarah.jpg',
    ),
    Student(
      name: 'Michael Chen',
      studentId: 'STU/2025/023',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.sent,
      avatarUrl: 'assets/avatars/michael.jpg',
    ),
    Student(
      name: 'Emma Wilson',
      studentId: 'STU/2025/024',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.failed,
      avatarUrl: 'assets/avatars/emma.jpg',
    ),
    Student(
      name: 'James Okoro',
      studentId: 'STU/2025/021',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.sent,
      avatarUrl: 'assets/avatars/james.jpg',
    ),
    Student(
      name: 'Sarah Johnson',
      studentId: 'STU/2025/022',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.pending,
      avatarUrl: 'assets/avatars/sarah.jpg',
    ),
    Student(
      name: 'Michael Chen',
      studentId: 'STU/2025/023',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.sent,
      avatarUrl: 'assets/avatars/michael.jpg',
    ),
    Student(
      name: 'Emma Wilson',
      studentId: 'STU/2025/024',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.failed,
      avatarUrl: 'assets/avatars/emma.jpg',
    ),
    Student(
      name: 'James Okoro',
      studentId: 'STU/2025/021',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.sent,
      avatarUrl: 'assets/avatars/james.jpg',
    ),
    Student(
      name: 'Sarah Johnson',
      studentId: 'STU/2025/022',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.pending,
      avatarUrl: 'assets/avatars/sarah.jpg',
    ),
    Student(
      name: 'Michael Chen',
      studentId: 'STU/2025/023',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.sent,
      avatarUrl: 'assets/avatars/michael.jpg',
    ),
    Student(
      name: 'Emma Wilson',
      studentId: 'STU/2025/024',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.failed,
      avatarUrl: 'assets/avatars/emma.jpg',
    ),
    Student(
      name: 'James Okoro',
      studentId: 'STU/2025/021',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.sent,
      avatarUrl: 'assets/avatars/james.jpg',
    ),
    Student(
      name: 'Sarah Johnson',
      studentId: 'STU/2025/022',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.pending,
      avatarUrl: 'assets/avatars/sarah.jpg',
    ),
    Student(
      name: 'Michael Chen',
      studentId: 'STU/2025/023',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.sent,
      avatarUrl: 'assets/avatars/michael.jpg',
    ),
    Student(
      name: 'Emma Wilson',
      studentId: 'STU/2025/024',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.failed,
      avatarUrl: 'assets/avatars/emma.jpg',
    ),
    Student(
      name: 'James Okoro',
      studentId: 'STU/2025/021',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.sent,
      avatarUrl: 'assets/avatars/james.jpg',
    ),
    Student(
      name: 'Sarah Johnson',
      studentId: 'STU/2025/022',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.pending,
      avatarUrl: 'assets/avatars/sarah.jpg',
    ),
    Student(
      name: 'Michael Chen',
      studentId: 'STU/2025/023',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.sent,
      avatarUrl: 'assets/avatars/michael.jpg',
    ),
    Student(
      name: 'Emma Wilson',
      studentId: 'STU/2025/024',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.failed,
      avatarUrl: 'assets/avatars/emma.jpg',
    ),
    Student(
      name: 'James Okoro',
      studentId: 'STU/2025/021',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.sent,
      avatarUrl: 'assets/avatars/james.jpg',
    ),
    Student(
      name: 'Sarah Johnson',
      studentId: 'STU/2025/022',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.pending,
      avatarUrl: 'assets/avatars/sarah.jpg',
    ),
    Student(
      name: 'Michael Chen',
      studentId: 'STU/2025/023',
      grade: 'Grade 1 - Excellence',
      status: StudentStatus.sent,
      avatarUrl: 'assets/avatars/michael.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    selectedStudents = List.generate(students.length, (index) => false);
  }

  List<Student> get filteredStudents {
    return students.where((student) {
      final matchesClass = student.grade == selectedClass;
      final matchesSearch =
          student.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          student.studentId.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesClass && matchesSearch;
    }).toList();
  }

  Color getStatusColor(StudentStatus status) {
    switch (status) {
      case StudentStatus.sent:
        return Colors.green;
      case StudentStatus.pending:
        return Colors.orange;
      case StudentStatus.failed:
        return Colors.red;
    }
  }

  String getStatusText(StudentStatus status) {
    switch (status) {
      case StudentStatus.sent:
        return 'Sent';
      case StudentStatus.pending:
        return 'Pending';
      case StudentStatus.failed:
        return 'Failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredStudents;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      
        title: Text(
          'Class Students',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.grey[600], size: 20),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Selection and Student Count Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Class',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedClass,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                            ),
                            items:
                                classes.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedClass = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${filtered.length} students',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Handle export PDF
                      },
                      icon: Icon(Icons.download, size: 16),
                      label: Text('Export PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 24),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by name or student ID...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  children:
                      filtered.mapIndexed((i, e) {
                        final student = filtered[i];
                        final originalIndex = students.indexOf(student);
                        return StudentCard(
                          student: student,
                          isSelected: selectedStudents[originalIndex],
                          onSelectionChanged: (selected) {
                            setState(() {
                              selectedStudents[originalIndex] =
                                  selected ?? false;
                            });
                          },
                          onViewReportCard: () {
                            widget.navigateTo();
                          },
                        );
                      }).toList(),
                ),
              ),
            ),
            // Students Grid
            // Expanded(
            //   child: GridView.builder(
            //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //       crossAxisCount: 4,
            //       crossAxisSpacing: 16,
            //       mainAxisSpacing: 16,
            //       childAspectRatio: 0.8,
            //     ),
            //     itemCount: filtered.length,
            //     itemBuilder: (context, index) {
            //       final student = filtered[index];
            //       final originalIndex = students.indexOf(student);

            //       return StudentCard(
            //         student: student,
            //         isSelected: selectedStudents[originalIndex],
            //         onSelectionChanged: (selected) {
            //           setState(() {
            //             selectedStudents[originalIndex] = selected ?? false;
            //           });
            //         },
            //         onViewReportCard: () {
            //           // Handle view report card
            //           showDialog(
            //             context: context,
            //             builder:
            //                 (context) => AlertDialog(
            //                   title: Text('Report Card'),
            //                   content: Text(
            //                     'Opening report card for ${student.name}',
            //                   ),
            //                   actions: [
            //                     TextButton(
            //                       onPressed: () => Navigator.pop(context),
            //                       child: Text('OK'),
            //                     ),
            //                   ],
            //                 ),
            //           );
            //         },
            //       );
            //     },
            //   ),
            // ),

            // Load More Button
            if (filtered.length >= 4)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: OutlinedButton(
                    onPressed: () {
                      // Handle load more students
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      'Load More Students',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final Student student;
  final bool isSelected;
  final ValueChanged<bool?> onSelectionChanged;
  final VoidCallback onViewReportCard;

  const StudentCard({
    Key? key,
    required this.student,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onViewReportCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox and Avatar Row
            Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: onSelectionChanged,
                  activeColor: Colors.blue,
                ),
                SizedBox(width: 10),
                // Student Name
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),

                    Text(
                      student.studentId,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Spacer(),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: getStatusColor(
                    student.status,
                  ).withOpacity(.5),
                  child: Text(
                    student.name.split(' ').map((n) => n[0]).take(2).join(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Student ID
            SizedBox(height: 8),

            // Grade and Status Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    student.grade,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: getStatusColor(student.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        getStatusIcon(student.status),
                        size: 10,
                        color: getStatusColor(student.status),
                      ),
                      SizedBox(width: 4),
                      Text(
                        getStatusText(student.status),
                        style: TextStyle(
                          fontSize: 10,
                          color: getStatusColor(student.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 36),

            // View Report Card Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onViewReportCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'View Report Card',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getStatusColor(StudentStatus status) {
    switch (status) {
      case StudentStatus.sent:
        return Colors.green;
      case StudentStatus.pending:
        return Colors.orange;
      case StudentStatus.failed:
        return Colors.red;
    }
  }

  String getStatusText(StudentStatus status) {
    switch (status) {
      case StudentStatus.sent:
        return 'Sent';
      case StudentStatus.pending:
        return 'Pending';
      case StudentStatus.failed:
        return 'Failed';
    }
  }

  IconData getStatusIcon(StudentStatus status) {
    switch (status) {
      case StudentStatus.sent:
        return Icons.check;
      case StudentStatus.pending:
        return Icons.access_time;
      case StudentStatus.failed:
        return Icons.close;
    }
  }
}
