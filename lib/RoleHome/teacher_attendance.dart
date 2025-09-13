import 'package:flutter/material.dart';

class TeacherAttendance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AttendanceScreen(),
    );
  }
}

enum AttendanceStatus { present, absent, late }

class Student {
  final String id;
  final String name;
  final String rollNumber;
  final String avatarUrl;
  AttendanceStatus status;

  Student({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.avatarUrl,
    this.status = AttendanceStatus.present,
  });
}

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final String className = "Grade 7-A Mathematics";
  final String date = "Today, March 15, 2024";
  final int totalStudents = 28;

  List<Student> students = [
    Student(
      id: '1',
      name: 'Alex Thompson',
      rollNumber: 'Roll #001',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Alex',
      status: AttendanceStatus.present,
    ),
    Student(
      id: '2',
      name: 'Emma Davis',
      rollNumber: 'Roll #002',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Emma',
      status: AttendanceStatus.present,
    ),
    Student(
      id: '3',
      name: 'Michael Chen',
      rollNumber: 'Roll #003',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Michael',
      status: AttendanceStatus.absent,
    ),
    Student(
      id: '4',
      name: 'Sofia Rodriguez',
      rollNumber: 'Roll #004',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Sofia',
      status: AttendanceStatus.late,
    ),
    Student(
      id: '5',
      name: 'James Wilson',
      rollNumber: 'Roll #005',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=James',
      status: AttendanceStatus.present,
    ),
    Student(
      id: '6',
      name: 'Olivia Brown',
      rollNumber: 'Roll #006',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Olivia',
      status: AttendanceStatus.present,
    ),
  ];

  void _updateStudentStatus(String studentId, AttendanceStatus newStatus) {
    setState(() {
      final studentIndex = students.indexWhere((s) => s.id == studentId);
      if (studentIndex != -1) {
        students[studentIndex].status = newStatus;
      }
    });
  }

  void _markAllPresent() {
    setState(() {
      for (var student in students) {
        student.status = AttendanceStatus.present;
      }
    });
  }

  int get presentCount =>
      students.where((s) => s.status == AttendanceStatus.present).length;
  int get absentCount =>
      students.where((s) => s.status == AttendanceStatus.absent).length;
  int get lateCount =>
      students.where((s) => s.status == AttendanceStatus.late).length;
  double get attendanceRate => (presentCount / students.length) * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.groups, color: Colors.blue[600]),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    className,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '$date • $totalStudents Students',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.filter_list, size: 18),
              label: Text('Filter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[600],
                side: BorderSide(color: Colors.blue[300]!),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Action Buttons
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _markAllPresent,
                  icon: Icon(Icons.check_circle, size: 18),
                  label: Text('Mark All Present'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[500],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // Save attendance logic
                  },
                  icon: Icon(Icons.save, size: 18),
                  label: Text('Save Attendance'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[500],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Spacer(),
                _buildLegend(),
              ],
            ),
          ),

          // Student List
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                padding: EdgeInsets.symmetric(vertical: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return StudentCard(
                    student: students[index],
                    onStatusChanged: _updateStudentStatus,
                  );
                },
              ),
            ),
          ),

          // Attendance Summary
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Attendance Summary",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    _buildSummaryCard(
                      title: 'Total Students',
                      count: '$totalStudents',
                      color: Colors.grey[100]!,
                      textColor: Colors.black87,
                    ),
                    SizedBox(width: 12),
                    _buildSummaryCard(
                      title: 'Present',
                      count: '$presentCount',
                      color: Colors.green[50]!,
                      textColor: Colors.green[600]!,
                    ),
                    SizedBox(width: 12),
                    _buildSummaryCard(
                      title: 'Absent',
                      count: '$absentCount',
                      color: Colors.red[50]!,
                      textColor: Colors.red[600]!,
                    ),
                    SizedBox(width: 12),
                    _buildSummaryCard(
                      title: 'Late',
                      count: '$lateCount',
                      color: Colors.orange[50]!,
                      textColor: Colors.orange[600]!,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attendance Rate: ${attendanceRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.download, size: 18),
                      label: Text('Export Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('Present', Colors.green),
        SizedBox(width: 16),
        _buildLegendItem('Absent', Colors.red),
        SizedBox(width: 16),
        _buildLegendItem('Late', Colors.orange),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String count,
    required Color color,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: textColor)),
          ],
        ),
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final Student student;
  final Function(String, AttendanceStatus) onStatusChanged;

  const StudentCard({
    Key? key,
    required this.student,
    required this.onStatusChanged,
  }) : super(key: key);

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(student.avatarUrl),
                  backgroundColor: Colors.grey[200],
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(student.status),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    student.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    student.rollNumber,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children:
                        AttendanceStatus.values.map((status) {
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => onStatusChanged(student.id, status),
                              child: Container(
                                margin: EdgeInsets.only(right: 4),
                                padding: EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      student.status == status
                                          ? _getStatusColor(status)
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    status.name.capitalize(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          student.status == status
                                              ? Colors.white
                                              : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    // Show student details
                  },
                  icon: Icon(Icons.visibility_outlined, size: 18),
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                SizedBox(height: 4),
                IconButton(
                  onPressed: () {
                    // Send message to student
                  },
                  icon: Icon(
                    Icons.message_outlined,
                    size: 18,
                    color: Colors.blue,
                  ),
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
