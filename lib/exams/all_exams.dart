import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AllExams extends StatefulWidget {
  const AllExams({super.key});

  @override
  State<AllExams> createState() => _ExamRecordsScreenState();
}

class _ExamRecordsScreenState extends State<AllExams> {
  String _selectedTerm = 'First Term';
  String _selectedClass = 'Grade 10A';
  final List<String> _terms = ['First Term', 'Second Term', 'Third Term'];
  final List<String> _classes = ['Grade 10A', 'Grade 10B', 'Grade 11A'];

  final List<SubjectRecord> _subjects = [
    SubjectRecord(
      name: 'Mathematics',
      teacher: 'Mr. Johnson',
      averageScore: 78,
      highestScore: 95,
      lowestScore: 62,
      performanceTrend: PerformanceTrend.up,
    ),
    SubjectRecord(
      name: 'English',
      teacher: 'Ms. Williams',
      averageScore: 85,
      highestScore: 98,
      lowestScore: 72,
      performanceTrend: PerformanceTrend.steady,
    ),
    SubjectRecord(
      name: 'Physics',
      teacher: 'Dr. Smith',
      averageScore: 65,
      highestScore: 88,
      lowestScore: 52,
      performanceTrend: PerformanceTrend.down,
    ),
    SubjectRecord(
      name: 'Chemistry',
      teacher: 'Prof. Brown',
      averageScore: 72,
      highestScore: 90,
      lowestScore: 58,
      performanceTrend: PerformanceTrend.up,
    ),
    SubjectRecord(
      name: 'Biology',
      teacher: 'Dr. Taylor',
      averageScore: 81,
      highestScore: 96,
      lowestScore: 68,
      performanceTrend: PerformanceTrend.steady,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Exam Records'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter_search),
            onPressed: _showAdvancedFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Filters
          _buildQuickFilters(),

          // Performance Overview
          _buildPerformanceOverview(),

          // Subjects List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _subjects.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildSubjectCard(_subjects[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTerm,
                  icon: const Icon(Iconsax.arrow_down_1),
                  isExpanded: true,
                  items:
                      _terms.map((term) {
                        return DropdownMenuItem<String>(
                          value: term,
                          child: Text(
                            term,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTerm = value!;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedClass,
                  icon: const Icon(Iconsax.arrow_down_1),
                  isExpanded: true,
                  items:
                      _classes.map((cls) {
                        return DropdownMenuItem<String>(
                          value: cls,
                          child: Text(
                            cls,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClass = value!;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatCard(
                  icon: Iconsax.chart_2,
                  color: Colors.blue.shade50,
                  iconColor: Colors.blue,
                  title: 'Class Average',
                  value: '76%',
                  trend: '+2% from last term',
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  icon: Iconsax.award,
                  color: Colors.green.shade50,
                  iconColor: Colors.green,
                  title: 'Top Subject',
                  value: 'English',
                  trend: '98% highest score',
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  icon: Iconsax.trend_up,
                  color: Colors.orange.shade50,
                  iconColor: Colors.orange,
                  title: 'Most Improved',
                  value: 'Physics',
                  trend: '+15% improvement',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String title,
    required String value,
    required String trend,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(SubjectRecord subject) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTrendColor(
                      subject.performanceTrend,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTrendIcon(subject.performanceTrend),
                        size: 14,
                        color: _getTrendColor(subject.performanceTrend),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTrendText(subject.performanceTrend),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getTrendColor(subject.performanceTrend),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Taught by ${subject.teacher}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildScoreIndicator(
                  label: 'Average',
                  value: '${subject.averageScore}%',
                  color: Colors.blue,
                ),
                _buildScoreIndicator(
                  label: 'Highest',
                  value: '${subject.highestScore}%',
                  color: Colors.green,
                ),
                _buildScoreIndicator(
                  label: 'Lowest',
                  value: '${subject.lowestScore}%',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Advanced Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Add your filter options here
              const Divider(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getTrendColor(PerformanceTrend trend) {
    switch (trend) {
      case PerformanceTrend.up:
        return Colors.green;
      case PerformanceTrend.down:
        return Colors.red;
      case PerformanceTrend.steady:
        return Colors.blue;
    }
  }

  IconData _getTrendIcon(PerformanceTrend trend) {
    switch (trend) {
      case PerformanceTrend.up:
        return Iconsax.arrow_up_3;
      case PerformanceTrend.down:
        return Iconsax.arrow_down_1;
      case PerformanceTrend.steady:
        return Iconsax.minus;
    }
  }

  String _getTrendText(PerformanceTrend trend) {
    switch (trend) {
      case PerformanceTrend.up:
        return 'Improving';
      case PerformanceTrend.down:
        return 'Declining';
      case PerformanceTrend.steady:
        return 'Stable';
    }
  }
}

enum PerformanceTrend { up, down, steady }

class SubjectRecord {
  final String name;
  final String teacher;
  final int averageScore;
  final int highestScore;
  final int lowestScore;
  final PerformanceTrend performanceTrend;

  SubjectRecord({
    required this.name,
    required this.teacher,
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    required this.performanceTrend,
  });
}
