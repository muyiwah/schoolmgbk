import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/models/teacher_model.dart';
import 'package:schmgtsystem/models/attendance_model.dart';
import 'package:schmgtsystem/models/communication_model.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';
import 'package:schmgtsystem/widgets/communication_dialog.dart';
import 'package:schmgtsystem/RoleHome/teacher.dart';

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState
    extends ConsumerState<TeacherDashboardScreen> {
  String? _selectedAcademicYear;
  String? _selectedTerm;
  bool _isLoading = false;

  // Attendance state
  DateTime _selectedDate = DateTime.now();
  final Map<String, String> _attendanceStatus = {};
  final Map<String, String> _attendanceRemarks = {};
  bool _isSubmittingAttendance = false;
  bool _hasUnsavedChanges = false;
  String? _selectedClassId;
  bool _isClassTeacher = false;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    try {
      // Load user profile first
      await ref
          .read(RiverpodProvider.profileProvider.notifier)
          .getUserProfile();

      // Load teacher profile and classes
      await ref
          .read(RiverpodProvider.teachersProvider.notifier)
          .getAllTeachers(context);

      // Set default academic year and term
      _selectedAcademicYear = '2025/2026';
      _selectedTerm = 'First';

      // Auto-detect class teacher assignment
      _detectClassTeacherAssignment();
    } catch (e) {
      showSnackbar(context, 'Error loading teacher data: $e');
    } finally {}
  }

  void _detectClassTeacherAssignment() {
    final teachersState = ref.read(RiverpodProvider.teachersProvider);
    final profileState = ref.read(RiverpodProvider.profileProvider);

    // Get current logged-in user
    final currentUser = profileState.user;
    if (currentUser == null) {
      setState(() {
        _isClassTeacher = false;
        _selectedClassId = null;
      });
      return;
    }

    // Find the teacher that matches the current user
    Teacher? currentTeacher;
    try {
      currentTeacher = teachersState.teacherListData.teachers?.firstWhere(
        (teacher) => teacher.user?.id == currentUser.id,
      );
    } catch (e) {
      currentTeacher = null;
    }

    if (currentTeacher?.teachingInfo?.isClassTeacher == true &&
        currentTeacher?.teachingInfo?.classTeacherClasses?.isNotEmpty == true) {
      // Teacher is a class teacher, set the first class as default
      final classTeacherClass =
          currentTeacher!.teachingInfo!.classTeacherClasses!.first;

      print('Class Teacher Assignment Detected:');
      print('Teacher ID: ${currentTeacher.id}');
      print('Teacher Name: ${currentTeacher.fullName}');
      print(
        'Class Teacher Classes: ${currentTeacher.teachingInfo!.classTeacherClasses!.length}',
      );
      print('Selected Class ID: ${classTeacherClass.id}');
      print('Selected Class Name: ${classTeacherClass.name}');

      setState(() {
        _isClassTeacher = true;
        _selectedClassId = classTeacherClass.id;
      });

      // Load attendance for the assigned class
      if (_selectedClassId != null) {
        _loadAttendanceForDate(_selectedClassId!);
      }
    } else {
      print('No Class Teacher Assignment Found:');
      print('Current User ID: ${currentUser.id}');
      print('Teacher Found: ${currentTeacher != null}');
      if (currentTeacher != null) {
        print(
          'Is Class Teacher: ${currentTeacher.teachingInfo?.isClassTeacher}',
        );
        print(
          'Class Teacher Classes Count: ${currentTeacher.teachingInfo?.classTeacherClasses?.length ?? 0}',
        );
      }

      setState(() {
        _isClassTeacher = false;
        _selectedClassId = null;
      });
    }
  }

  Future<void> _loadAttendanceForDate(String classId) async {
    final attendanceProvider = ref.read(RiverpodProvider.attendanceProvider);
    final classProvider = ref.read(RiverpodProvider.classProvider);
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Load class data first
    await classProvider.getSingleClass(context, classId);

    // Clear previous attendance data
    _attendanceStatus.clear();
    _attendanceRemarks.clear();
    _hasUnsavedChanges = false;

    // Try to fetch existing attendance data for the date
    await attendanceProvider.getAttendanceByDate(
      classId: classId,
      date: dateString,
    );

    // Initialize all students with default absent status
    _initializeAllStudentsWithDefaultStatus(classId);

    // If we have existing attendance data, update the UI
    if (attendanceProvider.hasAttendanceData) {
      _populateExistingAttendance();
    }

    setState(() {});
  }

  void _initializeAllStudentsWithDefaultStatus(String classId) {
    final classProvider = ref.read(RiverpodProvider.classProvider);
    final students = classProvider.singlgeClassData.data?.students ?? [];

    // Initialize all students with default absent status
    for (var student in students) {
      final studentId = student.id ?? student.admissionNumber ?? 'N/A';
      if (!_attendanceStatus.containsKey(studentId)) {
        _attendanceStatus[studentId] = 'absent';
        _attendanceRemarks[studentId] = '';
      }
    }
  }

  void _populateExistingAttendance() {
    final attendanceProvider = ref.read(RiverpodProvider.attendanceProvider);
    final records = attendanceProvider.attendanceRecords;

    // Update status and remarks for students who have existing attendance records
    for (var record in records) {
      final studentId = record.student.id;
      _attendanceStatus[studentId] = record.status;
      _attendanceRemarks[studentId] = record.remarks;
    }
  }

  void _markStudentAttendance(String studentId, String status) {
    setState(() {
      _attendanceStatus[studentId] = status;
      _hasUnsavedChanges = true;
    });
  }

  void _updateStudentRemarks(String studentId, String remarks) {
    setState(() {
      _attendanceRemarks[studentId] = remarks;
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _submitAttendance(String classId) async {
    final classProvider = ref.read(RiverpodProvider.classProvider);
    final students = classProvider.singlgeClassData.data?.students ?? [];
    final attendanceProvider = ref.read(RiverpodProvider.attendanceProvider);

    if (students.isEmpty) {
      showSnackbar(context, 'No students found for this class');
      return;
    }

    // Create attendance records for all students in the class
    final allStudentRecords =
        students.map((student) {
          final studentId = student.id ?? student.admissionNumber ?? 'N/A';
          final status = _attendanceStatus[studentId] ?? 'absent';
          final remarks = _attendanceRemarks[studentId] ?? '';

          return AttendanceRecord(
            studentId: studentId,
            status: status,
            remarks: remarks,
          );
        }).toList();

    setState(() {
      _isSubmittingAttendance = true;
    });

    try {
      final profileProvider = ref.read(RiverpodProvider.profileProvider);
      final user = profileProvider.user;

      if (user == null) {
        showSnackbar(context, 'User not found. Please login again.');
        return;
      }

      final request = MarkAttendanceRequest(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        term: _selectedTerm ?? 'First',
        academicYear: _selectedAcademicYear ?? '2025/2026',
        markerId: user.id ?? '',
        records: allStudentRecords,
      );

      final success = await attendanceProvider.markAttendance(
        classId: classId,
        request: request,
      );

      if (success) {
        showSnackbar(context, 'Attendance marked successfully!');
        setState(() {
          _hasUnsavedChanges = false;
        });

        // Reload the attendance data
        await _loadAttendanceForDate(classId);
      } else {
        showSnackbar(
          context,
          attendanceProvider.errorMessage ?? 'Failed to mark attendance',
        );
      }
    } catch (e) {
      showSnackbar(context, 'Error: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmittingAttendance = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final teachersState = ref.watch(RiverpodProvider.teachersProvider);
    final profileState = ref.watch(RiverpodProvider.profileProvider);

    // Get current logged-in user
    final currentUser = profileState.user;

    // Find the teacher that matches the current user
    Teacher? currentTeacher;
    if (currentUser != null) {
      try {
        currentTeacher = teachersState.teacherListData.teachers?.firstWhere(
          (teacher) => teacher.user?.id == currentUser.id,
        );
      } catch (e) {
        currentTeacher = null;
      }
    }

    final teacherClasses =
        currentTeacher?.teachingInfo?.classTeacherClasses ?? [];

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Class Teacher Dashboard'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadTeacherData),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTeacherInfoSection(currentTeacher),
            const SizedBox(height: 24),
            _buildClassSelectionSection(teacherClasses),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  // Desktop layout
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildClassOverview(teacherClasses),
                            const SizedBox(height: 16),
                            _buildAttendanceSection(teacherClasses),
                            const SizedBox(height: 16),
                            _buildCommunicationSection(teacherClasses),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildStudentsSection(teacherClasses),
                              const SizedBox(height: 16),
                              _buildQuickActions(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Mobile layout
                  return Column(
                    children: [
                      _buildClassOverview(teacherClasses),
                      const SizedBox(height: 16),
                      _buildAttendanceSection(teacherClasses),
                      const SizedBox(height: 16),
                      _buildCommunicationSection(teacherClasses),
                      const SizedBox(height: 16),
                      _buildStudentsSection(teacherClasses),
                      const SizedBox(height: 16),
                      _buildQuickActions(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherInfoSection(Teacher? teacher) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue[100],
            child:
            // teacher?.personalInfo?.profileImage != null
            //     ? ClipOval(
            //       child: Image.network(
            //         teacher!.personalInfo!.profileImage!,
            //         width: 80,
            //         height: 80,
            //         fit: BoxFit.cover,
            //         errorBuilder: (context, error, stackTrace) {
            //           return Icon(
            //             Icons.person,
            //             size: 40,
            //             color: Colors.blue[800],
            //           );
            //         },
            //       ),
            //     )
            //     :
            Icon(Icons.person, size: 40, color: Colors.blue[800]),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher?.fullName ??
                      teacher?.personalInfo?.firstName ??
                      'Teacher Name',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  teacher?.teachingInfo?.isClassTeacher == true
                      ? 'Class Teacher'
                      : 'Teacher',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Staff ID: ${teacher?.staffId ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Text(
              'Active',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelectionSection(List<ClassTeacherClass> classes) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Classes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),
          if (classes.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.class_, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No classes assigned',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Contact administrator to assign classes',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  classes.map((classInfo) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classInfo.name ?? 'Unknown Class',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Level: ${classInfo.level ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Section: ${classInfo.section ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Academic Year: ${classInfo.academicYear ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildClassOverview(List<ClassTeacherClass> classes) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Class Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  icon: Icons.class_,
                  label: 'Total Classes',
                  value: classes.length.toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  icon: Icons.people,
                  label: 'Total Students',
                  value:
                      '0', // This would be calculated from actual student data
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  icon: Icons.calendar_today,
                  label: 'Academic Year',
                  value: _selectedAcademicYear ?? 'N/A',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  icon: Icons.school,
                  label: 'Current Term',
                  value: _selectedTerm ?? 'N/A',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsSection(List<ClassTeacherClass> classes) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Students',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Navigate to teacher students screen
                  context.go('/teacher/students');
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (classes.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No students to display',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Students will appear here when classes are assigned',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final classInfo = classes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          classInfo.name?.substring(0, 1) ?? 'C',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classInfo.name ?? 'Unknown Class',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${classInfo.level} - ${classInfo.section}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '0 students', // This would be actual student count
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildActionCard(
                icon: Icons.checklist,
                title: 'Todo List',
                color: Colors.teal,
                onTap: () {
                  _navigateToTeacherDashboardApp();
                },
              ),
              _buildActionCard(
                icon: Icons.assignment,
                title: 'Take Attendance',
                color: Colors.green,
                onTap: () {
                  showSnackbar(context, 'Navigate to attendance');
                },
              ),
              _buildActionCard(
                icon: Icons.grade,
                title: 'Record Grades',
                color: Colors.orange,
                onTap: () {
                  showSnackbar(context, 'Navigate to grades');
                },
              ),
              _buildActionCard(
                icon: Icons.message,
                title: 'Send Message',
                color: Colors.purple,
                onTap: () {
                  showSnackbar(context, 'Navigate to messaging');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSection(List<ClassTeacherClass> teacherClasses) {
    if (!_isClassTeacher) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No Class Teacher Assignment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You are not assigned as a class teacher.\nContact administration for class teacher assignment.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_selectedClassId == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Loading class information...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // Get the assigned class information
    final assignedClass = teacherClasses.firstWhere(
      (classItem) => classItem.id == _selectedClassId,
      orElse: () => ClassTeacherClass(),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.event_available,
                  color: Colors.blue[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mark Attendance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Class: ${assignedClass.name ?? 'Unknown'} - ${assignedClass.level ?? 'Unknown'}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildAttendanceHeader(),
          const SizedBox(height: 16),
          _buildAttendanceContent(),
        ],
      ),
    );
  }

  Widget _buildAttendanceHeader() {
    final attendanceProvider = ref.watch(RiverpodProvider.attendanceProvider);
    final isSubmitted =
        attendanceProvider.attendanceByDate?.isSubmitted ?? false;
    final isLocked = attendanceProvider.attendanceByDate?.isLocked ?? false;
    final hasExistingData = attendanceProvider.hasAttendanceData;
    final attendanceStats = attendanceProvider.attendanceStats;
    final isToday = _isToday(_selectedDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasExistingData ? Colors.green[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasExistingData ? Colors.green[200]! : Colors.blue[200]!,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      hasExistingData
                          ? Icons.check_circle
                          : Icons.calendar_today,
                      size: 20,
                      color:
                          hasExistingData
                              ? Colors.green[700]
                              : Colors.blue[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isToday
                          ? 'Today - ${DateFormat('MMM dd, yyyy').format(_selectedDate)}'
                          : 'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            hasExistingData
                                ? Colors.green[700]
                                : Colors.blue[700],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 30),
                          ),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                          await _loadAttendanceForDate(_selectedClassId!);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              hasExistingData
                                  ? Colors.green[100]
                                  : Colors.blue[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Change Date',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                hasExistingData
                                    ? Colors.green[700]
                                    : Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasUnsavedChanges && !isSubmitted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Unsaved Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (isSubmitted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Submitted',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (isLocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Locked',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          // Show attendance summary if data exists
          if (hasExistingData && attendanceStats.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Present',
                    attendanceStats['present']?.toString() ?? '0',
                    Colors.green,
                    Icons.check_circle,
                  ),
                  _buildStatItem(
                    'Absent',
                    attendanceStats['absent']?.toString() ?? '0',
                    Colors.red,
                    Icons.cancel,
                  ),
                  _buildStatItem(
                    'Late',
                    attendanceStats['late']?.toString() ?? '0',
                    Colors.orange,
                    Icons.schedule,
                  ),
                  _buildStatItem(
                    'Total',
                    attendanceStats['total']?.toString() ?? '0',
                    Colors.blue,
                    Icons.people,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildAttendanceContent() {
    final classProvider = ref.watch(RiverpodProvider.classProvider);
    final attendanceProvider = ref.watch(RiverpodProvider.attendanceProvider);
    final students = classProvider.singlgeClassData.data?.students ?? [];
    final isLocked = attendanceProvider.attendanceByDate?.isLocked ?? false;
    final isSubmitted =
        attendanceProvider.attendanceByDate?.isSubmitted ?? false;

    if (attendanceProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (students.isEmpty) {
      return _buildEmptyAttendanceState();
    }

    return Column(
      children: [
        // Students list
        Container(
          height: 400,
          child: ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final studentId = student.id ?? student.admissionNumber ?? 'N/A';
              final currentStatus = _attendanceStatus[studentId] ?? 'absent';
              final currentRemarks = _attendanceRemarks[studentId] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(currentStatus).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: _getStatusColor(
                            currentStatus,
                          ).withOpacity(0.1),
                          child: Text(
                            (student.name ?? 'Unknown')[0].toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(currentStatus),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name ?? 'Unknown Student',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                student.admissionNumber ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              currentStatus,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getStatusColor(
                                currentStatus,
                              ).withOpacity(0.3),
                              width:
                                  attendanceProvider.hasAttendanceData ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (attendanceProvider.hasAttendanceData)
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: _getStatusColor(currentStatus),
                                ),
                              if (attendanceProvider.hasAttendanceData)
                                const SizedBox(width: 4),
                              if (_isToday(_selectedDate) &&
                                  !attendanceProvider.hasAttendanceData)
                                Icon(
                                  Icons.today,
                                  size: 14,
                                  color: Colors.purple,
                                ),
                              if (_isToday(_selectedDate) &&
                                  !attendanceProvider.hasAttendanceData)
                                const SizedBox(width: 4),
                              Text(
                                currentStatus.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(currentStatus),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (!isLocked) ...[
                      const SizedBox(height: 16),
                      // Quick action buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatusButton(
                              'Present',
                              'present',
                              studentId,
                              Colors.green,
                              currentStatus == 'present',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatusButton(
                              'Absent',
                              'absent',
                              studentId,
                              Colors.red,
                              currentStatus == 'absent',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatusButton(
                              'Late',
                              'late',
                              studentId,
                              Colors.orange,
                              currentStatus == 'late',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Remarks field
                      TextFormField(
                        initialValue: currentRemarks,
                        decoration: InputDecoration(
                          labelText: 'Remarks (Optional)',
                          hintText: 'Add any notes...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          prefixIcon: const Icon(Icons.note_add, size: 20),
                        ),
                        onChanged: (value) {
                          _updateStudentRemarks(studentId, value);
                        },
                      ),
                    ] else if (currentRemarks.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.note, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                currentRemarks,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Submit button
        if (students.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Attendance Summary',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        attendanceProvider.hasAttendanceData
                            ? 'Attendance already marked for ${_isToday(_selectedDate) ? 'today' : DateFormat('MMM dd, yyyy').format(_selectedDate)}'
                            : 'All ${students.length} students will be marked for ${_isToday(_selectedDate) ? 'today' : DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              attendanceProvider.hasAttendanceData
                                  ? Colors.green[600]
                                  : Colors.blue[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSubmitted
                            ? 'Click "Resubmit" to update attendance records'
                            : attendanceProvider.hasAttendanceData
                            ? 'You can modify attendance records below'
                            : 'All students default to "Absent" until marked',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              attendanceProvider.hasAttendanceData
                                  ? Colors.green[500]
                                  : Colors.blue[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                // Submit button
                ElevatedButton(
                  onPressed:
                      isLocked || _isSubmittingAttendance
                          ? null
                          : () => _submitAttendance(_selectedClassId!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _hasUnsavedChanges
                            ? Colors.green[600]
                            : Colors.grey[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isSubmittingAttendance
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Submitting...'),
                            ],
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isSubmitted
                                    ? 'Resubmit Attendance Updates'
                                    : 'Submit Attendance for All Students',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatusButton(
    String label,
    String status,
    String studentId,
    Color color,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => _markStudentAttendance(studentId, status),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(status),
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAttendanceState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Students Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Students will appear here once the class is selected',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'late':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  Widget _buildCommunicationSection(List<ClassTeacherClass> teacherClasses) {
    if (!_isClassTeacher || _selectedClassId == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.message, color: Colors.green[700], size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Communication',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Communication buttons
          Row(
            children: [
              Expanded(
                child: _buildCommunicationButton(
                  'Message Parents',
                  Icons.people,
                  Colors.blue,
                  () => _showCommunicationDialog(
                    CommunicationType.teacherParent,
                    _selectedClassId!,
                    null,
                    [], // Will be populated when parent IDs are available
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCommunicationButton(
                  'Message Admin',
                  Icons.admin_panel_settings,
                  Colors.purple,
                  () => _showCommunicationDialog(
                    CommunicationType.teacherAdmin,
                    _selectedClassId!,
                    null,
                    [], // Admin will be determined by role
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Recent communications preview
          _buildRecentCommunicationsPreview(),
        ],
      ),
    );
  }

  Widget _buildCommunicationButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        elevation: 0,
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCommunicationsPreview() {
    final communicationProvider = ref.watch(
      RiverpodProvider.communicationProvider,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Recent Communications',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed:
                    () => _showCommunicationDialog(
                      CommunicationType.teacherParent,
                      _selectedClassId!,
                      null,
                      [],
                    ),
                child: const Text('View All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (communicationProvider.hasCommunications)
            ...communicationProvider.communications
                .take(2)
                .map((comm) => _buildCommunicationPreviewItem(comm))
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No recent communications',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommunicationPreviewItem(CommunicationModel communication) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.blue[100],
                child: Text(
                  communication.sender.firstName.isNotEmpty
                      ? communication.sender.firstName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  communication.sender.fullName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                DateFormat(
                  'MMM dd',
                ).format(DateTime.parse(communication.createdAt)),
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
          if (communication.title.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              communication.title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 4),
          Text(
            communication.message,
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showCommunicationDialog(
    CommunicationType type,
    String classId,
    String? studentId,
    List<String>? parentIds,
  ) async {
    // Load communications first
    await ref
        .read(RiverpodProvider.communicationProvider.notifier)
        .getClassCommunications(classId: classId);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        builder:
            (context) => CommunicationDialog(
              classId: classId,
              studentId: studentId,
              communicationType: type,
              parentIds: parentIds,
            ),
      );
    }
  }

  void _navigateToTeacherDashboardApp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TeacherDashboardApp(
              navigateTo: () {
                // Navigation callback for future use
              },
              navigateTo2: () {
                // Second navigation callback for future use
              },
            ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
