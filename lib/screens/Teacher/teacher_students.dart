import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/models/student_model.dart';
import 'package:schmgtsystem/models/teacher_model.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';

class TeacherStudentsScreen extends ConsumerStatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  ConsumerState<TeacherStudentsScreen> createState() =>
      _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends ConsumerState<TeacherStudentsScreen>
    with TickerProviderStateMixin {
  String? _selectedClass;
  String? _selectedAcademicYear;
  String? _selectedTerm;
  bool _isLoading = false;
  List<StudentModel> _filteredStudents = [];
  List<String> _teacherClassIds = [];

  // Attendance tracking
  Map<String, String> _attendanceStatus =
      {}; // studentId -> status (present, absent, late)
  bool _isAttendanceMode = false;
  DateTime _attendanceDate = DateTime.now();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;

  // View mode
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _loadData();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load teacher data to get assigned classes
      await ref
          .read(RiverpodProvider.teachersProvider.notifier)
          .getAllTeachers(context);

      // Load students data
      await ref
          .read(RiverpodProvider.studentProvider.notifier)
          .getAllStudents(
            context,
            limit: 1000, // Load more students to ensure we get all
          );

      // Set default academic year and term
      _selectedAcademicYear = '2025/2026';
      _selectedTerm = 'First';

      _filterStudentsByTeacherClasses();
    } catch (e) {
      showSnackbar(context, 'Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterStudentsByTeacherClasses() {
    final teachersState = ref.read(RiverpodProvider.teachersProvider);
    final studentsState = ref.read(RiverpodProvider.studentProvider);

    // Get current teacher's classes
    final currentTeacher =
        teachersState.teacherListData.teachers?.isNotEmpty == true
            ? teachersState.teacherListData.teachers!.first
            : null;

    if (currentTeacher?.teachingInfo?.classTeacherClasses == null) {
      setState(() {
        _filteredStudents = [];
        _teacherClassIds = [];
      });
      return;
    }

    // Extract class IDs from teacher's assigned classes
    _teacherClassIds =
        currentTeacher!.teachingInfo!.classTeacherClasses!
            .map((classInfo) => classInfo.id ?? '')
            .where((id) => id.isNotEmpty)
            .toList();

    // Filter students by teacher's classes
    final allStudents = studentsState.students;
    _filteredStudents =
        allStudents.where((student) {
          final studentClassId = student.academicInfo.currentClass?.id;
          return studentClassId != null &&
              _teacherClassIds.contains(studentClassId);
        }).toList();

    setState(() {});
  }

  List<String> _getTeacherClassNames() {
    final teachersState = ref.read(RiverpodProvider.teachersProvider);
    final currentTeacher =
        teachersState.teacherListData.teachers?.isNotEmpty == true
            ? teachersState.teacherListData.teachers!.first
            : null;

    if (currentTeacher?.teachingInfo?.classTeacherClasses == null) {
      return [];
    }

    return currentTeacher!.teachingInfo!.classTeacherClasses!
        .map((classInfo) => classInfo.name ?? 'Unknown Class')
        .toList();
  }

  void _filterByClass(String? classId) {
    setState(() {
      _selectedClass = classId;
    });

    if (classId == null) {
      _filterStudentsByTeacherClasses();
      return;
    }

    final studentsState = ref.read(RiverpodProvider.studentProvider);
    final allStudents = studentsState.students;

    _filteredStudents =
        allStudents.where((student) {
          return student.academicInfo.currentClass?.id == classId;
        }).toList();
  }

  void _toggleAttendanceMode() {
    setState(() {
      _isAttendanceMode = !_isAttendanceMode;
      if (!_isAttendanceMode) {
        _attendanceStatus.clear();
      }
    });
  }

  void _markAttendance(String studentId, String status) {
    setState(() {
      _attendanceStatus[studentId] = status;
    });
  }

  void _saveAttendance() {
    // Here you would save attendance to backend
    showSnackbar(context, 'Attendance saved successfully!');
    _toggleAttendanceMode();
  }

  void _sendMessageToParent(StudentModel student) {
    showDialog(
      context: context,
      builder: (context) => _buildMessageDialog(student),
    );
  }

  Widget _buildMessageDialog(StudentModel student) {
    final messageController = TextEditingController();

    return AlertDialog(
      title: Text('Send Message to ${student.parentName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Student: ${student.fullName}'),
          const SizedBox(height: 16),
          TextField(
            controller: messageController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Type your message here...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Here you would send message to backend
            showSnackbar(context, 'Message sent successfully!');
            Navigator.pop(context);
          },
          child: const Text('Send'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildHeaderSection(),
                  _buildFiltersSection(),
                  _buildActionBar(),
                  Expanded(child: _buildStudentsList()),
                ],
              ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('My Students'),
      backgroundColor: Colors.blue[800],
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
          tooltip: _isGridView ? 'List View' : 'Grid View',
        ),
        IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[800]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.people,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Students',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_filteredStudents.length} students in your classes',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  'Total',
                  _filteredStudents.length.toString(),
                  Icons.people,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Present',
                  _attendanceStatus.values
                      .where((s) => s == 'present')
                      .length
                      .toString(),
                  Icons.check_circle,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Absent',
                  _attendanceStatus.values
                      .where((s) => s == 'absent')
                      .length
                      .toString(),
                  Icons.cancel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    final classNames = _getTeacherClassNames();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: _selectedClass,
              decoration: const InputDecoration(
                labelText: 'Filter by Class',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Classes'),
                ),
                ...classNames.map((className) {
                  return DropdownMenuItem<String>(
                    value: className,
                    child: Text(className),
                  );
                }),
              ],
              onChanged: (value) {
                // Find class ID by name
                final teachersState = ref.read(
                  RiverpodProvider.teachersProvider,
                );
                final currentTeacher =
                    teachersState.teacherListData.teachers?.isNotEmpty == true
                        ? teachersState.teacherListData.teachers!.first
                        : null;

                String? classId;
                if (value != null &&
                    currentTeacher?.teachingInfo?.classTeacherClasses != null) {
                  final classInfo = currentTeacher!
                      .teachingInfo!
                      .classTeacherClasses!
                      .firstWhere(
                        (c) => c.name == value,
                        orElse: () => ClassTeacherClass(),
                      );
                  classId = classInfo.id;
                }

                _filterByClass(classId);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Academic Year',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              initialValue: _selectedAcademicYear,
              readOnly: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Term',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              initialValue: _selectedTerm,
              readOnly: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _toggleAttendanceMode,
              icon: Icon(_isAttendanceMode ? Icons.close : Icons.checklist),
              label: Text(
                _isAttendanceMode ? 'Cancel Attendance' : 'Mark Attendance',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAttendanceMode ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_isAttendanceMode) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    _attendanceStatus.isNotEmpty ? _saveAttendance : null,
                icon: const Icon(Icons.save),
                label: const Text('Save Attendance'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    if (_filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No students found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _teacherClassIds.isEmpty
                  ? 'You are not assigned to any classes'
                  : 'No students are enrolled in your assigned classes',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    if (_isGridView) {
      return _buildGridView();
    } else {
      return _buildListView();
    }
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return FadeTransition(
          opacity: _fadeController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _slideController,
                curve: Interval(index * 0.1, 1.0),
              ),
            ),
            child: _buildStudentCard(student),
          ),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return FadeTransition(
          opacity: _fadeController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _slideController,
                curve: Interval(index * 0.1, 1.0),
              ),
            ),
            child: _buildStudentGridCard(student),
          ),
        );
      },
    );
  }

  Widget _buildStudentCard(StudentModel student) {
    final attendanceStatus = _attendanceStatus[student.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.blue[100],
                  child:
                      student.personalInfo.profileImage != null
                          ? ClipOval(
                            child: Image.network(
                              student.personalInfo.profileImage!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 35,
                                  color: Colors.blue[800],
                                );
                              },
                            ),
                          )
                          : Icon(
                            Icons.person,
                            size: 35,
                            color: Colors.blue[800],
                          ),
                ),
                if (_isAttendanceMode && attendanceStatus != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getAttendanceColor(attendanceStatus),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        _getAttendanceIcon(attendanceStatus),
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${student.admissionNumber}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Class: ${student.className} - ${student.classLevel}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Age: ${student.age} years',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        student.status == 'active'
                            ? Colors.green[50]
                            : Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          student.status == 'active'
                              ? Colors.green[200]!
                              : Colors.orange[200]!,
                    ),
                  ),
                  child: Text(
                    student.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          student.status == 'active'
                              ? Colors.green[700]
                              : Colors.orange[700],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_isAttendanceMode) ...[
                  Row(
                    children: [
                      _buildAttendanceButton(
                        student.id,
                        'present',
                        Icons.check,
                        Colors.green,
                      ),
                      const SizedBox(width: 4),
                      _buildAttendanceButton(
                        student.id,
                        'absent',
                        Icons.close,
                        Colors.red,
                      ),
                      const SizedBox(width: 4),
                      _buildAttendanceButton(
                        student.id,
                        'late',
                        Icons.schedule,
                        Colors.orange,
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _sendMessageToParent(student),
                        icon: Icon(Icons.message, color: Colors.blue[600]),
                        tooltip: 'Send Message',
                      ),
                      IconButton(
                        onPressed: () {
                          showSnackbar(
                            context,
                            'Navigate to ${student.fullName} details',
                          );
                        },
                        icon: Icon(Icons.visibility, color: Colors.blue[600]),
                        tooltip: 'View Details',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentGridCard(StudentModel student) {
    final attendanceStatus = _attendanceStatus[student.id];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue[100],
                  child:
                      student.personalInfo.profileImage != null
                          ? ClipOval(
                            child: Image.network(
                              student.personalInfo.profileImage!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.blue[800],
                                );
                              },
                            ),
                          )
                          : Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.blue[800],
                          ),
                ),
                if (_isAttendanceMode && attendanceStatus != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getAttendanceColor(attendanceStatus),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        _getAttendanceIcon(attendanceStatus),
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              student.fullName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Class: ${student.className}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            if (_isAttendanceMode) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttendanceButton(
                    student.id,
                    'present',
                    Icons.check,
                    Colors.green,
                  ),
                  _buildAttendanceButton(
                    student.id,
                    'absent',
                    Icons.close,
                    Colors.red,
                  ),
                  _buildAttendanceButton(
                    student.id,
                    'late',
                    Icons.schedule,
                    Colors.orange,
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () => _sendMessageToParent(student),
                    icon: Icon(Icons.message, color: Colors.blue[600]),
                    tooltip: 'Send Message',
                  ),
                  IconButton(
                    onPressed: () {
                      showSnackbar(
                        context,
                        'Navigate to ${student.fullName} details',
                      );
                    },
                    icon: Icon(Icons.visibility, color: Colors.blue[600]),
                    tooltip: 'View Details',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceButton(
    String studentId,
    String status,
    IconData icon,
    Color color,
  ) {
    final isSelected = _attendanceStatus[studentId] == status;

    return GestureDetector(
      onTap: () => _markAttendance(studentId, status),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Icon(icon, color: isSelected ? Colors.white : color, size: 16),
      ),
    );
  }

  Color _getAttendanceColor(String status) {
    switch (status) {
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

  IconData _getAttendanceIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check;
      case 'absent':
        return Icons.close;
      case 'late':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }
}
