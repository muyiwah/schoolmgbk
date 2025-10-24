import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TimeTableApp extends StatelessWidget {
  const TimeTableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Timetable (Grade 3)',
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
    '8:00-8:30', // Assembly time
    '8:30-9:30',
    '9:30-10:30',
    '10:30-10:45', // Short break
    '10:45-11:45',
    '11:45-12:45',
    '12:45-1:45',
    '1:45-2:15', // Quiz time
    '2:15-3:15',
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
    'Quiz Session',
    'Assembly',
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
    'Quiz Master',
    'Principal',
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
    Colors.yellow.shade100, // Quiz color
    Colors.cyan.shade100, // Assembly color
  ];

  late List<List<Map<String, String>>> _timetable;
  final List<List<Map<String, String>>> _favorites = [];
  bool _showTeachers = false;
  final GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _generateTimetable();
  }

  void _generateTimetable() {
    setState(() {
      _timetable = List.generate(_times.length, (timeIndex) {
        return List.generate(_days.length, (dayIndex) {
          // Add special periods
          if (_times[timeIndex] == '8:00-8:30') {
            return {
              'subject': 'ASSEMBLY',
              'teacher': _teachers[9],
              'isSpecial': 'true',
            };
          }
          if (_times[timeIndex] == '10:30-10:45') {
            return {
              'subject': 'SHORT BREAK',
              'teacher': '',
              'isSpecial': 'true',
            };
          }
          if (_times[timeIndex] == '1:45-2:15' && dayIndex == 4) {
            // Friday quiz
            return {
              'subject': 'QUIZ SESSION',
              'teacher': _teachers[8],
              'isSpecial': 'true',
            };
          }

          final subIndex =
              (timeIndex + dayIndex) %
              (_subjects.length - 2); // Exclude quiz and assembly
          return {
            'subject': _subjects[subIndex],
            'teacher': _teachers[subIndex],
            'isSpecial': 'false',
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

  Color _getCellColor(Map<String, String> cell) {
    if (cell['isSpecial'] == 'true') {
      if (cell['subject'] == 'ASSEMBLY') return _subjectColors[9];
      if (cell['subject'] == 'QUIZ SESSION') return _subjectColors[8];
      return Colors.grey[100]!;
    }
    return _subjectColors[_subjects.indexOf(cell['subject']!) %
        _subjectColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      key: _globalKey,
      appBar: AppBar(backgroundColor: Colors.white,
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
          Expanded(
            child: ListView.builder(
              itemCount: _times.length,
              itemBuilder: (context, timeIndex) {
                final isSpecialPeriod =
                    _times[timeIndex] == '8:00-8:30' ||
                    _times[timeIndex] == '10:30-10:45' ||
                    (_times[timeIndex] == '1:45-2:15' &&
                        _timetable[timeIndex][4]['subject'] == 'QUIZ SESSION');

                return Container(
                  height: isSpecialPeriod ? 50 : 80,
                  margin: EdgeInsets.only(bottom: isSpecialPeriod ? 0 : 4),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: isSpecialPeriod ? Colors.grey[100] : null,
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _times[timeIndex],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isSpecialPeriod
                                      ? Colors.blueGrey
                                      : Colors.blue,
                            ),
                          ),
                        ),
                      ),
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
                                  isSpecialPeriod
                                      ? Center(
                                        child: Text(
                                          cell['subject']!,
                                          style: TextStyle(
                                            color:
                                                cell['subject'] == 'SHORT BREAK'
                                                    ? Colors.red
                                                    : Colors.blueGrey,
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                cell['subject'] == 'SHORT BREAK'
                                                    ? 14
                                                    : 16,
                                          ),
                                        ),
                                      )
                                      : Card(
                                        elevation: 2,
                                        color: _getCellColor(cell),
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
