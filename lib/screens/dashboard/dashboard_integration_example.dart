// // Example integration for Comprehensive Dashboard
// // Add this to your existing navigation or routing configuration

// import 'package:flutter/material.dart';
// import 'package:schmgtsystem/screens/dashboard/comprehensive_dashboard.dart';

// // Example 1: Add to your existing drawer/sidebar navigation
// Widget _buildDashboardMenuItem() {
//   return ListTile(
//     leading: const Icon(Icons.dashboard),
//     title: const Text('Comprehensive Dashboard'),
//     onTap: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const ComprehensiveDashboardScreen(),
//         ),
//       );
//     },
//   );
// }

// // Example 2: Add to GoRouter configuration (if you uncomment router.dart)
// /*
// GoRoute(
//   path: '/comprehensive-dashboard',
//   builder: (context, state) => const ComprehensiveDashboardScreen(),
// ),
// */

// // Example 3: Add to your main dashboard as a card/button
// Widget _buildDashboardCard() {
//   return Card(
//     child: ListTile(
//       leading: const Icon(Icons.analytics, size: 32),
//       title: const Text('Comprehensive Metrics'),
//       subtitle: const Text('View detailed analytics and metrics'),
//       trailing: const Icon(Icons.arrow_forward_ios),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const ComprehensiveDashboardScreen(),
//           ),
//         );
//       },
//     ),
//   );
// }

// // Example 4: Add to your home screen
// /*
// class DashboardHomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Dashboard')),
//       body: Column(
//         children: [
//           // Your existing dashboard content
          
//           // Add the comprehensive dashboard card
//           _buildDashboardCard(),
          
//           // Rest of your content
//         ],
//       ),
//     );
//   }
// }
// */
