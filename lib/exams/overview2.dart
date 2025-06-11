import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:schmgtsystem/constants/appcolor.dart';

class ExaminationOverviewScreenTwo extends StatefulWidget {
  final Function navigateTo;

  const ExaminationOverviewScreenTwo({super.key, required this.navigateTo});

  @override
  State<ExaminationOverviewScreenTwo> createState() =>
      _ExaminationOverviewScreenState();
}

class _ExaminationOverviewScreenState
    extends State<ExaminationOverviewScreenTwo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Examination Overview',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Monitor student performance and exam analytics',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          widget.navigateTo();
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Create New Exam'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Export Reports'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
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
              const SizedBox(height: 32),

              // Stats Cards
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: ExamStatsCard(
                        title: 'Total Exams',
                        value: '24',
                        change: '+12% this month',
                        changeType: ChangeType.positive,
                        icon: Icons.assignment,
                        iconColor: const Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: ExamStatsCard(
                        title: 'Active Students',
                        value: '1,247',
                        change: '+5% this month',
                        changeType: ChangeType.positive,
                        icon: Icons.people,
                        iconColor: const Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: ExamStatsCard(
                        title: 'Average Score',
                        value: '78.5%',
                        change: '+2.3% from last exam',
                        changeType: ChangeType.positive,
                        icon: Icons.trending_up,
                        iconColor: const Color(0xFF06B6D4),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: ExamStatsCard(
                        title: 'Pass Rate',
                        value: '92.1%',
                        change: '+1.8% improvement',
                        changeType: ChangeType.positive,
                        icon: Icons.check_circle,
                        iconColor: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Charts Section
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Performance Trends Chart
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Performance Trends',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 250,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: true,
                                      horizontalInterval: 10,
                                      verticalInterval: 1,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Colors.grey.withOpacity(0.2),
                                          strokeWidth: 1,
                                        );
                                      },
                                      getDrawingVerticalLine: (value) {
                                        return FlLine(
                                          color: Colors.grey.withOpacity(0.2),
                                          strokeWidth: 1,
                                        );
                                      },
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: false,
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          interval: 1,
                                          getTitlesWidget: (
                                            double value,
                                            TitleMeta meta,
                                          ) {
                                            const style = TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                            );
                                            String text = '';
                                            switch (value.toInt()) {
                                              case 0:
                                                text = 'Jan';
                                                break;
                                              case 1:
                                                text = 'Feb';
                                                break;
                                              case 2:
                                                text = 'Mar';
                                                break;
                                              case 3:
                                                text = 'Apr';
                                                break;
                                              case 4:
                                                text = 'May';
                                                break;
                                              case 5:
                                                text = 'Jun';
                                                break;
                                            }
                                            return SideTitleWidget(
                                              meta: TitleMeta(
                                                min: 2,
                                                max: 6,
                                                parentAxisSize: 3,
                                                axisPosition: 2,
                                                appliedInterval: 33,
                                                sideTitles: SideTitles(),
                                                formattedValue:
                                                    'formattedValue',
                                                axisSide: AxisSide.left,
                                                rotationQuarterTurns: 4,
                                              ),
                                              // axisSide: meta.axisSide,
                                              child: Text(text, style: style),
                                            );
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 20,
                                          getTitlesWidget: (
                                            double value,
                                            TitleMeta meta,
                                          ) {
                                            const style = TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                            );
                                            return Text(
                                              '${value.toInt()}',
                                              style: style,
                                            );
                                          },
                                          reservedSize: 32,
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    minX: 0,
                                    maxX: 5,
                                    minY: 0,
                                    maxY: 100,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: const [
                                          FlSpot(0, 78),
                                          FlSpot(1, 80),
                                          FlSpot(2, 82),
                                          FlSpot(3, 79),
                                          FlSpot(4, 85),
                                          FlSpot(5, 78),
                                        ],
                                        isCurved: true,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF6366F1),
                                            Color(0xFF8B5CF6),
                                          ],
                                        ),
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter: (
                                            spot,
                                            percent,
                                            barData,
                                            index,
                                          ) {
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
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(
                                                0xFF6366F1,
                                              ).withOpacity(0.1),
                                              const Color(
                                                0xFF8B5CF6,
                                              ).withOpacity(0.05),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
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
                      ),
                      const SizedBox(width: 16),

                      // Subject Performance Pie Chart
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Subject Performance',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 60,
                                    sections: [
                                      PieChartSectionData(
                                        color: const Color(0xFF6366F1),
                                        value: 30,
                                        title: '',
                                        radius: 40,
                                      ),
                                      PieChartSectionData(
                                        color: const Color(0xFF8B5CF6),
                                        value: 25,
                                        title: '',
                                        radius: 40,
                                      ),
                                      PieChartSectionData(
                                        color: const Color(0xFF06B6D4),
                                        value: 15,
                                        title: '',
                                        radius: 40,
                                      ),
                                      PieChartSectionData(
                                        color: const Color(0xFF10B981),
                                        value: 20,
                                        title: '',
                                        radius: 40,
                                      ),
                                      PieChartSectionData(
                                        color: const Color(0xFFF59E0B),
                                        value: 10,
                                        title: '',
                                        radius: 40,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Legend
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  _buildLegendItem(
                                    'Mathematics',
                                    const Color(0xFF6366F1),
                                  ),
                                  _buildLegendItem(
                                    'English',
                                    const Color(0xFF8B5CF6),
                                  ),
                                  _buildLegendItem(
                                    'Science',
                                    const Color(0xFF06B6D4),
                                  ),
                                  _buildLegendItem(
                                    'History',
                                    const Color(0xFF10B981),
                                  ),
                                  _buildLegendItem(
                                    'Art',
                                    const Color(0xFFF59E0B),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Recent Examinations and Quick Actions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recent Examinations
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Recent Examinations',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'View All',
                                      style: TextStyle(
                                        color: Color(0xFF6366F1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Table Header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'EXAM',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'SUBJECT',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'CLASS',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'DATE',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'STATUS',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Table Rows
                              _buildExamRow(
                                'Mid-term Mathematics',
                                'Mathematics',
                                'Grade 10A',
                                'Dec 15, 2024',
                                ExamStatus.completed,
                              ),
                              _buildExamRow(
                                'English Literature Quiz',
                                'English',
                                'Grade 11B',
                                'Dec 18, 2024',
                                ExamStatus.scheduled,
                              ),
                              _buildExamRow(
                                'Science Practical',
                                'Physics',
                                'Grade 12A',
                                'Dec 20, 2024',
                                ExamStatus.inProgress,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Quick Actions and Top Performers
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            // Quick Actions
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quick Actions',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildQuickAction(
                                    Icons.add,
                                    'Create Exam',
                                    () {},
                                  ),
                                  _buildQuickAction(
                                    Icons.person_add,
                                    'Add Student',
                                    () {},
                                  ),
                                  _buildQuickAction(
                                    Icons.book,
                                    'Manage Subjects',
                                    () {},
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Top Performers
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Top Performers',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTopPerformer(
                                    'Sarah Johnson',
                                    'Grade 10A',
                                    '95.2%',
                                    Colors.blue,
                                  ),
                                  _buildTopPerformer(
                                    'Michael Chen',
                                    'Grade 11B',
                                    '94.8%',
                                    Colors.green,
                                  ),
                                  _buildTopPerformer(
                                    'Emma Davis',
                                    'Grade 12A',
                                    '93.7%',
                                    Colors.purple,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Floating Action Button
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {},
                  backgroundColor: const Color(0xFF6366F1),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildExamRow(
    String exam,
    String subject,
    String className,
    String date,
    ExamStatus status,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              exam,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(subject, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(className, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(date, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(status),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildTopPerformer(
    String name,
    String grade,
    String score,
    Color avatarColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor.withOpacity(0.1),
            child: Text(
              name.substring(0, 1),
              style: TextStyle(color: avatarColor, fontWeight: FontWeight.w600),
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
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$grade - $score',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ExamStatus status) {
    switch (status) {
      case ExamStatus.completed:
        return Colors.green;
      case ExamStatus.scheduled:
        return Colors.orange;
      case ExamStatus.inProgress:
        return Colors.blue;
    }
  }

  String _getStatusText(ExamStatus status) {
    switch (status) {
      case ExamStatus.completed:
        return 'Completed';
      case ExamStatus.scheduled:
        return 'Scheduled';
      case ExamStatus.inProgress:
        return 'In Progress';
    }
  }
}

enum ChangeType { positive, negative }

enum ExamStatus { completed, scheduled, inProgress }

class ExamStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final ChangeType changeType;
  final IconData icon;
  final Color iconColor;

  const ExamStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.changeType,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                changeType == ChangeType.positive
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 16,
                color:
                    changeType == ChangeType.positive
                        ? Colors.green
                        : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      changeType == ChangeType.positive
                          ? Colors.green
                          : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
