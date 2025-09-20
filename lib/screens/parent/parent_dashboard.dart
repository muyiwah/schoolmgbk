import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/models/parent_login_model.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:schmgtsystem/utils/constants.dart';
import 'package:schmgtsystem/repository/payment_repo.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/services/fee_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
  int _selectedTab = 0;
  String _selectedTerm = 'First';
  String _selectedAcademicYear = '2024/2025';
  int _selectedChildIndex = 0; // Track selected child index
  Map<String, bool> _selectedFees = {};
  Map<String, int> _feeAmounts = {};
  Map<String, int> _partialPaymentAmounts = {}; // Track partial payment amounts

  // Helper method to get available academic years from selected child
  List<String> _getAvailableAcademicYears(List<Child> children) {
    if (children.isEmpty) return ['2024/2025', '2023/2024', '2025/2026'];

    final child = children[_selectedChildIndex];
    final academicYear =
        child.currentTerm?.academicYear ??
        child.student?.academicInfo?.academicYear;

    return academicYear != null && academicYear.isNotEmpty
        ? [academicYear]
        : ['2024/2025', '2023/2024', '2025/2026'];
  }

  // Helper method to get available terms from selected child
  List<String> _getAvailableTerms(List<Child> children) {
    if (children.isEmpty) return ['First', 'Second', 'Third'];

    final child = children[_selectedChildIndex];
    final term = child.currentTerm?.term;

    return term != null && term.isNotEmpty
        ? [term]
        : ['First', 'Second', 'Third'];
  }

  @override
  Widget build(BuildContext context) {
    final parentLoginState = ref.watch(RiverpodProvider.parentLoginProvider);
    final parentLoginProvider = ref.read(
      RiverpodProvider.parentLoginProvider.notifier,
    );

    // Use helper methods from provider for cleaner access
    final children = parentLoginProvider.children ?? [];
    final financialSummary = parentLoginProvider.financialSummary;
    final communications = parentLoginProvider.communications ?? [];

    // Debug prints removed for production

    // Get available options
    final availableYears = _getAvailableAcademicYears(children);
    final availableTerms = _getAvailableTerms(children);

    // Auto-set academic year and term based on selected child
    if (children.isNotEmpty) {
      // Ensure selected child index is within bounds
      if (_selectedChildIndex >= children.length) {
        _selectedChildIndex = 0;
      }
      final selectedChild = children[_selectedChildIndex];
      final childAcademicYear =
          selectedChild.currentTerm?.academicYear ??
          selectedChild.student?.academicInfo?.academicYear;
      final childTerm = selectedChild.currentTerm?.term;

      if (childAcademicYear != null && childAcademicYear.isNotEmpty) {
        _selectedAcademicYear = childAcademicYear;
      } else if (availableYears.isNotEmpty) {
        _selectedAcademicYear = availableYears.first;
      }

      if (childTerm != null && childTerm.isNotEmpty) {
        _selectedTerm = childTerm;
      } else if (availableTerms.isNotEmpty) {
        _selectedTerm = availableTerms.first;
      }
    } else {
      // Fallback to available options
      if (availableYears.isNotEmpty) {
        _selectedAcademicYear = availableYears.first;
      }
      if (availableTerms.isNotEmpty) {
        _selectedTerm = availableTerms.first;
      }
    }

    if (parentLoginState.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (parentLoginState.errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error loading parent data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                parentLoginState.errorMessage!,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChildrenSection(children),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  // Desktop layout
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildAcademicOverview()),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildFeesPayments(
                                financialSummary,
                                children,
                                availableYears,
                                availableTerms,
                              ),
                              const SizedBox(height: 16),
                              _buildAnnouncements(communications),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // Mobile layout
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildAcademicOverview(),
                        const SizedBox(height: 16),
                        _buildFeesPayments(
                          financialSummary,
                          children,
                          availableYears,
                          availableTerms,
                        ),
                        const SizedBox(height: 16),
                        _buildAnnouncements(communications),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenSection(List<Child> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Children',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (children.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No children found',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Row(
            children:
                children.take(2).map((child) {
                  final student = child.student;
                  final financialInfo = student?.financialInfo;
                  final academicInfo = student?.academicInfo;
                  final currentClass = academicInfo?.currentClass;
                  final childCurrentTerm = child.currentTerm;
                  final feeSummary = child.feeSummary;

                  // Safety check for null data
                  if (student == null) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _buildChildCard(
                          'Unknown Student',
                          'Unknown Class',
                          '0%',
                          '0%',
                          'No Data',
                          Colors.grey,
                          'https://via.placeholder.com/60x60',
                        ),
                      ),
                    );
                  }

                  // Calculate attendance percentage (placeholder - would come from attendance data)
                  final attendancePercentage = '92%';

                  // Calculate academic performance (placeholder - would come from grades data)
                  final academicPerformance = '84%';

                  // Get fee status from child's current term or fee summary
                  String feeStatus;
                  Color feeStatusColor;

                  if (childCurrentTerm?.amountOwed != null &&
                      (childCurrentTerm?.amountOwed ?? 0) > 0) {
                    feeStatus = '₦${childCurrentTerm?.amountOwed} Due';
                    feeStatusColor = Colors.red;
                  } else if (feeSummary?.outstandingBalance != null &&
                      (feeSummary?.outstandingBalance ?? 0) > 0) {
                    feeStatus = '₦${feeSummary?.outstandingBalance} Due';
                    feeStatusColor = Colors.red;
                  } else if (financialInfo?.outstandingBalance != null &&
                      (financialInfo?.outstandingBalance ?? 0) > 0) {
                    feeStatus = '₦${financialInfo?.outstandingBalance} Due';
                    feeStatusColor = Colors.red;
                  } else {
                    feeStatus = 'Fees Paid';
                    feeStatusColor = Colors.green;
                  }

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildChildCard(
                        '${student.personalInfo?.firstName ?? ''} ${student.personalInfo?.lastName ?? ''}',
                        '${currentClass?.level ?? 'Unknown'} - ${currentClass?.name ?? 'Unknown'}',
                        attendancePercentage,
                        academicPerformance,
                        feeStatus,
                        feeStatusColor,
                        'https://via.placeholder.com/60x60',
                      ),
                    ),
                  );
                }).toList(),
          ),
      ],
    );
  }

  Widget _buildChildCard(
    String name,
    String grade,
    String attendance,
    String academic,
    String feeStatus,
    Color statusColor,
    String imageUrl,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              CircleAvatar(radius: 30, backgroundImage: NetworkImage(imageUrl)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      grade,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: 15),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Attendance',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        attendance,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Academic Avg',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        academic,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 23,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    statusColor == Colors.green
                        ? Icons.check_circle
                        : Icons.error,
                    color: statusColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    feeStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View Profile'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicOverview() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emma Johnson - Academic Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildTabButton('Performance', 0),
              _buildTabButton('Attendance', 1),
              _buildTabButton('Behavior', 2),
              _buildTabButton('Messages', 3),
            ],
          ),
          const SizedBox(height: 24),
          // Tab Content
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected ? Border.all(color: Colors.blue) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildGradeCard(String grade, String subject, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              grade,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subject,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildPerformanceContent();
      case 1:
        return _buildAttendanceContent();
      case 2:
        return _buildBehaviorContent();
      case 3:
        return _buildMessagesContent();
      default:
        return _buildPerformanceContent();
    }
  }

  Widget _buildPerformanceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildGradeCard('A-', 'Mathematics', Colors.blue),
            const SizedBox(width: 16),
            _buildGradeCard('B+', 'Science', Colors.green),
            const SizedBox(width: 16),
            _buildGradeCard('A', 'English', Colors.purple),
            const SizedBox(width: 16),
            _buildGradeCard('B', 'History', Colors.orange),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Recent Test Scores',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildTestScore('Math Quiz - Nov 15', '92/100'),
        _buildTestScore('Science Project - Nov 12', '88/100'),
        _buildTestScore('English Essay - Nov 8', '95/100'),
        const SizedBox(height: 24),
        const Text(
          'Subject Performance',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildSubjectPerformance('Mathematics', 92, Colors.blue),
        _buildSubjectPerformance('Science', 88, Colors.green),
        _buildSubjectPerformance('English', 95, Colors.purple),
        _buildSubjectPerformance('History', 85, Colors.orange),
      ],
    );
  }

  Widget _buildAttendanceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Today's Attendance Status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text(
                      'Present',
                      style: TextStyle(fontSize: 14, color: Colors.green),
                    ),
                    Text(
                      'Checked in at 8:15 AM',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Attendance Summary',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAttendanceStatCard(
                'Present',
                '92%',
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAttendanceStatCard(
                'Absent',
                '5%',
                Colors.red,
                Icons.cancel,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAttendanceStatCard(
                'Late',
                '3%',
                Colors.orange,
                Icons.schedule,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Recent Attendance',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildAttendanceRecord('Today', 'Present', '8:15 AM', Colors.green),
        _buildAttendanceRecord('Yesterday', 'Present', '8:20 AM', Colors.green),
        _buildAttendanceRecord('Nov 14', 'Late', '8:45 AM', Colors.orange),
        _buildAttendanceRecord('Nov 13', 'Present', '8:10 AM', Colors.green),
        _buildAttendanceRecord('Nov 12', 'Absent', '-', Colors.red),
      ],
    );
  }

  Widget _buildBehaviorContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Behavior Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.psychology, color: Colors.blue, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Behavior',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text(
                      'Excellent',
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                    Text(
                      'No incidents this month',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Behavior Logs',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildBehaviorLog(
          'Positive Behavior',
          'Helped a classmate with math homework',
          'Nov 15, 2024',
          Colors.green,
          Icons.thumb_up,
        ),
        _buildBehaviorLog(
          'Good Participation',
          'Actively participated in science discussion',
          'Nov 12, 2024',
          Colors.blue,
          Icons.school,
        ),
        _buildBehaviorLog(
          'Leadership',
          'Led group project presentation',
          'Nov 8, 2024',
          Colors.purple,
          Icons.leaderboard,
        ),
        _buildBehaviorLog(
          'Kindness',
          'Shared lunch with a classmate who forgot theirs',
          'Nov 5, 2024',
          Colors.orange,
          Icons.favorite,
        ),
      ],
    );
  }

  Widget _buildMessagesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Actions
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showNewMessageDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('New Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.schedule),
                label: const Text('Schedule Meeting'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Recent Messages',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildMessageItem(
          'Ms. Johnson (Math Teacher)',
          'Emma performed excellently in today\'s algebra test. She scored 95/100!',
          '2 hours ago',
          Colors.blue,
          Icons.school,
          true,
        ),
        _buildMessageItem(
          'Principal Smith',
          'Reminder: Parent-Teacher Conference scheduled for Dec 20th at 3:00 PM',
          '1 day ago',
          Colors.purple,
          Icons.admin_panel_settings,
          false,
        ),
        _buildMessageItem(
          'Ms. Davis (Science Teacher)',
          'Emma\'s science project was outstanding. She demonstrated great creativity.',
          '3 days ago',
          Colors.green,
          Icons.science,
          true,
        ),
        _buildMessageItem(
          'School Administration',
          'Winter break starts Dec 23rd. Classes resume Jan 8th.',
          '1 week ago',
          Colors.orange,
          Icons.calendar_today,
          false,
        ),
      ],
    );
  }

  Widget _buildTestScore(String test, String score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(test, style: const TextStyle(fontSize: 14)),
          Text(
            score,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectPerformance(String subject, int score, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              subject,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '$score%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 60,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: score / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatCard(
    String label,
    String percentage,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildAttendanceRecord(
    String date,
    String status,
    String time,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              date,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildBehaviorLog(
    String title,
    String description,
    String date,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(
    String sender,
    String message,
    String time,
    Color color,
    IconData icon,
    bool isRead,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sender,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isRead ? FontWeight.w500 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNewMessageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Message'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Send to',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('Administration'),
                  ),
                  DropdownMenuItem(
                    value: 'principal',
                    child: Text('Principal'),
                  ),
                ],
                onChanged: (value) {
                  // Handle dropdown selection if needed
                  if (value != null) {
                    // Add logic here if needed
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message sent successfully!')),
                );
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeesPayments(
    FinancialSummary? financialSummary,
    List<Child> children,
    List<String> availableYears,
    List<String> availableTerms,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Fees & Payments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              _buildVerificationBadge(),
              const Spacer(),
              if (children.length > 1) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        '${children.length} children',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Child Selector (only show if multiple children)
          if (children.length > 1) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Child',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<int>(
                      value: _selectedChildIndex,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      isExpanded: true,
                      items:
                          children.asMap().entries.map((entry) {
                            final index = entry.key;
                            final child = entry.value;
                            final student = child.student;
                            final studentName =
                                student?.personalInfo != null
                                    ? '${student!.personalInfo!.firstName ?? ''} ${student.personalInfo!.lastName ?? ''}'
                                    : 'Child ${index + 1}';

                            return DropdownMenuItem<int>(
                              value: index,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.blue.withOpacity(
                                      0.1,
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      studentName,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedChildIndex = value;
                            // Reset fee selections when switching children
                            _selectedFees.clear();
                            _partialPaymentAmounts.clear();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // // Term and Academic Year Selection
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Academic Year',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedAcademicYear,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          availableYears.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedAcademicYear = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Term',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: _selectedTerm,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          availableTerms.map((term) {
                            return DropdownMenuItem(
                              value: term,
                              child: Text(term),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedTerm = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Outstanding Balance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Outstanding Balance',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '₦${financialSummary?.totalAmountOwed ?? 0}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Due: December 15, 2024 - $_selectedTerm $_selectedAcademicYear',
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Fee Breakdown with Checkboxes
          const Text(
            'Fee Breakdown',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildFeeBreakdown(children),
          const SizedBox(height: 16),

          // Conditional Payment Section or Thank You Message
          if (_areFeesFullyPaid(children)) ...[
            // Show thank you message when fees are fully paid
            _buildThankYouSection(children),
          ] else ...[
            // Show payment section when fees are not fully paid
            _buildPaymentUploadSection(),
            const SizedBox(height: 16),

            // Pay Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showSchoolFeesPaymentPopup,
                icon: const Icon(Icons.payment),
                label: Text('Make Payment Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeeBreakdown(List<Child> children) {
    if (children.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Text(
            'No fee information available',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    final child = children[_selectedChildIndex];
    final feeRecord = child.currentTerm?.feeRecord;
    final feeDetails = feeRecord?.feeDetails;
    final payments = feeRecord?.payments ?? [];

    if (feeDetails == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Text(
            'Fee details not available',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    // Calculate payment status
    final totalPaid = payments
        .where((payment) => payment.status == 'Completed')
        .fold(0, (sum, payment) => sum + (payment.amount ?? 0));

    final baseFee = feeDetails.baseFee ?? 0;
    final totalFee = feeDetails.totalFee ?? 0;
    final balance = totalFee - totalPaid;

    // Update state variables
    _feeAmounts = {'Base Fee': baseFee, 'Total Fee': totalFee};

    // Add addOn fees to the map
    if (feeDetails.addOns != null && feeDetails.addOns!.isNotEmpty) {
      for (final addOn in feeDetails.addOns!) {
        final addOnMap = addOn as Map<String, dynamic>;
        final feeName = addOnMap['name'] ?? 'Additional Fee';
        final feeAmount = addOnMap['amount'] ?? 0;
        _feeAmounts[feeName] = feeAmount;
      }
    }

    // Initialize selected fees map with all fee items
    _selectedFees = _feeAmounts.map((key, value) => MapEntry(key, false));

    // Initialize partial payment amounts
    _partialPaymentAmounts = _feeAmounts.map(
      (key, value) => MapEntry(key, value),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fee Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (children.length > 1) ...[
                      const SizedBox(height: 2),
                      Text(
                        _getChildDisplayName(child),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      balance > 0
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  balance > 0 ? 'Outstanding' : 'Fully Paid',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: balance > 0 ? Colors.orange : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Fee Items
          _buildFeeItem(
            'Base Fee',
            baseFee,
            totalPaid >= baseFee,
            totalPaid > 0 ? (totalPaid > baseFee ? baseFee : totalPaid) : 0,
            true,
          ),

          if (feeDetails.addOns != null && feeDetails.addOns!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...feeDetails.addOns!.asMap().entries.map((entry) {
              final index = entry.key;
              final addOn = entry.value as Map<String, dynamic>;
              final feeName = addOn['name'] ?? 'Additional Fee ${index + 1}';
              final feeAmount = addOn['amount'] ?? 0;
              final isPaid = totalPaid >= (baseFee + feeAmount);
              final paidAmount =
                  totalPaid > baseFee
                      ? (totalPaid - baseFee > feeAmount
                          ? feeAmount
                          : totalPaid - baseFee)
                      : 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFeeItem(
                  feeName,
                  feeAmount,
                  isPaid,
                  paidAmount,
                  addOn['compulsory'] ?? false,
                ),
              );
            }),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Total Fees', totalFee, Colors.black87),
                const SizedBox(height: 8),
                _buildSummaryRow('Amount Paid', totalPaid, Colors.green),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Outstanding Balance',
                  balance,
                  balance > 0 ? Colors.red : Colors.green,
                  isBold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Payment History
          if (payments.isNotEmpty) ...[
            const Text(
              'Recent Payments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...payments
                .take(3)
                .map((payment) => _buildPaymentHistoryItem(payment))
                .toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildFeeItem(
    String name,
    int totalAmount,
    bool isPaid,
    int paidAmount,
    bool isRequired,
  ) {
    final progress = totalAmount > 0 ? paidAmount / totalAmount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaid ? Colors.green.withOpacity(0.3) : Colors.grey[300]!,
          width: isPaid ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green : Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPaid ? Colors.green[700] : Colors.black87,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isPaid
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPaid ? 'Paid' : 'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPaid ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount: ₦${totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  if (paidAmount > 0)
                    Text(
                      'Paid: ₦${paidAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              if (totalAmount > 0)
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isPaid ? Colors.green : Colors.orange,
                  ),
                ),
            ],
          ),
          if (totalAmount > 0 && !isPaid) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0 ? Colors.orange : Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    int amount,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          '₦${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryItem(dynamic payment) {
    final amount = payment.amount ?? 0;
    final status = payment.status ?? 'Unknown';
    final date = payment.date ?? '';
    final method = payment.method ?? 'Unknown';

    final isCompleted = status == 'Completed';
    final statusColor = isCompleted ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₦${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '$method • ${_formatDate(date)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getChildDisplayName(Child child) {
    final student = child.student;
    if (student?.personalInfo != null) {
      final firstName = student!.personalInfo!.firstName ?? '';
      final lastName = student.personalInfo!.lastName ?? '';
      return '$firstName $lastName'.trim();
    }
    return 'Child';
  }

  Widget _buildVerificationBadge() {
    final parentLoginProvider = ref.read(
      RiverpodProvider.parentLoginProvider.notifier,
    );
    final children = parentLoginProvider.children ?? [];
    if (children.isEmpty || _selectedChildIndex >= children.length) {
      return const SizedBox.shrink();
    }

    final selectedChild = children[_selectedChildIndex];
    final feeRecord = selectedChild.currentTerm?.feeRecord;
    final payments = feeRecord?.payments ?? [];

    // Check if any payment has been verified (has verifiedAt field)
    final hasVerifiedPayment = payments.any(
      (payment) => payment.verifiedAt != null && payment.verifiedAt!.isNotEmpty,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasVerifiedPayment ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasVerifiedPayment ? Colors.green[300]! : Colors.orange[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasVerifiedPayment ? Icons.verified : Icons.pending,
            size: 14,
            color: hasVerifiedPayment ? Colors.green[700] : Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Text(
            hasVerifiedPayment ? 'Verified' : 'Unverified',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color:
                  hasVerifiedPayment ? Colors.green[700] : Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentUploadSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.upload_file, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Payment Upload',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'You can make bank transfer and upload your payment receipt or bank transfer details here, tap the button below for the account number and bank name',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final parentLoginProvider = ref.read(
                      RiverpodProvider.parentLoginProvider.notifier,
                    );
                    final children = parentLoginProvider.children ?? [];
                    if (children.isEmpty ||
                        _selectedChildIndex >= children.length)
                      return;

                    final selectedChild = children[_selectedChildIndex];
                    final feeRecord = selectedChild.currentTerm?.feeRecord;
                    final feeDetails = feeRecord?.feeDetails;

                    if (feeDetails == null) return;

                    // Pre-select required fees in the main dashboard
                    _preSelectRequiredFees(feeDetails);

                    showDialog(
                      context: context,
                      builder:
                          (context) => SchoolFeesManualPaymentPopup(
                            feeDetails: feeDetails,
                            selectedFees: _selectedFees,
                            partialPaymentAmounts: _partialPaymentAmounts,
                            onFeesChanged: (
                              newSelectedFees,
                              newPartialAmounts,
                            ) {
                              setState(() {
                                _selectedFees = newSelectedFees;
                                _partialPaymentAmounts = newPartialAmounts;
                              });
                            },
                            onPaymentProcessed: () {
                              _processPayment();
                            },
                            selectedChildIndex: _selectedChildIndex,
                            feeRecord: feeRecord,
                          ),
                    );
                  },
                  icon: const Icon(Icons.attach_file, size: 16),
                  label: const Text('Upload Receipt'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              // const SizedBox(width: 12),
              // Expanded(
              //   child: OutlinedButton.icon(
              //     onPressed: _uploadBankTransfer,
              //     icon: const Icon(Icons.account_balance, size: 16),
              //     label: const Text('Bank Transfer'),
              //     style: OutlinedButton.styleFrom(
              //       foregroundColor: Colors.green,
              //       side: const BorderSide(color: Colors.green),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  bool _areFeesFullyPaid(List<Child> children) {
    if (children.isEmpty) return false;

    final child = children[_selectedChildIndex];
    final feeRecord = child.currentTerm?.feeRecord;
    final feeDetails = feeRecord?.feeDetails;
    final payments = feeRecord?.payments ?? [];

    if (feeDetails == null) return false;

    // Calculate payment status
    final totalPaid = payments
        .where((payment) => payment.status == 'Completed')
        .fold(0, (sum, payment) => sum + (payment.amount ?? 0));

    final totalFee = feeDetails.totalFee ?? 0;
    final balance = totalFee - totalPaid;

    return balance <= 0; // Fully paid when balance is 0 or negative
  }

  Widget _buildThankYouSection(List<Child> children) {
    if (children.isEmpty) return const SizedBox.shrink();

    final child = children[_selectedChildIndex];
    final studentName = child.student?.personalInfo?.firstName ?? 'Your child';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[50]!, Colors.green[100]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Success Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),

          // Thank You Message
          Text(
            'Thank You!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'All fees for $studentName have been successfully paid. We appreciate your prompt payment and continued support.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.green[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Additional Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Payment receipts and records are securely stored in your account.',
                    style: TextStyle(fontSize: 14, color: Colors.green[600]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() {
    // Show payment processing dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Processing Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Please wait while we process your payment...'),
            ],
          ),
        );
      },
    );

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close processing dialog

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment processed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset selected fees
        setState(() {
          _selectedFees = _selectedFees.map(
            (key, value) => MapEntry(key, false),
          );
          _partialPaymentAmounts = _feeAmounts.map(
            (key, value) => MapEntry(key, value),
          );
        });
      }
    });
  }

  void _showSchoolFeesPaymentPopup() {
    final parentLoginProvider = ref.read(
      RiverpodProvider.parentLoginProvider.notifier,
    );
    final children = parentLoginProvider.children ?? [];
    if (children.isEmpty || _selectedChildIndex >= children.length) return;

    final selectedChild = children[_selectedChildIndex];
    final feeRecord = selectedChild.currentTerm?.feeRecord;
    final feeDetails = feeRecord?.feeDetails;

    if (feeDetails == null) return;

    // Pre-select required fees in the main dashboard
    _preSelectRequiredFees(feeDetails);

    showDialog(
      context: context,
      builder:
          (context) => SchoolFeesPaymentPopup(
            feeDetails: feeDetails,
            selectedFees: _selectedFees,
            partialPaymentAmounts: _partialPaymentAmounts,
            onFeesChanged: (newSelectedFees, newPartialAmounts) {
              setState(() {
                _selectedFees = newSelectedFees;
                _partialPaymentAmounts = newPartialAmounts;
              });
            },
            onPaymentProcessed: () {
              _processPayment();
            },
            feeRecord: feeRecord,
          ),
    );
  }

  void _preSelectRequiredFees(FeeDetails feeDetails) {
    // Always select base fee as it's required
    _selectedFees['Base Fee'] = true;

    // Select compulsory add-ons
    if (feeDetails.addOns != null && feeDetails.addOns!.isNotEmpty) {
      for (final addOn in feeDetails.addOns!) {
        final addOnMap = addOn as Map<String, dynamic>;
        final feeName = addOnMap['name'] ?? 'Additional Fee';
        final isRequired = addOnMap['compulsory'] ?? false;

        if (isRequired) {
          _selectedFees[feeName] = true;
        }
      }
    }
  }

  Widget _buildAnnouncements(List<Communication> communications) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Announcements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (communications.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'No announcements available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...communications.take(3).map((communication) {
              final createdAt = communication.createdAt;
              final date =
                  createdAt != null
                      ? DateTime.parse(createdAt).toString().split(' ')[0]
                      : 'Unknown date';

              return _buildAnnouncementItem(
                communication.message ?? 'No message',
                date,
                Colors.blue,
              );
            }),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mail),
              label: const Text('Contact Teacher'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(String title, String date, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SchoolFeesPaymentPopup extends StatefulWidget {
  final FeeDetails feeDetails;
  final Map<String, bool> selectedFees;
  final Map<String, int> partialPaymentAmounts;
  final Function(Map<String, bool>, Map<String, int>) onFeesChanged;
  final VoidCallback onPaymentProcessed;
  final FeeRecord? feeRecord;

  const SchoolFeesPaymentPopup({
    Key? key,
    required this.feeDetails,
    required this.selectedFees,
    required this.partialPaymentAmounts,
    required this.onFeesChanged,
    required this.onPaymentProcessed,
    this.feeRecord,
  }) : super(key: key);

  @override
  _SchoolFeesPaymentPopupState createState() => _SchoolFeesPaymentPopupState();
}

class _SchoolFeesPaymentPopupState extends State<SchoolFeesPaymentPopup> {
  late Map<String, bool> _localSelectedFees;
  late Map<String, int> _localPartialPaymentAmounts;
  String selectedPaymentMethod = 'card';

  // Payment repository instance
  final PaymentRepo _paymentRepo = PaymentRepo();

  @override
  void initState() {
    super.initState();
    _localSelectedFees = Map.from(widget.selectedFees);
    _localPartialPaymentAmounts = Map.from(widget.partialPaymentAmounts);

    // Pre-check required fields
    _preCheckRequiredFields();
  }

  void _preCheckRequiredFields() {
    final feeRecord = widget.feeRecord;
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      // If there are existing payments, only show outstanding balances
      _showOnlyOutstandingBalances();
    } else {
      // If no payments, check required fields as before
      _checkRequiredFields();
    }
  }

  void _showOnlyOutstandingBalances() {
    final feeRecord = widget.feeRecord!;
    final baseFeeBalance = feeRecord.baseFeeBalance ?? 0;
    final addOnBalances = feeRecord.addOnBalances ?? [];

    // Check base fee if there's outstanding balance
    if (baseFeeBalance > 0) {
      _localSelectedFees['Base Fee'] = true;
      _localPartialPaymentAmounts['Base Fee'] = baseFeeBalance;
    }

    // Check add-ons with outstanding balances
    for (final addOnBalance in addOnBalances) {
      final addOnMap = addOnBalance as Map<String, dynamic>;
      final feeName = addOnMap['name'] ?? 'Additional Fee';
      final balance = addOnMap['balance'] ?? 0;

      if (balance > 0) {
        _localSelectedFees[feeName] = true;
        _localPartialPaymentAmounts[feeName] = balance;
      }
    }
  }

  void _checkRequiredFields() {
    // Always check base fee as it's required
    _localSelectedFees['Base Fee'] = true;

    // Check compulsory add-ons
    if (widget.feeDetails.addOns != null &&
        widget.feeDetails.addOns!.isNotEmpty) {
      for (final addOn in widget.feeDetails.addOns!) {
        final addOnMap = addOn as Map<String, dynamic>;
        final feeName = addOnMap['name'] ?? 'Additional Fee';
        final isRequired = addOnMap['compulsory'] ?? false;

        if (isRequired) {
          _localSelectedFees[feeName] = true;
        }
      }
    }
  }

  // Method to handle payment initialization
  Future<void> _handlePayment() async {
    if (selectedPaymentMethod == 'card') {
      await _initializeCardPayment();
    } else {
      // Handle bank transfer or other payment methods
      widget.onFeesChanged(_localSelectedFees, _localPartialPaymentAmounts);
      widget.onPaymentProcessed();
      Navigator.of(context).pop();
    }
  }

  // Method to initialize card payment
  Future<void> _initializeCardPayment() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Get the parent and student information
      final parentLoginProvider = ProviderScope.containerOf(
        context,
      ).read(RiverpodProvider.parentLoginProvider.notifier);

      final children = parentLoginProvider.children ?? [];
      if (children.isEmpty) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog('No children found');
        return;
      }

      final selectedChild = children[0]; // Use first child for now
      final studentId = selectedChild.student?.id ?? '';
      final parentId = parentLoginProvider.currentParent?.id ?? '';

      if (studentId.isEmpty || parentId.isEmpty) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog('Student or parent information not found');
        return;
      }

      // Get fee record ID
      final feeRecordId = widget.feeRecord?.id ?? '';
      if (feeRecordId.isEmpty) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog('Fee record not found');
        return;
      }

      // Calculate total amount using centralized fee manager
      final totalAmount = FeeManager.calculateSelectedTotal(
        _localSelectedFees,
        _localPartialPaymentAmounts,
        widget.feeDetails,
        widget.feeRecord,
      );

      // Prepare detailed fee breakdown for payment
      final feeBreakdown = _buildFeeBreakdownForPayment();

      // Prepare payment data
      final paymentData = {
        "studentId": studentId,
        "parentId": parentId,
        "academicYear": "2025/2026", // You can make this dynamic
        "term": "First", // You can make this dynamic
        "paymentType": "Tuition",
        "amount": totalAmount,
        "callbackUrl":
            "https://your-callback-url.com", // Update with your actual callback URL
        "metadata": "School fees payment",
        "description": "First term tuition payment",
        "transactionDetails": {
          "transactionId": "TXN${DateTime.now().millisecondsSinceEpoch}",
          "bankName": "Paystack",
          "accountNumber": "N/A",
          "referenceNumber": "REF${DateTime.now().millisecondsSinceEpoch}",
        },
        "feeRecordId": feeRecordId,
        "feeBreakdown": feeBreakdown, // Add detailed fee breakdown
      };

      // Call the initialize payment endpoint
      final response = await _paymentRepo.initializePayment(paymentData);

      // Close loading dialog
      Navigator.of(context).pop();

      if (HTTPResponseModel.isApiCallSuccess(response) &&
          response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final authorizationUrl = data['authorization_url'] as String?;

        if (authorizationUrl != null && authorizationUrl.isNotEmpty) {
          // Launch the authorization URL
          await _launchPaymentUrl(authorizationUrl);

          // Close the payment popup
          Navigator.of(context).pop();
        } else {
          _showErrorDialog(
            'Payment initialization failed: No authorization URL received',
          );
        }
      } else {
        _showErrorDialog(
          'Payment initialization failed: ${response.message ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showErrorDialog('Payment initialization failed: $e');
    }
  }

  // Method to launch payment URL
  Future<void> _launchPaymentUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog('Could not launch payment URL');
      }
    } catch (e) {
      _showErrorDialog('Error launching payment URL: $e');
    }
  }

  // Method to build detailed fee breakdown for payment
  Map<String, dynamic> _buildFeeBreakdownForPayment() {
    final feeBreakdown = <String, dynamic>{};
    final hasExistingPayments =
        widget.feeRecord?.amountPaid != null &&
        widget.feeRecord!.amountPaid! > 0;

    _localSelectedFees.forEach((feeName, isSelected) {
      if (isSelected) {
        int amount;
        if (hasExistingPayments) {
          amount = FeeManager.getOutstandingBalance(feeName, widget.feeRecord);
        } else {
          amount = FeeManager.getFeeAmount(feeName, widget.feeDetails);
        }

        feeBreakdown[feeName] = {
          'amount': amount,
          'isRequired': FeeManager.isRequiredFee(feeName, widget.feeDetails),
          'status': FeeManager.getFeeStatus(feeName, widget.feeRecord),
        };
      }
    });

    return feeBreakdown;
  }

  // Method to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.credit_card,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay School Fees',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Select the items you\'d like to pay for',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Row(
                children: [
                  // Left Panel - Fee Items
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fee Items',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20),

                          // TUITION & CORE Section
                          Text(
                            'TUITION & CORE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 12),

                          // Base Fee
                          _buildFeeItem(
                            'Base Fee',
                            'Core tuition fee',
                            '₦${(widget.feeDetails.baseFee ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            'Pending',
                            _localSelectedFees['Base Fee'] ?? false,
                            (value) => _updateFeeSelection('Base Fee', value!),
                            required: true,
                            statusColor: Colors.orange,
                            borderColor: Colors.red,
                          ),

                          SizedBox(height: 24),

                          // EXTRAS Section
                          Text(
                            'EXTRAS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 12),

                          // AddOn Fees
                          if (widget.feeDetails.addOns != null &&
                              widget.feeDetails.addOns!.isNotEmpty)
                            ...widget.feeDetails.addOns!.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final addOn = entry.value as Map<String, dynamic>;
                              final feeName =
                                  addOn['name'] ??
                                  'Additional Fee ${index + 1}';
                              final feeAmount = addOn['amount'] ?? 0;
                              final isRequired = addOn['compulsory'] ?? false;

                              return _buildFeeItem(
                                feeName,
                                'Additional fee',
                                '₦${feeAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                'Pending',
                                _localSelectedFees[feeName] ?? false,
                                (value) => _updateFeeSelection(feeName, value!),
                                required: isRequired,
                                statusColor: Colors.orange,
                                borderColor: isRequired ? Colors.red : null,
                              );
                            }),

                          Spacer(),

                          // Bottom Info
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Items marked Required must be paid this term.',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_getSelectedFeesCount()} items selected',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₦${_calculateSelectedTotal().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Divider
                  Container(width: 1, color: Colors.grey[200]),

                  // Right Panel - Payment Method
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () => setState(
                                        () => selectedPaymentMethod = 'card',
                                      ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          selectedPaymentMethod == 'card'
                                              ? Colors.blue[600]
                                              : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.credit_card,
                                          color:
                                              selectedPaymentMethod == 'card'
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Pay with Card',
                                          style: TextStyle(
                                            color:
                                                selectedPaymentMethod == 'card'
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              GestureDetector(
                                onTap:
                                    () => setState(
                                      () => selectedPaymentMethod = 'bank',
                                    ),
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        selectedPaymentMethod == 'bank'
                                            ? Colors.blue[600]
                                            : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.account_balance,
                                    color:
                                        selectedPaymentMethod == 'bank'
                                            ? Colors.white
                                            : Colors.grey[600],
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 32),

                          Text(
                            'Payment Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Show selected fees in summary
                          ..._localSelectedFees.entries
                              .where((entry) => entry.value)
                              .map((entry) {
                                final feeName = entry.key;
                                final amount =
                                    _localPartialPaymentAmounts[feeName] ?? 0;
                                return _buildSummaryRow(
                                  feeName,
                                  '₦${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                );
                              }),

                          SizedBox(height: 16),
                          Divider(),
                          SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '₦${_calculateSelectedTotal().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Payment Icons
                          Row(
                            children: [
                              _buildPaymentIcon(
                                'assets/visa.png',
                                Colors.blue[900]!,
                              ),
                              SizedBox(width: 8),
                              _buildPaymentIcon(
                                'assets/mastercard.png',
                                Colors.red,
                              ),
                              SizedBox(width: 8),
                              _buildPaymentIcon(
                                'assets/paypal.png',
                                Colors.blue,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Secure payment',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          Spacer(),

                          // Pay Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _getSelectedFeesCount() > 0
                                      ? () => _handlePayment()
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Pay Securely with Card',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildFeeItem(
    String title,
    String subtitle,
    String amount,
    String status,
    bool selected,
    Function(bool?) onChanged, {
    bool required = false,
    Color? statusColor,
    Color? borderColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Colors.grey[200]!,
          width: borderColor != null ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Checkbox(
            value: selected,
            onChanged:
                required && selected
                    ? null
                    : onChanged, // Disable unchecking for required fees
            activeColor: Colors.blue[600],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (required)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor?.withOpacity(0.1) ?? Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor ?? Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(amount, style: TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildPaymentIcon(String asset, Color color) {
    return Container(
      width: 24,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text(
          asset.contains('visa')
              ? 'V'
              : asset.contains('mastercard')
              ? 'MC'
              : 'PP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _updateFeeSelection(String feeName, bool isSelected) {
    final feeRecord = widget.feeRecord;
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      // If there are existing payments, don't allow unchecking outstanding balances
      if (!isSelected) {
        return; // Don't allow unchecking outstanding balances
      }
    } else {
      // If no payments, prevent unchecking required fields
      if (!isSelected && _isRequiredFee(feeName)) {
        return; // Don't allow unchecking required fees
      }
    }

    setState(() {
      _localSelectedFees[feeName] = isSelected;
    });
  }

  bool _isRequiredFee(String feeName) {
    // Base fee is always required
    if (feeName == 'Base Fee') return true;

    // Check if it's a compulsory add-on
    if (widget.feeDetails.addOns != null &&
        widget.feeDetails.addOns!.isNotEmpty) {
      for (final addOn in widget.feeDetails.addOns!) {
        final addOnMap = addOn as Map<String, dynamic>;
        final addOnName = addOnMap['name'] ?? 'Additional Fee';
        final isRequired = addOnMap['compulsory'] ?? false;

        if (addOnName == feeName && isRequired) {
          return true;
        }
      }
    }

    return false;
  }

  int _getSelectedFeesCount() {
    return _localSelectedFees.values.where((isSelected) => isSelected).length;
  }

  int _calculateSelectedTotal() {
    int total = 0;
    _localSelectedFees.forEach((fee, isSelected) {
      if (isSelected) {
        total += _localPartialPaymentAmounts[fee] ?? 0;
      }
    });
    return total;
  }

  int _getOutstandingAmount(String feeName) {
    final feeRecord = widget.feeRecord;
    if (feeRecord == null) return 0;

    if (feeName == 'Base Fee') {
      return feeRecord.baseFeeBalance ?? 0;
    }

    // Check add-on balances
    final addOnBalances = feeRecord.addOnBalances ?? [];
    for (final addOnBalance in addOnBalances) {
      final addOnMap = addOnBalance as Map<String, dynamic>;
      final balanceFeeName = addOnMap['name'] ?? 'Additional Fee';
      if (balanceFeeName == feeName) {
        return addOnMap['balance'] ?? 0;
      }
    }

    return 0;
  }

  String _getFeeAmountDisplay(String feeName) {
    final feeRecord = widget.feeRecord;
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      final outstandingAmount = _getOutstandingAmount(feeName);
      if (outstandingAmount > 0) {
        return '₦${outstandingAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
      } else {
        return '₦0'; // Fully paid
      }
    } else {
      // No payments, show full amount
      if (feeName == 'Base Fee') {
        return '₦${(widget.feeDetails.baseFee ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
      } else {
        // Find add-on amount
        if (widget.feeDetails.addOns != null &&
            widget.feeDetails.addOns!.isNotEmpty) {
          for (final addOn in widget.feeDetails.addOns!) {
            final addOnMap = addOn as Map<String, dynamic>;
            final addOnName = addOnMap['name'] ?? 'Additional Fee';
            if (addOnName == feeName) {
              final feeAmount = addOnMap['amount'] ?? 0;
              return '₦${feeAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
            }
          }
        }
        return '₦0';
      }
    }
  }

  String _getFeeStatus(String feeName) {
    final feeRecord = widget.feeRecord;
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      final outstandingAmount = _getOutstandingAmount(feeName);
      if (outstandingAmount > 0) {
        return 'Outstanding';
      } else {
        return 'Paid';
      }
    } else {
      return 'Pending';
    }
  }

  bool _isOutstandingBalance(String feeName) {
    final feeRecord = widget.feeRecord;
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      return _getOutstandingAmount(feeName) > 0;
    } else {
      return _isRequiredFee(feeName);
    }
  }

  Color _getStatusColor(String feeName) {
    final feeRecord = widget.feeRecord;
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      final outstandingAmount = _getOutstandingAmount(feeName);
      if (outstandingAmount > 0) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    } else {
      return Colors.orange;
    }
  }

  Color? _getBorderColor(String feeName) {
    final feeRecord = widget.feeRecord;
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      final outstandingAmount = _getOutstandingAmount(feeName);
      if (outstandingAmount > 0) {
        return Colors.red; // Outstanding balances are required
      } else {
        return Colors.green; // Fully paid
      }
    } else {
      return _isRequiredFee(feeName) ? Colors.red : null;
    }
  }
}

class SchoolFeesManualPaymentPopup extends ConsumerStatefulWidget {
  final FeeDetails feeDetails;
  final Map<String, bool> selectedFees;
  final Map<String, int> partialPaymentAmounts;
  final Function(Map<String, bool>, Map<String, int>) onFeesChanged;
  final VoidCallback onPaymentProcessed;
  final int selectedChildIndex;
  final FeeRecord? feeRecord;

  const SchoolFeesManualPaymentPopup({
    Key? key,
    required this.feeDetails,
    required this.selectedFees,
    required this.partialPaymentAmounts,
    required this.onFeesChanged,
    required this.onPaymentProcessed,
    required this.selectedChildIndex,
    this.feeRecord,
  }) : super(key: key);

  @override
  ConsumerState<SchoolFeesManualPaymentPopup> createState() =>
      _SchoolFeesManualPaymentPopupState();
}

class _SchoolFeesManualPaymentPopupState
    extends ConsumerState<SchoolFeesManualPaymentPopup> {
  late Map<String, bool> _localSelectedFees;
  late Map<String, int> _localPartialPaymentAmounts;
  File? uploadedReceipt;
  String? receiptFileName;
  String? cloudinaryUrl;
  bool isUploading = false;
  final PaymentRepo _paymentRepo = PaymentRepo();

  @override
  void initState() {
    super.initState();
    _localSelectedFees = Map.from(widget.selectedFees);
    _localPartialPaymentAmounts = Map.from(widget.partialPaymentAmounts);

    // Pre-check required fields
    _preCheckRequiredFields();
  }

  int _getSelectedFeesCount() {
    return _localSelectedFees.values.where((isSelected) => isSelected).length;
  }

  int _calculateSelectedTotal() {
    int total = 0;
    _localSelectedFees.forEach((fee, isSelected) {
      if (isSelected) {
        total += _localPartialPaymentAmounts[fee] ?? 0;
      }
    });
    return total;
  }

  bool _isRequiredFee(String feeName) {
    // Base fee is always required
    if (feeName == 'Base Fee') return true;

    // Check if it's a compulsory add-on
    if (widget.feeDetails.addOns != null &&
        widget.feeDetails.addOns!.isNotEmpty) {
      for (final addOn in widget.feeDetails.addOns!) {
        final addOnMap = addOn as Map<String, dynamic>;
        final addOnName = addOnMap['name'] ?? 'Additional Fee';
        final isRequired = addOnMap['compulsory'] ?? false;

        if (addOnName == feeName && isRequired) {
          return true;
        }
      }
    }

    return false;
  }

  Future<void> _uploadReceipt() async {
    setState(() {
      isUploading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.single;
        final fileName = platformFile.name;

        // Handle file data for both web and mobile platforms
        File? file;
        Uint8List? fileBytes;

        if (kIsWeb) {
          // For web platform, use bytes directly
          fileBytes = platformFile.bytes;
          if (fileBytes == null) {
            throw Exception('Failed to read file data');
          }
        } else {
          // For mobile platforms, use file path
          if (platformFile.path != null) {
            file = File(platformFile.path!);
            fileBytes = await file.readAsBytes();
          } else {
            throw Exception('File path is null');
          }
        }

        // Check if it's an image file
        final isImage =
            fileName.toLowerCase().endsWith('.jpg') ||
            fileName.toLowerCase().endsWith('.jpeg') ||
            fileName.toLowerCase().endsWith('.png');

        if (isImage) {
          // Upload image to Cloudinary using bytes
          final uploadedUrl = await _uploadImageToCloudinaryFromBytes(
            fileBytes,
          );

          if (uploadedUrl != null) {
            setState(() {
              uploadedReceipt = file; // Will be null on web, but that's okay
              receiptFileName = fileName;
              cloudinaryUrl = uploadedUrl;
            });

            // Create manual payment after successful upload
            await _createManualPayment(uploadedUrl);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Receipt uploaded and payment recorded successfully!',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            throw Exception('Failed to upload to cloud');
          }
        } else {
          // For PDF files, just store locally for now
          setState(() {
            uploadedReceipt = file; // Will be null on web, but that's okay
            receiptFileName = fileName;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Receipt uploaded successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading receipt: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      // Read and compress the image
      final compressedImageBytes = await _compressImage(imageFile);
      debugPrint(
        '📸 Compressed image size: ${compressedImageBytes.length} bytes',
      );

      // Use the robust upload method
      final uploadedUrl = await _robustCloudinaryUpload(compressedImageBytes);

      if (uploadedUrl != null) {
        debugPrint('✅ Receipt uploaded to Cloudinary: $uploadedUrl');
        return uploadedUrl;
      } else {
        throw Exception(
          'All upload strategies failed. Please check your Cloudinary configuration.',
        );
      }
    } catch (e) {
      debugPrint('❌ Cloudinary upload error: $e');
      rethrow;
    }
  }

  Future<String?> _uploadImageToCloudinaryFromBytes(
    Uint8List imageBytes,
  ) async {
    try {
      // Compress the image from bytes
      final compressedImageBytes = await _compressImageFromBytes(imageBytes);
      debugPrint(
        '📸 Compressed image size: ${compressedImageBytes.length} bytes',
      );

      // Use the robust upload method
      final uploadedUrl = await _robustCloudinaryUpload(compressedImageBytes);

      if (uploadedUrl != null) {
        debugPrint('✅ Receipt uploaded to Cloudinary: $uploadedUrl');
        return uploadedUrl;
      } else {
        throw Exception(
          'All upload strategies failed. Please check your Cloudinary configuration.',
        );
      }
    } catch (e) {
      debugPrint('❌ Cloudinary upload error: $e');
      rethrow;
    }
  }

  // Robust upload method with multiple strategies
  Future<String?> _robustCloudinaryUpload(Uint8List imageBytes) async {
    debugPrint('🚀 Starting robust Cloudinary upload for receipt...');

    // Strategy 1: Direct upload with your preset
    try {
      debugPrint(
        '📤 Strategy 1: Direct upload with preset "${AppConstants.cloudinaryPreset}"',
      );
      final result = await _directUpload(
        imageBytes,
        AppConstants.cloudinaryPreset,
      );
      if (result != null) {
        debugPrint('✅ Strategy 1 successful!');
        return result;
      }
    } catch (e) {
      debugPrint('❌ Strategy 1 failed: $e');
    }

    // Strategy 2: Upload with base64 encoding
    try {
      debugPrint('📤 Strategy 2: Base64 upload');
      final result = await _base64Upload(imageBytes);
      if (result != null) {
        debugPrint('✅ Strategy 2 successful!');
        return result;
      }
    } catch (e) {
      debugPrint('❌ Strategy 2 failed: $e');
    }

    // Strategy 3: Upload with different presets
    final fallbackPresets = ['unsigned_preset', 'ml_default', 'default'];
    for (String preset in fallbackPresets) {
      try {
        debugPrint('📤 Strategy 3: Trying preset "$preset"');
        final result = await _directUpload(imageBytes, preset);
        if (result != null) {
          debugPrint('✅ Strategy 3 successful with preset "$preset"!');
          return result;
        }
      } catch (e) {
        debugPrint('❌ Strategy 3 failed with preset "$preset": $e');
      }
    }

    debugPrint('❌ All upload strategies failed');
    return null;
  }

  // Direct upload method
  Future<String?> _directUpload(Uint8List imageBytes, String preset) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload',
      ),
    );

    request.fields['upload_preset'] = preset;
    request.fields['folder'] = 'receipts';
    request.fields['public_id'] =
        'receipt_${DateTime.now().millisecondsSinceEpoch}';

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'receipt_image.jpg',
      ),
    );

    final response = await request.send().timeout(const Duration(seconds: 30));
    final responseBody = await response.stream.bytesToString();

    debugPrint('📊 Upload response status: ${response.statusCode}');
    debugPrint('📊 Upload response body: $responseBody');

    if (response.statusCode == 200) {
      final data = json.decode(responseBody);
      return data['secure_url'] ?? data['url'];
    } else {
      throw Exception('Upload failed: ${response.statusCode} - $responseBody');
    }
  }

  // Base64 upload method
  Future<String?> _base64Upload(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);

    final response = await http
        .post(
          Uri.parse(
            'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload',
          ),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'file': 'data:image/jpeg;base64,$base64Image',
            'upload_preset': AppConstants.cloudinaryPreset,
            'folder': 'receipts',
            'public_id': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
          }),
        )
        .timeout(const Duration(seconds: 30));

    debugPrint('📊 Base64 upload response status: ${response.statusCode}');
    debugPrint('📊 Base64 upload response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['secure_url'] ?? data['url'];
    } else {
      throw Exception(
        'Base64 upload failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Uint8List> _compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception(
          'Could not decode image. Please try a different image.',
        );
      }

      // Resize image if it's too large (max 800px on longest side)
      img.Image resizedImage = image;
      if (image.width > 800 || image.height > 800) {
        resizedImage = img.copyResize(
          image,
          width: image.width > image.height ? 800 : null,
          height: image.height > image.width ? 800 : null,
          maintainAspect: true,
        );
      }

      // Compress the image with good quality
      final compressedBytes = img.encodeJpg(resizedImage, quality: 90);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      throw Exception('Failed to process image: ${e.toString()}');
    }
  }

  Future<Uint8List> _compressImageFromBytes(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception(
          'Could not decode image. Please try a different image.',
        );
      }

      // Resize image if it's too large (max 800px on longest side)
      img.Image resizedImage = image;
      if (image.width > 800 || image.height > 800) {
        resizedImage = img.copyResize(
          image,
          width: image.width > image.height ? 800 : null,
          height: image.height > image.width ? 800 : null,
          maintainAspect: true,
        );
      }

      // Compress the image with good quality
      final compressedBytes = img.encodeJpg(resizedImage, quality: 90);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      throw Exception('Failed to process image: ${e.toString()}');
    }
  }

  Future<void> _createManualPayment(String receiptUrl) async {
    try {
      // Get current parent login data
      final parentLoginProvider = ref.read(
        RiverpodProvider.parentLoginProvider.notifier,
      );
      final children = parentLoginProvider.children ?? [];
      if (children.isEmpty || widget.selectedChildIndex >= children.length) {
        throw Exception('No child data available');
      }

      final selectedChild = children[widget.selectedChildIndex];
      final student = selectedChild.student;
      final currentTerm = selectedChild.currentTerm;
      final feeRecord = currentTerm?.feeRecord;
      final feeDetails = feeRecord?.feeDetails;

      if (student == null || currentTerm == null || feeDetails == null) {
        throw Exception('Missing student or fee information');
      }

      // Calculate payment breakdown
      final paymentBreakdown = _buildPaymentBreakdown(feeDetails);
      final totalAmount = _calculateSelectedTotal();

      // Build request body
      final requestBody = {
        "studentId": student.id,
        "parentId": parentLoginProvider.currentParent?.id ?? "",
        "academicYear": currentTerm.academicYear ?? "2025/2026",
        "term": currentTerm.term ?? "First",
        "method": "Bank Transfer",
        "paymentType": "Tuition",
        "amount": totalAmount,
        "paymentBreakdown": paymentBreakdown,
        "transactionDetails": {
          "transactionId": "TXN${DateTime.now().millisecondsSinceEpoch}",
          "bankName": "First Bank of Nigeria",
          "accountNumber": "1234567890",
          "referenceNumber": "REF${DateTime.now().millisecondsSinceEpoch}",
        },
        "feeRecordId": feeRecord?.id ?? "",
        "receiptUrl": receiptUrl,
        "description": "Manual payment with receipt upload",
      };

      debugPrint('🚀 Creating manual payment with data: $requestBody');

      // Call the API
      final response = await _paymentRepo.createManualPayment(requestBody);

      if (response.code >= 200 && response.code < 300) {
        debugPrint('✅ Manual payment created successfully');

        // Refresh parent data to get latest updates
        final refreshSuccess = await parentLoginProvider.refreshData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                refreshSuccess
                    ? 'Payment recorded and data refreshed successfully!'
                    : 'Payment recorded successfully! (Data refresh failed)',
              ),
              backgroundColor: refreshSuccess ? Colors.green : Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception('Payment creation failed: ${response.message}');
      }
    } catch (e) {
      debugPrint('❌ Manual payment creation error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record payment: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      rethrow;
    }
  }

  Map<String, dynamic> _buildPaymentBreakdown(FeeDetails feeDetails) {
    final baseFeeAmount =
        _localSelectedFees['Base Fee'] == true
            ? (_localPartialPaymentAmounts['Base Fee'] ?? 0)
            : 0;

    final addOnPayments = <Map<String, dynamic>>[];

    if (widget.feeDetails.addOns != null &&
        widget.feeDetails.addOns!.isNotEmpty) {
      for (final addOn in widget.feeDetails.addOns!) {
        final addOnMap = addOn as Map<String, dynamic>;
        final feeName = addOnMap['name'] ?? 'Additional Fee';

        if (_localSelectedFees[feeName] == true) {
          addOnPayments.add({
            "addOnName": feeName,
            "amount": _localPartialPaymentAmounts[feeName] ?? 0,
          });
        }
      }
    }

    return {"baseFeeAmount": baseFeeAmount, "addOnPayments": addOnPayments};
  }

  void _removeReceipt() {
    setState(() {
      uploadedReceipt = null;
      receiptFileName = null;
      cloudinaryUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.76,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.credit_card,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay School Fees',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Select the items you\'d like to pay for',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Row(
                children: [
                  // Left Panel - Fee Items
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fee Items',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20),

                          // TUITION & CORE Section
                          Text(
                            'TUITION & CORE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 12),

                          // Base Fee
                          _buildFeeItem(
                            'Base Fee',
                            'Core tuition fee',
                            '₦${(widget.feeDetails.baseFee ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            'Pending',
                            _localSelectedFees['Base Fee'] ?? false,
                            (value) => _updateFeeSelection('Base Fee', value!),
                            required: true,
                            statusColor: Colors.orange,
                            borderColor: Colors.red,
                          ),

                          SizedBox(height: 24),

                          // EXTRAS Section
                          Text(
                            'EXTRAS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 12),

                          // AddOn Fees
                          if (widget.feeDetails.addOns != null &&
                              widget.feeDetails.addOns!.isNotEmpty)
                            ...widget.feeDetails.addOns!.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final addOn = entry.value as Map<String, dynamic>;
                              final feeName =
                                  addOn['name'] ??
                                  'Additional Fee ${index + 1}';
                              final feeAmount = addOn['amount'] ?? 0;
                              final isRequired = addOn['compulsory'] ?? false;

                              return _buildFeeItem(
                                feeName,
                                'Additional fee',
                                '₦${feeAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                'Pending',
                                _localSelectedFees[feeName] ?? false,
                                (value) => _updateFeeSelection(feeName, value!),
                                required: isRequired,
                                statusColor: Colors.orange,
                                borderColor: isRequired ? Colors.red : null,
                              );
                            }),

                          Spacer(),

                          // Bottom Info
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Items marked Required must be paid this term.',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_getSelectedFeesCount()} items selected',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₦${_calculateSelectedTotal().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Divider
                  Container(width: 1, color: Colors.grey[200]),

                  // Right Panel - Payment Method
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: ListView(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bank Transfer Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20),

                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance,
                                      color: Colors.blue[600],
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Bank Transfer Information',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                _buildBankDetailRow(
                                  'Bank Name:',
                                  'First Bank of Nigeria',
                                ),
                                _buildBankDetailRow(
                                  'Account Name:',
                                  'ABC School Limited',
                                ),
                                _buildBankDetailRow(
                                  'Account Number:',
                                  '1234567890',
                                ),
                                _buildBankDetailRow('Sort Code:', '123456'),
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.orange[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.orange[600],
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Please include your child\'s name and admission number as payment reference',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 32),

                          Text(
                            'Payment Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Show selected fees in summary
                          ..._localSelectedFees.entries
                              .where((entry) => entry.value)
                              .map((entry) {
                                final feeName = entry.key;
                                final amount =
                                    _localPartialPaymentAmounts[feeName] ?? 0;
                                return _buildSummaryRow(
                                  feeName,
                                  '₦${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                );
                              }),

                          SizedBox(height: 16),
                          Divider(),
                          SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '₦${_calculateSelectedTotal().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Bank Transfer Info
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.security,
                                  color: Colors.green[600],
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Bank transfer is secure and processed within 24-48 hours',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24),

                          // Receipt Upload Section
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upload Receipt (Optional)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Upload your payment receipt for verification',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 12),

                                if (uploadedReceipt == null) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed:
                                          isUploading ? null : _uploadReceipt,
                                      icon:
                                          isUploading
                                              ? SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : Icon(
                                                Icons.upload_file,
                                                size: 16,
                                              ),
                                      label: Text(
                                        isUploading
                                            ? 'Uploading...'
                                            : 'Upload Receipt',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        side: BorderSide(
                                          color: Colors.blue[600]!,
                                        ),
                                        foregroundColor: Colors.blue[600],
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.green[200]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cloudinaryUrl != null
                                                    ? 'Receipt uploaded to cloud'
                                                    : 'Receipt uploaded',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.green[700],
                                                ),
                                              ),
                                              Text(
                                                receiptFileName ??
                                                    'Unknown file',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.green[600],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (cloudinaryUrl != null)
                                                Text(
                                                  'Cloud storage: Active',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.blue[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: _removeReceipt,
                                          icon: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.red[600],
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(
                                            minWidth: 20,
                                            minHeight: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                SizedBox(height: 8),
                                Text(
                                  'Supported formats: PDF, JPG, PNG (Max 5MB)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Spacer(),

                          // Submit Payment Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _getSelectedFeesCount() > 0
                                      ? () {
                                        widget.onFeesChanged(
                                          _localSelectedFees,
                                          _localPartialPaymentAmounts,
                                        );
                                        widget.onPaymentProcessed();
                                        Navigator.of(context).pop();
                                      }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                disabledBackgroundColor: Colors.grey[300],
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.account_balance,
                                    color:
                                        _getSelectedFeesCount() > 0
                                            ? Colors.white
                                            : Colors.grey[500],
                                    size: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Submit Bank Transfer Payment',
                                    style: TextStyle(
                                      color:
                                          _getSelectedFeesCount() > 0
                                              ? Colors.white
                                              : Colors.grey[500],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildBankDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeItem(
    String title,
    String subtitle,
    String amount,
    String status,
    bool selected,
    Function(bool?) onChanged, {
    bool required = false,
    Color? statusColor,
    Color? borderColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Colors.grey[200]!,
          width: borderColor != null ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Checkbox(
            value: selected,
            onChanged:
                required && selected
                    ? null
                    : onChanged, // Disable unchecking for required fees
            activeColor: Colors.blue[600],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (required)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor?.withOpacity(0.1) ?? Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor ?? Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(amount, style: TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }

  void _preCheckRequiredFields() {
    final feeRecord = widget.feeRecord;
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      // If there are existing payments, only show outstanding balances
      _showOnlyOutstandingBalances();
    } else {
      // If no payments, check required fields as before
      _checkRequiredFields();
    }
  }

  void _showOnlyOutstandingBalances() {
    final feeRecord = widget.feeRecord!;
    final baseFeeBalance = feeRecord.baseFeeBalance ?? 0;
    final addOnBalances = feeRecord.addOnBalances ?? [];

    // Check base fee if there's outstanding balance
    if (baseFeeBalance > 0) {
      _localSelectedFees['Base Fee'] = true;
      _localPartialPaymentAmounts['Base Fee'] = baseFeeBalance;
    }

    // Check add-ons with outstanding balances
    for (final addOnBalance in addOnBalances) {
      final addOnMap = addOnBalance as Map<String, dynamic>;
      final feeName = addOnMap['name'] ?? 'Additional Fee';
      final balance = addOnMap['balance'] ?? 0;

      if (balance > 0) {
        _localSelectedFees[feeName] = true;
        _localPartialPaymentAmounts[feeName] = balance;
      }
    }
  }

  void _checkRequiredFields() {
    // Always check base fee as it's required
    _localSelectedFees['Base Fee'] = true;

    // Check compulsory add-ons
    if (widget.feeDetails.addOns != null &&
        widget.feeDetails.addOns!.isNotEmpty) {
      for (final addOn in widget.feeDetails.addOns!) {
        final addOnMap = addOn as Map<String, dynamic>;
        final feeName = addOnMap['name'] ?? 'Additional Fee';
        final isRequired = addOnMap['compulsory'] ?? false;

        if (isRequired) {
          _localSelectedFees[feeName] = true;
        }
      }
    }
  }

  void _updateFeeSelection(String feeName, bool isSelected) {
    final feeRecord = widget.feeRecord;
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      // If there are existing payments, don't allow unchecking outstanding balances
      if (!isSelected) {
        return; // Don't allow unchecking outstanding balances
      }
    } else {
      // If no payments, prevent unchecking required fields
      if (!isSelected && _isRequiredFee(feeName)) {
        return; // Don't allow unchecking required fees
      }
    }

    setState(() {
      _localSelectedFees[feeName] = isSelected;
    });
  }

  int _getOutstandingAmount(String feeName) {
    final feeRecord = widget.feeRecord;
    if (feeRecord == null) return 0;

    if (feeName == 'Base Fee') {
      return feeRecord.baseFeeBalance ?? 0;
    }

    // Check add-on balances
    final addOnBalances = feeRecord.addOnBalances ?? [];
    for (final addOnBalance in addOnBalances) {
      final addOnMap = addOnBalance as Map<String, dynamic>;
      final balanceFeeName = addOnMap['name'] ?? 'Additional Fee';
      if (balanceFeeName == feeName) {
        return addOnMap['balance'] ?? 0;
      }
    }

    return 0;
  }

  String _getFeeAmountDisplay(String feeName) {
    final feeRecord = widget.feeRecord;
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      final outstandingAmount = _getOutstandingAmount(feeName);
      if (outstandingAmount > 0) {
        return '₦${outstandingAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
      } else {
        return '₦0'; // Fully paid
      }
    } else {
      // No payments, show full amount
      if (feeName == 'Base Fee') {
        return '₦${(widget.feeDetails.baseFee ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
      } else {
        // Find add-on amount
        if (widget.feeDetails.addOns != null &&
            widget.feeDetails.addOns!.isNotEmpty) {
          for (final addOn in widget.feeDetails.addOns!) {
            final addOnMap = addOn as Map<String, dynamic>;
            final addOnName = addOnMap['name'] ?? 'Additional Fee';
            if (addOnName == feeName) {
              final feeAmount = addOnMap['amount'] ?? 0;
              return '₦${feeAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
            }
          }
        }
        return '₦0';
      }
    }
  }

  String _getFeeStatus(String feeName) {
    final feeRecord = widget.feeRecord;
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      final outstandingAmount = _getOutstandingAmount(feeName);
      if (outstandingAmount > 0) {
        return 'Outstanding';
      } else {
        return 'Paid';
      }
    } else {
      return 'Pending';
    }
  }

  bool _isOutstandingBalance(String feeName) {
    final feeRecord = widget.feeRecord;
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      return _getOutstandingAmount(feeName) > 0;
    } else {
      return _isRequiredFee(feeName);
    }
  }

  Color _getStatusColor(String feeName) {
    final feeRecord = widget.feeRecord;
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      final outstandingAmount = _getOutstandingAmount(feeName);
      if (outstandingAmount > 0) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    } else {
      return Colors.orange;
    }
  }

  Color? _getBorderColor(String feeName) {
    final feeRecord = widget.feeRecord;
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      final outstandingAmount = _getOutstandingAmount(feeName);
      if (outstandingAmount > 0) {
        return Colors.red; // Outstanding balances are required
      } else {
        return Colors.green; // Fully paid
      }
    } else {
      return _isRequiredFee(feeName) ? Colors.red : null;
    }
  }
}

// Usage example:
