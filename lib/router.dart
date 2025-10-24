// // Router Configuration with Login Route
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:schmgtsystem/home3.dart';
// import 'package:schmgtsystem/login_screen.dart';
// final routerProvider = Provider<GoRouter>((ref) {
//   return GoRouter(
//     initialLocation: '/login', // Start with login instead of dashboard
//     routes: [
//       // Login route (outside of shell - no sidebar/header)
//       GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

//       // Main app routes with persistent shell (sidebar + header)
//       ShellRoute(
//         builder: (context, state, child) {
//           return DashboardShell(child: child);
//         },
//         routes: [
//           GoRoute(
//             path: '/dashboard',
//             builder: (context, state) => const DashboardHomeScreen(),
//           ),
//           GoRoute(
//             path: '/students',
//             builder: (context, state) => const StudentsScreen(),
//             routes: [
//               GoRoute(
//                 path: '/add',
//                 builder: (context, state) => const AddStudentScreen(),
//               ),
//               GoRoute(
//                 path: '/reports',
//                 builder: (context, state) => const StudentReportsScreen(),
//               ),
//               GoRoute(
//                 path: '/:studentId',
//                 builder: (context, state) {
//                   final studentId = state.pathParameters['studentId']!;
//                   return StudentDetailScreen(studentId: studentId);
//                 },
//               ),
//             ],
//           ),
//           GoRoute(
//             path: '/classes',
//             builder: (context, state) => const ClassesScreen(),
//             routes: [
//               GoRoute(
//                 path: '/schedule',
//                 builder: (context, state) => const ClassScheduleScreen(),
//               ),
//               GoRoute(
//                 path: '/assign',
//                 builder: (context, state) => const AssignStudentsScreen(),
//               ),
//             ],
//           ),
//           GoRoute(
//             path: '/teachers',
//             builder: (context, state) => const TeachersScreen(),
//             routes: [
//               GoRoute(
//                 path: '/add',
//                 builder: (context, state) => const AddTeacherScreen(),
//               ),
//               GoRoute(
//                 path: '/schedule',
//                 builder: (context, state) => const TeacherScheduleScreen(),
//               ),
//             ],
//           ),
//           GoRoute(
//             path: '/attendance',
//             builder: (context, state) => const AttendanceScreen(),
//           ),
//           GoRoute(
//             path: '/exams',
//             builder: (context, state) => const ExamsScreen(),
//             routes: [
//               GoRoute(
//                 path: '/create',
//                 builder: (context, state) => const CreateExamScreen(),
//               ),
//               GoRoute(
//                 path: '/results',
//                 builder: (context, state) => const ExamResultsScreen(),
//               ),
//             ],
//           ),
//           GoRoute(
//             path: '/accounts',
//             builder: (context, state) => const AccountsOverviewScreen(),
//             routes: [
//               GoRoute(
//                 path: '/income',
//                 builder: (context, state) => const IncomeScreen(),
//               ),
//               GoRoute(
//                 path: '/expenditure',
//                 builder: (context, state) => const ExpenditureScreen(),
//               ),
//               GoRoute(
//                 path: '/fees',
//                 builder: (context, state) => const SchoolFeesScreen(),
//               ),
//             ],
//           ),
//           GoRoute(
//             path: '/reports',
//             builder: (context, state) => const ReportsScreen(),
//           ),
//           GoRoute(
//             path: '/settings',
//             builder: (context, state) => const SettingsScreen(),
//           ),
//         ],
//       ),
//     ],
//   );
// });
