import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/models/parent_login_response_model.dart';
import 'dart:async';
import 'package:schmgtsystem/repository/payment_repo.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:schmgtsystem/services/global_academic_year_service.dart';
import 'package:schmgtsystem/providers/auth_state_provider.dart';
import 'package:go_router/go_router.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> {
  String _selectedTerm = 'First';
  String _selectedAcademicYear = '2024/2025';
  int _selectedChildIndex = 0; // Track selected child index
  late GlobalAcademicYearService _academicYearService;
  Map<String, bool> _selectedFees = {};
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
  void initState() {
    super.initState();
    print('🔍 DEBUG: ===== PARENT DASHBOARD INITIALIZATION =====');
    print('🔍 DEBUG: Parent dashboard initState called');

    _academicYearService = GlobalAcademicYearService();
    print('🔍 DEBUG: Academic year service initialized');
    print(
      '🔍 DEBUG: Current academic year: ${_academicYearService.currentAcademicYearString}',
    );
    print('🔍 DEBUG: Current term: ${_academicYearService.currentTermString}');

    _academicYearService.addListener(_onAcademicYearChanged);
    print('🔍 DEBUG: Academic year listener added');

    // Check if parent data needs to be loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔍 DEBUG: Post frame callback triggered - checking parent data');
      _checkParentData();
    });
    print('🔍 DEBUG: ===== END PARENT DASHBOARD INITIALIZATION =====');
  }

  void _checkParentData() {
    print('🔍 DEBUG: ===== CHECKING PARENT DATA =====');
    final parentLoginState = ref.read(RiverpodProvider.parentLoginProvider);
    print('🔍 DEBUG: Parent login state loaded');
    print(
      '🔍 DEBUG: Parent data exists: ${parentLoginState.parentLoginData != null}',
    );
    print('🔍 DEBUG: Is loading: ${parentLoginState.isLoading}');
    print('🔍 DEBUG: Error message: ${parentLoginState.errorMessage}');

    // Always refresh data to ensure we get the latest from the correct endpoint
    print('🔍 DEBUG: Refreshing parent data from dashboard endpoint');
    _refreshParentDataSilently();
    print('🔍 DEBUG: ===== END CHECKING PARENT DATA =====');
  }

  Future<void> _refreshParentDataSilently() async {
    try {
      print('🔍 DEBUG: ===== STARTING SILENT PARENT DATA REFRESH =====');
      print('🔍 DEBUG: Starting silent parent data refresh...');
      final parentLoginProvider = ref.read(
        RiverpodProvider.parentLoginProvider.notifier,
      );
      print('🔍 DEBUG: Parent login provider obtained');

      print('🔍 DEBUG: ===== CALLING PARENT DASHBOARD ENDPOINT =====');
      print('🔍 DEBUG: Method: parentLoginProvider.refreshDataFromDashboard()');
      print('🔍 DEBUG: This will call: GET /api/parents/{parentId}');
      final success = await parentLoginProvider.refreshDataFromDashboard();
      print('🔍 DEBUG: Silent refresh result: $success');

      if (mounted) {
        print('🔍 DEBUG: Widget still mounted, calling setState');
        setState(() {});
        print('🔍 DEBUG: setState called successfully');
      } else {
        print('🔍 DEBUG: Widget no longer mounted, skipping setState');
      }
      print('🔍 DEBUG: ===== END SILENT PARENT DATA REFRESH =====');
    } catch (e) {
      print('🔍 DEBUG: Error in silent refresh: $e');
      print('🔍 DEBUG: Error type: ${e.runtimeType}');
      print('🔍 DEBUG: Error stack trace: ${StackTrace.current}');
      // Don't show error messages for silent refresh
    }
  }

  Future<void> _refreshParentData() async {
    try {
      print('🔍 DEBUG: Starting parent data refresh...');
      final parentLoginProvider = ref.read(
        RiverpodProvider.parentLoginProvider.notifier,
      );

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Refreshing data...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      print('🔍 DEBUG: ===== CALLING PARENT DASHBOARD ENDPOINT =====');
      print('🔍 DEBUG: Method: parentLoginProvider.refreshDataFromDashboard()');
      print('🔍 DEBUG: This will call: GET /api/parents/{parentId}');
      final success = await parentLoginProvider.refreshDataFromDashboard();
      print('🔍 DEBUG: Refresh result: $success');

      if (mounted) {
        setState(() {});

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data refreshed successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Show error message from provider with retry option
          final errorMessage =
              ref.read(RiverpodProvider.parentLoginProvider).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage ?? 'Failed to refresh data'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  _refreshParentData();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('🔍 DEBUG: Error refreshing parent data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                _refreshParentData();
              },
            ),
          ),
        );
      }
    }
  }

  void _onAcademicYearChanged() {
    if (mounted) {
      setState(() {
        // Trigger rebuild when academic year changes
      });
    }
  }

  @override
  void dispose() {
    _academicYearService.removeListener(_onAcademicYearChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if user is actually a parent - prevent admin access
    final authState = ref.watch(authStateProvider);
    if (authState.userRole != 'parent') {
      // If not a parent, redirect to appropriate dashboard
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (authState.userRole == 'admin') {
          context.go('/dashboard');
        } else if (authState.userRole == 'teacher') {
          context.go('/teacher');
        } else {
          context.go('/login');
        }
      });

      // Show loading while redirecting
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final parentLoginState = ref.watch(RiverpodProvider.parentLoginProvider);
    final parentLoginProvider = ref.read(
      RiverpodProvider.parentLoginProvider.notifier,
    );

    // Use helper methods from provider for cleaner access
    final children = parentLoginProvider.children ?? [];
    final financialSummary = parentLoginProvider.financialSummary;
    final communications = parentLoginProvider.communications ?? [];

    // Debug: Check children data
    print('🔍 DEBUG: Children count: ${children.length}');
    print(
      '🔍 DEBUG: Parent login data exists: ${parentLoginState.parentLoginData != null}',
    );
    if (parentLoginState.parentLoginData != null) {
      print(
        '🔍 DEBUG: Parent details exists: ${parentLoginState.parentLoginData!.data != null}',
      );
      if (parentLoginState.parentLoginData!.data != null) {
        print(
          '🔍 DEBUG: Children in parent data: ${parentLoginState.parentLoginData!.data!.children?.length ?? 0}',
        );
        if (parentLoginState.parentLoginData!.data!.children != null) {
          for (
            int i = 0;
            i < parentLoginState.parentLoginData!.data!.children!.length;
            i++
          ) {
            final child = parentLoginState.parentLoginData!.data!.children![i];
            print(
              '🔍 DEBUG: Child $i: ${child.student?.personalInfo?.firstName} ${child.student?.personalInfo?.lastName}',
            );
          }
        }
      }
    }

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
      // Fallback to available options with safety checks
      if (availableYears.isNotEmpty) {
        _selectedAcademicYear = availableYears.first;
      } else {
        _selectedAcademicYear = '2024/2025'; // Default fallback
      }
      if (availableTerms.isNotEmpty) {
        _selectedTerm = availableTerms.first;
      } else {
        _selectedTerm = 'First'; // Default fallback
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
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await parentLoginProvider.refreshDataFromDashboard();
            },
          ),
        ],
      ),
      body:
          children.isEmpty
              ? const Center(
                child: Text(
                  'No children found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(icon: Icon(Icons.home), text: 'Overview'),
                        Tab(icon: Icon(Icons.payment), text: 'Fees & Payments'),
                        Tab(
                          icon: Icon(Icons.calendar_today),
                          text: 'Attendance',
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Overview Tab
                          _buildOverviewTab(
                            parentLoginProvider,
                            children,
                            financialSummary,
                            communications,
                          ),
                          // Fees & Payments Tab
                          _buildFeesPaymentsTab(
                            children,
                            availableYears,
                            availableTerms,
                          ),
                          // Attendance Tab
                          _buildAttendanceTab(children),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  // Overview Tab
  Widget _buildOverviewTab(
    dynamic parentLoginProvider,
    List<Child> children,
    dynamic financialSummary,
    List<dynamic> communications,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(parentLoginProvider),
          const SizedBox(height: 20),
          _buildChildrenSection(children),
          const SizedBox(height: 20),
          _buildAcademicOverview(),
          const SizedBox(height: 20),
          _buildAnnouncements(communications),
        ],
      ),
    );
  }

  // Fees & Payments Tab
  Widget _buildFeesPaymentsTab(
    List<Child> children,
    List<String> availableYears,
    List<String> availableTerms,
  ) {
    // Check if fees are fully paid
    final isFullyPaid = _areFeesFullyPaid(children);
    print('🔍 DEBUG: Fees & Payments Tab - isFullyPaid: $isFullyPaid');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Academic Year and Term Selection
          _buildAcademicSelection(children),
          const SizedBox(height: 20),

          if (isFullyPaid) ...[
            // Show Thank You Card and Payment Details when fully paid
            _buildThankYouCard(children),
            const SizedBox(height: 20),
            _buildPaymentDetailsCard(children),
            const SizedBox(height: 20),
            _buildPaymentHistoryCard(children),
          ] else ...[
            // Show Outstanding Balance and Payment Options when not fully paid
            _buildOutstandingBalance(children),
            const SizedBox(height: 20),
            _buildFeeBreakdown(children),
            const SizedBox(height: 20),
            _buildPaymentButton(children),
          ],
        ],
      ),
    );
  }

  // Attendance Tab
  Widget _buildAttendanceTab(List<Child> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child Selection for Attendance
          _buildChildSelectionForAttendance(children),
          const SizedBox(height: 20),

          // Attendance Summary
          _buildAttendanceSummary(children),
          const SizedBox(height: 20),

          // Attendance Calendar
          _buildAttendanceCalendar(children),
          const SizedBox(height: 20),

          // Attendance Statistics
          _buildAttendanceStatistics(children),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(dynamic parentLoginProvider) {
    final parentLoginData = parentLoginProvider.state.parentLoginData;
    String parentName = 'Parent';

    // Debug: Log parent data structure
    print('🔍 DEBUG: ===== PARENT DATA STRUCTURE =====');
    print('🔍 DEBUG: parentLoginData: ${parentLoginData != null}');
    print('🔍 DEBUG: parent: ${parentLoginData?.data?.parent != null}');
    print(
      '🔍 DEBUG: personalInfo: ${parentLoginData?.data?.parent?.personalInfo != null}',
    );
    print('🔍 DEBUG: user: ${parentLoginData?.data?.parent?.user != null}');

    if (parentLoginData?.data?.parent?.personalInfo != null) {
      final personalInfo = parentLoginData!.data!.parent!.personalInfo!;
      print('🔍 DEBUG: personalInfo.firstName: ${personalInfo.firstName}');
      print('🔍 DEBUG: personalInfo.lastName: ${personalInfo.lastName}');
      print('🔍 DEBUG: personalInfo.title: ${personalInfo.title}');
    }

    if (parentLoginData?.data?.parent?.user != null) {
      final user = parentLoginData!.data!.parent!.user!;
      print('🔍 DEBUG: user.email: ${user.email}');
      print('🔍 DEBUG: user.isActive: ${user.isActive}');
      print('🔍 DEBUG: user.lastLogin: ${user.lastLogin}');
    }
    print('🔍 DEBUG: ===== END PARENT DATA STRUCTURE =====');

    // Get parent name from personalInfo (primary source)
    if (parentLoginData?.data?.parent?.personalInfo != null) {
      final personalInfo = parentLoginData!.data!.parent!.personalInfo!;
      final firstName = personalInfo.firstName ?? '';
      final lastName = personalInfo.lastName ?? '';
      final title = personalInfo.title ?? '';

      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        parentName = '$title $firstName $lastName'.trim();
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  parentName,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Parent Dashboard',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              // Refresh Button
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: _refreshParentData,
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                  tooltip: 'Refresh Data',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.family_restroom,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${parentLoginProvider.children?.length ?? 0} ${(parentLoginProvider.children?.length ?? 0) == 1 ? 'Child' : 'Children'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenSection(List<Child> children) {
    // Debug: Log children data structure
    print('🔍 DEBUG: ===== CHILDREN DATA STRUCTURE =====');
    print('🔍 DEBUG: children.length: ${children.length}');

    if (children.isNotEmpty) {
      final child = children[0];
      print('🔍 DEBUG: child.student: ${child.student != null}');
      print('🔍 DEBUG: child.currentTerm: ${child.currentTerm != null}');
      print('🔍 DEBUG: child.paymentHistory: ${child.paymentHistory != null}');

      if (child.student != null) {
        print('🔍 DEBUG: student.id: ${child.student?.id}');
        print(
          '🔍 DEBUG: student.admissionNumber: ${child.student?.admissionNumber}',
        );
        print(
          '🔍 DEBUG: student.personalInfo: ${child.student?.personalInfo != null}',
        );
        if (child.student?.personalInfo != null) {
          print(
            '🔍 DEBUG: student.firstName: ${child.student?.personalInfo?.firstName}',
          );
          print(
            '🔍 DEBUG: student.lastName: ${child.student?.personalInfo?.lastName}',
          );
        }
      }

      if (child.currentTerm != null) {
        print('🔍 DEBUG: currentTerm.term: ${child.currentTerm?.term}');
        print(
          '🔍 DEBUG: currentTerm.academicYear: ${child.currentTerm?.academicYear}',
        );
        print(
          '🔍 DEBUG: currentTerm.amountOwed: ${child.currentTerm?.amountOwed}',
        );
        print(
          '🔍 DEBUG: currentTerm.feeRecord: ${child.currentTerm?.feeRecord != null}',
        );
        if (child.currentTerm?.feeRecord != null) {
          print(
            '🔍 DEBUG: feeRecord.feeDetails: ${child.currentTerm?.feeRecord?.feeDetails != null}',
          );
          if (child.currentTerm?.feeRecord?.feeDetails != null) {
            print(
              '🔍 DEBUG: feeDetails.baseFee: ${child.currentTerm?.feeRecord?.feeDetails?.baseFee}',
            );
            print(
              '🔍 DEBUG: feeDetails.totalFee: ${child.currentTerm?.feeRecord?.feeDetails?.totalFee}',
            );
            print(
              '🔍 DEBUG: feeDetails.addOns: ${child.currentTerm?.feeRecord?.feeDetails?.addOns?.length ?? 0}',
            );
          }
        }
      }
    }
    print('🔍 DEBUG: ===== END CHILDREN DATA STRUCTURE =====');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Your Children',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                await _refreshParentData();
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
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
                  final academicInfo = student?.academicInfo;
                  final currentClass = academicInfo?.currentClass;
                  final childCurrentTerm = child.currentTerm;

                  // Safety check for null data
                  if (student == null) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _buildChildCard(
                          'Unknown Student',
                          'Unknown Class',
                          '0%',
                          'No Data',
                          Colors.grey,
                          'https://via.placeholder.com/60x60',
                        ),
                      ),
                    );
                  }

                  // Calculate attendance percentage (use 0% if no data available)
                  final attendancePercentage = '0%';

                  // Use feeDetails.totalFee for fee status - ultra simplified
                  String feeStatus;
                  Color feeStatusColor;

                  // Get feeDetails from feeRecord
                  final feeDetails = childCurrentTerm?.feeRecord?.feeDetails;
                  final totalFee = feeDetails?.totalFee ?? 0;

                  if (totalFee > 0) {
                    feeStatus = '£$totalFee Due';
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
                  margin: const EdgeInsets.only(right: 15),
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
    final parentLoginProvider = ref.read(
      RiverpodProvider.parentLoginProvider.notifier,
    );
    final children = parentLoginProvider.children ?? [];
    final selectedChild =
        children.isNotEmpty ? children[_selectedChildIndex] : null;
    final studentName =
        selectedChild?.student?.personalInfo != null
            ? '${selectedChild!.student!.personalInfo!.firstName ?? ''} ${selectedChild.student!.personalInfo!.lastName ?? ''}'
            : 'Student';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with student name and attendance icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$studentName - Attendance Monitor',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Real-time attendance tracking',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Attendance Content
          _buildAttendanceMonitor(),
        ],
      ),
    );
  }

  Widget _buildAttendanceMonitor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Today's Status Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[50]!, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.green[600],
                  size: 32,
                ),
              ),
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
                      'Awaiting Data',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      'Attendance data will appear here when available',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Attendance Statistics
        const Text(
          'Attendance Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildAttendanceStatCard(
                'Present',
                '0%',
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAttendanceStatCard(
                'Absent',
                '0%',
                Colors.red,
                Icons.cancel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAttendanceStatCard(
                'Late',
                '0%',
                Colors.orange,
                Icons.schedule,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Weekly Attendance Chart Placeholder
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
                'Weekly Attendance Trend',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Attendance chart will appear here',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Recent Attendance Records
        const Text(
          'Recent Attendance',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: const Center(
            child: Column(
              children: [
                Icon(Icons.event_note, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'No attendance records available',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Attendance records will appear here when data is available from the backend',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
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

  // Academic Selection for Fees Tab
  Widget _buildAcademicSelection(List<Child> children) {
    final availableYears = _getAvailableAcademicYears(children);
    final availableTerms = _getAvailableTerms(children);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Academic Period',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              // Refresh Button for Fees Tab
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: _refreshParentData,
                  icon: const Icon(Icons.refresh, color: Colors.blue, size: 20),
                  tooltip: 'Refresh Fee Data',
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Academic Year'),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedAcademicYear,
                      isExpanded: true,
                      items:
                          availableYears.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAcademicYear = value!;
                        });
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
                    const Text('Term'),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedTerm,
                      isExpanded: true,
                      items:
                          availableTerms.map((term) {
                            return DropdownMenuItem(
                              value: term,
                              child: Text(term),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTerm = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Outstanding Balance
  Widget _buildOutstandingBalance(List<Child> children) {
    if (children.isEmpty || _selectedChildIndex >= children.length) {
      return const SizedBox.shrink();
    }

    final child = children[_selectedChildIndex];
    final currentTerm = child.currentTerm;
    final feeDetails = currentTerm?.feeDetails; // Check top-level feeDetails
    final feeRecordDetails =
        currentTerm?.feeRecord?.feeDetails; // Check nested feeDetails

    // Debug logging
    print('🔍 DEBUG: Outstanding Balance Check');
    print('🔍 DEBUG: currentTerm?.status: ${currentTerm?.status}');
    print('🔍 DEBUG: feeDetails (top-level): $feeDetails');
    print('🔍 DEBUG: feeRecordDetails (nested): $feeRecordDetails');
    print('🔍 DEBUG: feeRecord: ${currentTerm?.feeRecord}');

    // Check if fee structure is not set - only check if feeDetails exists and has baseFee
    final effectiveFeeDetails = feeDetails ?? feeRecordDetails;
    final hasNoFeeStructure =
        effectiveFeeDetails == null ||
        effectiveFeeDetails.baseFee == null ||
        effectiveFeeDetails.baseFee == 0;

    print('🔍 DEBUG: Has no fee structure: $hasNoFeeStructure');
    print('🔍 DEBUG: effectiveFeeDetails: $effectiveFeeDetails');
    print('🔍 DEBUG: baseFee: ${effectiveFeeDetails?.baseFee}');
    print('🔍 DEBUG: Hiding outstanding balance: $hasNoFeeStructure');

    // Don't show outstanding balance if fee structure is not set
    if (hasNoFeeStructure) {
      print('🔍 DEBUG: Outstanding balance hidden - no fee structure');
      return const SizedBox.shrink();
    }

    final totalFee = effectiveFeeDetails.totalFee ?? 0;

    return Container(
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
                '£$totalFee',
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
    );
  }

  // Fee Breakdown
  Widget _buildFeeBreakdown(List<Child> children) {
    if (children.isEmpty || _selectedChildIndex >= children.length) {
      return const SizedBox.shrink();
    }

    final child = children[_selectedChildIndex];
    final currentTerm = child.currentTerm;
    final feeDetails = currentTerm?.feeDetails; // Check top-level feeDetails
    final feeRecordDetails =
        currentTerm?.feeRecord?.feeDetails; // Check nested feeDetails

    // Debug logging
    print('🔍 DEBUG: Fee Breakdown Check');
    print('🔍 DEBUG: currentTerm: $currentTerm');
    print('🔍 DEBUG: currentTerm?.status: ${currentTerm?.status}');
    print('🔍 DEBUG: feeDetails (top-level): $feeDetails');
    print('🔍 DEBUG: feeRecordDetails (nested): $feeRecordDetails');
    print('🔍 DEBUG: feeRecord: ${currentTerm?.feeRecord}');

    // Check if fee structure is not set - only check if feeDetails exists and has baseFee
    final effectiveFeeDetails = feeDetails ?? feeRecordDetails;
    final hasNoFeeStructure =
        effectiveFeeDetails == null ||
        effectiveFeeDetails.baseFee == null ||
        effectiveFeeDetails.baseFee == 0;

    print('🔍 DEBUG: Has no fee structure: $hasNoFeeStructure');
    print('🔍 DEBUG: effectiveFeeDetails: $effectiveFeeDetails');
    print('🔍 DEBUG: baseFee: ${effectiveFeeDetails?.baseFee}');
    print('🔍 DEBUG: feeDetails exists: ${feeDetails != null}');
    print('🔍 DEBUG: feeRecordDetails exists: ${feeRecordDetails != null}');

    if (hasNoFeeStructure) {
      print('🔍 DEBUG: Showing No Fee Structure Card');
      return _buildNoFeeStructureCard(currentTerm);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fee Breakdown',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              // Use the available fee details (prefer top-level, fallback to nested)
              Builder(
                builder: (context) {
                  final effectiveFeeDetails = feeDetails ?? feeRecordDetails;
                  if (effectiveFeeDetails == null) {
                    return const Text('No fee details available');
                  }

                  return Column(
                    children: [
                      // Base Fee
                      _buildFeeItem(
                        'Base Fee',
                        effectiveFeeDetails.baseFee ?? 0,
                        true,
                      ),

                      // Add-ons
                      if (effectiveFeeDetails.addOns != null &&
                          effectiveFeeDetails.addOns!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ...effectiveFeeDetails.addOns!.map((addOn) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildFeeItem(
                              addOn.name ?? 'Additional Fee',
                              addOn.amount ?? 0,
                              addOn.compulsory == true,
                            ),
                          );
                        }),
                      ],

                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Summary
                      _buildSummaryRow(
                        'Total Fees',
                        effectiveFeeDetails.totalFee ?? 0,
                      ),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Amount Paid', 0),
                      const SizedBox(height: 8),
                      _buildSummaryRow(
                        'Outstanding Balance',
                        effectiveFeeDetails.totalFee ?? 0,
                        isBold: true,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeeItem(String name, int amount, bool isRequired) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isRequired ? Colors.red : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Amount: £$amount',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  isRequired
                      ? Colors.red.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isRequired ? 'Required' : 'Optional',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isRequired ? Colors.red : Colors.orange,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Pending',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int amount, {bool isBold = false}) {
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
          '£$amount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? Colors.red : Colors.black87,
          ),
        ),
      ],
    );
  }

  // Payment Button
  Widget _buildPaymentButton(List<Child> children) {
    if (children.isEmpty || _selectedChildIndex >= children.length) {
      return const SizedBox.shrink();
    }

    final child = children[_selectedChildIndex];
    final currentTerm = child.currentTerm;
    final feeDetails = currentTerm?.feeDetails; // Check top-level feeDetails
    final feeRecordDetails =
        currentTerm?.feeRecord?.feeDetails; // Check nested feeDetails

    // Debug logging
    print('🔍 DEBUG: Payment Button Check');
    print('🔍 DEBUG: currentTerm?.status: ${currentTerm?.status}');
    print('🔍 DEBUG: feeDetails (top-level): $feeDetails');
    print('🔍 DEBUG: feeRecordDetails (nested): $feeRecordDetails');
    print('🔍 DEBUG: feeRecord: ${currentTerm?.feeRecord}');

    // Check if fee structure is not set - only check if feeDetails exists and has baseFee
    final effectiveFeeDetails = feeDetails ?? feeRecordDetails;
    final hasNoFeeStructure =
        effectiveFeeDetails == null ||
        effectiveFeeDetails.baseFee == null ||
        effectiveFeeDetails.baseFee == 0;

    print('🔍 DEBUG: Has no fee structure: $hasNoFeeStructure');
    print('🔍 DEBUG: effectiveFeeDetails: $effectiveFeeDetails');
    print('🔍 DEBUG: baseFee: ${effectiveFeeDetails?.baseFee}');
    print('🔍 DEBUG: Hiding payment button: $hasNoFeeStructure');

    // Don't show payment button if fee structure is not set
    if (hasNoFeeStructure) {
      print('🔍 DEBUG: Payment button hidden - no fee structure');
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showPaymentDialog(children[_selectedChildIndex]);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Make Payment',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _processPayment() {
    // Payment processing logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment processed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Attendance Methods
  Widget _buildChildSelectionForAttendance(List<Child> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Child',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButton<int>(
            value: _selectedChildIndex,
            isExpanded: true,
            items:
                children.asMap().entries.map((entry) {
                  final index = entry.key;
                  final child = entry.value;
                  final childName =
                      '${child.student?.personalInfo?.firstName ?? ''} ${child.student?.personalInfo?.lastName ?? ''}'
                          .trim();
                  return DropdownMenuItem(
                    value: index,
                    child: Text(
                      childName.isEmpty ? 'Child ${index + 1}' : childName,
                    ),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedChildIndex = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary(List<Child> children) {
    if (children.isEmpty || _selectedChildIndex >= children.length) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAttendanceCard('Present', 85, Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildAttendanceCard('Absent', 5, Colors.red)),
              const SizedBox(width: 16),
              Expanded(child: _buildAttendanceCard('Late', 10, Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(String title, int percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCalendar(List<Child> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Calendar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Calendar will be implemented when attendance endpoint is provided',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStatistics(List<Child> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Statistics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Statistics will be implemented when attendance endpoint is provided',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncements(List<dynamic> communications) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
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
          const SizedBox(height: 12),
          if (communications.isEmpty)
            const Text(
              'No announcements at the moment',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...communications
                .take(3)
                .map(
                  (communication) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      communication?['message'] ?? 'No message',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isVerified ? 'Verified' : 'Pending',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  bool _areFeesFullyPaid(List<Child> children) {
    print('🔍 DEBUG: _areFeesFullyPaid called');
    return children.every((child) {
      final currentTerm = child.currentTerm;
      if (currentTerm == null) {
        print('🔍 DEBUG: currentTerm is null, returning false');
        return false;
      }

      // Check if fee structure is not set - only check if feeDetails exists and has baseFee
      final feeDetails =
          currentTerm.feeDetails ?? currentTerm.feeRecord?.feeDetails;
      final hasNoFeeStructure =
          feeDetails == null ||
          feeDetails.baseFee == null ||
          feeDetails.baseFee == 0;

      if (hasNoFeeStructure) {
        print(
          '🔍 DEBUG: No fee structure set (no feeDetails or baseFee), returning false',
        );
        return false;
      }

      final isPaid =
          currentTerm.status == 'Paid' || (currentTerm.amountOwed ?? 0) == 0;
      print('🔍 DEBUG: currentTerm.status: ${currentTerm.status}');
      print('🔍 DEBUG: currentTerm.amountOwed: ${currentTerm.amountOwed}');
      print('🔍 DEBUG: isPaid: $isPaid');
      print('🔍 DEBUG: feeRecord: ${currentTerm.feeRecord}');

      return isPaid;
    });
  }

  String _getCurrentTermStatus(CurrentTerm? currentTerm) {
    if (currentTerm == null) return 'Unknown';
    return currentTerm.status ?? 'Unknown';
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  /// Beautiful Thank You Card for when fees are fully paid
  Widget _buildThankYouCard(List<Child> children) {
    if (children.isEmpty || _selectedChildIndex >= children.length) {
      return const SizedBox.shrink();
    }

    final child = children[_selectedChildIndex];
    final studentName = child.student?.personalInfo?.firstName ?? 'Your child';
    final currentTerm = child.currentTerm;
    final feeRecord = currentTerm?.feeRecord;
    final totalPaid = feeRecord?.amountPaid ?? 0;
    final academicYear = currentTerm?.academicYear ?? '2025/2026';
    final term = currentTerm?.term ?? 'Third';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[50]!, Colors.green[100]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.green[200]!, width: 1),
      ),
      child: Column(
        children: [
          // Success Icon with Animation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),

          // Thank You Message
          Text(
            'Payment Complete! 🎉',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          Text(
            'Thank you for your payment! All fees for $studentName have been successfully processed.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.green[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Payment Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Paid:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                    ),
                    Text(
                      '₦${totalPaid.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Academic Period:',
                      style: TextStyle(fontSize: 14, color: Colors.green[700]),
                    ),
                    Text(
                      '$term Term $academicYear',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Additional Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Payment receipts and records are securely stored in your account.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Payment Details Card showing what was paid for
  Widget _buildPaymentDetailsCard(List<Child> children) {
    if (children.isEmpty || _selectedChildIndex >= children.length) {
      return const SizedBox.shrink();
    }

    final child = children[_selectedChildIndex];
    final feeRecord = child.currentTerm?.feeRecord;
    final feeDetails = feeRecord?.feeDetails;

    if (feeDetails == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
              const Text(
                'Payment Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Base Fee
          _buildPaidFeeItem(
            'Base Fee',
            feeDetails.baseFee ?? 0,
            true,
            Icons.school,
            Colors.blue,
          ),

          // Add-ons
          if (feeDetails.addOns != null && feeDetails.addOns!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...feeDetails.addOns!.map((addOn) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPaidFeeItem(
                  addOn.name ?? 'Additional Fee',
                  addOn.amount ?? 0,
                  addOn.compulsory == true,
                  Icons.add_circle,
                  Colors.orange,
                ),
              );
            }),
          ],

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Total Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount Paid',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  '₦${(feeDetails.totalFee ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Individual paid fee item
  Widget _buildPaidFeeItem(
    String name,
    int amount,
    bool isRequired,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
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
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
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
                const SizedBox(height: 4),
                Text(
                  '₦${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                const Text(
                  'Paid',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Payment History Card showing recent payments
  Widget _buildPaymentHistoryCard(List<Child> children) {
    if (children.isEmpty || _selectedChildIndex >= children.length) {
      return const SizedBox.shrink();
    }

    final child = children[_selectedChildIndex];
    final feeRecord = child.currentTerm?.feeRecord;
    final payments = feeRecord?.payments ?? [];

    if (payments.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get completed payments only
    final completedPayments =
        payments.where((payment) {
          if (payment is Map<String, dynamic>) {
            return payment['status'] == 'Completed';
          }
          return false;
        }).toList();

    if (completedPayments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recent Payments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Show only the most recent completed payment
          ...completedPayments.take(1).map((payment) {
            final amount = payment['amount'] ?? 0;
            final date = payment['date'] ?? '';
            final method = payment['method'] ?? 'Gateway';
            final reference = payment['reference'] ?? '';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₦${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$method • ${_formatDate(date)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        'Ref: ${reference.substring(0, 8)}...',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildThankYouSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 48),
          const SizedBox(height: 12),
          Text(
            'Thank You!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All fees have been paid for this term.',
            style: TextStyle(fontSize: 16, color: Colors.green[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.upload_file, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                'Upload Payment Receipt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Please upload your payment receipt for verification.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement file upload
            },
            icon: const Icon(Icons.upload),
            label: const Text('Choose File'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showOutstandingPaymentPopup(Child child) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Outstanding Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Child: ${child.student?.personalInfo?.firstName ?? 'Unknown'} ${child.student?.personalInfo?.lastName ?? ''}',
              ),
              const SizedBox(height: 8),
              Text(
                'Outstanding Amount: £${child.currentTerm?.amountOwed ?? 0}',
              ),
              const SizedBox(height: 8),
              Text('Status: ${_getCurrentTermStatus(child.currentTerm)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement payment processing
              },
              child: const Text('Pay Now'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDialog(Child child) {
    final currentTerm = child.currentTerm;
    final feeDetails = currentTerm?.feeDetails;
    print('🔍 DEBUG: feeDetails: $currentTerm.');
    if (feeDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fee details not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Pre-select required fees
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
            feeRecord: currentTerm?.feeRecord,
          ),
    );
  }

  void _preSelectRequiredFees(FeeDetails feeDetails) {
    // Always select base fee as it's required
    _selectedFees['Base Fee'] = true;

    // Select compulsory add-ons
    if (feeDetails.addOns != null && feeDetails.addOns!.isNotEmpty) {
      for (final addOn in feeDetails.addOns!) {
        final feeName = addOn.name ?? 'Additional Fee';
        final isRequired = addOn.compulsory == true;

        if (isRequired) {
          _selectedFees[feeName] = true;
        }
      }
    }
  }

  Widget _buildNoFeeStructureCard(CurrentTerm? currentTerm) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon and Title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 48,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 20),

          // Main Title
          Text(
            'Fee Structure Pending',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            'The fee structure for ${currentTerm?.academicYear ?? 'this academic year'} - ${currentTerm?.term ?? 'current term'} has not been set up yet.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'What happens next?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'The school administration will set up the fee structure for this term. Once completed, you\'ll be able to view the fee breakdown and make payments.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Contact Information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.support_agent, color: Colors.blue[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need assistance?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Contact the school administration for more information about fee structures.',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Refresh Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _refreshParentData,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh Fee Information'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
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

  @override
  void initState() {
    super.initState();
    _localSelectedFees = Map.from(widget.selectedFees);
    _localPartialPaymentAmounts = Map.from(widget.partialPaymentAmounts);

    // Initialize all fee amounts
    _initializeFeeAmounts();

    // Pre-check required fields
    _preCheckRequiredFields();
  }

  void _initializeFeeAmounts() {
    // Initialize base fee amount
    _localPartialPaymentAmounts['Base Fee'] = widget.feeDetails.baseFee ?? 0;

    // Initialize add-on amounts
    if (widget.feeDetails.addOns != null &&
        widget.feeDetails.addOns!.isNotEmpty) {
      for (final addOn in widget.feeDetails.addOns!) {
        final feeName = addOn.name ?? 'Additional Fee';
        final feeAmount = addOn.amount ?? 0;
        _localPartialPaymentAmounts[feeName] = feeAmount;
      }
    }
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
        final feeName = addOn.name ?? 'Additional Fee';
        final isRequired = addOn.compulsory == true;

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
      final classId =
          selectedChild.student?.academicInfo?.currentClass?.id ?? '';

      if (studentId.isEmpty || parentId.isEmpty || classId.isEmpty) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog('Student, parent, or class information not found');
        return;
      }

      // // Get fee record ID
      // final feeRecordId = widget.feeRecord?.id ?? '';
      // if (feeRecordId.isEmpty) {
      //   Navigator.of(context).pop(); // Close loading dialog
      //   _showErrorDialog('Fee record not found');
      //   return;
      // }

      // Calculate total amount
      final totalAmount = _calculateSelectedTotal();

      // Prepare detailed fee breakdown for payment
      final feeBreakdown = _buildFeeBreakdownForPayment();

      // Get current academic year and term from the selected child
      final currentAcademicYear =
          selectedChild.currentTerm?.academicYear ?? "2025/2026";
      final currentTerm = selectedChild.currentTerm?.term ?? "First";

      // Prepare payment data
      final paymentData = {
        "studentId": studentId,
        "parentId": parentId,
        "classId": classId,
        "academicYear": currentAcademicYear,
        "term": currentTerm,
        "paymentType": "Tuition",
        "amount": totalAmount,
        "callbackUrl":
            "http://finesse-developers.web.app/", // Update with your actual callback URL
        "metadata": "School fees payment",
        "description": "$currentTerm term tuition payment",
        "transactionDetails": {
          "transactionId": "TXN${DateTime.now().millisecondsSinceEpoch}",
          "bankName": "Paystack",
          "accountNumber": "N/A",
          "referenceNumber": "REF${DateTime.now().millisecondsSinceEpoch}",
        },
        // "feeRecordId": feeRecordId,
        "feeBreakdown": feeBreakdown, // Add detailed fee breakdown
      };

      // Debug logging for payment data
      print('🔍 DEBUG: ===== PAYMENT DATA WITH CLASS ID =====');
      print('🔍 DEBUG: Student ID: $studentId');
      print('🔍 DEBUG: Parent ID: $parentId');
      print('🔍 DEBUG: Class ID: $classId');
      print('🔍 DEBUG: Academic Year: $currentAcademicYear');
      print('🔍 DEBUG: Term: $currentTerm');
      print('🔍 DEBUG: Total Amount: $totalAmount');
      print('🔍 DEBUG: ===== END PAYMENT DATA =====');

      // Call the initialize payment endpoint
      final paymentRepo = PaymentRepository();
      final response = await paymentRepo.initializePayment(paymentData);
      print(response.data);
      // Close loading dialog
      Navigator.of(context).pop();

      if (HTTPResponseModel.isApiCallSuccess(response) &&
          response.data != null) {
        final data = response.data as Map<String, dynamic>;

        // Debug: Print the response structure
        print('🔍 Parent Dashboard Response: $data');
        print('🔍 Response keys: ${data.keys.toList()}');

        // Extract the payment URL from the nested data object
        // The response structure is: {success: true, message: "...", data: {checkout_url: "..."}}
        final dataObject = data['data'] as Map<String, dynamic>?;
        final paymentUrl = dataObject?['checkout_url'] as String?;
        print('🔍 Extracted payment URL: $paymentUrl');

        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          // Launch the payment URL
          await _launchPaymentUrl(paymentUrl);

          // Show success message
          showSnackbar(
            context,
            'Payment initialized successfully! Redirecting to payment gateway...',
          );

          // Close the payment popup
          Navigator.of(context).pop();

          // Schedule refresh after 25 seconds to fetch updated data
          _scheduleDataRefresh();
        } else {
          _showErrorDialog(
            'Payment initialization failed: No payment URL received',
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
          amount = _getOutstandingAmount(feeName);
        } else {
          amount = _getFeeAmount(feeName);
        }

        feeBreakdown[feeName] = {
          'amount': amount,
          'isRequired': _isRequiredFee(feeName),
          'status': _getFeeStatus(feeName),
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

  /// Schedules a data refresh after 25 seconds to fetch updated data from backend
  void _scheduleDataRefresh() {
    Future.delayed(const Duration(seconds: 25), () async {
      if (mounted) {
        await _refreshParentData();
      }
    });
  }

  /// Refreshes parent data by re-authenticating as if user just logged in
  Future<void> _refreshParentData() async {
    try {
      // Get the parent dashboard context to refresh data
      // Since this is a popup, we need to trigger refresh in the parent screen
      final parentContext = context;

      // Show loading indicator
      showSnackbar(parentContext, 'Refreshing data...');

      // Get the parent login provider from the parent context
      final container = ProviderScope.containerOf(parentContext);
      final parentLoginProvider = container.read(
        RiverpodProvider.parentLoginProvider.notifier,
      );

      // Call refreshData which re-authenticates using saved credentials
      print(
        '🔍 DEBUG: ===== CALLING PARENT LOGIN ENDPOINT FOR PAYMENT REFRESH =====',
      );
      print('🔍 DEBUG: Method: parentLoginProvider.refreshData()');
      print(
        '🔍 DEBUG: This will call: POST /api/auth/login (re-authentication)',
      );
      final success = await parentLoginProvider.refreshData();

      if (success) {
        // Show success notification
        showSnackbar(parentContext, 'Data refreshed successfully!');
        print(
          '🔄 SchoolFeesPaymentPopup: Data refreshed after payment - Success',
        );
      } else {
        // Show error notification
        showSnackbar(
          parentContext,
          'Failed to refresh data. Please try again.',
        );
        print('❌ SchoolFeesPaymentPopup: Data refresh failed');
      }
    } catch (e) {
      print('❌ Error refreshing parent data: $e');
      showSnackbar(context, 'Error refreshing data. Please try again.');
    }
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
                            '£${(widget.feeDetails.baseFee ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
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
                              final addOn = entry.value;
                              final feeName =
                                  addOn.name ?? 'Additional Fee ${index + 1}';
                              final feeAmount = addOn.amount ?? 0;
                              final isRequired = addOn.compulsory == true;

                              return _buildFeeItem(
                                feeName,
                                'Additional fee',
                                '£${feeAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
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
                                    '£${_calculateSelectedTotal().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
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
                                  '£${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
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
                                '£${_calculateSelectedTotal().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
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
        final addOnName = addOn.name ?? 'Additional Fee';
        final isRequired = addOn.compulsory == true;

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

  int _getFeeAmount(String feeName) {
    if (feeName == 'Base Fee') {
      return widget.feeDetails.baseFee ?? 0;
    }

    // Find add-on amount
    if (widget.feeDetails.addOns != null &&
        widget.feeDetails.addOns!.isNotEmpty) {
      for (final addOn in widget.feeDetails.addOns!) {
        final addOnName = addOn.name ?? 'Additional Fee';
        if (addOnName == feeName) {
          return addOn.amount ?? 0;
        }
      }
    }

    return 0;
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
}
