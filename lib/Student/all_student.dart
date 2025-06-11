// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_timetable/flutter_timetable.dart';
// import 'package:intl/intl.dart';

// class AddStudentScreen extends StatelessWidget {
//   const AddStudentScreen({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) => MaterialApp(
//     routes: {
//       '/': (context) => const TimetableScreen(),
//       '/custom': (context) => const CustomTimetableScreen(),
//     },
//   );
// }

// /// Plain old default time table screen.
// class TimetableScreen extends StatelessWidget {
//   const TimetableScreen({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(
//       backgroundColor: Colors.grey,
//       actions: [
//         TextButton(
//           onPressed: () async => Navigator.pushNamed(context, '/custom'),
//           child: const Row(
//             mainAxisSize: MainAxisSize.max,
//             children: [
//               Icon(Icons.celebration_outlined, color: Colors.white),
//               SizedBox(width: 8),
//               Text(
//                 "Custom builders",
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//               SizedBox(width: 8),
//               Icon(Icons.chevron_right_outlined, color: Colors.white),
//             ],
//           ),
//         ),
//       ],
//     ),
//     body: const Timetable(),
//   );
// }

// class TeacherDetails extends StatelessWidget {
//   const TeacherDetails({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Column(
//         children: [
//           Container(
//             height: 180,
//             decoration: const BoxDecoration(
//               // color: Colors.amber,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(20),
//                 topRight: Radius.circular(20),
//               ),
//             ),
//             width: double.infinity,
//             child: Row(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 22, 98, 80),
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   padding: const EdgeInsets.all(10),
//                   width: MediaQuery.sizeOf(context).width * .4,
//                   height: 180,
//                   child: Row(
//                     children: [
//                       Container(
//                         height: 130,
//                         width: 130,
//                         decoration: const BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.pink,
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       Flexible(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             const Row(
//                               children: [
//                                 Text(
//                                   'Daniel Adams',
//                                   style: TextStyle(
//                                     fontSize: 16,color: Colors.white,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 SizedBox(width: 8),
//                                 CircleAvatar(child: Icon(Icons.edit)),
//                               ],
//                             ),
//                             const Flexible(
//                               child: Text(
//                                 'er rer er er er er er sdfasdf asdf asdf asdf asdfa sdf asdf asdf asdf asdf asdf ',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.normal,
//                                 ),
//                               ),
//                             ),
//                             Wrap(
//                               spacing: 30,
//                               runSpacing: 10,
//                               children: [
//                                 CustomBox(),
//                                 CustomBox(),
//                                 CustomBox(),
//                                 CustomBox(),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
// SizedBox(width: 20,),
//                 Expanded(
//                   child: Wrap(spacing: 10,runSpacing: 10,
//                     children: [
//                       CustomBox2(context),
//                       CustomBox2(context),
//                       CustomBox2(context),
//                       CustomBox2(context),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),SizedBox(height: 8,),
//           const Expanded(child: CustomTimetableScreen()),
//         ],
//       ),
//     );
//   }

//   Container CustomBox2(BuildContext context) {
//     return Container(
//                     height: 80,
//                     width: MediaQuery.sizeOf(context).width * .14,
//                     decoration: BoxDecoration(
//                       color: const Color.fromARGB(255, 48, 94, 246),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     padding: const EdgeInsets.all(10),
//                     child: const Row(crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Icon(Icons.ac_unit_outlined,
//                         color: Colors.white),const SizedBox(width: 8,),
//                         Column(crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               '33',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             Text(
//                               '3thisisdf asdf sdf 3',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w300,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   );
//   }

//   Container CustomBox() {
//     return Container(
//       width: 120,

//       child: const Row(
//         children: [
//           Icon(Icons.ac_unit,
//           color: Colors.white),
//           SizedBox(width: 8),
//           Text('A+', style: TextStyle(fontWeight: FontWeight.w600,
//           color: Colors.white)),
//         ],
//       ),
//     );
//   }
// }

// /// Timetable screen with all the stuff - controller, builders, etc.
// class CustomTimetableScreen extends StatefulWidget {
//   const CustomTimetableScreen({Key? key}) : super(key: key);
//   @override
//   State<CustomTimetableScreen> createState() => _CustomTimetableScreenState();
// }

// class _CustomTimetableScreenState extends State<CustomTimetableScreen> {
//   final items = generateItems();
//   final controller = TimetableController(
//     start: DateUtils.dateOnly(DateTime.now()).subtract(const Duration(days: 7)),
//     initialColumns: 3,
//     cellHeight: 80.0,
//     startHour: 9,
//     endHour: 18,
//   );

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       Future.delayed(const Duration(milliseconds: 100), () {
//         controller.jumpTo(DateTime.now());
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(
//       actions: [
//         TextButton(
//           onPressed: () async => Navigator.pop(context),
//           child: const Row(children: [SizedBox(width: 8)]),
//         ),
//         const Spacer(),
//         IconButton(
//           icon: const Icon(Icons.calendar_view_day),
//           onPressed: () => controller.setColumns(1),
//         ),
//         IconButton(
//           icon: const Icon(Icons.calendar_view_month_outlined),
//           onPressed: () => controller.setColumns(3),
//         ),
//         IconButton(
//           icon: const Icon(Icons.calendar_view_week),
//           onPressed: () => controller.setColumns(5),
//         ),
//         IconButton(
//           icon: const Icon(Icons.zoom_in),
//           onPressed: () => controller.setCellHeight(controller.cellHeight + 10),
//         ),
//         IconButton(
//           icon: const Icon(Icons.zoom_out),
//           onPressed: () => controller.setCellHeight(controller.cellHeight - 10),
//         ),
//       ],
//     ),
//     body: Timetable<String>(
//       controller: controller,
//       items: items,
//       cellBuilder:
//           (datetime) => Container(
//             decoration: BoxDecoration(
//               color: Colors.teal.withOpacity(.3),
//               border: Border.all(color: Colors.tealAccent, width: 0.2),
//             ),
//             child: Center(
//               child: Text(
//                 DateFormat("MM/d/yyyy\nha").format(datetime),
//                 style: const TextStyle(color: Colors.black),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//       cornerBuilder:
//           (datetime) => Container(
//             color: Colors.teal.withOpacity(.7),
//             child: Center(child: Text("${datetime.year}")),
//           ),
//       headerCellBuilder: (datetime) {
//         final color = Colors.white;
//         return Container(
//           decoration: BoxDecoration(
//             color: Colors.teal.withOpacity(.5),
//             border: Border(bottom: BorderSide(color: color, width: 2)),
//           ),
//           child: Center(
//             child: Text(
//               DateFormat("E\nMMM d").format(datetime),
//               style: TextStyle(color: color),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         );
//       },
//       hourLabelBuilder: (time) {
//         final hour = time.hour == 12 ? 12 : time.hour % 12;
//         final period = time.hour < 12 ? "am" : "pm";
//         final isCurrentHour = time.hour == DateTime.now().hour;
//         return Text(
//           "$hour$period",
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.normal,
//           ),
//         );
//       },
//       itemBuilder:
//           (item) => Container(
//             decoration: BoxDecoration(
//               color: Colors.teal.withAlpha(220),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 4,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Center(
//               child: Text(
//                 item.data ?? "",
//                 style: const TextStyle(fontSize: 14),
//               ),
//             ),
//           ),
//       nowIndicatorColor: Colors.red,
//       snapToDay: true,
//     ),
//     floatingActionButton: FloatingActionButton(
//       child: const Text("Now"),
//       onPressed: () => controller.jumpTo(DateTime.now()),
//     ),
//   );
// }

// /// Generates some random items for the timetable.
// List<TimetableItem<String>> generateItems() {
//   final random = Random();
//   final items = <TimetableItem<String>>[];
//   final today = DateUtils.dateOnly(DateTime.now());
//   for (var i = 0; i < 100; i++) {
//     int hourOffset = random.nextInt(56 * 24) - (7 * 24);
//     final date = today.add(Duration(hours: hourOffset));
//     items.add(
//       TimetableItem(
//         date,
//         date.add(Duration(minutes: (random.nextInt(8) * 15) + 15)),
//         data: "item $i",
//       ),
//     );
//   }
//   return items;
// }
import 'package:flutter/material.dart';
import 'package:schmgtsystem/constants/appcolor.dart';

class AllStudentsScreen extends StatefulWidget {
  final Function navigateTo;
  final Function navigateTo2;
  const AllStudentsScreen({
    super.key,
    required this.navigateTo,
    required this.navigateTo2,
  });

  @override
  State<AllStudentsScreen> createState() => _AllStudentsScreenState();
}

class _AllStudentsScreenState extends State<AllStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedClass = 'All Classes';
  String _selectedGender = 'All Genders';
  String _selectedStatus = 'All Status';
  int _currentPage = 1;

  final List<Student> _students = [
    Student(
      name: 'Sarah Johnson',
      age: 16,
      admissionNo: 'ADM-2024-001',
      className: 'SS2A',
      gender: 'Female',
      status: 'Admitted',
      parentName: 'Mrs. Johnson',
      avatar: 'S',
    ),
    Student(
      name: 'Michael Chen',
      age: 15,
      admissionNo: 'ADM-2024-002',
      className: 'SS1B',
      gender: 'Male',
      status: 'Pending',
      parentName: 'Mr. Chen',
      avatar: 'M',
    ),
    Student(
      name: 'Emma Wilson',
      age: 17,
      admissionNo: 'ADM-2024-003',
      className: 'SS3A',
      gender: 'Female',
      status: 'Admitted',
      parentName: 'Mrs. Wilson',
      avatar: 'E',
    ),
    Student(
      name: 'Emma Wilson',
      age: 17,
      admissionNo: 'ADM-2024-003',
      className: 'SS3A',
      gender: 'Female',
      status: 'Admitted',
      parentName: 'Mrs. Wilson',
      avatar: 'E',
    ),
    Student(
      name: 'Emma Wilson',
      age: 17,
      admissionNo: 'ADM-2024-003',
      className: 'SS3A',
      gender: 'Female',
      status: 'Admitted',
      parentName: 'Mrs. Wilson',
      avatar: 'E',
    ),
    Student(
      name: 'Emma Wilson',
      age: 17,
      admissionNo: 'ADM-2024-003',
      className: 'SS3A',
      gender: 'Female',
      status: 'Admitted',
      parentName: 'Mrs. Wilson',
      avatar: 'E',
    ),
    Student(
      name: 'Emma Wilson',
      age: 17,
      admissionNo: 'ADM-2024-003',
      className: 'SS3A',
      gender: 'Female',
      status: 'Admitted',
      parentName: 'Mrs. Wilson',
      avatar: 'E',
    ),
    Student(
      name: 'Emma Wilson',
      age: 17,
      admissionNo: 'ADM-2024-003',
      className: 'SS3A',
      gender: 'Female',
      status: 'Admitted',
      parentName: 'Mrs. Wilson',
      avatar: 'E',
    ),
    Student(
      name: 'Emma Wilson',
      age: 17,
      admissionNo: 'ADM-2024-003',
      className: 'SS3A',
      gender: 'Female',
      status: 'Admitted',
      parentName: 'Mrs. Wilson',
      avatar: 'E',
    ),
    Student(
      name: 'Emma Wilson',
      age: 17,
      admissionNo: 'ADM-2024-003',
      className: 'SS3A',
      gender: 'Female',
      status: 'Admitted',
      parentName: 'Mrs. Wilson',
      avatar: 'E',
    ),
    Student(
      name: 'Emma Wilson',
      age: 17,
      admissionNo: 'ADM-2024-003',
      className: 'SS3A',
      gender: 'Female',
      status: 'Admitted',
      parentName: 'Mrs. Wilson',
      avatar: 'E',
    ),
    Student(
      name: 'Emma Wilson',
      age: 17,
      admissionNo: 'ADM-2024-003',
      className: 'SS3A',
      gender: 'Female',
      status: 'Admitted',
      parentName: 'Mrs. Wilson',
      avatar: 'E',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Students',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Browse, search, and manage students across all classes',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    widget.navigateTo2();
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add New Student',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Students',
                    value: '1,247',
                    icon: Icons.groups,
                    color: const Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Classes',
                    value: '24',
                    icon: Icons.class_,
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Avg per Class',
                    value: '52',
                    icon: Icons.bar_chart,
                    color: const Color(0xFF06B6D4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Male Students',
                    value: '678',
                    icon: Icons.male,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Female Students',
                    value: '569',
                    icon: Icons.female,
                    color: const Color(0xFFEC4899),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Search and Filters
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, ID, or parent name...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF6366F1)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildDropdown(
                  [
                    'All Classes',
                    'Grade 1',
                    'Grade 2',
                    'Grade 3',
                    'Grade 4',
                    'Grade 5',
                  ],
                  _selectedClass,
                  (value) {
                    setState(() => _selectedClass = value!);
                  },
                ),
                const SizedBox(width: 16),
                _buildDropdown(
                  ['All Genders', 'Male', 'Female'],
                  _selectedGender,
                  (value) {
                    setState(() => _selectedGender = value!);
                  },
                ),
                const SizedBox(width: 16),
                _buildDropdown(
                  ['All Status', 'Owing', 'Paid'],
                  _selectedStatus,
                  (value) {
                    setState(() => _selectedStatus = value!);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Data Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 3,
                            child: Text(
                              'STUDENT',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'ADMISSION NO.',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'CLASS',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'GENDER',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'STATUS',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'PARENT NAME',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'ACTIONS',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Table Body
                    Expanded(
                      child: ListView.builder(
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Student Info
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: _getAvatarColor(
                                          student.avatar,
                                        ),
                                        child: Text(
                                          student.avatar,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            'Age: ${student.age}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Admission No
                                Expanded(
                                  flex: 2,
                                  child: Text(student.admissionNo),
                                ),

                                // Class
                                Expanded(
                                  flex: 1,
                                  child: Text(student.className),
                                ),

                                // Gender
                                Expanded(flex: 1, child: Text(student.gender)),

                                // Status
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          student.status == 'Admitted'
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      student.status,
                                      style: TextStyle(
                                        color:
                                            student.status == 'Admitted'
                                                ? Colors.green[700]
                                                : Colors.orange[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),

                                // Parent Name
                                Expanded(
                                  flex: 2,
                                  child: Text(student.parentName),
                                ),

                                // Actions
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          widget.navigateTo();
                                        },
                                        icon: const Icon(
                                          Icons.visibility,
                                          color: Color(0xFF6366F1),
                                          size: 18,
                                        ),
                                      ),
                                      // IconButton(
                                      //   onPressed: () {},
                                      //   icon: const Icon(
                                      //     Icons.edit,
                                      //     color: Colors.grey,
                                      //     size: 18,
                                      //   ),
                                      // ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
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
            ),

            // Pagination
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing 1 to 10 of 1,247 students',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _currentPage > 1 ? () {} : null,
                        child: const Text('Previous'),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '1',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(onPressed: () {}, child: const Text('2')),
                      TextButton(onPressed: () {}, child: const Text('3')),
                      TextButton(onPressed: () {}, child: const Text('Next')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(List hint, String value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint[0]),
        underline: const SizedBox(),
        items:
            hint.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Color _getAvatarColor(String initial) {
    switch (initial) {
      case 'S':
        return Colors.purple;
      case 'M':
        return Colors.teal;
      case 'E':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }
}

class Student {
  final String name;
  final int age;
  final String admissionNo;
  final String className;
  final String gender;
  final String status;
  final String parentName;
  final String avatar;

  Student({
    required this.name,
    required this.age,
    required this.admissionNo,
    required this.className,
    required this.gender,
    required this.status,
    required this.parentName,
    required this.avatar,
  });
}
