import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/models/attendance_model.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';
import 'package:schmgtsystem/utils/academic_year_helper.dart';

class AttendanceMarkingScreen extends ConsumerStatefulWidget {
  final String classId;
  final String className;
  final String classLevel;

  const AttendanceMarkingScreen({
    Key? key,
    required this.classId,
    required this.className,
    required this.classLevel,
  }) : super(key: key);

  @override
  ConsumerState<AttendanceMarkingScreen> createState() =>
      _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState
    extends ConsumerState<AttendanceMarkingScreen> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, String> _attendanceStatus = {};
  final Map<String, String> _attendanceRemarks = {};
  bool _isSubmitting = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadAttendanceForDate();
  }

  Future<void> _loadAttendanceForDate() async {
    final attendanceProvider = ref.read(RiverpodProvider.attendanceProvider);
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    await attendanceProvider.getAttendanceByDate(
      classId: widget.classId,
      date: dateString,
    );

    if (attendanceProvider.hasAttendanceData) {
      _populateExistingAttendance();
    }
  }

  void _populateExistingAttendance() {
    final attendanceProvider = ref.read(RiverpodProvider.attendanceProvider);
    final records = attendanceProvider.attendanceRecords;

    for (var record in records) {
      _attendanceStatus[record.student.id] = record.status;
      _attendanceRemarks[record.student.id] = record.remarks;
    }

    setState(() {});
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _attendanceStatus.clear();
        _attendanceRemarks.clear();
      });
      await _loadAttendanceForDate();
    }
  }

  Future<void> _submitAttendance() async {
    final attendanceProvider = ref.read(RiverpodProvider.attendanceProvider);
    final records = attendanceProvider.attendanceRecords;

    if (records.isEmpty) {
      showSnackbar(context, 'No students found for this class');
      return;
    }

    // Ensure all students have a status (default to 'absent' if not marked)
    final allStudentRecords =
        records.map((record) {
          final studentId = record.student.id;
          final status = _attendanceStatus[studentId] ?? 'absent';
          final remarks = _attendanceRemarks[studentId] ?? '';

          return AttendanceRecord(
            studentId: studentId,
            status: status,
            remarks: remarks,
          );
        }).toList();

    setState(() {
      _isSubmitting = true;
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
        term: AcademicYearHelper.getCurrentTerm(ref),
        academicYear: AcademicYearHelper.getCurrentAcademicYear(ref),
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
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = ref.watch(RiverpodProvider.attendanceProvider);
    final records = attendanceProvider.attendanceRecords;
    final isSubmitted = attendanceProvider.isAttendanceSubmitted;
    final isLocked = attendanceProvider.isAttendanceLocked;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Mark Attendance - ${widget.className}'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          if (_hasUnsavedChanges && !isSubmitted)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.className,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            widget.classLevel,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[700],
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
                    ElevatedButton.icon(
                      onPressed: isLocked ? null : _selectDate,
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: const Text('Change Date'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (attendanceProvider.hasAttendanceData) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Text(
                          '${records.length} Students',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Attendance List
          Expanded(
            child:
                attendanceProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : attendanceProvider.hasAttendanceData
                    ? _buildAttendanceList(records, isLocked)
                    : _buildEmptyState(),
          ),

          // Submit Button
          if (attendanceProvider.hasAttendanceData && !isSubmitted)
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
                          'All ${records.length} students will be marked for ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Unmarked students will be marked as "Absent"',
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
                        isLocked || _isSubmitting ? null : _submitAttendance,
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
                        _isSubmitting
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
                                  'Submit Attendance for All Students',
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
      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No attendance data found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a different date or check if students are enrolled',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
