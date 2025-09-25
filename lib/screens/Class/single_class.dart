import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/single_class_model.dart';
import 'package:schmgtsystem/models/attendance_model.dart';
import 'package:schmgtsystem/models/communication_model.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/widgets/message_popup.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';

class ClassDetailsScreen extends ConsumerStatefulWidget {
  final String classId;

  const ClassDetailsScreen({super.key, required this.classId});

  @override
  ConsumerState<ClassDetailsScreen> createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends ConsumerState<ClassDetailsScreen> {
  int selectedTabIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  // Attendance state
  DateTime _selectedDate = DateTime.now();
  final Map<String, String> _attendanceStatus = {};
  final Map<String, String> _attendanceRemarks = {};
  bool _isSubmittingAttendance = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadClassData();
  }

  @override
  void didUpdateWidget(ClassDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (selectedTabIndex == 1) {
      _loadAttendanceForDate();
    }
  }

  Future<void> _loadClassData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('Loading class data for classId: ${widget.classId}');

      await ref
          .read(RiverpodProvider.classProvider)
          .getSingleClass(context, widget.classId);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading class data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load class data: $e';
        });
      }
    }
  }

  Future<void> _loadAttendanceForDate() async {
    final attendanceProvider = ref.read(RiverpodProvider.attendanceProvider);
    final classProvider = ref.read(RiverpodProvider.classProvider);
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // First, ensure we have class data loaded
    if (classProvider.singlgeClassData.data?.students == null) {
      await _loadClassData();
    }

    // Try to fetch existing attendance data for the date
    await attendanceProvider.getAttendanceByDate(
      classId: widget.classId,
      date: dateString,
    );

    // Initialize all students with default absent status
    _initializeAllStudentsWithDefaultStatus();

    // If we have existing attendance data, update the UI
    if (attendanceProvider.hasAttendanceData) {
      _populateExistingAttendance();
    }

    setState(() {});
  }

  void _initializeAllStudentsWithDefaultStatus() {
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
      _attendanceStatus[record.student.id] = record.status;
      _attendanceRemarks[record.student.id] = record.remarks;
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

  Future<void> _submitAttendance() async {
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
        term: 'First', // You might want to get this from a provider
        academicYear: '2025/2026', // You might want to get this from a provider
        markerId: user.id ?? '',
        records: allStudentRecords,
      );

      final success = await attendanceProvider.markAttendance(
        classId: widget.classId,
        request: request,
      );

      if (success) {
        showSnackbar(context, 'Attendance marked successfully!');
        setState(() {
          _hasUnsavedChanges = false;
        });

        // Reload the attendance data
        await _loadAttendanceForDate();
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading class details...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadClassData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final classData =
        ref.watch(RiverpodProvider.classProvider).singlgeClassData;

    print('ClassData received: ${classData.toJson()}');
    print('ClassData.data: ${classData.data}');
    print('ClassData.data?.dataClass: ${classData.data?.dataClass}');

    if (classData.data == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No class data found'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildClassOverview(classData.data!),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildMainContent(classData.data!)),
                const SizedBox(width: 16),
                Expanded(flex: 1, child: _buildSidebar(classData.data!)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassOverview(Data data) {
    final classInfo = data.dataClass;
    final metrics = data.metrics;
    final classTeacher = classInfo?.classTeacher;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, Color(0xFF8B5CF6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class Details – ${classInfo?.name ?? 'Unknown Class'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${classInfo?.level ?? 'Unknown Level'} ${classInfo?.section ?? ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Comprehensive view of class assignments, performance, and student information',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            classTeacher?.name?.substring(0, 1).toUpperCase() ??
                                '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classTeacher?.name ?? 'No Class Teacher',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Staff ID: ${classTeacher?.staffId ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.email,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.message,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  Text(
                    '${metrics?.totalStudents ?? 0}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Total Students',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildGenderIcon('👨', '${metrics?.maleStudents ?? 0}'),
                      const SizedBox(width: 8),
                      _buildGenderIcon('👩', '${metrics?.femaleStudents ?? 0}'),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${metrics?.todayAttendance?.attendancePercentage ?? 0}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Today\'s Attendance',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  _buildActionButton(
                    '📧 Message Class Teacher',
                    Colors.white,
                    const Color(0xFF6366F1),
                    data,
                  ),
                  const SizedBox(height: 8),

                  _buildActionButton(
                    '✏️ Message Single Parent',
                    AppColors.tertiary3,
                    Colors.white,
                    data,
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    '👤 Message All Parents',
                    const Color(0xFF06B6D4),
                    Colors.white,
                    data,
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 20,
          left: 0,
          child: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderIcon(String emoji, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 2),
          Text(
            count,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    Color bgColor,
    Color textColor,
    Data classData,
  ) {
    return ElevatedButton(
      onPressed: () {
        if (text.contains('Message Class Teacher')) {
          showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            builder:
                (context) => MessagePopup(
                  title: 'Message to Class Teacher',
                  classId: classData.dataClass?.id ?? '',
                  classData: classData,
                  communicationType: CommunicationType.adminTeacher,
                ),
          );
        }
        if (text.contains('Single')) {
          showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            builder:
                (context) => MessagePopup(
                  title: 'Message to a Parent',
                  classId: classData.dataClass?.id ?? '',
                  classData: classData,
                  communicationType: CommunicationType.adminParent,
                ),
          );
        }
        if (text.contains('All')) {
          showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            builder:
                (context) => MessagePopup(
                  title: 'Message to all Parents',
                  classId: classData.dataClass?.id ?? '',
                  classData: classData,
                  parentIds: _getAllParentIds(classData),
                  communicationType: CommunicationType.adminParent,
                ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  List<String> _getAllParentIds(Data classData) {
    // Since parentId doesn't exist in Student model, we'll return student IDs for now
    // The backend will use these student IDs to find the associated parents
    // This would need to be updated when parentId is added to the Student model
    return classData.students
            ?.map((student) => student.id ?? '')
            .where((id) => id.isNotEmpty)
            .toList() ??
        [];
  }

  Widget _buildMainContent(Data data) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child:
                selectedTabIndex == 1
                    ? _buildStudentsListAttendance(data.students ?? [])
                    : _buildStudentsList(data.students ?? []),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Students List', 'Attendance'];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children:
            tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isSelected = index == selectedTabIndex;

              return GestureDetector(
                onTap: () {
                  setState(() => selectedTabIndex = index);
                  if (index == 1) {
                    _loadAttendanceForDate();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            isSelected
                                ? const Color(0xFF6366F1)
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      color:
                          isSelected
                              ? const Color(0xFF6366F1)
                              : Colors.grey[600],
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildStudentsList(List<Student> students) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Student',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  'Admission No.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  'Parent/Guardian',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  'Fee Status',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  'Attendance',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  'Action',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              students.isEmpty
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No students found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _buildStudentRow(
                        student.name ?? 'Unknown Student',
                        student.admissionNumber ?? 'N/A',
                        student.parentName ?? 'N/A',
                        student.feeStatus ?? 'Unknown',
                        student.todayAttendance ?? 'N/A',
                        _getFeeStatusColor(student.feeStatus),
                        student.id ??
                            student.admissionNumber ??
                            'N/A', // Pass student ID
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildStudentsListAttendance(List<Student> students) {
    final attendanceProvider = ref.watch(RiverpodProvider.attendanceProvider);
    final records = attendanceProvider.attendanceRecords;
    final isSubmitted =
        attendanceProvider.attendanceByDate?.isSubmitted ?? false;
    final isLocked = attendanceProvider.attendanceByDate?.isLocked ?? false;

    return Column(
      children: [
        // Header with date picker and status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
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
            ],
          ),
        ),

        // Students list - Always show all students
        Expanded(
          child:
              attendanceProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : students.isEmpty
                  ? _buildEmptyAttendanceState()
                  : _buildAllStudentsAttendanceList(students, isLocked),
        ),

        // Submit/Resubmit button - Always show if there are students
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
                // Summary of what will be submitted
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
                        'All ${students.length} students will be marked for ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                        style: TextStyle(fontSize: 13, color: Colors.blue[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSubmitted
                            ? 'Click "Resubmit" to update attendance records'
                            : 'All students default to "Absent" until marked',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[500],
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
                          : _submitAttendance,
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
                                style: TextStyle(
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

  Color _getFeeStatusColor(String? feeStatus) {
    switch (feeStatus?.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'unpaid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStudentRow(
    String name,
    String admissionNo,
    String parent,
    String feeStatus,
    String attendance,
    Color statusColor,
    String studentId,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/32',
                  ),
                ),
                const SizedBox(width: 8),
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Expanded(child: Text(admissionNo)),
          Expanded(child: Text(parent)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                feeStatus,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(child: Text(attendance)),
          Expanded(
            child: TextButton(
              onPressed: () {
                // Navigate to student profile using the student ID
                context.go('/students/single/$studentId');
              },
              child: const Text(
                'View Profile',
                style: TextStyle(color: Color(0xFF6366F1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllStudentsAttendanceList(
    List<Student> students,
    bool isLocked,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
                      color: _getStatusColor(currentStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getStatusColor(currentStatus).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      currentStatus.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(currentStatus),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
    );
  }

  Widget _buildAttendanceList(
    List<AttendanceRecordDetail> records,
    bool isLocked,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final student = record.student;
        final currentStatus = _attendanceStatus[student.id] ?? record.status;
        final currentRemarks = _attendanceRemarks[student.id] ?? record.remarks;

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
                      student.personalInfo.firstName[0].toUpperCase(),
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
                          student.personalInfo.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          student.admissionNumber,
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
                      color: _getStatusColor(currentStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getStatusColor(currentStatus).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      currentStatus.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(currentStatus),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
                        student.id,
                        Colors.green,
                        currentStatus == 'present',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatusButton(
                        'Absent',
                        'absent',
                        student.id,
                        Colors.red,
                        currentStatus == 'absent',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatusButton(
                        'Late',
                        'late',
                        student.id,
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
                    _updateStudentRemarks(student.id, value);
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
            'No Attendance Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Attendance records will appear here once marked',
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

  Widget _buildSidebar(Data data) {
    return Container(
      margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
      child: Container(
        height: double.infinity,
        child: ListView(
          children: [
            _buildQuickMetrics(data.metrics),
            const SizedBox(height: 16),
            _buildWeeklySchedule(data.academicInfo),
            const SizedBox(height: 16),
            _buildRecentCommunications(data.recentCommunications),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMetrics(Metrics? metrics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Metrics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Outstanding Fees',
            '${metrics?.feeStatus?.unpaid ?? 0} Students',
            Colors.red,
          ),
          _buildMetricRow(
            'Fee Collection Rate',
            '${metrics?.feeCollectionRate ?? '0%'}',
            Colors.green,
          ),
          _buildMetricRow(
            'Gender Ratio',
            '${metrics?.genderRatio?.male ?? '0%'} : ${metrics?.genderRatio?.female ?? '0%'}',
            Colors.grey,
          ),
          _buildMetricRow(
            'Available Slots',
            '${metrics?.availableSlots ?? 0}',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySchedule(AcademicInfo? academicInfo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Academic Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'CURRENT TERM',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _buildScheduleItem(
            'Academic Year',
            academicInfo?.currentAcademicYear ?? 'N/A',
            const Color(0xFF6366F1),
          ),
          _buildScheduleItem(
            'Current Term',
            academicInfo?.currentTerm ?? 'N/A',
            Colors.grey,
          ),
          if (academicInfo?.attendanceDate != null)
            _buildScheduleItem(
              'Last Attendance',
              '${academicInfo!.attendanceDate!.day}/${academicInfo.attendanceDate!.month}/${academicInfo.attendanceDate!.year}',
              Colors.orange,
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String subject, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            color == const Color(0xFF6366F1)
                ? color.withOpacity(0.1)
                : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color == const Color(0xFF6366F1) ? color : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  color == const Color(0xFF6366F1) ? color : Colors.grey[800],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildRecentCommunications(List<dynamic>? recentCommunications) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Communications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          if (recentCommunications == null || recentCommunications.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.message_outlined, size: 32, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No recent communications',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            ...recentCommunications
                .take(2)
                .map(
                  (communication) => _buildCommunicationItem(
                    '📧',
                    'Communication',
                    'Recent message',
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCommunicationItem(String icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
