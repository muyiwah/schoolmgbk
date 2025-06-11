import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExamRecordsScreen extends StatefulWidget {
  const ExamRecordsScreen({Key? key}) : super(key: key);

  @override
  State<ExamRecordsScreen> createState() => _ExamRecordsScreenState();
}

class _ExamRecordsScreenState extends State<ExamRecordsScreen> {
  String _selectedClass = 'Select Class';
  String _selectedTerm = 'Select Term';
  String _selectedSubject = 'All Subjects';
  String _selectedGrade = 'All Grades';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  int _currentPage = 1;
  final int _totalPages = 10;

  final List<String> _classes = [
    'Select Class',
    'Grade 9A',
    'Grade 9B',
    'Grade 10A',
    'Grade 10B',
  ];
  final List<String> _terms = [
    'Select Term',
    'First Term',
    'Second Term',
    'Third Term',
  ];
  final List<String> _subjects = [
    'All Subjects',
    'Mathematics',
    'English',
    'Science',
    'History',
    'Geography',
    'Physics',
    'Chemistry',
    'Biology',
  ];
  final List<String> _grades = [
    'All Grades',
    'A+',
    'A',
    'B+',
    'B',
    'C+',
    'C',
    'D',
    'F',
  ];

  final List<StudentRecord> _studentRecords = [
    StudentRecord(
      'John Smith',
      'Grade 9A',
      'Mathematics',
      85,
      'A',
      'Excellent work',
    ),
    StudentRecord(
      'Sarah Johnson',
      'Grade 9A',
      'English',
      92,
      'A+',
      'Outstanding',
    ),
    StudentRecord(
      'Mike Davis',
      'Grade 9B',
      'Science',
      67,
      'C',
      'Needs improvement',
    ),
    StudentRecord(
      'John Smith',
      'Grade 9A',
      'Mathematics',
      85,
      'A',
      'Excellent work',
    ),
    StudentRecord(
      'Sarah Johnson',
      'Grade 9A',
      'English',
      92,
      'A+',
      'Outstanding',
    ),
    StudentRecord(
      'Mike Davis',
      'Grade 9B',
      'Science',
      67,
      'C',
      'Needs improvement',
    ),
    StudentRecord(
      'John Smith',
      'Grade 9A',
      'Mathematics',
      85,
      'A',
      'Excellent work',
    ),
    StudentRecord(
      'Sarah Johnson',
      'Grade 9A',
      'English',
      92,
      'A+',
      'Outstanding',
    ),
    StudentRecord(
      'Mike Davis',
      'Grade 9B',
      'Science',
      67,
      'C',
      'Needs improvement',
    ),
    StudentRecord(
      'John Smith',
      'Grade 9A',
      'Mathematics',
      85,
      'A',
      'Excellent work',
    ),
    StudentRecord(
      'Sarah Johnson',
      'Grade 9A',
      'English',
      92,
      'A+',
      'Outstanding',
    ),
    StudentRecord(
      'Mike Davis',
      'Grade 9B',
      'Science',
      67,
      'C',
      'Needs improvement',
    ),
    StudentRecord(
      'John Smith',
      'Grade 9A',
      'Mathematics',
      85,
      'A',
      'Excellent work',
    ),
    StudentRecord(
      'Sarah Johnson',
      'Grade 9A',
      'English',
      92,
      'A+',
      'Outstanding',
    ),
    StudentRecord(
      'Mike Davis',
      'Grade 9B',
      'Science',
      67,
      'C',
      'Needs improvement',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildScoreTrendsChart(),
            const SizedBox(height: 24),
            _buildFiltersSection(),
            const SizedBox(height: 24),
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildTableSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Exam Records',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_download, size: 16),
              label: const Text('Export Excel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF17A2B8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf, size: 16),
              label: const Text('Export PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3545),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.brightness_4),
              style: IconButton.styleFrom(backgroundColor: Colors.grey[200]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Row(
      children: [
        _buildDropdown(_selectedClass, _classes, (value) {
          setState(() {
            _selectedClass = value!;
          });
        }),
        const SizedBox(width: 16),
        _buildDropdown(_selectedTerm, _terms, (value) {
          setState(() {
            _selectedTerm = value!;
          });
        }),
        const SizedBox(width: 16),
        _buildDropdown(_selectedSubject, _subjects, (value) {
          setState(() {
            _selectedSubject = value!;
          });
        }),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search student name or ID...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.search, size: 16),
          label: const Text('Search'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      width: 140,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        items:
            items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Average Score',
            '78.5',
            Icons.trending_up,
            const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Students Passed',
            '142/180',
            Icons.people,
            const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Top Performer',
            '95.2',
            Icons.emoji_events,
            const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Lowest Score',
            '32.1',
            Icons.trending_down,
            const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Subjects',
            '8',
            Icons.book,
            const Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
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
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreTrendsChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Score Trends by Subject',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 10,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey[200], strokeWidth: 1);
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(color: Colors.grey[200], strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const subjects = [
                          'Math',
                          'English',
                          'Science',
                          'History',
                          'Geography',
                          'Physics',
                          'Chemistry',
                          'Biology',
                        ];
                        if (value.toInt() < subjects.length) {
                          return SideTitleWidget(
                            meta: TitleMeta(min: 2, max: 20, parentAxisSize: 4, axisPosition: 4, appliedInterval: 4, sideTitles: SideTitles(), formattedValue: 'formattedValue', axisSide: AxisSide.right, rotationQuarterTurns: 4),
                            child: Text(
                              subjects[value.toInt()],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                minX: 0,
                maxX: 7,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 78),
                      FlSpot(1, 85),
                      FlSpot(2, 72),
                      FlSpot(3, 81),
                      FlSpot(4, 75),
                      FlSpot(5, 69),
                      FlSpot(6, 83),
                      FlSpot(7, 79),
                    ],
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1),
                        const Color(0xFF6366F1).withOpacity(0.8),
                      ],
                    ),
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
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [_buildTableHeader(), _buildDataTable(), _buildTableFooter()],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildDropdown(_selectedGrade, _grades, (value) {
            setState(() {
              _selectedGrade = value!;
            });
          }),
          const SizedBox(width: 16),
          Container(
            width: 160,
            child: TextField(
              controller: _dateController,
              decoration: InputDecoration(
                hintText: 'mm/dd/yyyy',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                suffixIcon: const Icon(Icons.calendar_today, size: 16),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const Spacer(),
          
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add New Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
        columns: const [
          DataColumn(
            label: Text(
              'Student Name',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text('Class', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          DataColumn(
            label: Text(
              'Subject',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text('Score', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          DataColumn(
            label: Text('Grade', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          DataColumn(
            label: Text(
              'Remarks',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DataColumn(
            label: Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        rows:
            _studentRecords.map((record) {
              return DataRow(
                cells: [
                  DataCell(Text(record.name)),
                  DataCell(Text(record.className)),
                  DataCell(Text(record.subject)),
                  DataCell(Text(record.score.toString())),
                  DataCell(_buildGradeBadge(record.grade)),
                  DataCell(Text(record.remarks)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF6366F1),
                            size: 18,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.delete,
                            color: Color(0xFFEF4444),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildGradeBadge(String grade) {
    Color color;
    switch (grade) {
      case 'A+':
      case 'A':
        color = const Color(0xFF10B981);
        break;
      case 'B+':
      case 'B':
        color = const Color(0xFF3B82F6);
        break;
      case 'C+':
      case 'C':
        color = const Color(0xFFF59E0B);
        break;
      default:
        color = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        grade,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTableFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text(
            'Showing 1 to 10 of 97 results',
            style: TextStyle(color: Colors.grey),
          ),
          const Spacer(),
          Row(
            children: [
              TextButton(
                onPressed:
                    _currentPage > 1
                        ? () {
                          setState(() {
                            _currentPage--;
                          });
                        }
                        : null,
                child: const Text('Previous'),
              ),
              const SizedBox(width: 8),
              ...List.generate(3, (index) {
                final pageNumber = index + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _currentPage = pageNumber;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor:
                          _currentPage == pageNumber
                              ? const Color(0xFF6366F1)
                              : Colors.transparent,
                      foregroundColor:
                          _currentPage == pageNumber
                              ? Colors.white
                              : Colors.grey[600],
                      minimumSize: const Size(32, 32),
                    ),
                    child: Text(pageNumber.toString()),
                  ),
                );
              }),
              const SizedBox(width: 8),
              TextButton(
                onPressed:
                    _currentPage < _totalPages
                        ? () {
                          setState(() {
                            _currentPage++;
                          });
                        }
                        : null,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}

class StudentRecord {
  final String name;
  final String className;
  final String subject;
  final int score;
  final String grade;
  final String remarks;

  StudentRecord(
    this.name,
    this.className,
    this.subject,
    this.score,
    this.grade,
    this.remarks,
  );
}
