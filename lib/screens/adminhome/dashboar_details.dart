import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/providers/provider.dart';

class DashboardDetails extends ConsumerStatefulWidget {
  final Function navigateBack;
  const DashboardDetails({super.key, required this.navigateBack});

  @override
  ConsumerState<DashboardDetails> createState() => _DashboardDetailsState();
}

class _DashboardDetailsState extends ConsumerState<DashboardDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedClass = 'All Classes';
  String selectedDepartment = 'All Departments';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Load metrics data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMetrics();
    });
  }

  Future<void> _loadMetrics() async {
    final metricsProvider = ref.read(RiverpodProvider.metricsProvider);
    await metricsProvider.getComprehensiveMetrics();
  }

  Future<void> _refreshMetrics() async {
    await _loadMetrics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isMobile = screenWidth < 768;
          final isTablet = screenWidth >= 768 && screenWidth < 1024;
          final isDesktop = screenWidth >= 1024;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(isMobile),
                _buildFilters(isMobile),
                _buildMetricsRow(isMobile, isTablet, isDesktop),
                _buildTabBar(isMobile),
                SizedBox(
                  height: isMobile ? 600 : 800,
                  child: _buildTabContent(isMobile, isTablet),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics Dashboard',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comprehensive school performance insights',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: Colors.grey[600],
                      size: isMobile ? 20 : 24,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(isMobile ? 8 : 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: isMobile ? 36 : 40,
                    height: isMobile ? 36 : 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[600],
                      size: isMobile ? 18 : 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isMobile ? 20 : 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.navigateBack();
                  },
                  icon: Icon(Icons.home, size: isMobile ? 16 : 18),
                  label: Text(isMobile ? 'Back' : 'Back to Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: isMobile ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _refreshMetrics,
                icon: Icon(Icons.refresh, size: isMobile ? 16 : 18),
                label: Text(isMobile ? 'Refresh' : 'Refresh Data'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 10 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isMobile) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDropdown('All Classes', [
                    'All Classes',
                    'Grade 1',
                    'Grade 2',
                    'Grade 3',
                  ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown('All Departments', [
                    'All Departments',
                    'Mathematics',
                    'Science',
                    'English',
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDatePicker()),
                const SizedBox(width: 12),
                _buildActionButton(
                  'Refresh',
                  Icons.refresh,
                  const Color(0xFF6C5CE7),
                ),
                const SizedBox(width: 8),
                _buildActionButton('Print', Icons.print, Colors.grey[600]!),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildDropdown('All Classes', [
              'All Classes',
              'Grade 1',
              'Grade 2',
              'Grade 3',
            ]),
            const SizedBox(width: 16),
            _buildDropdown('All Departments', [
              'All Departments',
              'Mathematics',
              'Science',
              'English',
            ]),
            const SizedBox(width: 16),
            _buildDatePicker(),
            const Spacer(),
            _buildActionButton(
              'Refresh',
              Icons.refresh,
              const Color(0xFF6C5CE7),
            ),
            const SizedBox(width: 12),
            _buildActionButton('Print', Icons.print, Colors.grey[600]!),
          ],
        ),
      );
    }
  }

  Widget _buildDropdown(String value, List<String> items) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: TextStyle(fontSize: 14)),
                );
              }).toList(),
          onChanged: (String? newValue) {},
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Text('mm/dd/yyyy', style: TextStyle(color: Colors.grey[600])),
          SizedBox(width: 8),
          Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.white, size: 16),
      label: Text(text, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
    );
  }

  Widget _buildMetricsRow(bool isMobile, bool isTablet, bool isDesktop) {
    final metricsProvider = ref.watch(RiverpodProvider.metricsProvider);
    final metrics = metricsProvider.comprehensiveMetrics;

    // Use real data from metrics or fallback to default values
    final metricsData = [
      {
        'title': 'Total Students',
        'value': _formatNumber(metrics?.data.overview.totalStudents ?? 19),
        'change': '+5.2%',
        'icon': Icons.people,
        'color': Colors.blue,
      },
      {
        'title': 'Total Staff',
        'value': _formatNumber(metrics?.data.overview.totalStaff ?? 6),
        'change': 'Active',
        'icon': Icons.school,
        'color': Colors.purple,
      },
      {
        'title': 'Total Classes',
        'value': _formatNumber(metrics?.data.overview.totalClasses ?? 9),
        'change': 'Active',
        'icon': Icons.class_,
        'color': Colors.teal,
      },
      {
        'title': 'Outstanding Fees',
        'value': _formatCurrency(
          metrics?.data.finances.outstanding.total ?? 191800,
        ),
        'change': '+12.3%',
        'icon': Icons.attach_money,
        'color': Colors.green,
      },
      {
        'title': 'Enrollment Rate',
        'value':
            '${metrics?.data.academics.classes.enrollment.rate ?? '3.14'}%',
        'change': '+2.1%',
        'icon': Icons.trending_up,
        'color': Colors.blue,
      },
      {
        'title': 'Capacity Utilization',
        'value':
            '${metrics?.data.academics.classes.enrollment.utilization ?? '2.86'}%',
        'change': '+3.2%',
        'icon': Icons.pie_chart,
        'color': Colors.indigo,
      },
    ];

    int crossAxisCount;
    double spacing;

    if (isMobile) {
      crossAxisCount = 2;
      spacing = 12;
    } else if (isTablet) {
      crossAxisCount = 3;
      spacing = 16;
    } else {
      crossAxisCount = 6;
      spacing = 16;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: isMobile ? 1.2 : 1.1,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: metricsData.length,
        itemBuilder: (context, index) {
          return _buildMetricCard(
            metricsData[index]['title'] as String,
            metricsData[index]['value'] as String,
            metricsData[index]['change'] as String,
            metricsData[index]['icon'] as IconData,
            metricsData[index]['color'] as Color,
            isMobile: isMobile,
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color color, {
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isMobile ? 11 : 13,
                  ),
                ),
              ),
              Icon(icon, color: color, size: isMobile ? 20 : 24),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: TextStyle(
              color: change.startsWith('+') ? Colors.green : Colors.grey[600],
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF6C5CE7),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFF6C5CE7),
        indicatorWeight: 3,
        isScrollable: isMobile,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people, size: isMobile ? 16 : 18),
                SizedBox(width: isMobile ? 6 : 8),
                Text(isMobile ? 'Students' : 'Students'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school, size: isMobile ? 16 : 18),
                SizedBox(width: isMobile ? 6 : 8),
                Text(isMobile ? 'Staff' : 'Teachers & Staff'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_balance_wallet, size: isMobile ? 16 : 18),
                SizedBox(width: isMobile ? 6 : 8),
                Text('Accounts'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_available, size: isMobile ? 16 : 18),
                SizedBox(width: isMobile ? 6 : 8),
                Text('Attendance'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings, size: isMobile ? 16 : 18),
                SizedBox(width: isMobile ? 6 : 8),
                Text('Operations'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(bool isMobile, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildStudentsTab(isMobile, isTablet),
          _buildTeachersStaffTab(isMobile, isTablet),
          _buildAccountsTab(isMobile, isTablet),
          _buildAttendanceTab(isMobile, isTablet),
          _buildOperationsTab(isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildStudentsTab(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: [
          _buildEnrollmentCard(isMobile),
          const SizedBox(height: 16),
          _buildNewAdmissionsCard(isMobile),
          const SizedBox(height: 16),
          _buildLowAttendanceCard(isMobile),
          const SizedBox(height: 16),
          _buildOutstandingFeesCard(isMobile),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildEnrollmentCard(isMobile),
                const SizedBox(height: 16),
                _buildNewAdmissionsCard(isMobile),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildLowAttendanceCard(isMobile),
                const SizedBox(height: 16),
                _buildOutstandingFeesCard(isMobile),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildTeachersStaffTab(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: [
          _buildTeachersByDepartmentCard(isMobile),
          const SizedBox(height: 16),
          _buildRecentHiresCard(isMobile),
          const SizedBox(height: 16),
          _buildStaffPerformanceCard(isMobile),
          const SizedBox(height: 16),
          _buildUpcomingEvaluationsCard(isMobile),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildTeachersByDepartmentCard(isMobile),
                const SizedBox(height: 16),
                _buildRecentHiresCard(isMobile),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildStaffPerformanceCard(isMobile),
                const SizedBox(height: 16),
                _buildUpcomingEvaluationsCard(isMobile),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildAccountsTab(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: [
          _buildRevenueBreakdownCard(isMobile),
          const SizedBox(height: 16),
          _buildMonthlyExpensesCard(isMobile),
          const SizedBox(height: 16),
          _buildPendingPaymentsCard(isMobile),
          const SizedBox(height: 16),
          _buildBudgetOverviewCard(isMobile),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildRevenueBreakdownCard(isMobile),
                const SizedBox(height: 16),
                _buildMonthlyExpensesCard(isMobile),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildPendingPaymentsCard(isMobile),
                const SizedBox(height: 16),
                _buildBudgetOverviewCard(isMobile),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildAttendanceTab(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: [
          _buildAttendanceTrendsCard(isMobile),
          const SizedBox(height: 16),
          _buildClassAttendanceCard(isMobile),
          const SizedBox(height: 16),
          _buildAbsentStudentsCard(isMobile),
          const SizedBox(height: 16),
          _buildAttendanceAlertsCard(isMobile),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildAttendanceTrendsCard(isMobile),
                const SizedBox(height: 16),
                _buildClassAttendanceCard(isMobile),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildAbsentStudentsCard(isMobile),
                const SizedBox(height: 16),
                _buildAttendanceAlertsCard(isMobile),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildOperationsTab(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: [
          _buildFacilitiesStatusCard(isMobile),
          const SizedBox(height: 16),
          _buildMaintenanceRequestsCard(isMobile),
          const SizedBox(height: 16),
          _buildTransportationCard(isMobile),
          const SizedBox(height: 16),
          _buildInventoryStatusCard(isMobile),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildFacilitiesStatusCard(isMobile),
                const SizedBox(height: 16),
                _buildMaintenanceRequestsCard(isMobile),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildTransportationCard(isMobile),
                const SizedBox(height: 16),
                _buildInventoryStatusCard(isMobile),
              ],
            ),
          ),
        ],
      );
    }
  }

  // Students Tab Cards (existing)
  Widget _buildEnrollmentCard(bool isMobile) {
    final metricsProvider = ref.watch(RiverpodProvider.metricsProvider);
    final metrics = metricsProvider.comprehensiveMetrics;
    final enrollmentByClass =
        metrics?.data.academics.classes.enrollment.byClass ?? [];

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Enrollment by Class',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          if (enrollmentByClass.isNotEmpty)
            ...enrollmentByClass
                .take(5)
                .map(
                  (classData) => _buildEnrollmentRow(
                    classData.level,
                    classData.count,
                    isMobile,
                  ),
                )
                .toList()
          else
            ...[
              'Grade 1',
              'Grade 2',
              'Grade 3',
            ].map((grade) => _buildEnrollmentRow(grade, 0, isMobile)).toList(),
        ],
      ),
    );
  }

  Widget _buildEnrollmentRow(String grade, int students, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            grade,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            '$students students',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewAdmissionsCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'New Admissions',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            '67',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6C5CE7),
            ),
          ),
          Text(
            'This term',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowAttendanceCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Low Attendance Students',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildAttendanceRow('John Smith', '67%', isMobile),
          _buildAttendanceRow('Sarah Johnson', '72%', isMobile),
          _buildAttendanceRow('Mike Davis', '69%', isMobile),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(String name, String percentage, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutstandingFeesCard(bool isMobile) {
    final metricsProvider = ref.watch(RiverpodProvider.metricsProvider);
    final metrics = metricsProvider.comprehensiveMetrics;
    final outstandingTotal = metrics?.data.finances.outstanding.total ?? 0;
    final unpaidCount =
        metrics?.data.finances.feeStatus
            .where((f) => f.id == 'unpaid')
            .firstOrNull
            ?.count ??
        0;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Outstanding Fees',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            _formatCurrency(outstandingTotal),
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          Text(
            '$unpaidCount students',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Teachers & Staff Tab Cards
  Widget _buildTeachersByDepartmentCard(bool isMobile) {
    final metricsProvider = ref.watch(RiverpodProvider.metricsProvider);
    final metrics = metricsProvider.comprehensiveMetrics;
    final staffByDepartment = metrics?.data.staff.byDepartment ?? [];

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Teachers by Department',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          if (staffByDepartment.isNotEmpty)
            ...staffByDepartment
                .map(
                  (dept) => _buildDepartmentRow(
                    dept.id,
                    dept.count,
                    _getDepartmentColor(dept.id),
                    isMobile,
                  ),
                )
                .toList()
          else
            ...['Mathematics', 'Science', 'English']
                .map(
                  (dept) => _buildDepartmentRow(
                    dept,
                    0,
                    _getDepartmentColor(dept),
                    isMobile,
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

  Color _getDepartmentColor(String department) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.yellow,
      Colors.pink,
      Colors.deepPurpleAccent,
    ];
    return colors[department.hashCode % colors.length];
  }

  Widget _buildDepartmentRow(
    String department,
    int count,
    Color color,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: Row(
        children: [
          Container(
            width: isMobile ? 10 : 12,
            height: isMobile ? 10 : 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Text(
              department,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            '$count teachers',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHiresCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Recent Hires',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildStaffRow(
            'Dr. Emily Watson',
            'Mathematics',
            'Jan 2025',
            isMobile,
          ),
          _buildStaffRow('Mr. James Liu', 'Science', 'Dec 2024', isMobile),
          _buildStaffRow('Ms. Anna Rodriguez', 'English', 'Nov 2024', isMobile),
        ],
      ),
    );
  }

  Widget _buildStaffRow(
    String name,
    String department,
    String date,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                department,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaffPerformanceCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Staff Performance',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildPerformanceRow('Excellent', 45, Colors.green, isMobile),
          _buildPerformanceRow('Good', 18, Colors.blue, isMobile),
          _buildPerformanceRow('Needs Improvement', 4, Colors.orange, isMobile),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(
    String rating,
    int count,
    Color color,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: Row(
        children: [
          Container(
            width: isMobile ? 10 : 12,
            height: isMobile ? 10 : 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Text(
              rating,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            '$count staff',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvaluationsCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Upcoming Evaluations',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            '12',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6C5CE7),
            ),
          ),
          Text(
            'This month',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Accounts Tab Cards
  Widget _buildRevenueBreakdownCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Revenue Breakdown',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildRevenueRow('Tuition Fees', '£420,000', Colors.green, isMobile),
          _buildRevenueRow('Activity Fees', '£45,000', Colors.blue, isMobile),
          _buildRevenueRow(
            'Transport Fees',
            '£22,000',
            Colors.orange,
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueRow(
    String source,
    String amount,
    Color color,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: Row(
        children: [
          Container(
            width: isMobile ? 10 : 12,
            height: isMobile ? 10 : 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Text(
              source,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyExpensesCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Monthly Expenses',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildExpenseRow('Salaries', '£125,000', isMobile),
          _buildExpenseRow('Utilities', '£15,500', isMobile),
          _buildExpenseRow('Maintenance', '£8,200', isMobile),
        ],
      ),
    );
  }

  Widget _buildExpenseRow(String category, String amount, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPaymentsCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Pending Payments',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildPaymentRow(
            'Vendor Payments',
            '£8,450',
            'Due in 5 days',
            isMobile,
          ),
          _buildPaymentRow(
            'Staff Bonuses',
            '£15,200',
            'Due in 2 days',
            isMobile,
          ),
          _buildPaymentRow(
            'Equipment Purchase',
            '£32,100',
            'Due in 10 days',
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    String description,
    String amount,
    String dueDate,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dueDate,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetOverviewCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Budget Overview',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            '78%',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6C5CE7),
            ),
          ),
          Text(
            'Budget utilized',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          LinearProgressIndicator(
            value: 0.78,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
          ),
        ],
      ),
    );
  }

  // Attendance Tab Cards
  Widget _buildAttendanceTrendsCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Weekly Attendance Trends',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildTrendRow('Monday', '96.2%', Colors.green, isMobile),
          _buildTrendRow('Tuesday', '94.8%', Colors.green, isMobile),
          _buildTrendRow('Wednesday', '93.1%', Colors.orange, isMobile),
          _buildTrendRow('Thursday', '95.5%', Colors.green, isMobile),
          _buildTrendRow('Friday', '89.3%', Colors.red, isMobile),
        ],
      ),
    );
  }

  Widget _buildTrendRow(
    String day,
    String percentage,
    Color color,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
      child: Row(
        children: [
          SizedBox(
            width: isMobile ? 60 : 80,
            child: Text(
              day,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: isMobile ? 6 : 8,
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: double.parse(percentage.replaceAll('%', '')) / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassAttendanceCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Class Attendance Today',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildClassAttendanceRow('Grade 1A', 28, 32, isMobile),
          _buildClassAttendanceRow('Grade 1B', 30, 32, isMobile),
          _buildClassAttendanceRow('Grade 2A', 29, 31, isMobile),
          _buildClassAttendanceRow('Grade 2B', 27, 30, isMobile),
        ],
      ),
    );
  }

  Widget _buildClassAttendanceRow(
    String className,
    int present,
    int total,
    bool isMobile,
  ) {
    double percentage = (present / total) * 100;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: Row(
        children: [
          SizedBox(
            width: isMobile ? 60 : 80,
            child: Text(
              className,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              '$present/$total',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color:
                  percentage >= 90
                      ? Colors.green
                      : percentage >= 80
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsentStudentsCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Absent Students Today',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildAbsentStudentRow(
            'Emma Wilson',
            'Grade 2A',
            'Sick Leave',
            isMobile,
          ),
          _buildAbsentStudentRow(
            'David Chen',
            'Grade 1B',
            'Family Emergency',
            isMobile,
          ),
          _buildAbsentStudentRow(
            'Lisa Brown',
            'Grade 2B',
            'Medical Appointment',
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildAbsentStudentRow(
    String name,
    String className,
    String reason,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                className,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                reason,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceAlertsCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Attendance Alerts',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            '8',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          Text(
            'Students below 75%',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Operations Tab Cards
  Widget _buildFacilitiesStatusCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Facilities Status',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildFacilityRow(
            'Classrooms',
            'Operational',
            Colors.green,
            isMobile,
          ),
          _buildFacilityRow('Library', 'Operational', Colors.green, isMobile),
          _buildFacilityRow(
            'Cafeteria',
            'Under Maintenance',
            Colors.orange,
            isMobile,
          ),
          _buildFacilityRow(
            'Playground',
            'Operational',
            Colors.green,
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityRow(
    String facility,
    String status,
    Color color,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: Row(
        children: [
          Container(
            width: isMobile ? 10 : 12,
            height: isMobile ? 10 : 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Text(
              facility,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceRequestsCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Maintenance Requests',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildMaintenanceRow('AC Unit Repair', 'Room 12', 'High', isMobile),
          _buildMaintenanceRow(
            'Plumbing Issue',
            'Restroom B',
            'Medium',
            isMobile,
          ),
          _buildMaintenanceRow('Light Fixture', 'Hallway', 'Low', isMobile),
        ],
      ),
    );
  }

  Widget _buildMaintenanceRow(
    String issue,
    String location,
    String priority,
    bool isMobile,
  ) {
    Color priorityColor =
        priority == 'High'
            ? Colors.red
            : priority == 'Medium'
            ? Colors.orange
            : Colors.green;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            issue,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                location,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey[600],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: isMobile ? 1 : 2,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w600,
                    color: priorityColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransportationCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Transportation',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _buildTransportRow('Bus Route A', '45 students', 'On Time', isMobile),
          _buildTransportRow('Bus Route B', '38 students', 'Delayed', isMobile),
          _buildTransportRow('Bus Route C', '42 students', 'On Time', isMobile),
        ],
      ),
    );
  }

  Widget _buildTransportRow(
    String route,
    String capacity,
    String status,
    bool isMobile,
  ) {
    Color statusColor = status == 'On Time' ? Colors.green : Colors.red;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            route,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                capacity,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryStatusCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
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
          Text(
            'Inventory Status',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            '5',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.orange[600],
            ),
          ),
          Text(
            'Items low in stock',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            'Textbooks, Stationery, Cleaning Supplies',
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for formatting data
  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final numValue =
        number is num ? number : double.tryParse(number.toString()) ?? 0;
    return numValue
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '£0';
    final numAmount =
        amount is num ? amount : double.tryParse(amount.toString()) ?? 0;
    if (numAmount >= 1000000) {
      return '£${(numAmount / 1000000).toStringAsFixed(1)}M';
    } else if (numAmount >= 1000) {
      return '£${(numAmount / 1000).toStringAsFixed(1)}K';
    } else {
      return '£${numAmount.toStringAsFixed(0)}';
    }
  }
}
