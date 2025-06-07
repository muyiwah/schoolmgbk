import 'package:flutter/material.dart';
import 'package:flutter_timetable/flutter_timetable.dart';

// class AddStudentScreen extends StatelessWidget {
//   const AddStudentScreen({super.key});

//   final List<String> days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
//   final List<String> timeSlots = const [
//     '8:00 AM',
//     '9:00 AM',
//     '10:00 AM',
//     '11:00 AM',
//     '12:00 PM',
//     '1:00 PM',
//     '2:00 PM',
//     '3:00 PM',
//     '4:00 PM',
//   ];

//   final List<Map<String, String>> schedule = const [
//     {
//       'time': '8:00 AM',
//       'Mon': '4A - Physics',
//       'Tue': '1A - Chemistry',
//       'Wed': '',
//       'Thu': '4A - Chemistry',
//       'Fri': '',
//     },
//     {
//       'time': '9:00 AM',
//       'Mon': '3B - Physics',
//       'Tue': '2B - Physics',
//       'Wed': '6A - Physics',
//       'Thu': '3B - Physics',
//       'Fri': '',
//     },
//     {
//       'time': '10:00 AM',
//       'Mon': '2B',
//       'Tue': '3A - Physics',
//       'Wed': '2B - Physics',
//       'Thu': '6B - Chemistry',
//       'Fri': '',
//     },
//     {
//       'time': '11:00 AM',
//       'Mon': '5A - Physics',
//       'Tue': '5B - Physics',
//       'Wed': '5C - Physics',
//       'Thu': '6A - Physics',
//       'Fri': '',
//     },
//     {
//       'time': '1:00 PM',
//       'Mon': '6C',
//       'Tue': '3C - Chemistry',
//       'Wed': '',
//       'Thu': '6A - Chemistry',
//       'Fri': '',
//     },
//     {
//       'time': '2:00 PM',
//       'Mon': '2B - Physics',
//       'Tue': '1A - Physics',
//       'Wed': '4A - Chemistry',
//       'Thu': '6B - Chemistry',
//       'Fri': '',
//     },
//   ];

//   Widget _buildProfileHeader() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.lightBlue.shade50,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(
//             radius: 30,
//             backgroundImage: NetworkImage('https://via.placeholder.com/150'),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 Text(
//                   'Daniel Adams',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//                 Text('Lorem ipsum, dolor sit amet consectetur.'),
//                 SizedBox(height: 4),
//                 Text('📅 14/09/1994   📧 daniel@example.com'),
//                 Text('📞 136-367-467'),
//               ],
//             ),
//           ),
//           Wrap(
//             spacing: 12,
//             children: [
//               _infoCard('98%', 'Attendance'),
//               _infoCard('2', 'Branches'),
//               _infoCard('8', 'Lessons'),
//               _infoCard('4', 'Classes'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   static Widget _infoCard(String value, String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             value,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           Text(label, style: const TextStyle(fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimetableTable() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: DataTable(
//         headingRowColor: MaterialStateColor.resolveWith(
//           (states) => Colors.grey.shade200,
//         ),
//         columns: [
//           const DataColumn(label: Text('Time')),
//           ...days.map((day) => DataColumn(label: Text(day))),
//         ],
//         rows:
//             schedule.map((row) {
//               return DataRow(
//                 cells: [
//                   DataCell(Text(row['time'] ?? '')),
//                   ...days.map(
//                     (day) => DataCell(_buildSubjectBox(row[day] ?? '')),
//                   ),
//                 ],
//               );
//             }).toList(),
//       ),
//     );
//   }

//   Widget _buildSubjectBox(String text) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: text.isEmpty ? Colors.transparent : Colors.blue.shade100,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(text, style: const TextStyle(fontSize: 12)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildProfileHeader(),
//           const SizedBox(height: 24),
//           const Text(
//             "Teacher's Schedule",
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           Expanded(child: _buildTimetableTable()),
//         ],
//       ),
//     );
//   }
// }

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_timetable/flutter_timetable.dart';
import 'package:intl/intl.dart';

class AddStudentScreen extends StatelessWidget {
  const AddStudentScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => MaterialApp(
    routes: {
      '/': (context) => const TimetableScreen(),
      '/custom': (context) => const CustomTimetableScreen(),
    },
  );
}

/// Plain old default time table screen.
class TimetableScreen extends StatelessWidget {
  const TimetableScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.grey,
      actions: [
        TextButton(
          onPressed: () async => Navigator.pushNamed(context, '/custom'),
          child: const Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(Icons.celebration_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Custom builders",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(width: 8),
              Icon(Icons.chevron_right_outlined, color: Colors.white),
            ],
          ),
        ),
      ],
    ),
    body: const Timetable(),
  );
}

class TeacherDetails extends StatelessWidget {
  const TeacherDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            height: 180,
            decoration: const BoxDecoration(
              // color: Colors.amber,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            width: double.infinity,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 22, 98, 80),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(10),
                  width: MediaQuery.sizeOf(context).width * .4,
                  height: 180,
                  child: Row(
                    children: [
                      Container(
                        height: 130,
                        width: 130,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.pink,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Daniel Adams',
                                  style: TextStyle(
                                    fontSize: 16,color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                CircleAvatar(child: Icon(Icons.edit)),
                              ],
                            ),
                            const Flexible(
                              child: Text(
                                'er rer er er er er er sdfasdf asdf asdf asdf asdfa sdf asdf asdf asdf asdf asdf ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            Wrap(
                              spacing: 30,
                              runSpacing: 10,
                              children: [
                                CustomBox(),
                                CustomBox(),
                                CustomBox(),
                                CustomBox(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
SizedBox(width: 20,),
                Expanded(
                  child: Wrap(spacing: 10,runSpacing: 10,
                    children: [
                      CustomBox2(context),
                      CustomBox2(context),
                      CustomBox2(context),
                      CustomBox2(context),
                    ],
                  ),
                ),
              ],
            ),
          ),SizedBox(height: 8,),
          const Expanded(child: CustomTimetableScreen()),
        ],
      ),
    );
  }

  Container CustomBox2(BuildContext context) {
    return Container(
                    height: 80,
                    width: MediaQuery.sizeOf(context).width * .14,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 48, 94, 246),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Row(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.ac_unit_outlined,
                        color: Colors.white),const SizedBox(width: 8,),
                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '33',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '3thisisdf asdf sdf 3',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
  }

  Container CustomBox() {
    return Container(
      width: 120,
     
      child: const Row(
        children: [
          Icon(Icons.ac_unit,
          color: Colors.white),
          SizedBox(width: 8),
          Text('A+', style: TextStyle(fontWeight: FontWeight.w600,
          color: Colors.white)),
        ],
      ),
    );
  }
}

/// Timetable screen with all the stuff - controller, builders, etc.
class CustomTimetableScreen extends StatefulWidget {
  const CustomTimetableScreen({Key? key}) : super(key: key);
  @override
  State<CustomTimetableScreen> createState() => _CustomTimetableScreenState();
}

class _CustomTimetableScreenState extends State<CustomTimetableScreen> {
  final items = generateItems();
  final controller = TimetableController(
    start: DateUtils.dateOnly(DateTime.now()).subtract(const Duration(days: 7)),
    initialColumns: 3,
    cellHeight: 80.0,
    startHour: 9,
    endHour: 18,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(const Duration(milliseconds: 100), () {
        controller.jumpTo(DateTime.now());
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [
        TextButton(
          onPressed: () async => Navigator.pop(context),
          child: const Row(children: [SizedBox(width: 8)]),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.calendar_view_day),
          onPressed: () => controller.setColumns(1),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_view_month_outlined),
          onPressed: () => controller.setColumns(3),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_view_week),
          onPressed: () => controller.setColumns(5),
        ),
        IconButton(
          icon: const Icon(Icons.zoom_in),
          onPressed: () => controller.setCellHeight(controller.cellHeight + 10),
        ),
        IconButton(
          icon: const Icon(Icons.zoom_out),
          onPressed: () => controller.setCellHeight(controller.cellHeight - 10),
        ),
      ],
    ),
    body: Timetable<String>(
      controller: controller,
      items: items,
      cellBuilder:
          (datetime) => Container(
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(.3),
              border: Border.all(color: Colors.tealAccent, width: 0.2),
            ),
            child: Center(
              child: Text(
                DateFormat("MM/d/yyyy\nha").format(datetime),
                style: const TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      cornerBuilder:
          (datetime) => Container(
            color: Colors.teal.withOpacity(.7),
            child: Center(child: Text("${datetime.year}")),
          ),
      headerCellBuilder: (datetime) {
        final color = Colors.white;
        return Container(
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(.5),
            border: Border(bottom: BorderSide(color: color, width: 2)),
          ),
          child: Center(
            child: Text(
              DateFormat("E\nMMM d").format(datetime),
              style: TextStyle(color: color),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      hourLabelBuilder: (time) {
        final hour = time.hour == 12 ? 12 : time.hour % 12;
        final period = time.hour < 12 ? "am" : "pm";
        final isCurrentHour = time.hour == DateTime.now().hour;
        return Text(
          "$hour$period",
          style: TextStyle(
            fontSize: 14,
            fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.normal,
          ),
        );
      },
      itemBuilder:
          (item) => Container(
            decoration: BoxDecoration(
              color: Colors.teal.withAlpha(220),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                item.data ?? "",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
      nowIndicatorColor: Colors.red,
      snapToDay: true,
    ),
    floatingActionButton: FloatingActionButton(
      child: const Text("Now"),
      onPressed: () => controller.jumpTo(DateTime.now()),
    ),
  );
}

/// Generates some random items for the timetable.
List<TimetableItem<String>> generateItems() {
  final random = Random();
  final items = <TimetableItem<String>>[];
  final today = DateUtils.dateOnly(DateTime.now());
  for (var i = 0; i < 100; i++) {
    int hourOffset = random.nextInt(56 * 24) - (7 * 24);
    final date = today.add(Duration(hours: hourOffset));
    items.add(
      TimetableItem(
        date,
        date.add(Duration(minutes: (random.nextInt(8) * 15) + 15)),
        data: "item $i",
      ),
    );
  }
  return items;
}
