import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/single_class_model.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/widgets/message_popup.dart';

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

  @override
  void initState() {
    super.initState();
    _loadClassData();
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
                  ),
                  const SizedBox(height: 8),

                  _buildActionButton(
                    '✏️ Message Single Parent',
                    AppColors.tertiary3,
                    Colors.white,
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    '👤 Message All Parents',
                    const Color(0xFF06B6D4),
                    Colors.white,
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

  Widget _buildActionButton(String text, Color bgColor, Color textColor) {
    return ElevatedButton(
      onPressed: () {
        if (text.contains('Message Class Teacher')) {
          showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            builder:
                (context) => MessagePopup(title: 'Message to Class Teacher'),
          );
        }
        if (text.contains('Single')) {
          showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            builder: (context) => MessagePopup(title: 'Message to a Parent'),
          );
        }
        if (text.contains('All')) {
          showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            builder: (context) => MessagePopup(title: 'Message to all Parents'),
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
                onTap: () => setState(() => selectedTabIndex = index),
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
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildStudentsListAttendance(List<Student> students) {
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
                  'Attendance',
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
                      return _buildStudentRowAttendance(
                        student.name ?? 'Unknown Student',
                        student.admissionNumber ?? 'N/A',
                        student.parentName ?? 'N/A',
                        student.todayAttendance ?? 'N/A',
                      );
                    },
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
              onPressed: () {},
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

  Widget _buildStudentRowAttendance(
    String name,
    String admissionNo,
    String parent,
    String attendance,
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
          // Expanded(
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          //     decoration: BoxDecoration(
          //       color: statusColor.withOpacity(0.1),
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     child: Text(
          //       feeStatus,
          //       style: TextStyle(
          //         color: statusColor,
          //         fontSize: 12,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ),
          // ),
          // Expanded(child: Text(attendance)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Mark Attendance',
                  style: TextStyle(color: Color(0xFF6366F1)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
