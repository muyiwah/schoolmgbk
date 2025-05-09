import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fluttertoast/fluttertoast.dart';


class Edit2 extends StatelessWidget {
  const Edit2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Timetable Creator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const TimeTableCreatorScreen(),
    );
  }
}

// Data Models
class Subject {
  final String name;
  final int color;

  Subject({required this.name, required this.color});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class Teacher {
  final String name;
  final String abbreviation;

  Teacher({required this.name, required this.abbreviation});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Teacher &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class Classroom {
  final String name;

  Classroom({required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Classroom &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class TimeTableEntry {
  final Subject? subject;
  final Teacher? teacher;
  final Classroom? classroom;
  final String? notes;

  TimeTableEntry({this.subject, this.teacher, this.classroom, this.notes});

  factory TimeTableEntry.empty() => TimeTableEntry();

  TimeTableEntry copyWith({
    Subject? subject,
    Teacher? teacher,
    Classroom? classroom,
    String? notes,
  }) {
    return TimeTableEntry(
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
      classroom: classroom ?? this.classroom,
      notes: notes ?? this.notes,
    );
  }
}

// Main Screen
class TimeTableCreatorScreen extends StatefulWidget {
  const TimeTableCreatorScreen({super.key});

  @override
  State<TimeTableCreatorScreen> createState() => _TimeTableCreatorScreenState();
}

class _TimeTableCreatorScreenState extends State<TimeTableCreatorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> _defaultDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];
  final Map<String, List<String>> _dayPeriods = {};
  List<List<TimeTableEntry>> _timetable = [];
  List<Subject> _subjects = [];
  List<Teacher> _teachers = [];
  List<Classroom> _classrooms = [];
  String _timetableName = 'My Timetable';
  bool _showDetails = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    setState(() {
      // Initialize each day with default periods
      for (var day in _defaultDays) {
        _dayPeriods[day] = [
          '8:00-9:00',
          '9:00-10:00',
          '10:00-11:00',
          '11:00-11:20', // Break
          '11:20-12:20',
          '12:20-1:20',
          '1:20-2:20',
          '2:20-3:00',
        ];
      }

      // Initialize with sample data
      _subjects = [
        Subject(name: 'Mathematics', color: Colors.blue.value),
        Subject(name: 'English', color: Colors.green.value),
        Subject(name: 'Physics', color: Colors.purple.value),
        Subject(name: 'Chemistry', color: Colors.orange.value),
        Subject(name: 'Biology', color: Colors.red.value),
        Subject(name: 'History', color: Colors.teal.value),
        Subject(name: 'Geography', color: Colors.indigo.value),
        Subject(name: 'Computer Science', color: Colors.pink.value),
        Subject(name: 'Assembly', color: Colors.cyan.value),
        Subject(name: 'Quiz', color: Colors.yellow.value),
      ];

      _teachers = [
        Teacher(name: 'Mr. Smith', abbreviation: 'MS'),
        Teacher(name: 'Ms. Johnson', abbreviation: 'MJ'),
        Teacher(name: 'Dr. Brown', abbreviation: 'DB'),
        Teacher(name: 'Prof. Wilson', abbreviation: 'PW'),
        Teacher(name: 'Mrs. Davis', abbreviation: 'MD'),
      ];

      _classrooms = [
        Classroom(name: 'Room 101'),
        Classroom(name: 'Room 102'),
        Classroom(name: 'Lab A'),
        Classroom(name: 'Lab B'),
        Classroom(name: 'Auditorium'),
      ];

      _resetTimetable();
    });
  }

  void _resetTimetable() {
    setState(() {
      // Find the maximum number of periods across all days
      int maxPeriods = _dayPeriods.values.fold(
        0,
        (max, periods) => periods.length > max ? periods.length : max,
      );

      // Initialize timetable with max periods rows and days columns
      _timetable = List.generate(
        maxPeriods,
        (i) => List.generate(
          _dayPeriods.length,
          (j) => TimeTableEntry.empty(),
          growable: false,
        ),
        growable: false,
      );
    });
  }

  void _addDay(String day) {
    if (day.isEmpty) return;
    setState(() {
      // Add new day with default periods
      _dayPeriods[day] = List.from(_dayPeriods.values.first);
      _resetTimetable();
    });
  }

  void _removeDay(String day) {
    if (_dayPeriods.length <= 1) {
      Fluttertoast.showToast(msg: "You must have at least one day");
      return;
    }
    setState(() {
      _dayPeriods.remove(day);
      _resetTimetable();
    });
  }

  void _addPeriodToDay(String day, String period) {
    if (period.isEmpty) return;
    setState(() {
      _dayPeriods[day]!.add(period);
      _resetTimetable();
    });
  }

  void _removePeriodFromDay(String day, int periodIndex) {
    if (_dayPeriods[day]!.length <= 1) {
      Fluttertoast.showToast(msg: "You must have at least one period");
      return;
    }
    setState(() {
      _dayPeriods[day]!.removeAt(periodIndex);
      _resetTimetable();
    });
  }

  Future<void> _editPeriodForDay(
    String day,
    int periodIndex,
    String newPeriod,
  ) async {
    if (newPeriod.isEmpty) return;
    setState(() {
      _dayPeriods[day]![periodIndex] = newPeriod;
    });
  }

  void _addSubject(String name, Color color) {
    if (name.isEmpty) return;
    setState(() {
      _subjects.add(Subject(name: name, color: color.value));
    });
  }

  void _removeSubject(Subject subject) {
    setState(() {
      _subjects.remove(subject);
      // Clear this subject from all timetable entries
      for (var row in _timetable) {
        for (var entry in row) {
          if (entry.subject == subject) {
            entry = entry.copyWith(subject: null);
          }
        }
      }
    });
  }

  void _addTeacher(String name, String abbreviation) {
    if (name.isEmpty) return;
    setState(() {
      _teachers.add(Teacher(name: name, abbreviation: abbreviation));
    });
  }

  void _removeTeacher(Teacher teacher) {
    setState(() {
      _teachers.remove(teacher);
      // Clear this teacher from all timetable entries
      for (var row in _timetable) {
        for (var entry in row) {
          if (entry.teacher == teacher) {
            entry = entry.copyWith(teacher: null);
          }
        }
      }
    });
  }

  void _addClassroom(String name) {
    if (name.isEmpty) return;
    setState(() {
      _classrooms.add(Classroom(name: name));
    });
  }

  void _removeClassroom(Classroom classroom) {
    setState(() {
      _classrooms.remove(classroom);
      // Clear this classroom from all timetable entries
      for (var row in _timetable) {
        for (var entry in row) {
          if (entry.classroom == classroom) {
            entry = entry.copyWith(classroom: null);
          }
        }
      }
    });
  }

  Future<void> _editCell(int periodIndex, int dayIndex) async {
    final entry = _timetable[periodIndex][dayIndex];
    final result = await showDialog<TimeTableEntry>(
      context: context,
      builder:
          (context) => EditEntryDialog(
            entry: entry,
            subjects: _subjects,
            teachers: _teachers,
            classrooms: _classrooms,
          ),
    );

    if (result != null) {
      setState(() {
        _timetable[periodIndex][dayIndex] = result;
      });
    }
  }

  Future<void> _exportAsPdf() async {
    final pdf = pw.Document();
    final days = _dayPeriods.keys.toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                _timetableName,
                style:  pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Time',
                          style:  pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      ...days
                          .map(
                            (day) => pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                day,
                                style:  pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                  for (
                    int periodIndex = 0;
                    periodIndex < _timetable.length;
                    periodIndex++
                  )
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            periodIndex < _dayPeriods[days.first]!.length
                                ? _dayPeriods[days.first]![periodIndex]
                                : '',
                          ),
                        ),
                        for (
                          int dayIndex = 0;
                          dayIndex < days.length;
                          dayIndex++
                        )
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: _buildPdfCell(periodIndex, dayIndex, days),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${_timetableName.toLowerCase().replaceAll(' ', '-')}.pdf',
    );
  }

  pw.Widget _buildPdfCell(int periodIndex, int dayIndex, List<String> days) {
    final day = days[dayIndex];
    final periodsForDay = _dayPeriods[day]!;

    // Skip if this period doesn't exist for this day
    if (periodIndex >= periodsForDay.length) {
      return pw.Container();
    }

    final entry = _timetable[periodIndex][dayIndex];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          entry.subject?.name ?? 'Free',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color:
                entry.subject != null
                    ? PdfColor.fromInt(entry.subject!.color)
                    : PdfColors.grey,
          ),
        ),
        if (_showDetails && entry.teacher != null)
          pw.Text(
            '(${entry.teacher!.abbreviation})',
            style: const pw.TextStyle(fontSize: 10),
          ),
        if (_showDetails && entry.classroom != null)
          pw.Text(
            entry.classroom!.name,
            style: const pw.TextStyle(fontSize: 10),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _dayPeriods.keys.toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_timetableName),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _exportAsPdf,
              tooltip: 'Export as PDF',
            ),
            IconButton(
              icon: Icon(_showDetails ? Icons.list : Icons.grid_on),
              onPressed: () => setState(() => _showDetails = !_showDetails),
              tooltip: _showDetails ? 'Hide details' : 'Show details',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: 'Timetable'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildTimetableTab(days), _buildSettingsTab(days)],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final name = await showDialog<String>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Name your timetable'),
                    content: TextField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Timetable name',
                      ),
                      controller: TextEditingController(text: _timetableName),
                      onSubmitted: (value) => Navigator.pop(context, value),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          final text =
                              (context
                                          .findAncestorWidgetOfExactType<
                                            AlertDialog
                                          >()!
                                          .content
                                      as TextField)
                                  .controller!
                                  .text;
                          Navigator.pop(context, text);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
            );
            if (name != null && name.isNotEmpty) {
              setState(() => _timetableName = name);
            }
          },
          tooltip: 'Rename timetable',
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }

  Widget _buildTimetableTab(List<String> days) {
    // Find the maximum number of periods across all days for proper row display
    final maxPeriods = _dayPeriods.values.fold(
      0,
      (max, periods) => periods.length > max ? periods.length : max,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                const SizedBox(
                  width: 120,
                  child: Center(
                    child: Text(
                      'Time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ...days
                    .map(
                      (day) => SizedBox(
                        width: 180,
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
            // Timetable Rows
            for (int periodIndex = 0; periodIndex < maxPeriods; periodIndex++)
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Card(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            periodIndex < _dayPeriods[days.first]!.length
                                ? _dayPeriods[days.first]![periodIndex]
                                : '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...days.asMap().entries.map((dayEntry) {
                    final dayIndex = dayEntry.key;
                    final day = dayEntry.value;
                    final periodsForDay = _dayPeriods[day]!;

                    // Only show cell if this period exists for the day
                    if (periodIndex >= periodsForDay.length) {
                      return SizedBox(width: 180, height: 80);
                    }

                    final entry = _timetable[periodIndex][dayIndex];
                    final isSpecial =
                        periodsForDay[periodIndex].contains('Break') ||
                        periodsForDay[periodIndex].contains('Assembly') ||
                        periodsForDay[periodIndex].contains('Quiz');

                    return InkWell(
                      onTap: () => _editCell(periodIndex, dayIndex),
                      child: SizedBox(
                        width: 180,
                        height: isSpecial ? 50 : 80,
                        child: Card(
                          color:
                              isSpecial
                                  ? Colors.grey[100]
                                  : entry.subject != null
                                  ? Color(entry.subject!.color).withOpacity(0.2)
                                  : null,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isSpecial)
                                  Text(
                                    periodsForDay[periodIndex],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          periodsForDay[periodIndex].contains(
                                                'Break',
                                              )
                                              ? Colors.red
                                              : Colors.blue,
                                    ),
                                  )
                                else
                                  Text(
                                    entry.subject?.name ?? 'Tap to add',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          entry.subject != null
                                              ? Color(entry.subject!.color)
                                              : Colors.grey,
                                    ),
                                  ),
                                if (!isSpecial &&
                                    _showDetails &&
                                    entry.teacher != null)
                                  Text(
                                    entry.teacher!.abbreviation,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                if (!isSpecial &&
                                    _showDetails &&
                                    entry.classroom != null)
                                  Text(
                                    entry.classroom!.name,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab(List<String> days) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Days Management
            _buildSectionHeader('Days of Week'),
            Wrap(
              spacing: 8,
              children:
                  days
                      .map(
                        (day) => Chip(
                          label: Text(day),
                          onDeleted: () => _removeDay(day),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Add new day',
                      hintText: 'E.g. Saturday',
                    ),
                    onFieldSubmitted: _addDay,
                  ),
                ),
              ],
            ),

            // Day-Specific Period Management
            _buildSectionHeader('Day-Specific Periods'),
            ...days
                .map(
                  (day) => ExpansionTile(
                    title: Text(day),
                    children: [
                      Column(
                        children: [
                          Wrap(
                            spacing: 8,
                            children:
                                _dayPeriods[day]!.asMap().entries.map((entry) {
                                  final periodIndex = entry.key;
                                  return ActionChip(
                                    label: Text(entry.value),
                                    onPressed: () async {
                                      final newPeriod = await showDialog<
                                        String
                                      >(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: Text(
                                                'Edit period for $day',
                                              ),
                                              content: TextFormField(
                                                initialValue: entry.value,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText:
                                                          'New time period',
                                                      hintText:
                                                          'E.g. 9:30-10:30',
                                                    ),
                                                onFieldSubmitted:
                                                    (value) => Navigator.pop(
                                                      context,
                                                      value,
                                                    ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    final text =
                                                        (context
                                                                    .findAncestorWidgetOfExactType<
                                                                      AlertDialog
                                                                    >()!
                                                                    .content
                                                                as TextField)
                                                            .controller!
                                                            .text;
                                                    Navigator.pop(
                                                      context,
                                                      text,
                                                    );
                                                  },
                                                  child: const Text('Save'),
                                                ),
                                              ],
                                            ),
                                      );
                                      if (newPeriod != null &&
                                          newPeriod != entry.value) {
                                        _editPeriodForDay(
                                          day,
                                          periodIndex,
                                          newPeriod,
                                        );
                                      }
                                    },
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Add period to $day',
                                    hintText: 'E.g. 3:00-4:00',
                                  ),
                                  onFieldSubmitted:
                                      (period) => _addPeriodToDay(day, period),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ],
                  ),
                )
                .toList(),

            // Subjects Management
            _buildSectionHeader('Subjects'),
            Wrap(
              spacing: 8,
              children:
                  _subjects.map((subject) {
                    return Chip(
                      backgroundColor: Color(subject.color).withOpacity(0.2),
                      label: Text(subject.name),
                      avatar: CircleAvatar(
                        backgroundColor: Color(subject.color),
                        child: const Icon(
                          Icons.subject,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      onDeleted: () => _removeSubject(subject),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Subject name',
                      hintText: 'E.g. Biology',
                    ),
                    onFieldSubmitted: (name) {
                      if (name.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder:
                              (context) => ColorPickerDialog(
                                title: 'Select color for $name',
                                onColorSelected: (color) {
                                  _addSubject(name, color);
                                },
                              ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),

            // Teachers Management
            _buildSectionHeader('Teachers'),
            Wrap(
              spacing: 8,
              children:
                  _teachers.map((teacher) {
                    return Chip(
                      label: Text('${teacher.name} (${teacher.abbreviation})'),
                      onDeleted: () => _removeTeacher(teacher),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Teacher name',
                      hintText: 'E.g. Mr. Smith',
                    ),
                    onFieldSubmitted: (name) {
                      if (name.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Enter teacher abbreviation'),
                                content: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Abbreviation',
                                    hintText: 'E.g. MS',
                                  ),
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(4),
                                    UpperCaseTextFormatter(),
                                  ],
                                  onFieldSubmitted: (abbr) {
                                    if (abbr.isNotEmpty) {
                                      Navigator.pop(context);
                                      _addTeacher(name, abbr);
                                    }
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),

            // Classrooms Management
            _buildSectionHeader('Classrooms'),
            Wrap(
              spacing: 8,
              children:
                  _classrooms.map((classroom) {
                    return Chip(
                      label: Text(classroom.name),
                      onDeleted: () => _removeClassroom(classroom),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Classroom name',
                      hintText: 'E.g. Room 101',
                    ),
                    onFieldSubmitted: _addClassroom,
                  ),
                ),
              ],
            ),

            // Reset Button
            _buildSectionHeader('Danger Zone'),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.warning),
                label: const Text('Reset Timetable'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Reset Timetable?'),
                          content: const Text(
                            'This will clear all your entries but keep your structure.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _resetTimetable();
                              },
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}

// Dialogs
class EditEntryDialog extends StatefulWidget {
  final TimeTableEntry entry;
  final List<Subject> subjects;
  final List<Teacher> teachers;
  final List<Classroom> classrooms;

  const EditEntryDialog({
    Key? key,
    required this.entry,
    required this.subjects,
    required this.teachers,
    required this.classrooms,
  }) : super(key: key);

  @override
  _EditEntryDialogState createState() => _EditEntryDialogState();
}

class _EditEntryDialogState extends State<EditEntryDialog> {
  late Subject? _selectedSubject;
  late Teacher? _selectedTeacher;
  late Classroom? _selectedClassroom;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.entry.subject;
    _selectedTeacher = widget.entry.teacher;
    _selectedClassroom = widget.entry.classroom;
    _notesController = TextEditingController(text: widget.entry.notes ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Timetable Entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Subject>(
              value: _selectedSubject,
              decoration: const InputDecoration(labelText: 'Subject'),
              items:
                  widget.subjects
                      .map(
                        (subject) => DropdownMenuItem(
                          value: subject,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: Color(subject.color),
                              ),
                              const SizedBox(width: 8),
                              Text(subject.name),
                            ],
                          ),
                        ),
                      )
                      .toList(),
              onChanged:
                  (subject) => setState(() => _selectedSubject = subject),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Teacher>(
              value: _selectedTeacher,
              decoration: const InputDecoration(
                labelText: 'Teacher (optional)',
              ),
              items:
                  widget.teachers
                      .map(
                        (teacher) => DropdownMenuItem(
                          value: teacher,
                          child: Text(
                            '${teacher.name} (${teacher.abbreviation})',
                          ),
                        ),
                      )
                      .toList(),
              onChanged:
                  (teacher) => setState(() => _selectedTeacher = teacher),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Classroom>(
              value: _selectedClassroom,
              decoration: const InputDecoration(
                labelText: 'Classroom (optional)',
              ),
              items:
                  widget.classrooms
                      .map(
                        (classroom) => DropdownMenuItem(
                          value: classroom,
                          child: Text(classroom.name),
                        ),
                      )
                      .toList(),
              onChanged:
                  (classroom) => setState(() => _selectedClassroom = classroom),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              TimeTableEntry(
                subject: _selectedSubject,
                teacher: _selectedTeacher,
                classroom: _selectedClassroom,
                notes:
                    _notesController.text.isNotEmpty
                        ? _notesController.text
                        : null,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

class ColorPickerDialog extends StatelessWidget {
  final String title;
  final Function(Color) onColorSelected;

  const ColorPickerDialog({
    Key? key,
    required this.title,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.blueGrey,
    ];

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          children:
              colors.map((color) {
                return InkWell(
                  onTap: () {
                    onColorSelected(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    color: color,
                  ),
                );
              }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
