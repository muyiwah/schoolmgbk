import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/models/attendance_model.dart';

class AttendanceSummaryScreen extends ConsumerStatefulWidget {
  final String classId;
  final String className;
  final String classLevel;

  const AttendanceSummaryScreen({
    Key? key,
    required this.classId,
    required this.className,
    required this.classLevel,
  }) : super(key: key);

  @override
  ConsumerState<AttendanceSummaryScreen> createState() =>
      _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState
    extends ConsumerState<AttendanceSummaryScreen> {
  @override
  void initState() {
    super.initState();
    _loadAttendanceSummary();
  }

  Future<void> _loadAttendanceSummary() async {
    final attendanceProvider = ref.read(RiverpodProvider.attendanceProvider);
    await attendanceProvider.getAttendanceSummary(classId: widget.classId);
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = ref.watch(RiverpodProvider.attendanceProvider);
    final summary = attendanceProvider.attendanceSummary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Attendance Summary - ${widget.className}'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: _loadAttendanceSummary,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body:
          attendanceProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : attendanceProvider.hasSummaryData
              ? _buildSummaryContent(summary!)
              : _buildEmptyState(),
    );
  }

  Widget _buildSummaryContent(AttendanceSummaryData summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                Text(
                  summary.classInfo.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  summary.classInfo.level,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Students',
                        '${summary.summary.length}',
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Attendance Days',
                        '${summary.totalAttendanceDays}',
                        Icons.calendar_today,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Overall Statistics
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                  'Overall Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildOverallStats(summary.summary),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Student List
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                  'Student Attendance Records',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                ...summary.summary
                    .map((studentSummary) => _buildStudentCard(studentSummary))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStats(List<StudentAttendanceSummary> summaries) {
    if (summaries.isEmpty) {
      return const Text('No data available');
    }

    int totalPresent = 0;
    int totalAbsent = 0;
    int totalDays = summaries.first.totalDays;
    int totalPossibleAttendance = summaries.length * totalDays;

    for (var summary in summaries) {
      totalPresent += summary.presentCount;
      totalAbsent += summary.absentCount;
    }

    double overallRate =
        totalPossibleAttendance > 0
            ? (totalPresent / totalPossibleAttendance) * 100
            : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Present',
                '$totalPresent',
                Colors.green,
                Icons.check_circle,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Absent',
                '$totalAbsent',
                Colors.red,
                Icons.cancel,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'Rate',
                '${overallRate.toStringAsFixed(1)}%',
                Colors.blue,
                Icons.trending_up,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
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
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(StudentAttendanceSummary studentSummary) {
    final attendanceRate = studentSummary.attendanceRate;
    Color rateColor = Colors.green;
    if (attendanceRate < 70) {
      rateColor = Colors.red;
    } else if (attendanceRate < 90) {
      rateColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                child: Text(
                  studentSummary.student.name.split(' ').first[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.blue[700],
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
                      studentSummary.student.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      studentSummary.student.admissionNumber,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: rateColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: rateColor.withOpacity(0.3)),
                ),
                child: Text(
                  '${attendanceRate}%',
                  style: TextStyle(
                    color: rateColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  'Present',
                  '${studentSummary.presentCount}',
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  'Absent',
                  '${studentSummary.absentCount}',
                  Colors.red,
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  'Total Days',
                  '${studentSummary.totalDays}',
                  Colors.blue,
                ),
              ),
            ],
          ),
          if (studentSummary.records.isNotEmpty) ...[
            const SizedBox(height: 12),
            ExpansionTile(
              title: const Text(
                'Recent Records',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              children: [
                ...studentSummary.records
                    .take(5)
                    .map(
                      (record) => Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(DateTime.parse(record.date)),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  record.status,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                record.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(record.status),
                                ),
                              ),
                            ),
                            if (record.remarks.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  record.remarks,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
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
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No attendance summary found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
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
}
