import 'package:flutter/material.dart';
import 'package:schmgtsystem/constants/appcolor.dart';

class AllTables extends StatefulWidget {
  final Function navigateBack;
  AllTables({super.key, required this.navigateBack});

  @override
  _AllTablesState createState() => _AllTablesState();
}

class _AllTablesState extends State<AllTables> {
  String selectedClass = 'Grade 1A';

  final List<String> classes = [
    'Grade 1A',
    'Grade 2A',
    'JSS1',
    'JSS2',
    'SS1',
    'SS2',
    'SS3',
  ];

  final Map<String, List<TimetableEntry>> timetableData = {
    'Monday': [
      TimetableEntry(
        'Mathematics',
        'Mr. Johnson',
        'Room 101',
        Colors.blue[100]!,
      ),
      TimetableEntry('English', 'Ms. Smith', 'Room 102', Colors.green[100]!),
      TimetableEntry('Break', '', '', Colors.grey[100]!),
      TimetableEntry('English', 'Ms. Smith', 'Room 102', Colors.green[100]!),
      TimetableEntry('English', 'Ms. Smith', 'Room 102', Colors.red[100]!),

      TimetableEntry('English', 'Ms. Smith', 'Room 102', Colors.blue[100]!),
    ],
    'Tuesday': [
      TimetableEntry('English', 'Ms. Smith', 'Room 102', Colors.amber[100]!),
      TimetableEntry(
        'Mathematics',
        'Mr. Johnson',
        'Room 101',
        Colors.blue[100]!,
      ),
      TimetableEntry('Science', 'Dr. Brown', 'Lab 1', Colors.purple[100]!),
      TimetableEntry('English', 'Ms. Smith', 'Room 102', Colors.grey[100]!),
      TimetableEntry('English', 'Ms. Smith', 'Room 102', Colors.red[100]!),

      TimetableEntry(
        'English',
        'Ms. Smith',
        'Room 102',
        Colors.deepPurple[100]!,
      ),
    ],
    'Wednesday': [
      TimetableEntry('Science', 'Dr. Brown', 'Lab 1', Colors.purple[100]!),
      TimetableEntry('Break', '', '', Colors.grey[100]!),
      TimetableEntry('English', 'Ms. Smith', 'Room 102', Colors.green[100]!),
      TimetableEntry('English', 'Ms. Smith', 'Room 102', Colors.purple[100]!),
      TimetableEntry('English', 'Ms. Smith', 'Room 102', Colors.red[100]!),

      TimetableEntry('English', 'Ms. Smith', 'Room 102', Colors.yellow[100]!),
    ],
    'Thursday': [
      TimetableEntry('Art', 'Ms. Davis', 'Art Room', Colors.yellow[100]!),
      TimetableEntry('History', 'Mr. Taylor', 'Room 103', Colors.orange[100]!),
      TimetableEntry(
        'Mathematics',
        'Mr. Johnson',
        'Room 101',
        Colors.blue[100]!,
      ),
      TimetableEntry('English', 'Ms. Smith', 'Room 102', Colors.purple[100]!),
      TimetableEntry(
        'English',
        'Ms. Smith',
        'Room 102',
        Colors.pinkAccent[100]!,
      ),

      TimetableEntry(
        'English',
        'Ms. Smith',
        'Room 102',
        Colors.deepOrange[100]!,
      ),
    ],
    'Friday': [
      TimetableEntry('PE', 'Mr. Wilson', 'Gym', Colors.red[100]!),
      TimetableEntry('Music', 'Ms. Lee', 'Music Room', Colors.blue[100]!),
      TimetableEntry('Free Period', '', '', Colors.grey[100]!),
      TimetableEntry('English', 'Ms. Smith', 'Room 102', Colors.green[100]!),
      TimetableEntry(
        'English',
        'Ms. Smith',
        'Room 102',
        Colors.deepPurple[100]!,
      ),

      TimetableEntry('English', 'Ms. Smith', 'Room 102', Colors.red[100]!),
    ],
  };

  final List<String> timeSlots = [
    '8:00-9:00',
    '9:00-10:00',
    '10:00-11:00',
    '11:00-12:00',
    '12:00-1:00',
    '1:00-2:00',
  ];

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
                          const SizedBox(height: 20),
                          _buildActionsSection(),
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

  Widget _buildHeader({required  navigate}) {
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
                onPressed: () {},
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
    return Card(
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  classes.map((className) {
                    bool isSelected = className == selectedClass;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedClass = className;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Color(0xFF6366F1) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          className,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$selectedClass - Weekly Timetable',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            _buildTimetableGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableGrid() {
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
            timeSlots.asMap().entries.map((entry) {
              int index = entry.key;
              String timeSlot = entry.value;

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
                    List<TimetableEntry> dayEntries = timetableData[day] ?? [];
                    TimetableEntry? entry =
                        index < dayEntries.length ? dayEntries[index] : null;

                    return DataCell(
                      entry != null ? _buildTimetableCell(entry) : Container(),
                    );
                  }),
                ],
              );
            }).toList(),
      ),
    );
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
}

class TimetableEntry {
  final String subject;
  final String teacher;
  final String room;
  final Color color;

  TimetableEntry(this.subject, this.teacher, this.room, this.color);
}
