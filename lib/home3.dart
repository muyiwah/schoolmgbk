import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;
import 'package:schmgtsystem/login_screen.dart';
import 'package:schmgtsystem/providers/subject_provider.dart';
import 'package:schmgtsystem/providers/class_provider.dart';
import 'package:schmgtsystem/screens/Class/manage_student_class.dart';
import 'package:schmgtsystem/screens/Class/subject_management.dart';
import 'package:schmgtsystem/screens/accunts/class_payment_details.dart';
import 'package:schmgtsystem/screens/accunts/fee_breakdown.dart';
import 'package:schmgtsystem/screens/accunts/fee_verification.dart';
import 'package:schmgtsystem/screens/exams/records.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screen imports - Class
import 'package:schmgtsystem/screens/Class/all_table.dart';
import 'package:schmgtsystem/screens/Class/classes.dart';
import 'package:schmgtsystem/screens/Class/single_class.dart';
import 'package:schmgtsystem/screens/Class/class_level_management.dart';

// Screen imports - Student
import 'package:schmgtsystem/screens/Student/add_student.dart';
import 'package:schmgtsystem/screens/Student/all_parents.dart';
import 'package:schmgtsystem/screens/Student/all_student.dart';
import 'package:schmgtsystem/screens/Student/create_timetale.dart';
import 'package:schmgtsystem/screens/Student/parent_all_transactions.dart';
import 'package:schmgtsystem/screens/Student/single_parent.dart';
import 'package:schmgtsystem/screens/Student/single_student.dart';
import 'package:schmgtsystem/screens/Student/timetable.dart';

// Screen imports - Accounts
import 'package:schmgtsystem/screens/accunts/account_home.dart';
import 'package:schmgtsystem/screens/accunts/accounts.dart';
import 'package:schmgtsystem/screens/accunts/expenditure_manager.dart';

// Screen imports - Admissions
import 'package:schmgtsystem/screens/admissions/admission_screen.dart';
import 'package:schmgtsystem/screens/admissions/register_online.dart';
import 'package:schmgtsystem/screens/admissions/admission_management.dart';

// Screen imports - CBT
import 'package:schmgtsystem/screens/cbt/cbt_crateexam_teacher.dart';
import 'package:schmgtsystem/screens/cbt/cbt_question_bank.dart';
import 'package:schmgtsystem/screens/cbt/cbt_result.dart';
import 'package:schmgtsystem/screens/cbt/cbt_score_parent.dart';
import 'package:schmgtsystem/screens/cbt/cbt_take_exam.dart';

// Screen imports - Communication
import 'package:schmgtsystem/screens/communication/new_communication.dart';

// Screen imports - Exams
import 'package:schmgtsystem/screens/exams/add_exams.dart';
import 'package:schmgtsystem/screens/exams/overview2.dart';

// Screen imports - Admin Home
import 'package:schmgtsystem/screens/adminhome/dashboar_details.dart';
import 'package:schmgtsystem/screens/adminhome/dshboard.dart';
import 'package:schmgtsystem/screens/parent/parent_dashboard.dart';
import 'package:schmgtsystem/screens/teacher/teacher_dashboard.dart';
import 'package:schmgtsystem/screens/teacher/teacher_students.dart';

// Screen imports - Promotions
import 'package:schmgtsystem/screens/promotions/manage_promotion.dart';
import 'package:schmgtsystem/screens/promotions/report_card.dart';
import 'package:schmgtsystem/screens/promotions/student_list_reportcard.dart';

// Screen imports - Staff
import 'package:schmgtsystem/screens/staff/add_staff.dart';
import 'package:schmgtsystem/screens/staff/all_staff.dart';
import 'package:schmgtsystem/screens/staff/teachers.dart';

// Screen imports - Inventory

// Other imports
import 'package:schmgtsystem/custom_timetable.dart';
import 'package:schmgtsystem/deepseek/deepseek2222/examsetupscreen.dart';
import 'package:schmgtsystem/schoolfees_monitor.dart';

// Menu Item Model
class MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final List<MenuItem>? subItems;
  final List<String>? allowedRoles;

  MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    this.subItems,
    this.allowedRoles,
  });
}

// Providers
final currentUserRoleProvider = StateProvider<String>((ref) => 'admin');
final sidebarExpandedProvider = StateProvider<bool>((ref) => true);
final selectedMenuIndexProvider = StateProvider<int>((ref) => 0);

// Menu Configuration
final menuItemsProvider = Provider<List<MenuItem>>((ref) {
  final userRole = ref.watch(currentUserRoleProvider);

  final allMenuItems = [
    MenuItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: '/dashboard',
      allowedRoles: ['admin', 'accountant'],
    ),
    MenuItem(
      title: 'Class Teacher',
      icon: Icons.dashboard,
      route: '/teacher',
      allowedRoles: ['teacher'],
    ),
    MenuItem(
      title: 'Students',
      icon: Icons.people,
      route: '/students',
      allowedRoles: ['admin'],
      subItems: [
        MenuItem(title: 'All Students', icon: Icons.list, route: '/students'),
        MenuItem(title: 'Add Student', icon: Icons.add, route: '/students/add'),

        MenuItem(
          title: 'Parents',
          icon: Icons.family_restroom,
          route: '/students/parents',
        ),
        // MenuItem(
        //   title: 'Parent Transactions',
        //   icon: Icons.payment,
        //   route: '/students/parent-transactions',
        // ),
        // MenuItem(
        //   title: 'Time Table',
        //   icon: Icons.schedule,
        //   route: '/students/timetable',
        // ),
        // MenuItem(
        //   title: 'Create Time Table',
        //   icon: Icons.create,
        //   route: '/students/create-timetable',
        // ),
        // MenuItem(
        //   title: 'Attendance',
        //   icon: Icons.check_circle,
        //   route: '/students/attendance',
        // ),
      ],
    ),
    MenuItem(
      title: 'Classes',
      icon: Icons.class_,
      route: '/classes',
      allowedRoles: ['admin'],
      subItems: [
        MenuItem(title: 'All Classes', icon: Icons.list, route: '/classes'),
        MenuItem(
          title: 'Subject Management',
          icon: Icons.class_,
          route: '/classes/subject-management',
        ),
        MenuItem(
          title: 'All Tables',
          icon: Icons.table_chart,
          route: '/classes/tables',
        ),
        MenuItem(
          title: 'Class Level Management',
          icon: Icons.table_chart,
          route: '/classes/level-management',
        ),
        MenuItem(
          title: 'Assign Students',
          icon: Icons.assignment,
          route: '/classes/assign',
        ),
        // MenuItem(
        //   title: 'Time Table',
        //   icon: Icons.schedule,
        //   route: '/classes/timetable',
        // ),
        MenuItem(
          title: 'Exam Schedule',
          icon: Icons.event,
          route: '/classes/exam-schedule',
        ),
      ],
    ),
    MenuItem(
      title: 'Staff',
      icon: Icons.person,
      route: '/staff',
      allowedRoles: ['admin'],
      subItems: [
        MenuItem(title: 'All Staff', icon: Icons.list, route: '/staff'),
        MenuItem(title: 'Add Staff', icon: Icons.add, route: '/staff/add'),
        // MenuItem(
        //   title: 'Assign Teacher',
        //   icon: Icons.assignment_ind,
        //   route: '/staff/assign-teacher',
        // ),
        // MenuItem(
        //   title: 'Create Timetable',
        //   icon: Icons.create,
        //   route: '/staff/create-timetable',
        // ),
      ],
    ),
    // MenuItem(
    //   title: 'CBT',
    //   icon: Icons.quiz,
    //   route: '/cbt',
    //   allowedRoles: ['admin', 'teacher'],
    //   subItems: [
    //     MenuItem(
    //       title: 'Create Exam',
    //       icon: Icons.add,
    //       route: '/cbt/create-exam',
    //     ),
    //     MenuItem(
    //       title: 'Question Bank',
    //       icon: Icons.library_books,
    //       route: '/cbt/question-bank',
    //     ),
    //     MenuItem(
    //       title: 'Take Exam',
    //       icon: Icons.play_arrow,
    //       route: '/cbt/take-exam',
    //     ),
    //     MenuItem(
    //       title: 'Results',
    //       icon: Icons.assessment,
    //       route: '/cbt/results',
    //     ),
    //     MenuItem(
    //       title: 'Student Results',
    //       icon: Icons.school,
    //       route: '/cbt/student-results',
    //     ),
    //     MenuItem(
    //       title: 'Parent Score',
    //       icon: Icons.family_restroom,
    //       route: '/cbt/parent-score',
    //     ),
    //   ],
    // ),
    // MenuItem(
    //   title: 'Inventory',
    //   icon: Icons.inventory,
    //   route: '/inventory',
    //   allowedRoles: ['admin'],
    //   subItems: [
    //     MenuItem(
    //       title: 'Inventory',
    //       icon: Icons.inventory_2,
    //       route: '/inventory',
    //     ),
    //   ],
    // ),
    MenuItem(
      title: 'Parent',
      icon: Icons.inventory,
      route: '/parent',
      allowedRoles: ['parent'],
      subItems: [
        // MenuItem(
        //   title: 'Inventory',
        //   icon: Icons.inventory_2,
        //   route: '/inventory',
        // ),
      ],
    ),
    MenuItem(
      title: 'Exams',
      icon: Icons.quiz,
      route: '/exams',
      allowedRoles: ['admin', 'teacher'],
      subItems: [
        // MenuItem(title: 'All Exams', icon: Icons.list, route: '/exams'),
        // MenuItem(title: 'Add Exam', icon: Icons.add, route: '/exams/add'),
        // MenuItem(
        //   title: 'Exam Schedule',
        //   icon: Icons.schedule,
        //   route: '/exams/schedule',
        // ),
        MenuItem(
          title: 'Records',
          icon: Icons.record_voice_over,
          route: '/exams/records',
        ),
      ],
    ),
    MenuItem(
      title: 'Admissions',
      icon: Icons.school,
      route: '/admissions',
      allowedRoles: ['admin'],
      subItems: [
        MenuItem(
          title: 'All Admissions',
          icon: Icons.list,
          route: '/admissions',
        ),
        MenuItem(
          title: 'Student Admission Form',
          icon: Icons.person_add,
          route: '/admissions/form',
        ),
      ],
    ),
    MenuItem(
      title: 'Notifications',
      icon: Icons.notifications,
      route: '/notifications',
      allowedRoles: ['admin'],
      subItems: [
        MenuItem(
          title: 'New Notification',
          icon: Icons.add,
          route: '/notifications/new',
        ),
      ],
    ),
    MenuItem(
      title: 'Promotions',
      icon: Icons.trending_up,
      route: '/promotions',
      allowedRoles: ['admin'],
      subItems: [
        MenuItem(
          title: 'Manage Promotion',
          icon: Icons.manage_accounts,
          route: '/promotions/manage',
        ),
        MenuItem(
          title: 'Report Card',
          icon: Icons.description,
          route: '/promotions/report-card',
        ),
        MenuItem(
          title: 'Single Report',
          icon: Icons.description_outlined,
          route: '/promotions/single-report',
        ),
      ],
    ),
    MenuItem(
      title: 'Accounts',
      icon: Icons.account_balance,
      route: '/accounts',
      allowedRoles: ['admin', 'accountant'],
      subItems: [
        // MenuItem(title: 'Account Home', icon: Icons.home, route: '/accounts'),
        MenuItem(
          title: 'Fee Verification',
          icon: Icons.home,
          route: '/accounts/fee-verification',
        ),
        MenuItem(
          title: 'Class Account',
          icon: Icons.home,
          route: '/accounts/class-account',
        ),
        MenuItem(
          title: 'Class Fee Breakdown',
          icon: Icons.home,
          route: '/accounts/class-fee-breakdown',
        ),
        // MenuItem(
        //   title: 'Income',
        //   icon: Icons.trending_up,
        //   route: '/accounts/income',
        // ),
        // MenuItem(
        //   title: 'Expenditure',
        //   icon: Icons.trending_down,
        //   route: '/accounts/expenditure',
        // ),
        // MenuItem(
        //   title: 'Expenditure Manager',
        //   icon: Icons.manage_accounts,
        //   route: '/accounts/expenditure-manager',
        // ),
        MenuItem(
          title: 'School Fees',
          icon: Icons.payment,
          route: '/accounts/fees',
        ),
      ],
    ),
  ];

  // Filter menu items based on user role
  return allMenuItems.where((item) {
    return item.allowedRoles == null || item.allowedRoles!.contains(userRole);
  }).toList();
});

// Router Configuration with Persistent Shell
final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    // Get the current user role from the provider
    final container = ProviderScope.containerOf(context);
    final userRole = container.read(currentUserRoleProvider);

    // If user is a parent and trying to access non-parent routes, redirect to parent dashboard
    if (userRole == 'parent' &&
        state.uri.path != '/parent' &&
        state.uri.path != '/login') {
      return '/parent';
    }

    return null; // No redirect needed
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    ShellRoute(
      builder: (context, state, child) {
        return DashboardShell(child: child);
      },
      routes: [
        // Dashboard
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardHomeScreen(),
        ),
        GoRoute(
          path: '/dashboard/details',
          builder: (context, state) => const DashboardDetailsScreen(),
        ),

        // Parent Dashboard Route
        GoRoute(
          path: '/parent',
          builder: (context, state) => const ParentScreen(),
        ),

        // Teacher Dashboard Route
        GoRoute(
          path: '/teacher',
          builder: (context, state) => const TeacherDashboardScreen(),
          routes: [
            GoRoute(
              path: 'students',
              builder: (context, state) => const TeacherStudentsScreen(),
            ),
          ],
        ),

        // Students Routes
        GoRoute(
          path: '/students',
          builder: (context, state) => const StudentsScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddStudentScreen(),
            ),
            GoRoute(
              path: 'single/:studentId',
              builder: (context, state) {
                final studentId = state.pathParameters['studentId']!;
                return SingleStudentScreen(studentId: studentId);
              },
            ),
            GoRoute(
              path: 'parents',
              builder: (context, state) => const AllParentsScreen(),
            ),
            GoRoute(
              path: 'single-parent/:parentId',
              builder: (context, state) {
                final parentId = state.pathParameters['parentId']!;
                return SingleParentScreen(parentId: parentId);
              },
            ),
            GoRoute(
              path: 'parent-transactions',
              builder: (context, state) => const ParentTransactionsScreen(),
            ),
            GoRoute(
              path: 'timetable',
              builder: (context, state) => const StudentTimetableScreen(),
            ),
            GoRoute(
              path: 'create-timetable',
              builder: (context, state) => const CreateTimetableScreen(),
            ),
            GoRoute(
              path: 'attendance',
              builder: (context, state) => const StudentAttendanceScreen(),
            ),
          ],
        ),

        // Classes Routes
        GoRoute(
          path: '/classes',
          builder: (context, state) => const ClassesScreen(),
          routes: [
            GoRoute(path: 'single', redirect: (context, state) => '/classes'),
            GoRoute(
              path: 'single/:classId',
              builder: (context, state) {
                final classId = state.pathParameters['classId'] ?? '';
                return SingleClassScreen(classId: classId);
              },
            ),
            GoRoute(
              path: 'tables',
              builder: (context, state) => const AllTablesScreen(),
            ),
            GoRoute(
              path: 'subject-management',
              builder:
                  (context, state) => provider.MultiProvider(
                    providers: [
                      provider.ChangeNotifierProvider(
                        create: (context) => SubjectProvider(),
                      ),
                      provider.ChangeNotifierProvider(
                        create: (context) => ClassProvider(),
                      ),
                    ],
                    child: const SubjectsManagementPage(),
                  ),
            ),
            GoRoute(
              path: 'assign',
              builder: (context, state) => const AssignStudentsScreen(),
            ),
            GoRoute(
              path: 'timetable',
              builder: (context, state) => const ClassTimetableScreen(),
            ),
            GoRoute(
              path: 'exam-schedule',
              builder: (context, state) => const ExamScheduleScreen(),
            ),
            GoRoute(
              path: 'level-management',
              builder: (context, state) => const ClassLevelManagementScreen(),
            ),
          ],
        ),

        // Staff Routes
        GoRoute(
          path: '/staff',
          builder: (context, state) => const AllStaffScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddStaffScreen(),
            ),
            GoRoute(
              path: 'assign-teacher',
              builder: (context, state) => const AssignTeacherScreen(),
            ),
            GoRoute(
              path: 'create-timetable',
              builder: (context, state) => const CreateTimetableScreen(),
            ),
          ],
        ),

        // CBT Routes
        GoRoute(
          path: '/cbt',
          builder: (context, state) => const CBTHomeScreen(),
          routes: [
            GoRoute(
              path: 'create-exam',
              builder: (context, state) => const CBTCreateExamScreen(),
            ),
            GoRoute(
              path: 'question-bank',
              builder: (context, state) => const CBTQuestionBankScreen(),
            ),
            GoRoute(
              path: 'take-exam',
              builder: (context, state) => const CBTTakeExamScreen(),
            ),
            GoRoute(
              path: 'results',
              builder: (context, state) => const CBTResultsScreen(),
            ),
            GoRoute(
              path: 'student-results',
              builder: (context, state) => const CBTStudentResultsScreen(),
            ),
            GoRoute(
              path: 'parent-score',
              builder: (context, state) => const CBTParentScoreScreen(),
            ),
          ],
        ),

        // Inventory Routes
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const InventoryScreen(),
        ),

        // Exams Routes
        GoRoute(
          path: '/exams',
          builder: (context, state) => const ExamsScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) => const AddExamScreen(),
            ),
            GoRoute(
              path: 'schedule',
              builder: (context, state) => const ExamScheduleScreen(),
            ),
            GoRoute(
              path: 'records',
              builder: (context, state) => const ExamRecords(),
            ),
          ],
        ),

        // Admissions Routes
        GoRoute(
          path: '/admissions',
          builder: (context, state) => const AdmissionManagementScreen(),
          routes: [
            GoRoute(
              path: 'form',
              builder: (context, state) => StudentAdmissionForm(),
            ),
          ],
        ),

        // Notifications Routes
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const NewNotificationScreen(),
            ),
          ],
        ),

        // Promotions Routes
        GoRoute(
          path: '/promotions',
          builder: (context, state) => const PromotionsScreen(),
          routes: [
            GoRoute(
              path: 'manage',
              builder: (context, state) => const ManagePromotionScreen(),
            ),
            GoRoute(
              path: 'report-card',
              builder: (context, state) => const ReportCardListScreen(),
            ),
            GoRoute(
              path: 'single-report',
              builder: (context, state) => const SingleReportScreen(),
            ),
          ],
        ),

        // Accounts Routes
        GoRoute(
          path: '/accounts',
          builder: (context, state) => const AccountHomeScreen(),
          routes: [
            GoRoute(
              path: 'class-account',
              builder:
                  (context, state) => PaymentDetailsScreen(
                    classId: null,
                    className: 'All Classes',
                  ),
            ),
            GoRoute(
              path: 'class-fee-breakdown',
              builder: (context, state) => PaymentBreakdownScreen(),
            ),
            GoRoute(
              path: 'fee-verification',
              builder: (context, state) => PaymentVerificationScreen(),
            ),
            GoRoute(
              path: 'income',
              builder: (context, state) => const IncomeScreen(),
            ),
            GoRoute(
              path: 'expenditure',
              builder: (context, state) => const ExpenditureScreen(),
            ),
            GoRoute(
              path: 'expenditure-manager',
              builder: (context, state) => const ExpenditureManagerScreen(),
            ),
            GoRoute(
              path: 'fees',
              builder: (context, state) => const SchoolFeesScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

// Main Dashboard Shell - This stays persistent
class DashboardShell extends ConsumerWidget {
  final Widget child;

  const DashboardShell({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarExpanded = ref.watch(sidebarExpandedProvider);

    return Scaffold(
      body: Row(
        children: [
          // Persistent Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: sidebarExpanded ? 280 : 70,
            child: PersistentSidebar(),
          ),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Persistent Header
                PersistentHeader(),
                // Dynamic Content
                Expanded(
                  child: Container(
                    color: Colors.grey[50],
                    child: child, // This changes based on the route
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Persistent Sidebar Component
class PersistentSidebar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = ref.watch(menuItemsProvider);
    final sidebarExpanded = ref.watch(sidebarExpandedProvider);
    final userRole = ref.watch(currentUserRoleProvider);
    final currentLocation =
        GoRouter.of(context).routeInformationProvider.value.location;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.indigo[900]!, Colors.indigo[700]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sidebar Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Logo/Icon
                CircleAvatar(
                  radius: sidebarExpanded ? 30 : 20,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.school,
                    color: Colors.indigo[700],
                    size: sidebarExpanded ? 30 : 20,
                  ),
                ),
                if (sidebarExpanded) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'LoveSpring Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    userRole.toUpperCase(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),

          const Divider(color: Colors.white30),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isActive = _isRouteActive(currentLocation, item.route);
                final hasSubItems =
                    item.subItems != null && item.subItems!.isNotEmpty;

                if (hasSubItems && sidebarExpanded) {
                  return _buildExpandableMenuItem(
                    context,
                    ref,
                    item,
                    currentLocation,
                  );
                } else {
                  return _buildMenuItem(context, ref, item, isActive);
                }
              },
            ),
          ),

          const Divider(color: Colors.white30),

          // Sidebar Toggle
          Container(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              onPressed: () {
                ref.read(sidebarExpandedProvider.notifier).state =
                    !sidebarExpanded;
              },
              icon: Icon(
                sidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
                color: Colors.white,
              ),
              tooltip: sidebarExpanded ? 'Collapse Sidebar' : 'Expand Sidebar',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    WidgetRef ref,
    MenuItem item,
    bool isActive,
  ) {
    final sidebarExpanded = ref.watch(sidebarExpandedProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(item.icon, color: Colors.white, size: 20),
        title:
            sidebarExpanded
                ? Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                )
                : null,
        onTap: () => context.go(item.route),
        contentPadding: EdgeInsets.symmetric(
          horizontal: sidebarExpanded ? 16 : 8,
          vertical: 4,
        ),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildExpandableMenuItem(
    BuildContext context,
    WidgetRef ref,
    MenuItem item,
    String currentLocation,
  ) {
    final isParentActive = _isRouteActive(currentLocation, item.route);

    return ExpansionTile(
      leading: Icon(item.icon, color: Colors.white, size: 20),
      title: Text(
        item.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      backgroundColor: isParentActive ? Colors.white.withOpacity(0.1) : null,
      children:
          item.subItems!.map((subItem) {
            final isSubActive = _isRouteActive(currentLocation, subItem.route);
            return Container(
              margin: const EdgeInsets.only(left: 20, right: 8, bottom: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color:
                    isSubActive
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent,
              ),
              child: ListTile(
                leading: Icon(subItem.icon, color: Colors.white70, size: 16),
                title: Text(
                  subItem.title,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                onTap: () => context.go(subItem.route),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                dense: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            );
          }).toList(),
    );
  }

  bool _isRouteActive(String currentLocation, String itemRoute) {
    if (itemRoute == '/dashboard') {
      return currentLocation == '/dashboard';
    }
    return currentLocation.startsWith(itemRoute);
  }
}

// Persistent Header Component
class PersistentHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation =
        GoRouter.of(context).routeInformationProvider.value.location;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Breadcrumbs
          Expanded(child: _buildBreadcrumbs(currentLocation)),
          // Header Actions
          Row(
            children: [
              // Role Switcher (for demo - only show for admin)
              if (ref.watch(currentUserRoleProvider) == 'admin')
                _buildRoleSelector(ref),
              if (ref.watch(currentUserRoleProvider) == 'admin')
                const SizedBox(width: 16),
              // Notifications
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Notifications clicked')),
                  // );
                },
              ),
              const SizedBox(width: 8),
              // User Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.indigo,
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              // Logout Button
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: () => _showLogoutDialog(context),
                tooltip: 'Logout',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs(String currentLocation) {
    final segments =
        currentLocation
            .split('/')
            .where((s) => s.isNotEmpty)
            .map((s) => s.replaceAll('-', ' ').toUpperCase())
            .toList();

    if (segments.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        for (int i = 0; i < segments.length; i++) ...[
          if (i > 0)
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          Text(
            segments[i],
            style: TextStyle(
              fontSize: 14,
              color:
                  i == segments.length - 1 ? Colors.indigo : Colors.grey[600],
              fontWeight:
                  i == segments.length - 1
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRoleSelector(WidgetRef ref) {
    final currentRole = ref.watch(currentUserRoleProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButton<String>(
        value: currentRole,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        items:
            ['admin', 'teacher', 'accountant', 'parent'].map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    color:
                        role == 'admin'
                            ? Colors.red
                            : role == 'teacher'
                            ? Colors.blue
                            : role == 'accountant'
                            ? Colors.green
                            : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
        onChanged: (newRole) {
          if (newRole != null) {
            ref.read(currentUserRoleProvider.notifier).state = newRole;
          }
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Clear saved credentials
                await _clearSavedCredentials();
                // Reset user role to default
                final container = ProviderScope.containerOf(context);
                container.read(currentUserRoleProvider.notifier).state =
                    'admin';
                // Clear user data and redirect to login
                context.go('/login');
                showSnackbar(context, 'Logged out successfully');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Clear saved credentials (for logout)
  Future<void> _clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
      await prefs.remove('saved_role');
    } catch (e) {
      // Handle error silently
      print('Error clearing saved credentials: $e');
    }
  }
}

// Screen Components - Using actual screens from the archive
class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MetricScreen(
      navigateTo: () {
        context.go('/dashboard/details');
      },
    );
  }
}

class DashboardDetailsScreen extends StatelessWidget {
  const DashboardDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DashboardDetails(
      navigateBack: () {
        context.go('/dashboard');
      },
    );
  }
}

// Student Screens
class StudentsScreen extends StatelessWidget {
  const StudentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AllStudentsScreen();
  }
}

class AddStudentScreen extends StatelessWidget {
  const AddStudentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const StudentRegistrationPage();
  }
}

class SingleStudentScreen extends StatelessWidget {
  final String studentId;
  const SingleStudentScreen({Key? key, required this.studentId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleStudent(studentId: studentId);
  }
}

class AllParentsScreen extends StatelessWidget {
  const AllParentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AllParents(
      navigateTo: (parentId) {
        context.go('/students/single-parent/$parentId');
      },
    );
  }
}

class SingleParentScreen extends StatelessWidget {
  final String parentId;

  const SingleParentScreen({Key? key, required this.parentId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Debug: Print the parentId being passed
    print('SingleParentScreen received parentId: $parentId');

    return SingleParent(
      parentId: parentId,
      navigateTo: () {
        context.go('/students/parents');
      },
      navigateTo2: () {
        context.go('/students/parent-transactions');
      },
    );
  }
}

class ParentTransactionsScreen extends StatelessWidget {
  const ParentTransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PaymentSummaryScreen(
      navigateTo: () {
        context.go('/students/parents');
      },
    );
  }
}

class StudentTimetableScreen extends StatelessWidget {
  const StudentTimetableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CreateTimetale();
  }
}

class CreateTimetableScreen extends StatelessWidget {
  const CreateTimetableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CreateTimetale();
  }
}

class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ExamSetupScreen();
  }
}

// Class Screens
class ClassesScreen extends StatelessWidget {
  const ClassesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SchoolClasses(
      navigateTo: () {
        context.go('/classes/tables');
      },
      navigateTo2: () async {
        context.go('/classes/single');
      },
      navigateTo3: () {
        context.go('/classes/assign');
      },
    );
  }
}

class SingleClassScreen extends StatelessWidget {
  final String classId;

  const SingleClassScreen({Key? key, required this.classId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClassDetailsScreen(classId: classId);
  }
}

class AllTablesScreen extends StatelessWidget {
  const AllTablesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AllTables(
      navigateBack: () {
        context.go('/classes');
      },
    );
  }
}

class AssignStudentsScreen extends StatelessWidget {
  const AssignStudentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ManageStudentClass();
  }
}

class ClassTimetableScreen extends StatelessWidget {
  const ClassTimetableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TimeTableApp();
  }
}

class ExamScheduleScreen extends StatelessWidget {
  const ExamScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExamTimeTable();
  }
}

// Staff Screens
class AllStaffScreen extends StatelessWidget {
  const AllStaffScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AllStaff(
      navigateTo: () {
        // AllStaff doesn't actually use navigateTo, but keeping for compatibility
        context.go('/staff');
      },
    );
  }
}

class AddStaffScreen extends StatelessWidget {
  const AddStaffScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AddStaff();
  }
}

class AssignTeacherScreen extends StatelessWidget {
  const AssignTeacherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AssignTeacher();
  }
}

// CBT Screens
class CBTHomeScreen extends StatelessWidget {
  const CBTHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        CBTExamCreatorPage(),
        QuestionBankScreen(),
        ExamScreen(),
        CBTResultsScreen(),
        CbtExamResultsDashboard(),
        CbtParentDashboard(),
      ],
    );
  }
}

class CBTCreateExamScreen extends StatelessWidget {
  const CBTCreateExamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CBTExamCreatorPage();
  }
}

class CBTQuestionBankScreen extends StatelessWidget {
  const CBTQuestionBankScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuestionBankScreen();
  }
}

class CBTTakeExamScreen extends StatelessWidget {
  const CBTTakeExamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExamScreen();
  }
}

class CBTResultsScreen extends StatelessWidget {
  const CBTResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CBTResultsScreen();
  }
}

class CBTStudentResultsScreen extends StatelessWidget {
  const CBTStudentResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CbtExamResultsDashboard();
  }
}

class CBTParentScoreScreen extends StatelessWidget {
  const CBTParentScoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CbtParentDashboard();
  }
}

// Inventory Screen
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const InventoryScreen();
  }
}

// Exam Screens
class ExamsScreen extends StatelessWidget {
  const ExamsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExaminationOverviewScreenTwo(
      navigateTo: () {
        context.go('/exams/add');
      },
    );
  }
}

class AddExamScreen extends StatelessWidget {
  const AddExamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CreateNewExamScreen(
      navigateBack: () {
        context.go('/exams');
      },
    );
  }
}

class ExamRecords extends StatelessWidget {
  const ExamRecords({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ExamRecordsScreen();
  }
}

// Admissions Screen
class AdmissionsScreen extends StatelessWidget {
  const AdmissionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AdmissionsOverviewPage();
  }
}

// Notifications Screens
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AdminMessagingCenter();
  }
}

class NewNotificationScreen extends StatelessWidget {
  const NewNotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AdminMessagingCenter();
  }
}

// Promotions Screens
class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StudentPromotionManager();
  }
}

class ManagePromotionScreen extends StatelessWidget {
  const ManagePromotionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StudentPromotionManager();
  }
}

class ReportCardListScreen extends StatelessWidget {
  const ReportCardListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReportCardStudentList(
      navigateTo: () {
        context.go('/promotions/single-report');
      },
    );
  }
}

class SingleReportScreen extends StatelessWidget {
  const SingleReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReportCardScreen(
      navigateTo: () {
        context.go('/promotions/report-card');
      },
    );
  }
}

// Account Screens
class AccountHomeScreen extends StatelessWidget {
  const AccountHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AccountHome();
  }
}

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const FinancialOverviewScreen();
  }
}

class ParentScreen extends StatelessWidget {
  const ParentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ParentDashboardScreen();
  }
}

class ExpenditureScreen extends StatelessWidget {
  const ExpenditureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpenditureScreen();
  }
}

class ExpenditureManagerScreen extends StatelessWidget {
  const ExpenditureManagerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpenditureManger();
  }
}

class SchoolFeesScreen extends StatelessWidget {
  const SchoolFeesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SchoolFeesDashboard();
  }
}
