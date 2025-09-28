// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class Teacher1 extends StatefulWidget {
//   @override
//   _Teacher1State createState() => _Teacher1State();
// }

// class _Teacher1State extends State<Teacher1> {
//   List<Teacher> teachers = [
//     Teacher(
//       id: 'T001',
//       name: 'John Smith',
//       department: 'Mathematics',
//       clockInHistory: [
//         ClockInRecord(DateTime.now().subtract(Duration(days: 1)), true),
//         ClockInRecord(DateTime.now().subtract(Duration(days: 2)), true),
//         ClockInRecord(DateTime.now().subtract(Duration(days: 3)), false),
//       ],
//     ),
//     Teacher(
//       id: 'T002',
//       name: 'Sarah Johnson',
//       department: 'Science',
//       clockInHistory: [
//         ClockInRecord(DateTime.now().subtract(Duration(days: 1)), true),
//         ClockInRecord(DateTime.now().subtract(Duration(days: 2)), false),
//         ClockInRecord(DateTime.now().subtract(Duration(days: 3)), true),
//       ],
//     ),
//     Teacher(
//       id: 'T003',
//       name: 'Michael Brown',
//       department: 'English',
//       clockInHistory: [
//         ClockInRecord(DateTime.now().subtract(Duration(days: 1))),
//         ClockInRecord(DateTime.now().subtract(Duration(days: 2))),
//         ClockInRecord(DateTime.now().subtract(Duration(days: 3))),
//       ],
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Teacher Attendance'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: () {
//               setState(() {
//                 // Refresh data
//               });
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Today: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Implement clock-in functionality for admin
//                   },
//                   child: Text('Clock In All'),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: teachers.length,
//               itemBuilder: (context, index) {
//                 final teacher = teachers[index];
//                 final lastClockIn =
//                     teacher.clockInHistory.isNotEmpty
//                         ? teacher.clockInHistory.first
//                         : null;

//                 return Card(
//                   margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: ListTile(
//                     leading: CircleAvatar(child: Text(teacher.name[0])),
//                     title: Text(teacher.name),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(teacher.department),
//                         if (lastClockIn != null)
//                           Text(
//                             'Last Clock-In: ${DateFormat('MMM dd, hh:mm a').format(lastClockIn.dateTime)} '
//                             '(${lastClockIn.clockedIn ? 'Present' : 'Absent'})',
//                             style: TextStyle(
//                               color:
//                                   lastClockIn.clockedIn
//                                       ? Colors.green
//                                       : Colors.red,
//                             ),
//                           ),
//                       ],
//                     ),
//                     trailing: ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           teacher.clockInHistory.insert(
//                             0,
//                             ClockInRecord(DateTime.now()),
//                           );
//                         });
//                       },
//                       child: Text('Clock In'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder:
//                               (_) => TeacherDetailsScreen(teacher: teacher),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Teacher {
//   final String id;
//   final String name;
//   final String department;
//   List<ClockInRecord> clockInHistory;

//   Teacher({
//     required this.id,
//     required this.name,
//     required this.department,
//     this.clockInHistory = const [],
//   });
// }

// class ClockInRecord {
//   final DateTime dateTime;
//   final bool clockedIn;

//   ClockInRecord(this.dateTime, [this.clockedIn = true]);
// }

// class TeacherDetailsScreen extends StatelessWidget {
//   const TeacherDetailsScreen({super.key, required this.teacher});
//   final Teacher teacher;
//   @override
//   Widget build(BuildContext context) {
//     // Prepare attendance data for the chart
//     final presentCount =
//         teacher.clockInHistory.where((record) => record.clockedIn).length;
//     final absentCount = teacher.clockInHistory.length - presentCount;

//     return Scaffold(
//       appBar: AppBar(title: Text('${teacher.name} - Attendance')),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Attendance Summary',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       Container(
//                         height: 200,
//                         child: SfCircularChart(
//                           series: <CircularSeries>[
//                             PieSeries<AttendanceData, String>(
//                               dataSource: [
//                                 AttendanceData(
//                                   'Present',
//                                   presentCount,
//                                   Colors.green,
//                                 ),
//                                 AttendanceData(
//                                   'Absent',
//                                   absentCount,
//                                   Colors.red,
//                                 ),
//                               ],
//                               xValueMapper:
//                                   (AttendanceData data, _) => data.status,
//                               yValueMapper:
//                                   (AttendanceData data, _) => data.count,
//                               pointColorMapper:
//                                   (AttendanceData data, _) => data.color,
//                               dataLabelSettings: DataLabelSettings(
//                                 isVisible: true,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Monthly Attendance',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       // Container(
//                       //   height: 300,
//                       //   child: SfCartesianChart(
//                       //     primaryXAxis: CategoryAxis(),
//                       //     series: <ChartSeries>[
//                       //       ColumnSeries<MonthlyData, String>(
//                       //         dataSource: _getMonthlyData(teacher),
//                       //         xValueMapper: (MonthlyData data, _) => data.month,
//                       //         yValueMapper:
//                       //             (MonthlyData data, _) => data.presentDays,
//                       //         name: 'Present',
//                       //         color: Colors.green,
//                       //       ),
//                       //       ColumnSeries<MonthlyData, String>(
//                       //         dataSource: _getMonthlyData(teacher),
//                       //         xValueMapper: (MonthlyData data, _) => data.month,
//                       //         yValueMapper:
//                       //             (MonthlyData data, _) => data.absentDays,
//                       //         name: 'Absent',
//                       //         color: Colors.red,
//                       //       ),
//                       //     ],
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Attendance Calendar',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       _buildAttendanceCalendar(teacher),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<MonthlyData> _getMonthlyData(Teacher teacher) {
//     // This is a simplified version - in a real app, you'd group by month
//     return [
//       MonthlyData('Jan', 18, 2),
//       MonthlyData('Feb', 16, 4),
//       MonthlyData('Mar', 20, 0),
//     ];
//   }

//   Widget _buildAttendanceCalendar(Teacher teacher) {
//     // This is a simplified calendar view
//     // In a real app, you might use a package like table_calendar
//     final daysInMonth = 30; // Simplified
//     final firstDay = DateTime.now().subtract(Duration(days: daysInMonth));

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 7,
//         childAspectRatio: 1.0,
//       ),
//       itemCount: daysInMonth,
//       itemBuilder: (context, index) {
//         final currentDay = firstDay.add(Duration(days: index));
//         final wasPresent = teacher.clockInHistory.any(
//           (record) =>
//               record.clockedIn &&
//               record.dateTime.year == currentDay.year &&
//               record.dateTime.month == currentDay.month &&
//               record.dateTime.day == currentDay.day,
//         );

//         return Container(
//           margin: EdgeInsets.all(2),
//           decoration: BoxDecoration(
//             color: wasPresent ? Colors.green[100] : Colors.red[100],
//             border: Border.all(color: Colors.grey),
//             borderRadius: BorderRadius.circular(4),
//           ),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('${currentDay.day}'),
//                 Icon(
//                   wasPresent ? Icons.check : Icons.close,
//                   size: 16,
//                   color: wasPresent ? Colors.green : Colors.red,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class AttendanceData {
//   final String status;
//   final int count;
//   final Color color;

//   AttendanceData(this.status, this.count, this.color);
// }

// class MonthlyData {
//   final String month;
//   final int presentDays;
//   final int absentDays;

//   MonthlyData(this.month, this.presentDays, this.absentDays);
// }
