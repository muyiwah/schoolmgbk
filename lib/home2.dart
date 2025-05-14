// import 'package:flutter/material.dart';

// class MenuItem {
//   final String title;
//   final IconData icon;
//   final List<String> subMenuItems;

//   MenuItem(this.title, this.icon, this.subMenuItems);
// }

// class SchoolAdminDashboard2 extends StatelessWidget {
//   const SchoolAdminDashboard2({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'School Admin Dashboard',
//       theme: ThemeData.light().copyWith(
//         primaryColor: Colors.indigoAccent,
//         scaffoldBackgroundColor: const Color(0xFFF5F6FA),
//       ),
//       home: const DashboardScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   late final Map<String, Widget> internalRoutes = _createRoutes();

//   String currentRoute = 'home';
//   List<String> breadcrumbs = ['home'];

//   final List<MenuItem> menuItems = [
//     MenuItem('Home', Icons.home, []),
//     MenuItem('Class', Icons.person_add, ['Add Class', 'All Classes']),
//     MenuItem('Inventory', Icons.inventory, ['All item', 'Edit item']),
//     MenuItem('Student', Icons.school, [
//       'All Students',
//       'Add Student',
//       'Attendance',
//       'Time Table',
//       'Edit4',
//       'Edit5',
//       'Create Time Table',
//     ]),
//     MenuItem('Fees', Icons.attach_money, [
//       'Teacher1',
//       'Admin1',
//       'Admin2',
//       'Admin3',
//       'All Fees',
//       'Add/Edit Fee',
//     ]),
//     MenuItem('CBT', Icons.computer, [
//       'Add CBT Exam',
//       'Manage Exam',
//       'Results',
//       'New',
//     ]),
//     MenuItem('Exams', Icons.assignment, ['All Exams', 'Add Exam']),
//     MenuItem('Staff', Icons.person, [
//       'All Staff',
//       'Add Staff',
//       'Time Table',
//       'Teacher',
//       'Attendance',
//     ]),
//     MenuItem('Lesson Notes', Icons.book, ['All Notes', 'Add New Note']),
//     MenuItem('Library', Icons.library_books, ['All Books', 'Add Librarian']),
//     MenuItem('Chats', Icons.chat, []),
//     MenuItem('Admissions', Icons.school, []),
//     MenuItem('Promotions', Icons.star, []),
//     MenuItem('Accounts', Icons.account_circle, []),
//   ];

//   Map<String, Widget> _createRoutes() {
//     return {
//       'home': const HomeScreen(),
//       'class/add': AddClassScreen(
//         onNavigateToInnerRoute:
//             () => navigateTo('student/addstudent/innerroute'),
//       ),
//       'student/attendance': Attendance(
//         onNavigateToInnerRoute:
//             () => navigateTo('student/addstudent/innerroute'),
//       ),
//       'inventory/all': const AllItemsScreen(),
//       'inventory/edit': const EditItemScreen(),
//       'student/allstudents': Container(
//         color: Colors.amber,
//         child: Center(
//           child: ElevatedButton(
//             onPressed: () {
//               navigateTo('student/addstudent/innerroute');
//             },
//             child: const Text('go'),
//           ),
//         ),
//       ),
//       'student/addstudent': Container(
//         color: Colors.green,
//         child: const Center(child: Text('Add Student')),
//       ),
//       'accounts': Container(
//         color: Colors.red,
//         child: const Center(child: Text('Account')),
//       ),
//       'student/addstudent/innerroute': InnerRoute(
//         navigateTo: () {
//           navigateTo('inventory/all');
//         },
//       ),
//     };
//   }

//   void navigateTo(String route) {
//     print(route);
//     setState(() {
//       currentRoute = route;
//       if (!breadcrumbs.contains(route)) {
//         breadcrumbs.add(route);
//       }
//     });
//   }

//   void navigateBack() {
//     if (breadcrumbs.length > 1) {
//       setState(() {
//         breadcrumbs.removeLast();
//         currentRoute = breadcrumbs.last;
//       });
//     }
//   }

//   Widget _buildDashboardContent() {
//     return internalRoutes[currentRoute] ??
//         const Center(child: Text('Page not found'));
//   }

//   Widget _buildBreadcrumbs() {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children:
//               breadcrumbs.map((route) {
//                 final label = route.split('/').last;
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4),
//                   child: Chip(
//                     label: Text(label),
//                     onDeleted:
//                         route != currentRoute
//                             ? () {
//                               setState(() {
//                                 final index = breadcrumbs.indexOf(route);
//                                 breadcrumbs = breadcrumbs.sublist(0, index + 1);
//                                 currentRoute = route;
//                               });
//                             }
//                             : null,
//                   ),
//                 );
//               }).toList(),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: _buildBreadcrumbs(),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: navigateBack,
//         ),
//       ),
//       body: Row(
//         children: [
//           // Persistent Sidebar
//           Container(
//             width: 220,
//             color: Colors.indigoAccent,
//             child: Column(
//               children: [
//                 const SizedBox(height: 40),
//                 const Icon(Icons.school, color: Colors.white, size: 40),
//                 const SizedBox(height: 10),
//                 const Text(
//                   'Admin Dashboard',
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//                 const SizedBox(height: 20),
//                 Expanded(
//                   child: ListView(
//                     children:
//                         menuItems.map((menu) {
//                           return ExpansionTile(
//                             title: Text(
//                               menu.title,
//                               style: const TextStyle(color: Colors.white),
//                             ),
//                             leading: Icon(menu.icon, color: Colors.white),
//                             children:
//                                 menu.subMenuItems.isNotEmpty
//                                     ? menu.subMenuItems.map((subItem) {
//                                       return ListTile(
//                                         title: Text(
//                                           subItem,
//                                           style: const TextStyle(
//                                             color: Colors.white70,
//                                           ),
//                                         ),
//                                         onTap: () {
//                                           navigateTo(
//                                             '${menu.title.toLowerCase()}/${subItem.toLowerCase().replaceAll(" ", "")}',
//                                           );
//                                         },
//                                       );
//                                     }).toList()
//                                     : [
//                                       ListTile(
//                                         title: const Text(
//                                           'View',
//                                           style: TextStyle(
//                                             color: Colors.white70,
//                                           ),
//                                         ),
//                                         onTap: () {
//                                           navigateTo(menu.title.toLowerCase());
//                                         },
//                                       ),
//                                     ],
//                           );
//                         }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Main Content Area
//           Expanded(child: _buildDashboardContent()),
//         ],
//       ),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Home Screen', style: TextStyle(fontSize: 24)),
//     );
//   }
// }

// class AddClassScreen extends StatelessWidget {
//   final VoidCallback onNavigateToInnerRoute;

//   const AddClassScreen({super.key, required this.onNavigateToInnerRoute});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ElevatedButton(
//         onPressed: onNavigateToInnerRoute,
//         child: const Text('go'),
//       ),
//     );
//   }
// }

// class Attendance extends StatelessWidget {
//   final VoidCallback onNavigateToInnerRoute;
//   Attendance({super.key, required this.onNavigateToInnerRoute});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         children: [
//           const Text('All Classes Screen', style: TextStyle(fontSize: 24)),
//           ElevatedButton(
//             onPressed: onNavigateToInnerRoute,
//             child: const Text('go'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AllItemsScreen extends StatelessWidget {
//   const AllItemsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('All Items Screen', style: TextStyle(fontSize: 24)),
//     );
//   }
// }

// class EditItemScreen extends StatelessWidget {
//   const EditItemScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Text('Edit Item Screen', style: TextStyle(fontSize: 24)),
//     );
//   }
// }

// class InnerRoute extends StatelessWidget {
//   final VoidCallback? onNavigateToInnerRoute;
//   final VoidCallback? navigateTo;
//   InnerRoute({super.key, this.onNavigateToInnerRoute, this.navigateTo});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         ElevatedButton(
//           onPressed: () {
//             navigateTo!();
//           },
//           child: Text('back'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             onNavigateToInnerRoute!();
//           },
//           child: Text('go inner'),
//         ),
//         Text('Inner Route Screen', style: TextStyle(fontSize: 24)),
//       ],
//     );
//   }
// }
