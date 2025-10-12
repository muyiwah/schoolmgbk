// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:schmgtsystem/providers/provider.dart';

// class ComprehensiveDashboardScreen extends ConsumerStatefulWidget {
//   const ComprehensiveDashboardScreen({super.key});

//   @override
//   ConsumerState<ComprehensiveDashboardScreen> createState() =>
//       _ComprehensiveDashboardScreenState();
// }

// class _ComprehensiveDashboardScreenState
//     extends ConsumerState<ComprehensiveDashboardScreen> {
//   String? _selectedAcademicYear;
//   String? _selectedTerm;

//   @override
//   void initState() {
//     super.initState();
//     // Load metrics on screen initialization
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadMetrics();
//     });
//   }

//   Future<void> _loadMetrics() async {
//     final metricsProvider = ref.read(RiverpodProvider.metricsProvider);
//     await metricsProvider.getComprehensiveMetrics(
//       academicYear: _selectedAcademicYear,
//       term: _selectedTerm,
//     );
//   }

//   Future<void> _refreshMetrics() async {
//     await _loadMetrics();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final metricsProvider = ref.watch(RiverpodProvider.metricsProvider);
//     final metrics = metricsProvider.comprehensiveMetrics;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Comprehensive Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _refreshMetrics,
//           ),
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               setState(() {
//                 _selectedAcademicYear = value == 'All' ? null : value;
//               });
//               _loadMetrics();
//             },
//             itemBuilder:
//                 (context) => [
//                   const PopupMenuItem(value: 'All', child: Text('All Years')),
//                   const PopupMenuItem(
//                     value: '2024/2025',
//                     child: Text('2024/2025'),
//                   ),
//                   const PopupMenuItem(
//                     value: '2025/2026',
//                     child: Text('2025/2026'),
//                   ),
//                 ],
//             child: const Icon(Icons.calendar_today),
//           ),
//         ],
//       ),
//       body:
//           metricsProvider.isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : metricsProvider.errorMessage != null
//               ? _buildErrorWidget(metricsProvider.errorMessage!)
//               : metrics == null
//               ? _buildEmptyWidget()
//               : _buildDashboardContent(metrics),
//     );
//   }

//   Widget _buildErrorWidget(String error) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//           const SizedBox(height: 16),
//           Text(
//             'Error Loading Metrics',
//             style: Theme.of(context).textTheme.headlineSmall,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             error,
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton.icon(
//             onPressed: _refreshMetrics,
//             icon: const Icon(Icons.refresh),
//             label: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.dashboard_outlined, size: 64, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             'No Metrics Available',
//             style: Theme.of(context).textTheme.headlineSmall,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Metrics data will appear here once available',
//             style: TextStyle(color: Colors.grey[600]),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton.icon(
//             onPressed: _refreshMetrics,
//             icon: const Icon(Icons.refresh),
//             label: const Text('Refresh'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDashboardContent(Map<String, dynamic> metrics) {
//     return RefreshIndicator(
//       onRefresh: _refreshMetrics,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header with last updated info
//             _buildLastUpdatedHeader(),
//             const SizedBox(height: 16),

//             // Overview Cards
//             _buildOverviewSection(metrics),
//             const SizedBox(height: 24),

//             // Student Metrics
//             if (metrics['studentMetrics'] != null)
//               _buildStudentMetricsSection(metrics['studentMetrics']),
//             const SizedBox(height: 24),

//             // Financial Metrics
//             if (metrics['financialMetrics'] != null)
//               _buildFinancialMetricsSection(metrics['financialMetrics']),
//             const SizedBox(height: 24),

//             // Academic Metrics
//             if (metrics['academicMetrics'] != null)
//               _buildAcademicMetricsSection(metrics['academicMetrics']),
//             const SizedBox(height: 24),

//             // Attendance Metrics
//             if (metrics['attendanceMetrics'] != null)
//               _buildAttendanceMetricsSection(metrics['attendanceMetrics']),
//             const SizedBox(height: 24),

//             // Recent Activities
//             if (metrics['recentActivities'] != null)
//               _buildRecentActivitiesSection(metrics['recentActivities']),
//             const SizedBox(height: 24),

//             // Performance Metrics
//             if (metrics['performanceMetrics'] != null)
//               _buildPerformanceMetricsSection(metrics['performanceMetrics']),
//             const SizedBox(height: 24),

//             // System Metrics
//             if (metrics['systemMetrics'] != null)
//               _buildSystemMetricsSection(metrics['systemMetrics']),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLastUpdatedHeader() {
//     final metricsProvider = ref.watch(RiverpodProvider.metricsProvider);
//     final lastUpdated = metricsProvider.lastUpdated;

//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.blue[200]!),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.update, color: Colors.blue[600], size: 20),
//           const SizedBox(width: 8),
//           Text(
//             lastUpdated != null
//                 ? 'Last updated: ${_formatDateTime(lastUpdated)}'
//                 : 'Data loaded',
//             style: TextStyle(
//               color: Colors.blue[800],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOverviewSection(Map<String, dynamic> metrics) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Overview',
//           style: Theme.of(
//             context,
//           ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 12),
//         GridView.count(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisCount: 2,
//           crossAxisSpacing: 12,
//           mainAxisSpacing: 12,
//           childAspectRatio: 1.5,
//           children: [
//             _buildMetricCard(
//               'Total Students',
//               metrics['totalStudents']?.toString() ?? '0',
//               Icons.people,
//               Colors.blue,
//             ),
//             _buildMetricCard(
//               'Total Classes',
//               metrics['totalClasses']?.toString() ?? '0',
//               Icons.school,
//               Colors.green,
//             ),
//             _buildMetricCard(
//               'Total Teachers',
//               metrics['totalTeachers']?.toString() ?? '0',
//               Icons.person,
//               Colors.orange,
//             ),
//             _buildMetricCard(
//               'Total Revenue',
//               _formatCurrency(metrics['totalRevenue']),
//               Icons.attach_money,
//               Colors.purple,
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildStudentMetricsSection(Map<String, dynamic> studentMetrics) {
//     return _buildSection('Student Metrics', Icons.people, Colors.blue, [
//       _buildMetricRow('Active Students', studentMetrics['activeStudents']),
//       _buildMetricRow('New Admissions', studentMetrics['newAdmissions']),
//       _buildMetricRow(
//         'Graduated Students',
//         studentMetrics['graduatedStudents'],
//       ),
//       _buildMetricRow('Average Age', studentMetrics['averageAge']),
//     ]);
//   }

//   Widget _buildFinancialMetricsSection(Map<String, dynamic> financialMetrics) {
//     return _buildSection(
//       'Financial Metrics',
//       Icons.attach_money,
//       Colors.green,
//       [
//         _buildMetricRow(
//           'Total Revenue',
//           _formatCurrency(financialMetrics['totalRevenue']),
//         ),
//         _buildMetricRow(
//           'Monthly Revenue',
//           _formatCurrency(financialMetrics['monthlyRevenue']),
//         ),
//         _buildMetricRow(
//           'Outstanding Fees',
//           _formatCurrency(financialMetrics['outstandingFees']),
//         ),
//         _buildMetricRow(
//           'Collection Rate',
//           '${financialMetrics['collectionRate']}%',
//         ),
//       ],
//     );
//   }

//   Widget _buildAcademicMetricsSection(Map<String, dynamic> academicMetrics) {
//     return _buildSection('Academic Metrics', Icons.school, Colors.purple, [
//       _buildMetricRow('Average Grade', academicMetrics['averageGrade']),
//       _buildMetricRow('Pass Rate', '${academicMetrics['passRate']}%'),
//       _buildMetricRow('Top Performing Class', academicMetrics['topClass']),
//       _buildMetricRow('Subjects Offered', academicMetrics['subjectsCount']),
//     ]);
//   }

//   Widget _buildAttendanceMetricsSection(
//     Map<String, dynamic> attendanceMetrics,
//   ) {
//     return _buildSection(
//       'Attendance Metrics',
//       Icons.event_available,
//       Colors.orange,
//       [
//         _buildMetricRow(
//           'Overall Attendance',
//           '${attendanceMetrics['overallAttendance']}%',
//         ),
//         _buildMetricRow('Present Today', attendanceMetrics['presentToday']),
//         _buildMetricRow('Absent Today', attendanceMetrics['absentToday']),
//         _buildMetricRow('Late Today', attendanceMetrics['lateToday']),
//       ],
//     );
//   }

//   Widget _buildRecentActivitiesSection(List<dynamic> recentActivities) {
//     return _buildSection(
//       'Recent Activities',
//       Icons.history,
//       Colors.teal,
//       recentActivities.take(5).map((activity) {
//         return ListTile(
//           leading: CircleAvatar(
//             backgroundColor: Colors.teal[100],
//             child: Icon(Icons.notifications, color: Colors.teal[700]),
//           ),
//           title: Text(activity['title'] ?? 'Activity'),
//           subtitle: Text(activity['description'] ?? ''),
//           trailing: Text(
//             _formatDateTime(DateTime.parse(activity['timestamp'])),
//             style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildPerformanceMetricsSection(
//     Map<String, dynamic> performanceMetrics,
//   ) {
//     return _buildSection(
//       'Performance Metrics',
//       Icons.trending_up,
//       Colors.indigo,
//       [
//         _buildMetricRow('System Uptime', '${performanceMetrics['uptime']}%'),
//         _buildMetricRow(
//           'Response Time',
//           '${performanceMetrics['responseTime']}ms',
//         ),
//         _buildMetricRow('Active Users', performanceMetrics['activeUsers']),
//         _buildMetricRow('Data Usage', performanceMetrics['dataUsage']),
//       ],
//     );
//   }

//   Widget _buildSystemMetricsSection(Map<String, dynamic> systemMetrics) {
//     return _buildSection('System Metrics', Icons.settings, Colors.grey, [
//       _buildMetricRow('Database Size', systemMetrics['databaseSize']),
//       _buildMetricRow('Storage Used', systemMetrics['storageUsed']),
//       _buildMetricRow('Backup Status', systemMetrics['backupStatus']),
//       _buildMetricRow('Last Maintenance', systemMetrics['lastMaintenance']),
//     ]);
//   }

//   Widget _buildSection(
//     String title,
//     IconData icon,
//     Color color,
//     List<Widget> children,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, color: color, size: 24),
//             const SizedBox(width: 8),
//             Text(
//               title,
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.grey[50],
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey[200]!),
//           ),
//           child: Column(children: children),
//         ),
//       ],
//     );
//   }

//   Widget _buildMetricCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, color: color, size: 32),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.grey[600], fontSize: 12),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMetricRow(String label, dynamic value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
//           Text(
//             value?.toString() ?? 'N/A',
//             style: TextStyle(
//               color: Colors.grey[700],
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatCurrency(dynamic amount) {
//     if (amount == null) return '£0';
//     final numAmount =
//         amount is num ? amount : double.tryParse(amount.toString()) ?? 0;
//     return '£${numAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
//   }

//   String _formatDateTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);

//     if (difference.inMinutes < 1) {
//       return 'Just now';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes}m ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours}h ago';
//     } else {
//       return '${difference.inDays}d ago';
//     }
//   }
// }
