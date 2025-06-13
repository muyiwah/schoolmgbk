import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schmgtsystem/Class/all_table.dart';
import 'package:schmgtsystem/Class/assign_student.dart';
import 'package:schmgtsystem/Class/classes.dart';
import 'package:schmgtsystem/Class/single_class.dart';
import 'package:schmgtsystem/RoleHome/teacher.dart';
import 'package:schmgtsystem/Student/add_student.dart';
import 'package:schmgtsystem/Student/all_parents.dart';
import 'package:schmgtsystem/Student/all_student.dart';
import 'package:schmgtsystem/Student/create_timetale.dart';
import 'package:schmgtsystem/Student/parent_all_transactions.dart';
import 'package:schmgtsystem/Student/single_parent.dart';
import 'package:schmgtsystem/Student/single_student.dart';
import 'package:schmgtsystem/Student/timetable.dart';
import 'package:schmgtsystem/Teacher/screens/Teacher.dart';
import 'package:schmgtsystem/Teacher/screens/allparents.dart';
import 'package:schmgtsystem/accunts/account_home.dart';
import 'package:schmgtsystem/accunts/accounts.dart';
import 'package:schmgtsystem/accunts/expenditure.dart';
import 'package:schmgtsystem/accunts/expenditure_manager.dart';
import 'package:schmgtsystem/add_class.dart';
import 'package:schmgtsystem/admin111.dart';
import 'package:schmgtsystem/admin222.dart';
import 'package:schmgtsystem/admin3333.dart';
import 'package:schmgtsystem/admissions/admission_screen.dart';
import 'package:schmgtsystem/all_students.dart';
import 'package:schmgtsystem/color_pallete.dart';
import 'package:schmgtsystem/component/allstudentpanenew.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/create_table_testing.dart';
import 'package:schmgtsystem/custom_timetable.dart';
import 'package:schmgtsystem/deepseek/deepseek2222/examsetupscreen.dart';
import 'package:schmgtsystem/exams/records.dart';
import 'package:schmgtsystem/home/dashboar_details.dart';
import 'package:schmgtsystem/home/dshboard.dart';
import 'package:collection/collection.dart';
import 'package:schmgtsystem/exams/add_exams.dart';
import 'package:schmgtsystem/exams/all_exams.dart';
import 'package:schmgtsystem/exams/exam_schedule.dart';
import 'package:schmgtsystem/exams/examination_overview.dart';
import 'package:schmgtsystem/exams/overview2.dart';
import 'package:schmgtsystem/home2.dart';
import 'package:schmgtsystem/promotions/manage_promotion.dart';
import 'package:schmgtsystem/providers/user_provider.dart';
import 'package:schmgtsystem/staff/add_staff.dart';
import 'package:schmgtsystem/staff/all_staff.dart';
import 'package:schmgtsystem/staff/teachers.dart';
import 'package:schmgtsystem/staff/timetable.dart';
import 'package:schmgtsystem/teacher111.dart';
import 'package:schmgtsystem/tesing2222.dart';
import 'package:schmgtsystem/testing3333.dart';
import 'package:schmgtsystem/testing4444.dart';
import 'package:schmgtsystem/testingg5555.dart';
import 'package:schmgtsystem/widgets/header_new.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final List<String> subMenuItems;

  MenuItem(this.title, this.icon, this.subMenuItems);
}

class SchoolAdminDashboard3 extends StatelessWidget {
  const SchoolAdminDashboard3({super.key});

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
String roleRoute = '';

class _DashboardScreenState extends State<DashboardScreen> {
  late final Map<String, Widget> internalRoutes = _createRoutes();
  String currentRoute = 'home';
  List<String> breadcrumbs = ['home'];
  @override
  void initState() {
    super.initState();
    applyRole();

    // for (int i = 0; i < menuItems.length; i++) {
    //   _controllers[i] = ExpansionTileController();
    // }
  }

  applyRole() {
    Provider.of<UserProvider>(context, listen: false).userRole == 'Teacher'
        ? currentRoute = 'teacherhome'
        : Provider.of<UserProvider>(context, listen: false).userRole == 'Admin'
        ? currentRoute = 'home'
        : currentRoute = 'accounthome';
    roleRoute = currentRoute;
    setState(() {});
  }

  Set<int> _builtTiles = {};
  Map<String, Widget> _createRoutes() {
    return {
      'home': MetricScreen(
        navigateTo: () {
          navigateTo('home/dashboard_details');
        },
      ),

      'teacherhome': TeacherDashboardApp(),
      'accounthome': AccountHome(),
      // 'class/add': AddClassScreen(
      //   onNavigateToInnerRoute:
      //       () => navigateTo('student/addstudent/innerroute'),
      // ),
      // 'student/attendance': Attendance(
      //   onNavigateToInnerRoute:
      //       () => navigateTo('student/addstudent/innerroute'),
      // ),
      // 'inventory/allitem': const AllStudentsPage(),

      /////students
      ///
      'student/singlestudent': const SingleStudent(),

      'student/timetable': const CreateTimetale(),
      'student/examschedule': ExamTimeTable(),
      'student/registration': StudentRegistrationPage(
        navigateTo: () {
          navigateTo('student/allstudents');
        },
      ),
      'student/parents': AllParents(
        navigateTo: () {
          navigateTo('student/single_parent');
        },
      ),
      'student/parent_all_transactions': PaymentSummaryScreen(
        navigateTo: () {
          navigateTo('student/single_parent');
        },
      ),
      'student/allstudents': AllStudentsScreen(
        navigateTo: () {
          navigateTo('student/singlestudent');
        },
        navigateTo2: () {
          navigateTo('student/registration');
        },
      ),
      'staff/allstaff': AllStaff(
        navigateTo: () {
          navigateTo('student/single_parent');
        },
      ),
      'student/single_parent': SingleParent(
        navigateTo: () {
          navigateTo('student/parents');
        },
        navigateTo2: () {
          navigateTo('student/parent_all_transactions');
        },
      ),
      'home/dashboard_details': DashboardDetails(
        navigateBack: () {
          navigateTo('home');
        },
      ),

      ///classssess
      'class/timetable': const TimeTableApp(),
      'class/assignstudent': const AssignStudentsScreen(),
      'class/allclasses': SchoolClasses(
        navigateTo: () {
          navigateTo('class/alltables');
        },
        navigateTo2: () {
          navigateTo2('class/singleclass');
        },
        navigateTo3: () {
          navigateTo('class/assignstudent');
        },
      ),
      'class/singleclass': ClassDetailsScreen(
        navigateTo: () {
          navigateTo('class/allclasses');
        },
      ),
      'class/alltables': AllTables(
        navigateBack: () {
          navigateTo('class/allclasses');
        },
      ),

      'staff/addstaff': const AddStaff(),
      'student/attendance': const ExamSetupScreen(),
      'staff/createtimetable': const Edit5(),

      ///examssss
      'exams/allexams': ExaminationOverviewScreenTwo(
        navigateTo: () {
          navigateTo('exams/addexam');
        },
      ),
      // 'exams/overview': const ExaminationOverviewPage(),
      'exams/examschedule': const ExamSchedule(),
      'exams/records': const ExamRecordsScreen(),
      'exams/addexam': CreateNewExamScreen(
        navigateBack: () {
          navigateTo('exams/allexams');
        },
      ),

      ////admissions
      'admissions/alladmissions': const AdmissionsOverviewPage(),

      ///staff
      'staff/assignteacher': const AssignTeacher(),

      ////promotions
      'promotions/managepromotion': StudentPromotionManager(),

      ////accounts
      'accounts/income': const FinancialOverviewScreen(),
      'accounts/expenditure': ExpenditureScreen(),
      'accounts/expendituremanager': ExpenditureManger(),

      // 'inventory/edititem': const StudentTablePage2(),//////undo for web
      // 'student/allstudents': Container(
      //   color: Colors.amber,
      //   child: Center(
      //     child: ElevatedButton(
      //       onPressed: () {
      //         navigateTo('student/addstudent/innerroute');
      //       },
      //       child: const Text('go'),
      //     ),
      //   ),
      // ),
      'accounts': Container(
        color: Colors.red,
        child: const Center(child: Text('Account')),
      ),
      'student/addstudent/innerroute': InnerRoute(
        navigateTo: () {
          navigateTo('student/allstudents');
        },
        onNavigateToInnerRoute:
            () => navigateTo('student/addstudent/innerroute/inner'),
      ),
      'student/addstudent/innerroute/inner': Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: ElevatedButton(
            onPressed: () {
              navigateTo('student/addstudent/innerroute');
            },
            child: Text('back'),
          ),
        ),
        body: Container(
          color: Colors.pink,
          child: const Center(child: Text('inner inner routeee')),
        ),
      ),
    };
  }

  int selectedIndex = 0;
  final Map<int, ExpansionTileController> _controllers = {};
  final ExpansionTileController _controller = ExpansionTileController();
  // UniqueKey _tileKey = UniqueKey();
  final List<MenuItem> menuItems = [
    MenuItem('home', Icons.person_add, []),
    MenuItem('Class', Icons.person_add, [
      'All Classes',
      'Single class',
      'Assign Student',
      'Time Table',
    ]),
    // MenuItem('Inventory', Icons.person_add, ['All item', 'Edit item']),
    MenuItem('Student', Icons.calendar_today, [
      'All Students',
      // 'Add Student',
      // 'Single Student',
      // 'Attendance',
      // 'Time Table',
      'Parents',
      'Exam Schedule',

      // 'Create Time Table',
    ]),
    // MenuItem('Fees', Icons.attach_money, [
    //   'Teacher1',
    //   'Admin1',
    //   'Admin2',
    //   'Admin3',
    //   'All Fees',
    //   'Add/Edit Fee',
    // ]),
    // MenuItem('CBT', Icons.attach_money, [
    //   'Add CBT Exam',
    //   'Manage Exam',
    //   'Results',
    //   'New',
    // ]),
    MenuItem('Exams', Icons.attach_money, [
      'All Exams',
      'Exam Schedule',
      'Records',
      // 'Overview',
    ]),
    MenuItem('Staff', Icons.attach_money, [
      'All Staff',
      'Add Staff',
      'Assign Teacher',
      'Create Timetable',
    ]),
    // MenuItem('Lesson Notes', Icons.attach_money, ['All Notes', 'Add New Note']),
    // MenuItem('Inventory', Icons.attach_money, ['All Inventory', 'Add New']),
    // MenuItem('Library', Icons.attach_money, ['All Books', 'Add Libarian']),
    // MenuItem('Chats', Icons.attach_money, []),
    MenuItem('Admissions', Icons.attach_money, ['All Admissions']),
    MenuItem('Promotions', Icons.attach_money, ['Manage Promotion']),
    MenuItem('Accounts', Icons.attach_money, [
      'Income',
      'Expenditure',
      'Expenditure Manager',
    ]),
  ];
  bool _isExpanded = false;
  String? selectedSubMenu;
  int tabSelected = -1;
  int subSelected = -1;
  void navigateTo(String route) {
    print(route);
    setState(() {
      currentRoute = route;
      if (!breadcrumbs.contains(route)) {
        breadcrumbs.add(route);
      }
    });
  }

  void navigateTo2(String route) {
    print(route);
    setState(() {
      currentRoute = route;
      if (!breadcrumbs.contains(route)) {
        breadcrumbs.add(route);
      }
    });
  }

  void navigateBack() {
    if (breadcrumbs.length > 1) {
      setState(() {
        breadcrumbs.removeLast();
        currentRoute = breadcrumbs.last;
      });
    }
  }

  Widget _buildDashboardContent() {
    return internalRoutes[currentRoute] ??
        const Center(child: Text('Page not found'));
  }

  Widget _buildBreadcrumbs() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              breadcrumbs.map((route) {
                final label = route.split('/').last;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Chip(
                    label: Text(label),
                    onDeleted:
                        route != currentRoute
                            ? () {
                              setState(() {
                                final index = breadcrumbs.indexOf(route);
                                breadcrumbs = breadcrumbs.sublist(0, index + 1);
                                currentRoute = route;
                              });
                            }
                            : null,
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text(roleRoute)),
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
              margin: const EdgeInsets.all(10),
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
                color: AppColors.secondary,
              ),
              width: 220,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.home, color: Colors.white),
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
                  const SizedBox(height: 40),

                  Expanded(
                    child: ListView(
                      children:
                          menuItems.mapIndexed((index, menu) {
                            if (menu.subMenuItems.isEmpty) {
                            
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    tabSelected = -1;
                                  });
                                  print(menu.title);
                                  navigateTo(roleRoute);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                    left: 10,
                                    right: 20,
                                    bottom: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color:
                                        tabSelected == -1
                                            ? Color.fromARGB(
                                              115,
                                              226,
                                              239,
                                              248,
                                            ).withOpacity(.4)
                                            : Colors.transparent,
                                  ),
                                  padding: const EdgeInsets.only(
                                    left: 6.0,
                                    top: 8,
                                    bottom: 8,
                                    right: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        menu.icon,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      SizedBox(width: 20),
                                      Text(
                                        menu.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return ExpansionTile(
                              iconColor: Colors.blue,
                              collapsedIconColor: Colors.white,
                              title: Text(
                                menu.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              leading: Icon(
                                menu.icon,
                                color: Colors.white,
                                size: 14,
                              ),
                              children:
                                  menu.subMenuItems.isNotEmpty
                                      ? menu.subMenuItems.mapIndexed((
                                        index,
                                        subItem,
                                      ) {
                                        return InkWell(
                                          onTap: () {
                                            print('hi');

                                            setState(() {
                                              selectedIndex = index;
                                              tabSelected = index;
                                              selectedSubMenu = subItem;
                                            });
                                            navigateTo(
                                              '${menu.title.toLowerCase()}/${subItem.toLowerCase().replaceAll(" ", "")}',
                                            );
                                          },
                                          child: Container(
                                            // padding: const EdgeInsets.symmetric(
                                            //   horizontal: 5,
                                            // ),
                                            alignment: Alignment.centerLeft,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color:
                                                  (tabSelected == index &&
                                                          selectedSubMenu ==
                                                              subItem)
                                                      ? const Color.fromARGB(
                                                        115,
                                                        226,
                                                        239,
                                                        248,
                                                      ).withOpacity(.4)
                                                      : Colors.transparent,
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 5,
                                              horizontal: 20,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 30.0,
                                              ),
                                              child: Text(
                                                subItem,
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                    255,
                                                    255,
                                                    243,
                                                    243,
                                                  ),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList()
                                      : [
                                        ListTile(
                                          title: const Padding(
                                            padding: EdgeInsets.only(
                                              left: 42.0,
                                            ),
                                            child: Text(
                                              'View',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            navigateTo(
                                              menu.title.toLowerCase(),
                                            );
                                          },
                                        ),
                                      ],
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Scaffold(
                appBar: buildAppBar(context),
                body: Column(
                  children: [
                    // Container(
                    //   height: 40,
                    //   color: Colors.transparent,
                    //   padding: const EdgeInsets.only(top: 14.0, bottom: 2),
                    //   alignment: Alignment.centerLeft,
                    //   child: const Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text(
                    //         'School Admin Dashboard',
                    //         style: TextStyle(
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.indigo,
                    //         ),
                    //       ),
                    //       CircleAvatar(
                    //         backgroundColor: Colors.indigoAccent,
                    //         child: Icon(Icons.person, color: Colors.white),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                          right: 10,
                          top: 10,
                          bottom: 20,
                        ),
                        color: Colors.transparent,
                        child: _buildDashboardContent(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

// class MenuItem {
//   final String title;
//   final IconData icon;
//   final List<String> subMenu;

//   MenuItem(this.title, this.icon, this.subMenu);
// }

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

class Account extends StatelessWidget {
  Account({super.key, this.onNavigate});

  final void Function(String destination)? onNavigate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => onNavigate?.call('Subaccount'),

            child: const Text('ho to subaccount'),
          ),
          ElevatedButton(
            onPressed: () => onNavigate?.call('AccountSettings'),
            child: const Text('Go to Settings'),
          ),
        ],
      ),
    );
  }
}

class subaccount extends StatelessWidget {
  const subaccount({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Center(
        child: ElevatedButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to Account'),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Center(
        child: ElevatedButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to Account'),
        ),
      ),
    );
  }
}

class InnerRoute extends StatelessWidget {
  final VoidCallback? onNavigateToInnerRoute;
  final VoidCallback? navigateTo;
  InnerRoute({super.key, this.onNavigateToInnerRoute, this.navigateTo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            navigateTo!();
          },
          child: Text('back'),
        ),
        ElevatedButton(
          onPressed: () {
            onNavigateToInnerRoute!();
          },
          child: Text('go inner'),
        ),
        Text('Inner Route Screen', style: TextStyle(fontSize: 24)),
      ],
    );
  }
}
