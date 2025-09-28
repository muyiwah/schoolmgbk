import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/models/teacher_model.dart';
import 'package:schmgtsystem/models/timetable_model.dart';

class TeacherTimetableScreen extends ConsumerStatefulWidget {
  const TeacherTimetableScreen({super.key});

  @override
  ConsumerState<TeacherTimetableScreen> createState() =>
      _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState
    extends ConsumerState<TeacherTimetableScreen> {
  String? _selectedClassId;
  bool _isClassTeacher = false;
  TimetableModel? _teacherTimetable;
  bool _isLoadingTimetable = false;

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

      // Auto-detect class teacher assignment
      _detectClassTeacherAssignment();

      // Load timetable for the teacher's class
      _loadTeacherTimetable();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading teacher data: $e');
      }
    }
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

      setState(() {
        _isClassTeacher = true;
        _selectedClassId = classTeacherClass.id;
      });
    } else {
      setState(() {
        _isClassTeacher = false;
        _selectedClassId = null;
      });
    }
  }

  Future<void> _loadTeacherTimetable() async {
    if (_selectedClassId == null) return;

    try {
      setState(() {
        _isLoadingTimetable = true;
      });

      final success = await ref
          .read(RiverpodProvider.timetableProvider.notifier)
          .getClassTimetable(classId: _selectedClassId!);

      if (success) {
        final timetableProvider = ref.read(RiverpodProvider.timetableProvider);
        setState(() {
          _teacherTimetable = timetableProvider.currentTimetable;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading timetable: $e');
      }
    } finally {
      setState(() {
        _isLoadingTimetable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Class Timetable'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTeacherTimetable,
            tooltip: 'Refresh Timetable',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isClassTeacher || _selectedClassId == null) {
      return _buildNotClassTeacherState();
    }

    if (_isLoadingTimetable) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_teacherTimetable == null) {
      return _buildEmptyTimetableState();
    }

    return _buildTimetableContent();
  }

  Widget _buildNotClassTeacherState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Not a Class Teacher',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You are not assigned as a class teacher.\nTimetable access is only available for class teachers.',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTimetableState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No Timetable Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Timetable for your class has not been created yet.\nPlease contact the administrator.',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTeacherTimetable,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimetableHeader(),
          const SizedBox(height: 20),
          _buildTimetableGrid(),
        ],
      ),
    );
  }

  Widget _buildTimetableHeader() {
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
          Icon(Icons.schedule, color: Colors.blue[600], size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Class Timetable',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Academic Year: ${_teacherTimetable?.academicYear ?? 'N/A'} | Term: ${_teacherTimetable?.term ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (_isLoadingTimetable)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.blue[600]),
              onPressed: _loadTeacherTimetable,
              tooltip: 'Refresh Timetable',
            ),
        ],
      ),
    );
  }

  Widget _buildTimetableGrid() {
    if (_teacherTimetable == null) return Container();

    // Get all unique time slots from the schedule
    final allTimeSlots = <String>{};
    for (final daySchedule in _teacherTimetable!.schedule) {
      for (final period in daySchedule.periods) {
        allTimeSlots.add('${period.startTime} - ${period.endTime}');
      }
    }

    // Sort time slots chronologically by start time
    final sortedTimeSlots = allTimeSlots.toList();
    sortedTimeSlots.sort((a, b) {
      // Extract start time from "8:00AM - 8:45AM" format
      final startTimeA = a.split(' - ')[0];
      final startTimeB = b.split(' - ')[0];

      // Convert to DateTime for proper comparison
      final timeA = _parseTime12Hour(startTimeA);
      final timeB = _parseTime12Hour(startTimeB);

      return timeA.compareTo(timeB);
    });

    return Container(
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          dataRowHeight: 75,
          headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
          columns: [
            DataColumn(
              label: Text(
                'Time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].map(
              (day) => DataColumn(
                label: Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
          rows:
              sortedTimeSlots.map((timeSlot) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        timeSlot,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    ...[
                      'Monday',
                      'Tuesday',
                      'Wednesday',
                      'Thursday',
                      'Friday',
                    ].map((day) {
                      // Find the day schedule
                      final daySchedule =
                          _teacherTimetable!.schedule
                              .where(
                                (schedule) =>
                                    schedule.day.toLowerCase() ==
                                    day.toLowerCase(),
                              )
                              .firstOrNull;

                      // Find the period for this time slot
                      final period =
                          daySchedule?.periods
                              .where(
                                (p) =>
                                    '${p.startTime} - ${p.endTime}' == timeSlot,
                              )
                              .firstOrNull;

                      return DataCell(
                        period != null
                            ? _buildTimetableCell(
                              period.subject,
                              period.teacher ?? '',
                              period.room ?? '',
                            )
                            : Container(),
                      );
                    }),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildTimetableCell(String subject, String teacher, String room) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getSubjectColor(subject).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getSubjectColor(subject).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            subject,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: _getSubjectColor(subject),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (teacher.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              teacher,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (room.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              room,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  DateTime _parseTime12Hour(String timeString) {
    try {
      // Handle formats like "8:00AM", "10:15AM", "2:30PM"
      final timeRegex = RegExp(
        r'(\d{1,2}):(\d{2})(AM|PM)',
        caseSensitive: false,
      );
      final match = timeRegex.firstMatch(timeString);

      if (match == null) {
        throw FormatException('Invalid time format: $timeString');
      }

      int hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)!.toUpperCase();

      // Convert to 24-hour format
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return DateTime(2024, 1, 1, hour, minute);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing time "$timeString": $e');
      }
      // Return a default time if parsing fails
      return DateTime(2024, 1, 1, 8, 0);
    }
  }

  Color _getSubjectColor(String subject) {
    // Generate consistent colors based on subject name
    final colors = [
      Colors.blue[600]!,
      Colors.green[600]!,
      Colors.purple[600]!,
      Colors.orange[600]!,
      Colors.red[600]!,
      Colors.teal[600]!,
      Colors.pink[600]!,
      Colors.indigo[600]!,
      Colors.cyan[600]!,
    ];

    final hash = subject.hashCode;
    return colors[hash.abs() % colors.length];
  }
}
