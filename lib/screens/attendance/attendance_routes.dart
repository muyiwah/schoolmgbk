// Example integration for attendance screens
// This shows how to add attendance functionality to existing class management

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/screens/attendance/attendance_marking_screen.dart';
import 'package:schmgtsystem/screens/attendance/attendance_summary_screen.dart';

// Add these routes to your existing GoRouter configuration
class AttendanceRoutes {
  static const String attendanceMarking = '/attendance/mark/:classId';
  static const String attendanceSummary = '/attendance/summary/:classId';

  static List<RouteBase> get routes => [
    GoRoute(
      path: attendanceMarking,
      name: 'attendance-marking',
      builder: (context, state) {
        final classId = state.pathParameters['classId']!;
        final className = state.uri.queryParameters['className'] ?? 'Class';
        final classLevel = state.uri.queryParameters['classLevel'] ?? 'Level';

        return AttendanceMarkingScreen(
          classId: classId,
          className: className,
          classLevel: classLevel,
        );
      },
    ),
    GoRoute(
      path: attendanceSummary,
      name: 'attendance-summary',
      builder: (context, state) {
        final classId = state.pathParameters['classId']!;
        final className = state.uri.queryParameters['className'] ?? 'Class';
        final classLevel = state.uri.queryParameters['classLevel'] ?? 'Level';

        return AttendanceSummaryScreen(
          classId: classId,
          className: className,
          classLevel: classLevel,
        );
      },
    ),
  ];
}

// Example widget to add to your existing class management screen
class AttendanceActionsWidget extends StatelessWidget {
  final String classId;
  final String className;
  final String classLevel;

  const AttendanceActionsWidget({
    Key? key,
    required this.classId,
    required this.className,
    required this.classLevel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.go(
                '/attendance/mark/$classId',
                extra: {'className': className, 'classLevel': classLevel},
              );
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Mark Attendance'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              context.go(
                '/attendance/summary/$classId',
                extra: {'className': className, 'classLevel': classLevel},
              );
            },
            icon: const Icon(Icons.analytics_outlined),
            label: const Text('View Summary'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[600],
              side: BorderSide(color: Colors.blue[600]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// Example usage in your existing class management screen:
/*
class ClassManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Your existing class information
          ClassInfoWidget(),
          
          // Add attendance actions
          Padding(
            padding: EdgeInsets.all(16),
            child: AttendanceActionsWidget(
              classId: 'your-class-id',
              className: 'Grade 1A',
              classLevel: 'Primary 1',
            ),
          ),
          
          // Your existing content
          Expanded(child: YourExistingContent()),
        ],
      ),
    );
  }
}
*/
