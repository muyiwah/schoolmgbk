import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Edit extends StatelessWidget {
  const Edit({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Timetable Creator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      home: const TimeTableCreatorScreen(),
    );
  }
}

class TimeTableCreatorScreen extends StatefulWidget {
  const TimeTableCreatorScreen({super.key});

  @override
  State<TimeTableCreatorScreen> createState() => _TimeTableCreatorScreenState();
}

class _TimeTableCreatorScreenState extends State<TimeTableCreatorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> _defaultDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final List<String> _defaultPeriods = [
    '8:00-9:00',
    '9:00-10:00',
    '10:00-11:00',
    '11:00-12:00',
    '12:00-1:00',
    '1:00-2:00',
    '2:00-3:00'
  ];

  List<String> _days = [];
  List<String> _periods = [];
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
      _days = List.from(_defaultDays);
      _periods = List.from(_defaultPeriods);
      
      // Initialize with sample subjects
      _subjects = [
        Subject(name: 'Mathematics', color: Colors.blue.value),
        Subject(name: 'English', color: Colors.green.value),
        Subject(name: 'Physics', color: Colors.purple.value),
      ];
      
      // Initialize with sample teachers
      _teachers = [
        Teacher(name: 'Mr. Smith', abbreviation: 'MS'),
        Teacher(name: 'Ms. Johnson', abbreviation: 'MJ'),
      ];
      
      // Initialize with sample classrooms
      _classrooms = [
        Classroom(name: 'Room 101'),
        Classroom(name: 'Lab A'),
      ];
      
      // Initialize empty timetable
      _resetTimetable();
    });
  }

  void _resetTimetable() {
    setState(() {
      _timetable = List.generate(_periods.length, 
        (i) => List.generate(_days.length, 
          (j) => TimeTableEntry.empty()
        )
      );
    });
  }

  void _addDay(String day) {
    if (day.isEmpty) return;
    setState(() {
      _days.add(day);
      // Add a column to each row
      for (var row in _timetable) {
        row.add(TimeTableEntry.empty());
      }
    });
  }

  void _removeDay(int index) {
    if (_days.length <= 1) {
      Fluttertoast.showToast(msg: "You must have at least one day");
      return;
    }
    setState(() {
      _days.removeAt(index);
      // Remove column from each row
      for (var row in _timetable) {
        row.removeAt(index);
      }
    });
  }

  void _addPeriod(String period) {
    if (period.isEmpty) return;
    setState(() {
      _periods.add(period);
      // Add a new row
      _timetable.add(List.generate(_days.length, (i) => TimeTableEntry.empty()));
    });
  }

  void _removePeriod(int index) {
    if (_periods.length <= 1) {
      Fluttertoast.showToast(msg: "You must have at least one period");
      return;
    }
    setState(() {
      _periods.removeAt(index);
      _timetable.removeAt(index);
    });
  }

  void _addSubject(String name, Color color) {
    if (name.isEmpty) return;
    setState(() {
      _subjects.add(Subject(name: name, color: color.value));
    });
  }

  void _addTeacher(String name, String abbreviation) {
    if (name.isEmpty) return;
    setState(() {
      _teachers.add(Teacher(name: name, abbreviation: abbreviation));
    });
  }

  void _addClassroom(String name) {
    if (name.isEmpty) return;
    setState(() {
      _classrooms.add(Classroom(name: name));
    });
  }

  Future<void> _editCell(int periodIndex, int dayIndex) async {
    final entry = _timetable[periodIndex][dayIndex];
    final result = await showDialog<TimeTableEntry>(
      context: context,
      builder: (context) => EditEntryDialog(
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(_timetableName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('Time', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      ..._days.map((day) => pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(day, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      )).toList(),
                    ],
                  ),
                  ..._periods.asMap().entries.map((periodEntry) {
                    final periodIndex = periodEntry.key;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(_periods[periodIndex]),
                        ),
                        ..._timetable[periodIndex].map((entry) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              children: [
                                pw.Text(entry.subject?.name ?? ''),
                                if (_showDetails && entry.teacher != null)
                                  pw.Text('(${entry.teacher!.abbreviation})', style: const pw.TextStyle(fontSize: 10)),
                                if (_showDetails && entry.classroom != null)
                                  pw.Text(entry.classroom!.name, style: const pw.TextStyle(fontSize: 10)),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
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

  @override
  Widget build(BuildContext context) {
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
              Tab(icon: Icon(Icons.calendar_today)),
              Tab(icon: Icon(Icons.settings)),
          ],
          ),
        ),
        body: TabBarView(
          children: [
            // Timetable Tab
            _buildTimetableTab(),
            // Settings Tab
            _buildSettingsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final name = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Name your timetable'),
                content: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Timetable name'),
                  onSubmitted: (value) => Navigator.pop(context, value),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, _timetableName),
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
            if (name != null) {
              setState(() => _timetableName = name);
            }
          },
          tooltip: 'Rename timetable',
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }

  Widget _buildTimetableTab() {
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
                  child: Center(child: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                ),
                ..._days.map((day) => SizedBox(
                  width: 180,
                  child: Center(
                    child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )).toList(),
              ],
            ),
            // Timetable Rows
            ..._periods.asMap().entries.map((periodEntry) {
              final periodIndex = periodEntry.key;
              return Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Card(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_periods[periodIndex]),
                        ),
                      ),
                    ),
                  ),
                  ..._days.asMap().entries.map((dayEntry) {
                    final dayIndex = dayEntry.key;
                    final entry = _timetable[periodIndex][dayIndex];
                    return InkWell(
                      onTap: () => _editCell(periodIndex, dayIndex),
                      child: SizedBox(
                        width: 180,
                        height: 80,
                        child: Card(
                          color: entry.subject != null 
                              ? Color(entry.subject!.color).withOpacity(0.2)
                              : null,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  entry.subject?.name ?? 'Tap to add',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: entry.subject != null 
                                        ? Color(entry.subject!.color)
                                        : Colors.grey,
                                  ),
                                ),
                                if (_showDetails && entry.teacher != null)
                                  Text(
                                    entry.teacher!.abbreviation,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                if (_showDetails && entry.classroom != null)
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
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
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
              children: _days.asMap().entries.map((entry) {
                final index = entry.key;
                return Chip(
                  label: Text(entry.value),
                  onDeleted: () => _removeDay(index),
                );
              }).toList(),
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
            
            // Periods Management
            _buildSectionHeader('Time Periods'),
            Wrap(
              spacing: 8,
              children: _periods.asMap().entries.map((entry) {
                final index = entry.key;
                return Chip(
                  label: Text(entry.value),
                  onDeleted: () => _removePeriod(index),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Add new period',
                      hintText: 'E.g. 3:00-4:00',
                    ),
                    onFieldSubmitted: _addPeriod,
                  ),
                ),
              ],
            ),
            
            // Subjects Management
            _buildSectionHeader('Subjects'),
            Wrap(
              spacing: 8,
              children: _subjects.map((subject) {
                return Chip(
                  backgroundColor: Color(subject.color).withOpacity(0.2),
                  label: Text(subject.name),
                  avatar: CircleAvatar(
                    backgroundColor: Color(subject.color),
                    child: const Icon(Icons.subject, size: 16, color: Colors.white),
                  ),
                  onDeleted: () {
                    setState(() {
                      _subjects.remove(subject);
                    });
                  },
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
                          builder: (context) => ColorPickerDialog(
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
              children: _teachers.map((teacher) {
                return Chip(
                  label: Text('${teacher.name} (${teacher.abbreviation})'),
                  onDeleted: () {
                    setState(() {
                      _teachers.remove(teacher);
                    });
                  },
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
                          builder: (context) => AlertDialog(
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
              children: _classrooms.map((classroom) {
                return Chip(
                  label: Text(classroom.name),
                  onDeleted: () {
                    setState(() {
                      _classrooms.remove(classroom);
                    });
                  },
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
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Timetable?'),
                      content: const Text('This will clear all your entries but keep your structure.'),
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

// Data Models
class Subject {
  final String name;
  final int color;

  Subject({required this.name, required this.color});
}

class Teacher {
  final String name;
  final String abbreviation;

  Teacher({required this.name, required this.abbreviation});
}

class Classroom {
  final String name;

  Classroom({required this.name});
}

class TimeTableEntry {
  final Subject? subject;
  final Teacher? teacher;
  final Classroom? classroom;
  final String? notes;

  TimeTableEntry({
    this.subject,
    this.teacher,
    this.classroom,
    this.notes,
  });

  factory TimeTableEntry.empty() => TimeTableEntry();
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
    _notesController = TextEditingController(text: widget.entry.notes);
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
              items: widget.subjects
                  .map((subject) => DropdownMenuItem(
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
                      ))
                  .toList(),
              onChanged: (subject) => setState(() => _selectedSubject = subject),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Teacher>(
              value: _selectedTeacher,
              decoration: const InputDecoration(labelText: 'Teacher (optional)'),
              items: widget.teachers
                  .map((teacher) => DropdownMenuItem(
                        value: teacher,
                        child: Text('${teacher.name} (${teacher.abbreviation})'),
                      ))
                  .toList(),
              onChanged: (teacher) => setState(() => _selectedTeacher = teacher),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Classroom>(
              value: _selectedClassroom,
              decoration: const InputDecoration(labelText: 'Classroom (optional)'),
              items: widget.classrooms
                  .map((classroom) => DropdownMenuItem(
                        value: classroom,
                        child: Text(classroom.name),
                      ))
                  .toList(),
              onChanged: (classroom) => setState(() => _selectedClassroom = classroom),
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
                notes: _notesController.text.isNotEmpty ? _notesController.text : null,
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
          children: colors.map((color) {
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
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}