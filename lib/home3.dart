import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/login_screen.dart';
import 'package:schmgtsystem/widgets/add_teacher.dart';

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
      allowedRoles: ['admin', 'teacher', 'accountant'],
    ),
    MenuItem(
      title: 'Students',
      icon: Icons.people,
      route: '/students',
      allowedRoles: ['admin', 'teacher'],
      subItems: [
        MenuItem(title: 'All Students', icon: Icons.list, route: '/students'),
        MenuItem(title: 'Add Student', icon: Icons.add, route: '/students/add'),
        MenuItem(title: 'Student Reports', icon: Icons.assessment,route: '/students/reports',
        ),
      ],
    ),
    MenuItem(
      title: 'Classes',
      icon: Icons.class_,
      route: '/classes',
      allowedRoles: ['admin', 'teacher'],
      subItems: [
        MenuItem(title: 'All Classes', icon: Icons.list, route: '/classes'),
        MenuItem(
          title: 'Class Schedule',
          icon: Icons.schedule,
          route: '/classes/schedule',
        ),
        MenuItem(
          title: 'Assign Students',
          icon: Icons.assignment,
          route: '/classes/assign',
        ),
      ],
    ),
    MenuItem(
      title: 'Teachers',
      icon: Icons.person,
      route: '/teachers',
      allowedRoles: ['admin'],
      subItems: [
        MenuItem(title: 'All Teachers', icon: Icons.list, route: '/teachers'),
        MenuItem(title: 'Add Teacher', icon: Icons.add, route: '/teachers/add'),
        MenuItem(
          title: 'Teacher Schedule',
          icon: Icons.schedule,
          route: '/teachers/schedule',
        ),
      ],
    ),
    MenuItem(
      title: 'Attendance',
      icon: Icons.check_circle,
      route: '/attendance',
      allowedRoles: ['admin', 'teacher'],
    ),
    MenuItem(
      title: 'Exams',
      icon: Icons.quiz,
      route: '/exams',
      allowedRoles: ['admin', 'teacher'],
      subItems: [
        MenuItem(title: 'All Exams', icon: Icons.list, route: '/exams'),
        MenuItem(title: 'Create Exam', icon: Icons.add, route: '/exams/create'),
        MenuItem(
          title: 'Results',
          icon: Icons.assessment,
          route: '/exams/results',
        ),
      ],
    ),
    MenuItem(
      title: 'Accounts',
      icon: Icons.account_balance,
      route: '/accounts',
      allowedRoles: ['admin', 'accountant'],
      subItems: [
        MenuItem(title: 'Overview', icon: Icons.dashboard, route: '/accounts'),
        MenuItem(
          title: 'Income',
          icon: Icons.trending_up,
          route: '/accounts/income',
        ),
        MenuItem(
          title: 'Expenditure',
          icon: Icons.trending_down,
          route: '/accounts/expenditure',
        ),
        MenuItem(
          title: 'School Fees',
          icon: Icons.payment,
          route: '/accounts/fees',
        ),
      ],
    ),
    MenuItem(
      title: 'Reports',
      icon: Icons.bar_chart,
      route: '/reports',
      allowedRoles: ['admin'],
    ),
    MenuItem(
      title: 'Settings',
      icon: Icons.settings,
      route: '/settings',
      allowedRoles: ['admin'],
    ),
  ];

  // Filter menu items based on user role
  return allMenuItems.where((item) {
    return item.allowedRoles == null || item.allowedRoles!.contains(userRole);
  }).toList();
});

// Router Configuration with Persistent Shell// Fixed Router Configuration with correct sub-route paths
final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    ShellRoute(
      builder: (context, state, child) {
        return DashboardShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardHomeScreen(),
        ),
        GoRoute(
          path: '/students',
          builder: (context, state) => const StudentsScreen(),
          routes: [
            // FIXED: Remove leading slash from sub-routes
            GoRoute(
              path: 'add', // Changed from '/add' to 'add'
              builder: (context, state) => const AddStudentScreen(),
            ),
            GoRoute(
              path: 'reports', // Changed from '/reports' to 'reports'
              builder: (context, state) => const StudentReportsScreen(),
            ),
            GoRoute(
              path: ':studentId', // Changed from '/:studentId' to ':studentId'
              builder: (context, state) {
                final studentId = state.pathParameters['studentId']!;
                return StudentDetailScreen(studentId: studentId);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/classes',
          builder: (context, state) => const ClassesScreen(),
          routes: [
            GoRoute(
              path: 'schedule', // Changed from '/schedule' to 'schedule'
              builder: (context, state) => const ClassScheduleScreen(),
            ),
            GoRoute(
              path: 'assign', // Changed from '/assign' to 'assign'
              builder: (context, state) => const AssignStudentsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/teachers',
          builder: (context, state) => const TeachersScreen(),
          routes: [
            GoRoute(
              path: 'add', // Changed from '/add' to 'add'
              builder: (context, state) => const AddTeacherScreen(),
            ),
            GoRoute(
              path: 'schedule', // Changed from '/schedule' to 'schedule'
              builder: (context, state) => const TeacherScheduleScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/attendance',
          builder: (context, state) => const AttendanceScreen(),
        ),
        GoRoute(
          path: '/exams',
          builder: (context, state) => const ExamsScreen(),
          routes: [
            GoRoute(
              path: 'create', // Changed from '/create' to 'create'
              builder: (context, state) => const CreateExamScreen(),
            ),
            GoRoute(
              path: 'results', // Changed from '/results' to 'results'
              builder: (context, state) => const ExamResultsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/accounts',
          builder: (context, state) => const AccountsOverviewScreen(),
          routes: [
            GoRoute(
              path: 'income', // Changed from '/income' to 'income'
              builder: (context, state) => const IncomeScreen(),
            ),
            GoRoute(
              path:
                  'expenditure', // Changed from '/expenditure' to 'expenditure'
              builder: (context, state) => const ExpenditureScreen(),
            ),
            GoRoute(
              path: 'fees', // Changed from '/fees' to 'fees'
              builder: (context, state) => const SchoolFeesScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
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
                    'School Management',
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
              // Role Switcher (for demo)
              _buildRoleSelector(ref),
              const SizedBox(width: 16),
              // Notifications
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications clicked')),
                  );
                },
              ),
              const SizedBox(width: 8),
              // User Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.indigo,
                child: const Icon(Icons.person, color: Colors.white, size: 18),
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

    return DropdownButton<String>(
      value: currentRole,
      underline: const SizedBox.shrink(),
      items:
          ['admin', 'teacher', 'accountant'].map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role.toUpperCase()),
            );
          }).toList(),
      onChanged: (newRole) {
        if (newRole != null) {
          ref.read(currentUserRoleProvider.notifier).state = newRole;
        }
      },
    );
  }
}

// Sample Screen Components (replace with your actual screens)
class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(child: Center(child: Text('Dashboard content goes here'))),
        ],
      ),
    );
  }
}

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Students',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () => context.go('/students/add'),
                child: const Text('Add Student'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Expanded(
            child: Center(child: Text('Students list will go here')),
          ),
        ],
      ),
    );
  }
}

// Add other screen implementations...
class AddStudentScreen extends StatelessWidget {
  const AddStudentScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/students'),
              ),
              const Text(
                'Add Student',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Expanded(
            child: Center(child: Text('Add student form goes here')),
          ),
        ],
      ),
    );
  }
}

class StudentReportsScreen extends StatelessWidget {
  const StudentReportsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Student Reports'));
}

class StudentDetailScreen extends StatelessWidget {
  final String studentId;
  const StudentDetailScreen({Key? key, required this.studentId})
    : super(key: key);
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Student Detail: $studentId'));
}

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Center(child: Text('Classes'));
}

class ClassScheduleScreen extends StatelessWidget {
  const ClassScheduleScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Class Schedule'));
}

class AssignStudentsScreen extends StatelessWidget {
  const AssignStudentsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Assign Students'));
}

class TeachersScreen extends StatelessWidget {
  const TeachersScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Center(child: Text('Teachers'));
}

class AddTeacherScreen extends StatelessWidget {
  const AddTeacherScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Add Teacher'));
}

class TeacherScheduleScreen extends StatelessWidget {
  const TeacherScheduleScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Teacher Schedule'));
}

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Center(child: Text('Attendance'));
}

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Center(child: Text('Exams'));
}

class CreateExamScreen extends StatelessWidget {
  const CreateExamScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Create Exam'));
}

class ExamResultsScreen extends StatelessWidget {
  const ExamResultsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Exam Results'));
}

class AccountsOverviewScreen extends StatelessWidget {
  const AccountsOverviewScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Accounts Overview'));
}

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Center(child: Text('Income'));
}

class ExpenditureScreen extends StatelessWidget {
  const ExpenditureScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Expenditure'));
}

class SchoolFeesScreen extends StatelessWidget {
  const SchoolFeesScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('School Fees'));
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Center(child: Text('Reports'));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Center(child: Text('Settings'));
}
