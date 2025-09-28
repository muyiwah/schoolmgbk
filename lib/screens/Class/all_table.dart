import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/models/timetable_model.dart';
import 'package:schmgtsystem/screens/Class/edit_timetable_screen.dart';
import 'package:flutter/foundation.dart';

class AllTables extends ConsumerStatefulWidget {
  final Function navigateBack;
  AllTables({super.key, required this.navigateBack});

  @override
  ConsumerState<AllTables> createState() => _AllTablesState();
}

class _AllTablesState extends ConsumerState<AllTables> {
  String? selectedClassId;
  TimetableModel? selectedTimetable;
  bool isLoadingTimetable = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    await ref
        .read(RiverpodProvider.classProvider.notifier)
        .getAllClasses(context);
  }

  Future<void> _loadTimetableForClass(String classId) async {
    if (classId.isEmpty) return;

    setState(() {
      isLoadingTimetable = true;
    });

    try {
      final success = await ref
          .read(RiverpodProvider.timetableProvider.notifier)
          .getClassTimetable(classId: classId);

      if (success) {
        final timetableProvider = ref.read(RiverpodProvider.timetableProvider);
        setState(() {
          selectedTimetable = timetableProvider.currentTimetable;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading timetable for class $classId: $e');
      }
    } finally {
      setState(() {
        isLoadingTimetable = false;
      });
    }
  }

  void _onClassSelected(String classId) {
    setState(() {
      selectedClassId = classId;
      selectedTimetable = null;
    });
    _loadTimetableForClass(classId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(
                navigate: () {
                  widget.navigateBack();
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildClassSelector(),
                          const SizedBox(height: 20),
                          _buildTimetableCard(),
                          // const SizedBox(height: 20),
                          // _buildActionsSection(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(flex: 1, child: _buildQuickStats()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required navigate}) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, Color(0xFF8B5CF6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Class Timetables',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Easily view and switch between class schedules',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _navigateToEditTimetable(),
                icon: Icon(Icons.edit, size: 16),
                label: Text('Edit Timetable'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF6366F1),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 40,
          left: 30,
          child: IconButton(
            onPressed: () {
              navigate();
            },
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildClassSelector() {
    final classProvider = ref.watch(RiverpodProvider.classProvider);

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Class',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            if (classProvider.classData.classes?.isEmpty ?? true)
              const Center(
                child: Text(
                  'No classes available',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    (classProvider.classData.classes ?? []).map((classItem) {
                      bool isSelected = classItem.id == selectedClassId;
                      return GestureDetector(
                        onTap: () => _onClassSelected(classItem.id ?? ''),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Color(0xFF6366F1)
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            classItem.level ?? 'Unnamed Class',
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.grey[700],
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableCard() {
    final classProvider = ref.watch(RiverpodProvider.classProvider);
    final selectedClass =
        (classProvider.classData.classes ?? [])
            .where((c) => c.id == selectedClassId)
            .firstOrNull;

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${selectedClass?.name ?? 'Select a Class'} - Weekly Timetable',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            if (selectedClassId == null)
              const Center(
                child: Text(
                  'Please select a class to view timetable',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            else if (isLoadingTimetable)
              const Center(child: CircularProgressIndicator())
            else if (selectedTimetable == null)
              const Center(
                child: Text(
                  'No timetable data available for this class',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            else
              _buildTimetableGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableGrid() {
    if (selectedTimetable == null) return Container();

    // Get all unique time slots from the schedule
    final allTimeSlots = <String>{};
    for (final daySchedule in selectedTimetable!.schedule) {
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowHeight: 75,
        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
        columns: [
          DataColumn(
            label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        selectedTimetable!.schedule
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
                            TimetableEntry(
                              period.subject,
                              period.teacher ?? '',
                              period.room ?? '',
                              _getSubjectColor(period.subject),
                            ),
                          )
                          : Container(),
                    );
                  }),
                ],
              );
            }).toList(),
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
      Colors.blue[100]!,
      Colors.green[100]!,
      Colors.purple[100]!,
      Colors.orange[100]!,
      Colors.red[100]!,
      Colors.amber[100]!,
      Colors.teal[100]!,
      Colors.pink[100]!,
      Colors.indigo[100]!,
      Colors.cyan[100]!,
    ];

    final hash = subject.hashCode;
    return colors[hash.abs() % colors.length];
  }

  Widget _buildTimetableCell(TimetableEntry entry) {
    return Container(
      width: 120,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: entry.color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: entry.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            entry.subject,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
          if (entry.teacher.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              entry.teacher,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
          if (entry.room.isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(
              entry.room,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionButton(
                  'Print Timetable',
                  Icons.print,
                  Color(0xFF6366F1),
                ),
                _buildActionButton(
                  'Export PDF',
                  Icons.picture_as_pdf,
                  Color(0xFF8B5CF6),
                ),
                _buildActionButton(
                  'Assign Substitute',
                  Icons.person_add,
                  Color(0xFF06B6D4),
                ),
                _buildActionButton(
                  'Switch Term',
                  Icons.swap_horiz,
                  Colors.grey[600]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      children: [
        _buildStatsCard(),
        const SizedBox(height: 20),
        _buildMostTaughtCard(),
        const SizedBox(height: 20),
        _buildSubjectHoursCard(),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Total Subjects', '8'),
            _buildStatRow('Free Periods', '3'),
            _buildStatRow('Conflicts', '0', color: Colors.green),
            _buildStatRow('Total Hours', '25'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color ?? Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMostTaughtCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Taught Subject',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.calculate,
                      size: 32,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mathematics',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    '6 hours/week',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectHoursCard() {
    final subjects = [
      {'name': 'Mathematics', 'hours': 6, 'color': Colors.blue},
      {'name': 'English', 'hours': 5, 'color': Colors.green},
      {'name': 'Science', 'hours': 4, 'color': Colors.purple},
      {'name': 'Others', 'hours': 10, 'color': Colors.grey},
    ];

    return Card(
      color: Colors.white,

      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject Hours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            ...subjects.map((subject) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        subject['name'] as String,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 6,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (subject['hours'] as int) / 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: subject['color'] as Color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '${subject['hours']}h',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _navigateToEditTimetable() {
    if (selectedClassId == null || selectedTimetable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a class with an existing timetable'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final classProvider = ref.read(RiverpodProvider.classProvider);
    final selectedClass =
        (classProvider.classData.classes ?? [])
            .where((c) => c.id == selectedClassId)
            .firstOrNull;

    if (selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected class not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditTimetableScreen(
              classId: selectedClassId!,
              className: selectedClass.level ?? 'Unknown Class',
              existingTimetable: selectedTimetable,
            ),
      ),
    ).then((result) {
      // Refresh timetable data if edit was successful
      if (result == true) {
        _loadTimetableForClass(selectedClassId!);
      }
    });
  }
}

class TimetableEntry {
  final String subject;
  final String teacher;
  final String room;
  final Color color;

  TimetableEntry(this.subject, this.teacher, this.room, this.color);
}
