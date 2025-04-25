import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
// import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TimeTableApp extends StatelessWidget {
  const TimeTableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Timetable',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const TimeTableScreen(),
    );
  }
}

class TimeTableScreen extends StatefulWidget {
  const TimeTableScreen({super.key});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];
  final List<String> _times = [
    '8:00-9:00',
    '9:00-10:00',
    '10:00-11:00',
    '11:00-11:20', // Break period
    '11:20-12:20',
    '12:20-1:20',
    '1:20-2:20',
    '2:20-3:00',
  ];

  final List<String> _subjects = [
    'Mathematics',
    'English',
    'Physics',
    'Chemistry',
    'Biology',
    'History',
    'Geography',
    'Computer Science',
  ];

  final List<String> _teachers = [
    'Mr. Smith',
    'Ms. Johnson',
    'Dr. Brown',
    'Prof. Wilson',
    'Mrs. Davis',
    'Mr. Taylor',
    'Ms. Clark',
    'Dr. White',
  ];

  final List<Color> _subjectColors = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.purple.shade100,
    Colors.orange.shade100,
    Colors.red.shade100,
    Colors.teal.shade100,
    Colors.indigo.shade100,
    Colors.pink.shade100,
  ];

  late List<List<Map<String, String>>> _timetable;
  final List<List<Map<String, String>>> _favorites = [];
  bool _showTeachers = false;
  bool _isBreak = false;

  @override
  void initState() {
    super.initState();
    _generateTimetable();
  }

  void _generateTimetable() {
    setState(() {
      _timetable = List.generate(_times.length, (timeIndex) {
        return List.generate(_days.length, (dayIndex) {
          // Add break period
          if (_times[timeIndex] == '11:00-11:20') {
            return {'subject': 'BREAK', 'teacher': '', 'isBreak': 'true'};
          }

          final subIndex = (timeIndex + dayIndex) % _subjects.length;
          return {
            'subject': _subjects[subIndex],
            'teacher': _teachers[subIndex],
            'isBreak': 'false',
          };
        });
      });
    });
  }

  void _saveFavorite() {
    setState(() {
      _favorites.add(List.from(_timetable));
      Fluttertoast.showToast(
        msg: "Timetable saved to favorites!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  Future<void> _exportAsPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Table(
            border: pw.TableBorder.all(),
            children: [
              // Header
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Time',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  ..._days
                      .map(
                        (day) => pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            day,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
              // Rows
              ..._times.asMap().entries.map((timeEntry) {
                final timeIndex = timeEntry.key;
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(_times[timeIndex]),
                    ),
                    ..._timetable[timeIndex]
                        .map(
                          (cell) => pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              _showTeachers && cell['teacher']!.isNotEmpty
                                  ? '${cell['subject']}\n(${cell['teacher']})'
                                  : cell['subject']!,
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        )
                        .toList(),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'school-timetable.pdf',
    );
  }

  Future<void> _exportAsImage() async {
    final boundary =
        _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final imageBytes = byteData?.buffer.asUint8List();

    if (imageBytes != null) {
      // await Share.file(
      //   'School Timetable',
      //   'timetable.png',
      //   imageBytes,
      //   'image/png',
      // );
    }
  }

  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: const Text('School Timetable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFavorite,
            tooltip: 'Save to favorites',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportAsPdf,
            tooltip: 'Export as PDF',
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _exportAsImage,
            tooltip: 'Export as Image',
          ),
          IconButton(
            icon: Icon(_showTeachers ? Icons.person_off : Icons.person),
            onPressed: () => setState(() => _showTeachers = !_showTeachers),
            tooltip: 'Toggle teachers',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Row
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(
                  width: 100,
                  child: Center(
                    child: Text(
                      'Time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ..._days
                    .map(
                      (day) => SizedBox(
                        width: 150,
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
          // Timetable Content
         Expanded(
            child: ListView.builder(
              itemCount: _times.length,
              itemBuilder: (context, timeIndex) {
                final isBreak = _times[timeIndex] == '11:00-11:20';
                return Container(
                  height: isBreak ? 40 : 80, // Smaller height for break row
                  margin: EdgeInsets.only(
                    bottom: isBreak ? 0 : 4,
                  ), // Adjust spacing
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics:
                        const ClampingScrollPhysics(), // Prevent over-scrolling
                    children: [
                      // Time cell
                      Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: isBreak ? Colors.grey[100] : null,
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _times[timeIndex],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isBreak ? Colors.red : Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      // Subject cells
                      ..._timetable[timeIndex]
                          .map(
                            (cell) => Container(
                              width: 150,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                              child:
                                  isBreak
                                      ? Center(
                                        child: Text(
                                          'BREAK',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                      : Card(
                                        elevation: 2,
                                        color:
                                            _subjectColors[_subjects.indexOf(
                                                  cell['subject']!,
                                                ) %
                                                _subjectColors.length],
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  cell['subject']!,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                if (_showTeachers &&
                                                    cell['teacher']!.isNotEmpty)
                                                  Text(
                                                    cell['teacher']!,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                );
              },
            ),
          ),
          // Favorites Section
          if (_favorites.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 8.0,
                    ),
                    child: Text(
                      'Favorites:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ..._favorites.asMap().entries.map((entry) {
                    final index = entry.key;
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ActionChip(
                        label: Text('Timetable ${index + 1}'),
                        onPressed: () {
                          setState(() {
                            _timetable = List.from(entry.value);
                          });
                        },
                        avatar: const Icon(Icons.schedule, size: 16),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateTimetable,
        tooltip: 'Generate New',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
