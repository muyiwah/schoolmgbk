import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/providers/provider.dart';

class MetricScreen extends ConsumerStatefulWidget {
  final Function navigateTo;
  MetricScreen({super.key, required this.navigateTo});

  @override
  ConsumerState<MetricScreen> createState() => _MetricScreenState();
}

class _MetricScreenState extends ConsumerState<MetricScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _animationController.forward();

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
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isMobile = screenWidth < 768;
            final isTablet = screenWidth >= 768 && screenWidth < 1024;
            final isDesktop = screenWidth >= 1024;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Column(
                children: [
                  _buildHeader(isMobile),
                  SizedBox(height: isMobile ? 24 : 32),
                  _buildStatsCards(isMobile, isTablet, isDesktop),
                  SizedBox(height: isMobile ? 24 : 32),
                  _buildChartsSection(isMobile, isTablet),
                  SizedBox(height: isMobile ? 24 : 32),
                  _buildQuickActions(isMobile),
                  SizedBox(height: isMobile ? 24 : 32),
                  _buildFeatureCards(isMobile, isTablet),
                  SizedBox(height: isMobile ? 24 : 32),
                  _buildRecentActivity(isMobile),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
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
                          'Dashboard',
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'LoveSpring Dashboard',
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
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
                SizedBox(height: isMobile ? 16 : 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          widget.navigateTo();
                        },
                        icon: Icon(Icons.analytics, size: isMobile ? 16 : 18),
                        label: Text(isMobile ? 'Analytics' : 'View Analytics'),
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
                      label: Text(isMobile ? 'Refresh' : 'Refresh'),
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
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(bool isMobile, bool isTablet, bool isDesktop) {
    final metricsProvider = ref.watch(RiverpodProvider.metricsProvider);
    final metrics = metricsProvider.comprehensiveMetrics;

    // Use real data from metrics or fallback to default values
    final statsData = [
      {
        'title': 'Total Students',
        'value': _formatNumber(metrics?.data.overview.totalStudents ?? 1247),
        'change': '+12%', // This could come from metrics comparison
        'changeText': 'from last month',
        'changeColor': const Color(0xFF10B981),
        'icon': Icons.people,
        'iconColor': const Color(0xFF6366F1),
        'gradient': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      },
      {
        'title': 'Active Teachers',
        'value': _formatNumber(metrics?.data.overview.totalStaff ?? 87),
        'change': '+3%', // This could come from metrics comparison
        'changeText': 'from last month',
        'changeColor': const Color(0xFF10B981),
        'icon': Icons.school,
        'iconColor': const Color(0xFF8B5CF6),
        'gradient': [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
      },
      {
        'title': 'Total Classes',
        'value': _formatNumber(metrics?.data.overview.totalClasses ?? 9),
        'change': 'Active',
        'changeText': 'classes available',
        'changeColor': const Color(0xFF10B981),
        'icon': Icons.class_,
        'iconColor': const Color(0xFF06B6D4),
        'gradient': [const Color(0xFF06B6D4), const Color(0xFF0891B2)],
      },
      {
        'title': 'Outstanding Fees',
        'value': _formatCurrency(
          metrics?.data.finances.outstanding.total ?? 191800,
        ),
        'change':
            '${metrics?.data.finances.feeStatus.where((f) => f.id == 'unpaid').first.count ?? 14} students',
        'changeText': 'unpaid fees',
        'changeColor': const Color(0xFFEF4444),
        'icon': Icons.attach_money,
        'iconColor': const Color(0xFF10B981),
        'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
      },
    ];

    int crossAxisCount;
    double childAspectRatio;
    double spacing;

    if (isMobile) {
      crossAxisCount = 2;
      childAspectRatio = 1.2;
      spacing = 12;
    } else if (isTablet) {
      crossAxisCount = 3;
      childAspectRatio = 1.1;
      spacing = 16;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 1.1;
      spacing = 20;
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: statsData.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value * (index + 1)),
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: _buildStatCard(
                  title: statsData[index]['title'] as String,
                  value: statsData[index]['value'] as String,
                  change: statsData[index]['change'] as String,
                  changeText: statsData[index]['changeText'] as String,
                  changeColor: statsData[index]['changeColor'] as Color,
                  icon: statsData[index]['icon'] as IconData,
                  iconColor: statsData[index]['iconColor'] as Color,
                  gradient: statsData[index]['gradient'] as List<Color>,
                  isMobile: isMobile,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required String changeText,
    required Color changeColor,
    required IconData icon,
    required Color iconColor,
    required List<Color> gradient,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
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
                    fontSize: isMobile ? 12 : 14,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: isMobile ? 16 : 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: isMobile ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  changeText,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(bool isMobile, bool isTablet) {
    if (isMobile) {
      return Column(
        children: [
          _buildAttendanceChart(isMobile),
          const SizedBox(height: 16),
          _buildRevenueChart(isMobile),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _buildAttendanceChart(isMobile)),
          SizedBox(width: isTablet ? 16 : 24),
          Expanded(child: _buildRevenueChart(isMobile)),
        ],
      );
    }
  }

  Widget _buildAttendanceChart(bool isMobile) {
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
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          SizedBox(
            height: isMobile ? 150 : 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE5E7EB),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 95),
                      FlSpot(1, 92),
                      FlSpot(2, 97),
                      FlSpot(3, 94),
                      FlSpot(4, 98),
                      FlSpot(5, 88),
                      FlSpot(6, 90),
                    ],
                    isCurved: true,
                    color: const Color(0xFF6366F1),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF6366F1),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(bool isMobile) {
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
            'Revenue vs Expenses',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          SizedBox(
            height: isMobile ? 150 : 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 70000,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                        ];
                        if (value.toInt() >= 0 &&
                            value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()],
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10000,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toInt()}K',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildBarGroup(0, 45000, 38000),
                  _buildBarGroup(1, 52000, 43000),
                  _buildBarGroup(2, 48000, 45000),
                  _buildBarGroup(3, 62000, 48000),
                  _buildBarGroup(4, 55000, 44000),
                  _buildBarGroup(5, 49000, 42000),
                ],
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE5E7EB),
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildLegendItem('Revenue', const Color(0xFF06B6D4)),
              const SizedBox(width: 24),
              _buildLegendItem('Expenses', AppColors.secondary),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double revenue, double expenses) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: revenue,
          color: const Color(0xFF06B6D4),
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        BarChartRodData(
          toY: expenses,
          color: const Color(0xFF8B5CF6),
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
      barsSpace: 4,
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildQuickActions(bool isMobile) {
    final actions = [
      {
        'title': 'Add Student',
        'icon': Icons.person_add,
        'color': const Color(0xFF6366F1),
      },
      {
        'title': 'Mark Attendance',
        'icon': Icons.check_circle,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Create Exam',
        'icon': Icons.quiz,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'View Reports',
        'icon': Icons.analytics,
        'color': const Color(0xFF06B6D4),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Row(
          children:
              actions.map((action) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: isMobile ? 8 : 12),
                    child: _buildQuickActionCard(
                      title: action['title'] as String,
                      icon: action['icon'] as IconData,
                      color: action['color'] as Color,
                      isMobile: isMobile,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
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
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: isMobile ? 16 : 20, color: color),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(bool isMobile) {
    final metricsProvider = ref.watch(RiverpodProvider.metricsProvider);
    final metrics = metricsProvider.comprehensiveMetrics;

    // Create activities based on real metrics data
    final activities = [
      {
        'title': 'Recent Payments',
        'time':
            '${metrics?.data.finances.recentPayments.transactions ?? 0} transactions',
        'icon': Icons.payment,
      },
      {
        'title': 'Payment Amount',
        'time': _formatCurrency(
          metrics?.data.finances.recentPayments.amount ?? 0,
        ),
        'icon': Icons.attach_money,
      },
      {
        'title': 'Enrollment Rate',
        'time': '${metrics?.data.academics.classes.enrollment.rate ?? '0'}%',
        'icon': Icons.trending_up,
      },
      {
        'title': 'Capacity Utilization',
        'time':
            '${metrics?.data.academics.classes.enrollment.utilization ?? '0'}%',
        'icon': Icons.pie_chart,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children:
                activities.map((activity) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isMobile ? 6 : 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            activity['icon'] as IconData,
                            size: isMobile ? 14 : 16,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                        SizedBox(width: isMobile ? 8 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity['title'] as String,
                                style: TextStyle(
                                  fontSize: isMobile ? 13 : 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              Text(
                                activity['time'] as String,
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCards(bool isMobile, bool isTablet) {
    int crossAxisCount;
    double childAspectRatio;
    double spacing;

    if (isMobile) {
      crossAxisCount = 1;
      childAspectRatio = 1.3;
      spacing = 12;
    } else if (isTablet) {
      crossAxisCount = 2;
      childAspectRatio = 1.2;
      spacing = 16;
    } else {
      crossAxisCount = 3;
      childAspectRatio = 1.1;
      spacing = 20;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
          children: [
            _buildFeatureCard(
              title: 'Student Management',
              description:
                  'Comprehensive student records, enrollment tracking, and academic progress monitoring.',
              icon: Icons.people,
              iconColor: const Color(0xFF6366F1),
              isMobile: isMobile,
            ),
            _buildFeatureCard(
              title: 'Academic Tracking',
              description:
                  'Real-time grade tracking, assignment management, and performance analytics.',
              icon: Icons.assignment,
              iconColor: const Color(0xFF8B5CF6),
              isMobile: isMobile,
            ),
            _buildFeatureCard(
              title: 'Financial Management',
              description:
                  'Fee collection, expense tracking, and comprehensive financial reporting.',
              icon: Icons.account_balance,
              iconColor: const Color(0xFF06B6D4),
              isMobile: isMobile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required bool isMobile,
    bool hasAction = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.1),
                  iconColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: isMobile ? 20 : 24, color: iconColor),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              color: const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          if (hasAction) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Manage Finances'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF06B6D4),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
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
    if (amount == null) return '\$0';
    final numAmount =
        amount is num ? amount : double.tryParse(amount.toString()) ?? 0;
    return '\$${numAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }
}
