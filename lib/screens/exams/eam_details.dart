import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SubjectExamDetails extends StatelessWidget {
  SubjectExamDetails({super.key});
  SubjectRecord subject = SubjectRecord(
    name: 'Physics',
    teacher: 'Mr Abrahams',
    averageScore: 60,
    highestScore: 80,
    lowestScore: 30,
    performanceTrend: PerformanceTrend.down,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(subject.name),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Iconsax.filter_search), onPressed: () {}),
          IconButton(
            icon: const Icon(Iconsax.export),
            onPressed: () {
              // Export functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Subject Summary Header
          _buildSubjectHeader(context),

          // Performance Charts Section
          _buildPerformanceCharts(),

          // Students List
          Expanded(child: _buildStudentsList()),
        ],
      ),
    );
  }

  Widget _buildSubjectHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Taught by ${subject.teacher}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
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
                      size: 16,
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                'Average',
                '${subject.averageScore}%',
                Colors.blue,
              ),
              _buildStatItem(
                'Highest',
                '${subject.highestScore}%',
                Colors.green,
              ),
              _buildStatItem(
                'Lowest',
                '${subject.lowestScore}%',
                Colors.orange,
              ),
              _buildStatItem('Students', '42', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Iconsax.chart, size: 18, color: color),
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
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildPerformanceCharts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Performance Distribution',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Score Distribution Chart',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildScoreRange('90-100', '12%', Colors.green),
                  _buildScoreRange('80-89', '24%', Colors.lightGreen),
                  _buildScoreRange('70-79', '32%', Colors.yellow),
                  _buildScoreRange('<70', '32%', Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRange(String range, String percentage, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(range, style: const TextStyle(fontSize: 10)),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsList() {
    final students = [
      StudentResult(
        name: 'Alice Johnson',
        score: 95,
        rank: 1,
        attendance: '98%',
      ),
      StudentResult(name: 'Bob Smith', score: 92, rank: 2, attendance: '95%'),
      StudentResult(
        name: 'Charlie Brown',
        score: 88,
        rank: 3,
        attendance: '90%',
      ),
      StudentResult(
        name: 'Diana Prince',
        score: 85,
        rank: 4,
        attendance: '97%',
      ),
      StudentResult(name: 'Ethan Hunt', score: 82, rank: 5, attendance: '92%'),
      StudentResult(name: 'Fiona Green', score: 78, rank: 6, attendance: '89%'),
      StudentResult(
        name: 'George Wilson',
        score: 75,
        rank: 7,
        attendance: '94%',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Student Results',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Iconsax.sort, size: 16),
                label: const Text('Sort'),
              ),
            ],
          ),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: students.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return _buildStudentCard(students[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(StudentResult student) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  student.rank.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Attendance: ${student.attendance}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getScoreColor(student.score).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${student.score}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(student.score),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.orange;
    return Colors.red;
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

class StudentResult {
  final String name;
  final int score;
  final int rank;
  final String attendance;

  StudentResult({
    required this.name,
    required this.score,
    required this.rank,
    required this.attendance,
  });
}

// Add this to your existing SubjectRecord class
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
