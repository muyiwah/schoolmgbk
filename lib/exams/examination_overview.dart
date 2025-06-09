import 'package:flutter/material.dart';
import 'dart:math' as math;


class ExaminationOverviewPage extends StatefulWidget {
  const ExaminationOverviewPage({super.key});

  @override
  State<ExaminationOverviewPage> createState() =>
      _ExaminationOverviewPageState();
}

class _ExaminationOverviewPageState extends State<ExaminationOverviewPage> {
  final List<Examination> _examinations = [
    Examination(
      name: 'Mathematics Final',
      subject: 'Mathematics',
      className: 'Grade 10A',
      date: DateTime(2024, 12, 15),
      status: ExamStatus.completed,
    ),
    Examination(
      name: 'Physics Quiz',
      subject: 'Physics',
      className: 'Grade 11B',
      date: DateTime(2024, 12, 18),
      status: ExamStatus.scheduled,
    ),
    Examination(
      name: 'Chemistry Lab Test',
      subject: 'Chemistry',
      className: 'Grade 12A',
      date: DateTime(2024, 12, 20),
      status: ExamStatus.inProgress,
    ),
  ];

  final List<SubjectPerformance> _subjectPerformances = [
    SubjectPerformance(
      subject: 'Mathematics',
      averageScore: 82.4,
      studentCount: 156,
      color: const Color(0xFF6366F1),
      icon: Icons.calculate,
    ),
    SubjectPerformance(
      subject: 'Physics',
      averageScore: 76.8,
      studentCount: 142,
      color: const Color(0xFF8B5CF6),
      icon: Icons.science,
    ),
    SubjectPerformance(
      subject: 'Chemistry',
      averageScore: 79.2,
      studentCount: 138,
      color: const Color(0xFF10B981),
      icon: Icons.biotech,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeroSection(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCards(),
                    const SizedBox(height: 32),
                    _buildChartsSection(),
                    const SizedBox(height: 32),
                    _buildRecentExaminationsSection(),
                    const SizedBox(height: 32),
                    _buildSubjectPerformanceSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Examination Overview',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Monitor student performance, manage exams, and track academic\nprogress with comprehensive analytics and insights.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Create New Exam'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF6366F1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.trending_up, size: 18),
                            label: const Text('View Performance Reports'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white70),
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
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Students',
            '1,247',
            const Color(0xFF6366F1),
            Icons.people,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Active Exams',
            '23',
            const Color(0xFF8B5CF6),
            Icons.quiz,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Average Score',
            '78.5%',
            const Color(0xFF06B6D4),
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Pass Rate',
            '85.2%',
            const Color(0xFF10B981),
            Icons.check_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Row(
      children: [
        Expanded(child: _buildPerformanceTrendsChart()),
        const SizedBox(width: 24),
        Expanded(child: _buildSubjectDistributionChart()),
      ],
    );
  }

  Widget _buildPerformanceTrendsChart() {
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
            'Exam Performance Trends',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: LineChartPainter(),
              size: const Size(double.infinity, 200),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Text(
                'Jan',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              Text(
                'Feb',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              Text(
                'Mar',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              Text(
                'Apr',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              Text(
                'May',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              Text(
                'Jun',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectDistributionChart() {
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
            'Subject Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: CustomPaint(painter: DonutChartPainter()),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildChartLegend(),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    final subjects = [
      {'name': 'Mathematics', 'color': const Color(0xFF6366F1)},
      {'name': 'Physics', 'color': const Color(0xFF8B5CF6)},
      {'name': 'Chemistry', 'color': const Color(0xFF06B6D4)},
      {'name': 'Biology', 'color': const Color(0xFF10B981)},
      {'name': 'English', 'color': const Color(0xFFF59E0B)},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children:
          subjects.map((subject) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: subject['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  subject['name'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildRecentExaminationsSection() {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Text(
                  'Recent Examinations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Exam'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildExaminationsTable(),
        ],
      ),
    );
  }

  Widget _buildExaminationsTable() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB),
            border: Border(
              top: BorderSide(color: Color(0xFFE5E7EB)),
              bottom: BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'EXAM NAME',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'SUBJECT',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'CLASS',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'DATE',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'STATUS',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  'ACTIONS',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
        ..._examinations.map((exam) => _buildExaminationRow(exam)),
      ],
    );
  }

  Widget _buildExaminationRow(Examination exam) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              exam.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Expanded(
            child: Text(
              exam.subject,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            child: Text(
              exam.className,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            child: Text(
              '${exam.date.month}/${exam.date.day}/${exam.date.year}',
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(child: _buildStatusChip(exam.status)),
          SizedBox(
            width: 80,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility, size: 18),
                  color: const Color(0xFF6366F1),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 18),
                  color: const Color(0xFF10B981),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ExamStatus status) {
    Color bgColor, textColor;
    String text;

    switch (status) {
      case ExamStatus.completed:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        text = 'Completed';
        break;
      case ExamStatus.scheduled:
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        text = 'Scheduled';
        break;
      case ExamStatus.inProgress:
        bgColor = const Color(0xFFDDD6FE);
        textColor = const Color(0xFF6B21A8);
        text = 'In Progress';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSubjectPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subject Performance Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children:
              _subjectPerformances.map((performance) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildSubjectPerformanceCard(performance),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubjectPerformanceCard(SubjectPerformance performance) {
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
          Row(
            children: [
              Text(
                performance.subject,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: performance.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  performance.icon,
                  color: performance.color,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Average Score',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 4),
              Text(
                '${performance.averageScore}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Students',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 4),
              Text(
                '${performance.studentCount}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: performance.averageScore / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: performance.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum ExamStatus { completed, scheduled, inProgress }

class Examination {
  final String name;
  final String subject;
  final String className;
  final DateTime date;
  final ExamStatus status;

  Examination({
    required this.name,
    required this.subject,
    required this.className,
    required this.date,
    required this.status,
  });
}

class SubjectPerformance {
  final String subject;
  final double averageScore;
  final int studentCount;
  final Color color;
  final IconData icon;

  SubjectPerformance({
    required this.subject,
    required this.averageScore,
    required this.studentCount,
    required this.color,
    required this.icon,
  });
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF6366F1)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final gridPaint =
        Paint()
          ..color = const Color(0xFFE5E7EB)
          ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 1; i < 6; i++) {
      final x = size.width * i / 6;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw performance line
    final path = Path();
    final points = [
      Offset(0, size.height * 0.3),
      Offset(size.width * 0.2, size.height * 0.25),
      Offset(size.width * 0.4, size.height * 0.15),
      Offset(size.width * 0.6, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.1),
      Offset(size.width, size.height * 0.2),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint =
        Paint()
          ..color = const Color(0xFF6366F1)
          ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.6;

    final subjects = [
      {'percentage': 35, 'color': const Color(0xFF6366F1)},
      {'percentage': 20, 'color': const Color(0xFF8B5CF6)},
      {'percentage': 15, 'color': const Color(0xFF06B6D4)},
      {'percentage': 20, 'color': const Color(0xFF10B981)},
      {'percentage': 10, 'color': const Color(0xFFF59E0B)},
    ];

    double startAngle = -math.pi / 2;

    for (final subject in subjects) {
      final percentage = subject['percentage'] as int;
      final color = subject['color'] as Color;
      final sweepAngle = (percentage / 100) * 2 * math.pi;

      final paint =
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = radius - innerRadius;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (radius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
