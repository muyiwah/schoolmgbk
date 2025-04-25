import 'package:flutter/material.dart';
import 'package:schmgtsystem/Student/all_student.dart';
import 'package:schmgtsystem/Student/timetable.dart';
import 'package:schmgtsystem/Teacher/screens/Teacher.dart';
import 'package:schmgtsystem/Teacher/screens/allparents.dart';
import 'package:schmgtsystem/add_class.dart';
import 'package:schmgtsystem/all_students.dart';
import 'package:schmgtsystem/color_pallete.dart';
import 'package:schmgtsystem/dshboard.dart';
import 'package:collection/collection.dart';

class SchoolAdminDashboard extends StatelessWidget {
  const SchoolAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Admin Dashboard',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.indigoAccent,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        textTheme: ThemeData.light().textTheme.apply(bodyColor: Colors.black),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
@override
  void initState() {
    super.initState();
    for (int i = 0; i < menuItems.length; i++) {
      _controllers[i] = ExpansionTileController();
    }
  }
Set<int> _builtTiles = {};

  int selectedIndex = 0;
final Map<int, ExpansionTileController> _controllers = {};
final ExpansionTileController _controller = ExpansionTileController();
// UniqueKey _tileKey = UniqueKey();
  final List<MenuItem> menuItems = [
    MenuItem('Home', Icons.person_add, []),
    MenuItem('Class', Icons.person_add, ['Add Class', 'All Classes']),
    MenuItem('Inventory', Icons.person_add, ['All item', 'Edit item']),
    MenuItem('Student', Icons.calendar_today, [
      'All Students',
      'Add Student',
      'Attendance',
    ]),
    MenuItem('Fees', Icons.attach_money, ['All Fees', 'Add/Edit Fee']),
    MenuItem('Exams', Icons.attach_money, ['All Exams', 'Add Exam']),
    MenuItem('Staff', Icons.attach_money, [
      'All Staff'
          'Time Table',
      'Teacher',
      'Attendance',
    ]),
    MenuItem('Lesson Notes', Icons.attach_money, ['All Notes', 'Add New Note']),
    MenuItem('Inventory', Icons.attach_money, ['All Inventory', 'Add New']),
    MenuItem('Library', Icons.attach_money, ['All Books', 'Add Libarian']),
    MenuItem('Chats', Icons.attach_money, []),
    MenuItem('Admissions', Icons.attach_money, []),
    MenuItem('Accounts', Icons.attach_money, []),
  ];
  bool _isExpanded = false;
  String? selectedSubMenu;
  int tabSelected = -1;
  int subSelected = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(.1),
              // const Color.fromARGB(255, 221, 250, 247),
              Colors.white,
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.7),
                    spreadRadius: 1,
                    offset: const Offset(-1, 1),
                    blurRadius: 1,
                  ),
                ],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  width: .2,
                  color: Colors.black.withOpacity(.5),
                ),
                // border: Border(right: BorderSide(width: .2)),
                color: homeColor,
              ),
              width: 220,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.attach_money, color: Colors.white),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        ...menuItems.asMap().entries.map((entry) {
                          int index = entry.key;
                          MenuItem item = entry.value;
                          bool isSelected = selectedIndex == index;

                          if (item.subMenu.isEmpty) {
                            return InkWell(
                              onTap: () {
                                if (index == 0) {
                                  isSelected = false;
                            // WidgetsBinding.instance.addPostFrameCallback((
                            //         _,
                            //       ) {
                            //         for (
                            //           int i = 0;
                            //           i < _controllers.length;
                            //           i++
                            //         ) {
                            //           if (i != index) {
                            //             _controllers[i]?.collapse();
                            //           }
                            //         }
                            //         _controllers[index]?.expand();
                            //       });
                                  for (
                                    int i = 0;
                                    i < _controllers.length;
                                    i++
                                  ) {
                                    if (i != index && _builtTiles.contains(i)) {
                                      _controllers[i]?.collapse();
                                    }
                                  }
                                  setState(() {});
                                }

                                setState(() {
                                  tabSelected = index;
                                  selectedSubMenu = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                alignment: Alignment.centerLeft,
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color:
                                      tabSelected == index
                                          ? const Color.fromARGB(
                                            115,
                                            67,
                                            70,
                                            72,
                                          ).withOpacity(.4)
                                          : null,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 20,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      item.icon,
                                      size: 12,
                                      color:
                                          // tabSelected == index
                                          //     ?
                                          Colors.white,
                                      // : Colors.black,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color:
                                            //     tabSelected == index
                                            //         ?
                                            Colors.white,
                                        //         : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ExpansionTile(
                           controller: _controllers[index],
                            iconColor: Colors.blue, // arrow color when expanded
                            collapsedIconColor: Colors.white, //
                            // trailing: Icon(
                            //   Icons.expand_more,
                            //   size: 20, // change icon size here
                            // ),
                            onExpansionChanged: (value) {
                               _builtTiles.add(index); 
                              // print(value);
                              // value
                              //     ? setState(() {
                              //       tabSelected = index;
                              //     })
                              //     : setState(() {
                              //       tabSelected = -1;
                              //     });
                            },
                            title: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 11),
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            initiallyExpanded: isSelected,
                            children:
                                item.subMenu.isNotEmpty
                                    ? item.subMenu.mapIndexed((index, sub) {
                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            tabSelected = -1;
                                            selectedIndex = index;
                                            selectedSubMenu = sub;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color:
                                                selectedSubMenu == sub
                                                    ? const Color.fromARGB(
                                                      115,
                                                      67,
                                                      70,
                                                      72,
                                                    ).withOpacity(.4)
                                                    : null,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          alignment: Alignment.centerLeft,
                                          height: 30,

                                          margin: const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 20,
                                          ),
                                          child: Text(
                                            sub,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color:
                                                  //     selectedSubMenu == sub
                                                  //         ?
                                                  Colors.white,
                                              //         : Colors.black,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList()
                                    : [
                                      ListTile(
                                        title: Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        selected: selectedIndex == index,
                                        selectedTileColor: Colors.indigoAccent
                                            .withOpacity(0.1),
                                        onTap: () {
                                          setState(() {
                                            selectedIndex = index;
                                            selectedSubMenu = null;
                                          });
                                        },
                                      ),
                                    ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 30,
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    alignment: Alignment.centerLeft,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'School Admin Dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.indigoAccent,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      color: Colors.transparent,
                      child: _buildDashboardContent(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildDashboardContent() {
    // Handle submenu selections first
    if (selectedSubMenu != null) {
      switch (selectedSubMenu) {
        case 'Add Class':
          return _buildCustomScreen('Add Class Screen', Colors.blue.shade100);
        case 'All Classes':
          return _buildCustomScreen(
            'All Classes Screen',
            Colors.green.shade100,
          );
        case 'All item':
          return _buildCustomScreen(
            'All Inventory Items Screen',
            Colors.orange.shade100,
          );
        case 'Edit item':
          return _buildCustomScreen(
            'Edit Inventory Item Screen',
            Colors.purple.shade100,
          );
        case 'All Students':
          return const AllStudents();
        case 'Add Student':
          return _buildCustomScreen('Add Student Screen', Colors.teal.shade100);
        case 'Attendance':
          return _buildCustomScreen(
            'Student Attendance Screen',
            Colors.amber.shade100,
          );
        case 'All Fees':
          return _buildCustomScreen('All Fees Screen', Colors.indigo.shade100);
        case 'Add/Edit Fee':
          return _buildCustomScreen(
            'Add/Edit Fee Screen',
            Colors.deepOrange.shade100,
          );
        case 'All Exams':
          return _buildCustomScreen(
            'All Exams Screen',
            Colors.lightGreen.shade100,
          );
        case 'Add Exam':
          return _buildCustomScreen('Add Exam Screen', Colors.cyan.shade100);
        case 'All Staff':
          return _buildCustomScreen('All Staff Screen', Colors.brown.shade100);
        case 'Time Table':
          return const StudentTimetableScreen();
        case 'Teacher':
          return const AddTeacherScreen();
        case 'All Notes':
          return _buildCustomScreen(
            'All Lesson Notes Screen',
            Colors.pink.shade100,
          );
        case 'Add New Note':
          return _buildCustomScreen(
            'Add New Lesson Note Screen',
            Colors.lime.shade100,
          );
        case 'All Inventory':
          return _buildCustomScreen(
            'All Inventory Screen',
            Colors.deepPurple.shade100,
          );
        case 'Add New':
          return _buildCustomScreen(
            'Add New Inventory Screen',
            Colors.blueGrey.shade100,
          );
        case 'All Books':
          return _buildCustomScreen(
            'Library Books Screen',
            Colors.red.shade100,
          );
        case 'Add Libarian':
          return _buildCustomScreen(
            'Add Librarian Screen',
            Colors.yellow.shade100,
          );
      }
    }

    // Handle main menu selections
    switch (selectedIndex) {
      case 0: // Home
        return const MetricScreen();
      case 1: // Class
        return _buildCustomScreen(
          'Class Management Screen',
          Colors.blue.shade200,
        );
      case 2: // Inventory
        return _buildCustomScreen(
          'Inventory Management Screen',
          Colors.green.shade200,
        );
      case 3: // Student
        return const AllStudents();
      case 4: // Fees
        return const StudentTablePage();
      case 5: // Exams
        return _buildCustomScreen(
          'Exams Management Screen',
          Colors.orange.shade200,
        );
      case 6: // Staff
        return _buildCustomScreen(
          'Staff Management Screen',
          Colors.purple.shade200,
        );
      case 7: // Lesson Notes
        return _buildCustomScreen(
          'Lesson Notes Management Screen',
          Colors.teal.shade200,
        );
      case 8: // Inventory
        return _buildCustomScreen(
          'Inventory Management Screen',
          Colors.amber.shade200,
        );
      case 9: // Library
        return _buildCustomScreen(
          'Library Management Screen',
          Colors.indigo.shade200,
        );
      case 10: // Chats
        return _buildCustomScreen('Chats Screen', Colors.deepOrange.shade200);
      case 11: // Admissions
        return _buildCustomScreen(
          'Admissions Screen',
          Colors.lightGreen.shade200,
        );
      case 12: // Accounts
        return _buildCustomScreen('Accounts Screen', Colors.cyan.shade200);
      default:
        return const Center(child: Text('Select an option'));
    }
  }

  Widget _buildCustomScreen(String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final List<String> subMenu;

  MenuItem(this.title, this.icon, this.subMenu);
}

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Fees Screen',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
