import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import 'package:schmgtsystem/screens/Teacher/teacher_timetable_screen.dart';
import 'package:schmgtsystem/screens/Student/create_timetale.dart';
import 'package:schmgtsystem/models/uniform_model.dart';
import 'package:schmgtsystem/repository/uniform_repository.dart';
import 'package:schmgtsystem/utils/academic_year_helper.dart';
import 'package:schmgtsystem/services/global_academic_year_service.dart';

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
  late GlobalAcademicYearService _academicYearService;

  // Uniform data
  final UniformRepository _uniformRepository = UniformRepository();
  List<UniformModel> _classUniforms = [];
  bool _isLoadingUniforms = false;
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
    _academicYearService = GlobalAcademicYearService();
    _academicYearService.addListener(_onAcademicYearChanged);
    _loadTeacherData();
  }

  void _onAcademicYearChanged() {
    if (mounted) {
      setState(() {
        _selectedAcademicYear = _academicYearService.currentAcademicYearString;
        _selectedTerm = _academicYearService.currentTermString;
      });
    }
  }

  @override
  void dispose() {
    _academicYearService.removeListener(_onAcademicYearChanged);
    super.dispose();
  }

  Future<void> _loadClassUniforms(String classId) async {
    setState(() {
      _isLoadingUniforms = true;
    });

    try {
      final response = await _uniformRepository.getUniforms(classId);
      if (response.success && response.data != null) {
        setState(() {
          _classUniforms = response.data!;
        });
      }
    } catch (e) {
      // Handle error silently for teacher view
    } finally {
      setState(() {
        _isLoadingUniforms = false;
      });
    }
  }

  Future<void> _loadTeacherData() async {
    try {
      // Load teacher profile and classes
      await ref
          .read(RiverpodProvider.teachersProvider.notifier)
          .getAllTeachers(context);

      // Set default academic year and term from backend
      _selectedAcademicYear = AcademicYearHelper.getCurrentAcademicYear(ref);
      _selectedTerm = AcademicYearHelper.getCurrentTerm(ref);

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

      // Load attendance and communications for the assigned class
      if (_selectedClassId != null) {
        _loadAttendanceForDate(_selectedClassId!);
        _loadCommunicationsForClass(_selectedClassId!);
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

  Future<void> _loadCommunicationsForClass(String classId) async {
    try {
      // Load both teacher-to-parent and admin-to-teacher communications
      // Also load user's inbox
      await Future.wait([
        ref
            .read(RiverpodProvider.communicationProvider.notifier)
            .getClassCommunications(
              classId: classId,
              communicationType: CommunicationType.teacherParent.value,
            ),
        ref
            .read(RiverpodProvider.communicationProvider.notifier)
            .getClassCommunications(
              classId: classId,
              communicationType: CommunicationType.adminTeacher.value,
            ),
        ref
            .read(RiverpodProvider.communicationProvider.notifier)
            .getUserCommunications(refresh: true),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading communications for class: $e');
      }
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
        academicYear:
            _selectedAcademicYear ??
            AcademicYearHelper.getCurrentAcademicYear(ref),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Class Teacher Dashboard'),
            Text(
              '${_academicYearService.currentAcademicYearString} • ${_academicYearService.currentTermString} Term',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ],
        ),
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
                            _buildUniformSection(teacherClasses),
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
                      _buildUniformSection(teacherClasses),
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

  Widget _buildUniformSection(List<ClassTeacherClass> classes) {
    if (classes.isEmpty) return const SizedBox.shrink();

    // Load uniforms for the first class if not already loaded
    if (_classUniforms.isEmpty && !_isLoadingUniforms && classes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadClassUniforms(classes.first.id ?? '');
      });
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
              const Icon(Icons.checkroom, color: Color(0xFF1565C0), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Class Uniforms',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              const Spacer(),
              if (_classUniforms.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${_classUniforms.length}/7 days',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isLoadingUniforms)
            const Center(child: CircularProgressIndicator())
          else if (_classUniforms.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.checkroom_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No uniforms assigned for this class',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 7,
              itemBuilder: (context, index) {
                final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                final fullDays = [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday',
                ];
                final day = days[index];
                final fullDay = fullDays[index];
                final hasUniform = _classUniforms.any((u) => u.day == fullDay);

                return Container(
                  decoration: BoxDecoration(
                    color:
                        hasUniform
                            ? _getDayColor(fullDay).withOpacity(0.1)
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          hasUniform
                              ? _getDayColor(fullDay).withOpacity(0.3)
                              : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              hasUniform
                                  ? _getDayColor(fullDay)
                                  : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (hasUniform)
                        Icon(
                          Icons.check,
                          color: _getDayColor(fullDay),
                          size: 16,
                        )
                      else
                        Icon(Icons.remove, color: Colors.grey[400], size: 16),
                    ],
                  ),
                );
              },
            ),

          if (_classUniforms.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Uniform Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...() {
                    final sortedUniforms = List<UniformModel>.from(
                      _classUniforms,
                    );
                    sortedUniforms.sort((a, b) {
                      const dayOrder = [
                        'Monday',
                        'Tuesday',
                        'Wednesday',
                        'Thursday',
                        'Friday',
                        'Saturday',
                        'Sunday',
                      ];
                      return dayOrder
                          .indexOf(a.day)
                          .compareTo(dayOrder.indexOf(b.day));
                    });
                    return sortedUniforms
                        .map(
                          (uniform) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(
                                    top: 6,
                                    right: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getDayColor(uniform.day),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${uniform.day}: ${uniform.uniform}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList();
                  }(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getDayColor(String day) {
    switch (day) {
      case 'Monday':
        return const Color(0xFF2196F3);
      case 'Tuesday':
        return const Color(0xFF4CAF50);
      case 'Wednesday':
        return const Color(0xFFFF9800);
      case 'Thursday':
        return const Color(0xFF9C27B0);
      case 'Friday':
        return const Color(0xFFF44336);
      case 'Saturday':
        return const Color(0xFF607D8B);
      case 'Sunday':
        return const Color(0xFF795548);
      default:
        return Colors.grey;
    }
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
              _buildActionCard(
                icon: Icons.schedule,
                title: 'View Timetable',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TeacherTimetableScreen(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                icon: Icons.add_circle_outline,
                title: 'Create Timetable',
                color: Colors.indigo,
                onTap: () {
                  _navigateToCreateTimetable();
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

          // Inbox section
          _buildInboxSection(),

          const SizedBox(height: 16),

          // Recent communications preview
          _buildRecentCommunicationsPreview(),

          const SizedBox(height: 16),

          // Admin communications preview
          _buildAdminCommunicationsPreview(),
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

  Widget _buildInboxSection() {
    return Consumer(
      builder: (context, ref, child) {
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
                  Icon(Icons.inbox, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Inbox',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      // Load user communications (inbox)
                      await ref
                          .read(RiverpodProvider.communicationProvider.notifier)
                          .getUserCommunications(refresh: true);
                      _showInboxDialog();
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Show recent inbox messages
              if (communicationProvider.hasCommunications)
                ...communicationProvider.communications
                    .take(3)
                    .map((comm) => _buildInboxPreviewItem(comm))
              else
                const Text(
                  'No messages in inbox',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInboxPreviewItem(CommunicationModel communication) {
    final isUnread =
        !communication.readBy.any(
          (read) =>
              read.userId ==
              ref.read(RiverpodProvider.profileProvider).user?.id,
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUnread ? Colors.blue[200]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _getCommunicationTypeColor(
              communication.communicationType,
            ),
            child: Text(
              communication.sender.firstName.isNotEmpty
                  ? communication.sender.firstName[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        communication.title.isNotEmpty
                            ? communication.title
                            : communication.message,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isUnread ? FontWeight.w600 : FontWeight.normal,
                          color: isUnread ? Colors.blue[800] : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'From: ${communication.sender.firstName} ${communication.sender.lastName}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat(
              'MMM dd',
            ).format(DateTime.parse(communication.createdAt)),
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showInboxDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => _InboxDialog(),
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
                'Messages to Parents',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  // Load teacher-to-parent communications
                  await ref
                      .read(RiverpodProvider.communicationProvider.notifier)
                      .getClassCommunications(
                        classId: _selectedClassId!,
                        communicationType:
                            CommunicationType.teacherParent.value,
                      );
                  _showCommunicationDialog(
                    CommunicationType.teacherParent,
                    _selectedClassId!,
                    null,
                    [],
                  );
                },
                child: const Text('View All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (communicationProvider.hasCommunications) ...[
            // Show only teacher-to-parent communications
            ...communicationProvider
                .getTeacherToParentCommunications()
                .take(2)
                .map((comm) => _buildCommunicationPreviewItem(comm)),
            // If no teacher-to-parent communications, show a message
            if (communicationProvider
                .getTeacherToParentCommunications()
                .isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No teacher-to-parent communications yet',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ),
          ] else
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

  Widget _buildAdminCommunicationsPreview() {
    final communicationProvider = ref.watch(
      RiverpodProvider.communicationProvider,
    );

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
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 16,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Messages from Admin',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  // Load admin-to-teacher communications
                  await ref
                      .read(RiverpodProvider.communicationProvider.notifier)
                      .getClassCommunications(
                        classId: _selectedClassId!,
                        communicationType: CommunicationType.adminTeacher.value,
                      );
                  _showCommunicationDialog(
                    CommunicationType.adminTeacher,
                    _selectedClassId!,
                    null,
                    [],
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (communicationProvider.hasCommunications) ...[
            // Show only admin-to-teacher communications
            ...communicationProvider
                .getAdminToTeacherCommunications()
                .take(2)
                .map((comm) => _buildCommunicationPreviewItem(comm)),
            // If no admin-to-teacher communications, show a message
            if (communicationProvider.getAdminToTeacherCommunications().isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No messages from admin yet',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ),
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No admin communications',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommunicationPreviewItem(CommunicationModel communication) {
    final isTeacherToParent =
        communication.communicationType ==
        CommunicationType.teacherParent.value;
    final isAdminToTeacher =
        communication.communicationType == CommunicationType.adminTeacher.value;

    Color avatarColor;
    Color textColor;
    String typeLabel;

    if (isTeacherToParent) {
      avatarColor = Colors.teal[100]!;
      textColor = Colors.teal[700]!;
      typeLabel = 'Teacher → Parent';
    } else if (isAdminToTeacher) {
      avatarColor = Colors.blue[100]!;
      textColor = Colors.blue[700]!;
      typeLabel = 'Admin → Teacher';
    } else {
      avatarColor = Colors.grey[100]!;
      textColor = Colors.grey[700]!;
      typeLabel = communication.communicationType.replaceAll('_', ' → ');
    }

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
                backgroundColor: avatarColor,
                child: Text(
                  communication.sender.firstName.isNotEmpty
                      ? communication.sender.firstName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      communication.sender.fullName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      typeLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
    // Load communications with specific type filter
    await ref
        .read(RiverpodProvider.communicationProvider.notifier)
        .getClassCommunications(
          classId: classId,
          communicationType: type.value,
        );

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

  void _navigateToCreateTimetable() {
    if (!_isClassTeacher || _selectedClassId == null) {
      showSnackbar(context, 'You must be a class teacher to create timetables');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateTimetale(preselectedClassId: _selectedClassId),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Color _getCommunicationTypeColor(String communicationType) {
    switch (communicationType) {
      case 'ADMIN_TEACHER':
        return Colors.blue;
      case 'ADMIN_PARENT':
        return Colors.green;
      case 'TEACHER_ADMIN':
        return Colors.orange;
      case 'PARENT_TEACHER':
        return Colors.purple;
      case 'TEACHER_PARENT':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

class _InboxDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_InboxDialog> createState() => _InboxDialogState();
}

class _InboxDialogState extends ConsumerState<_InboxDialog> {
  @override
  Widget build(BuildContext context) {
    final communicationProvider = ref.watch(
      RiverpodProvider.communicationProvider,
    );

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      contentPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.inbox, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          const Text(
            'Inbox',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child:
            communicationProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : communicationProvider.hasCommunications
                ? ListView.builder(
                  itemCount: communicationProvider.communications.length,
                  itemBuilder: (context, index) {
                    final communication =
                        communicationProvider.communications[index];
                    return _buildInboxItem(communication);
                  },
                )
                : const Center(
                  child: Text(
                    'No messages in inbox',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildInboxItem(CommunicationModel communication) {
    final isUnread =
        !communication.readBy.any(
          (read) =>
              read.userId ==
              ref.read(RiverpodProvider.profileProvider).user?.id,
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread ? Colors.blue[200]! : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          // Mark as read
          if (isUnread) {
            await ref
                .read(RiverpodProvider.communicationProvider.notifier)
                .markAsRead(communicationId: communication.id);
          }

          // Show thread
          await ref
              .read(RiverpodProvider.communicationProvider.notifier)
              .getCommunicationThread(threadId: communication.threadId);

          Navigator.pop(context);
          _showThreadDialog(communication);
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: _getCommunicationTypeColor(
                communication.communicationType,
              ),
              child: Text(
                communication.sender.firstName.isNotEmpty
                    ? communication.sender.firstName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          communication.title.isNotEmpty
                              ? communication.title
                              : communication.message,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                isUnread ? FontWeight.w600 : FontWeight.w500,
                            color: isUnread ? Colors.blue[800] : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'From: ${communication.sender.firstName} ${communication.sender.lastName}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'MMM dd, yyyy • HH:mm',
                    ).format(DateTime.parse(communication.createdAt)),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Color _getCommunicationTypeColor(String communicationType) {
    switch (communicationType) {
      case 'ADMIN_TEACHER':
        return Colors.blue;
      case 'ADMIN_PARENT':
        return Colors.green;
      case 'TEACHER_ADMIN':
        return Colors.orange;
      case 'PARENT_TEACHER':
        return Colors.purple;
      case 'TEACHER_PARENT':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _showThreadDialog(CommunicationModel communication) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder:
          (context) => CommunicationDialog(
            classId: communication.classId ?? '',
            communicationType: CommunicationType.values.firstWhere(
              (type) => type.value == communication.communicationType,
              orElse: () => CommunicationType.teacherParent,
            ),
            threadId:
                communication
                    .threadId, // Pass threadId for thread-based communication
          ),
    );
  }
}
