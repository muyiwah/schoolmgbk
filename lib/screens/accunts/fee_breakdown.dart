import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PaymentBreakdownScreen extends StatefulWidget {
  const PaymentBreakdownScreen({Key? key}) : super(key: key);

  @override
  State<PaymentBreakdownScreen> createState() => _PaymentBreakdownScreenState();
}

class _PaymentBreakdownScreenState extends State<PaymentBreakdownScreen> {
  String _selectedTerm = 'Spring Term 2024';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _terms = [
    'Spring Term 2024',
    'Fall Term 2023',
    'Summer Term 2024',
    'Winter Term 2024',
  ];

  final List<GradeClassData> _gradeClasses = [
    GradeClassData(
      name: 'Grade 5 - A',
      studentCount: 28,
      requiredFees: {'Tuition': 450, 'Books': 85, 'Uniform': 65},
      optionalFees: {'Transport': 120, 'Sports': 45, 'Lunch Program': 180},
    ),
    GradeClassData(
      name: 'Grade 5 - B',
      studentCount: 26,
      requiredFees: {'Tuition': 450, 'Books': 85, 'Uniform': 65},
      optionalFees: {'Transport': 120, 'Sports': 45, 'Lunch Program': 180},
    ),
    GradeClassData(
      name: 'Grade 6 - A',
      studentCount: 30,
      requiredFees: {'Tuition': 480, 'Books': 95, 'Uniform': 70},
      optionalFees: {'Transport': 120, 'Sports': 50, 'Lunch Program': 190},
    ),
    GradeClassData(
      name: 'Grade 6 - B',
      studentCount: 32,
      requiredFees: {'Tuition': 480, 'Books': 95, 'Uniform': 70},
      optionalFees: {'Transport': 120, 'Sports': 50, 'Lunch Program': 190},
    ),
    GradeClassData(
      name: 'Grade 7 - A',
      studentCount: 29,
      requiredFees: {'Tuition': 520, 'Books': 105, 'Uniform': 75},
      optionalFees: {'Transport': 130, 'Sports': 55, 'Lunch Program': 200},
    ),
    GradeClassData(
      name: 'Grade 7 - B',
      studentCount: 31,
      requiredFees: {'Tuition': 520, 'Books': 105, 'Uniform': 75},
      optionalFees: {'Transport': 130, 'Sports': 55, 'Lunch Program': 200},
    ),
    GradeClassData(
      name: 'Grade 8 - A',
      studentCount: 27,
      requiredFees: {'Tuition': 550, 'Books': 115, 'Uniform': 80},
      optionalFees: {'Transport': 140, 'Sports': 60, 'Lunch Program': 210},
    ),
    GradeClassData(
      name: 'Grade 8 - B',
      studentCount: 33,
      requiredFees: {'Tuition': 550, 'Books': 115, 'Uniform': 80},
      optionalFees: {'Transport': 140, 'Sports': 60, 'Lunch Program': 210},
    ),
    GradeClassData(
      name: 'Grade 9 - A',
      studentCount: 25,
      requiredFees: {'Tuition': 580, 'Books': 125, 'Uniform': 85},
      optionalFees: {'Transport': 150, 'Sports': 65, 'Lunch Program': 220},
    ),
    GradeClassData(
      name: 'Grade 9 - B',
      studentCount: 29,
      requiredFees: {'Tuition': 580, 'Books': 125, 'Uniform': 85},
      optionalFees: {'Transport': 150, 'Sports': 65, 'Lunch Program': 220},
    ),
    GradeClassData(
      name: 'Grade 10 - A',
      studentCount: 26,
      requiredFees: {'Tuition': 600, 'Books': 135, 'Uniform': 90},
      optionalFees: {'Transport': 160, 'Sports': 70, 'Lunch Program': 230},
    ),
    GradeClassData(
      name: 'Grade 10 - B',
      studentCount: 28,
      requiredFees: {'Tuition': 600, 'Books': 135, 'Uniform': 90},
      optionalFees: {'Transport': 160, 'Sports': 70, 'Lunch Program': 230},
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
            _buildControlsSection(),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildGradeClassesSection()),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildSummarySection()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Breakdown – Spring Term 2024',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Comprehensive fee overview for all classes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Export Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlsSection() {
    return Row(
      children: [
        Container(
          width: 200,
          child: DropdownButtonFormField<String>(
            value: _selectedTerm,
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
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items:
                _terms.map((term) {
                  return DropdownMenuItem(
                    value: term,
                    child: Text(term, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTerm = value!;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by Class...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
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
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.help_outline, color: Colors.grey[400]),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[100],
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.view_list, color: Colors.grey[700]),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[100],
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildGradeClassesSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            _gradeClasses.map((gradeClass) {
              final index = _gradeClasses.indexOf(gradeClass);
              return Container(
                width: 320, // Fixed width for consistent cards
                margin: EdgeInsets.only(
                  right: index < _gradeClasses.length - 1 ? 16 : 0,
                ),
                child: _buildGradeClassCard(gradeClass),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildGradeClassCard(GradeClassData gradeClass) {
    final totalRequired = gradeClass.requiredFees.values.fold(
      0,
      (sum, fee) => sum + fee,
    );
    final totalOptional = gradeClass.optionalFees.values.fold(
      0,
      (sum, fee) => sum + fee,
    );
    final totalExpected = totalRequired + totalOptional;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  gradeClass.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${gradeClass.studentCount} students',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Required Fees Section
            Row(
              children: [
                const Text(
                  'Required Fees',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...gradeClass.requiredFees.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Text(
                      '\$${entry.value}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 20),

            // Optional Fees Section
            const Text(
              'Optional Fees',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...gradeClass.optionalFees.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Text(
                      '\$${entry.value}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 20),
            Container(height: 1, color: Colors.grey[200]),
            const SizedBox(height: 16),

            // Total Expected
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Expected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '\$${totalExpected.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text('Print'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Details'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    final totalRevenue = _gradeClasses.fold<int>(0, (sum, gradeClass) {
      final classTotal =
          gradeClass.requiredFees.values.fold(0, (s, fee) => s + fee) +
          gradeClass.optionalFees.values.fold(0, (s, fee) => s + fee);
      return (sum + (classTotal * gradeClass.studentCount)).toInt();
    });

    final totalStudents = _gradeClasses.fold<int>(
      0,
      (sum, gradeClass) => sum + gradeClass.studentCount,
    );
    final averagePerStudent =
        totalStudents > 0 ? (totalRevenue / totalStudents).round() : 0;

    return Column(
      children: [
        _buildSummaryAnalyticsCard(totalRevenue, averagePerStudent),
        const SizedBox(height: 24),
        _buildRequiredVsOptionalChart(),
        const SizedBox(height: 24),
        _buildClassesOverviewCard(),
      ],
    );
  }

  Widget _buildSummaryAnalyticsCard(int totalRevenue, int averagePerStudent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Summary Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Two separate cards
        Column(
          children: [
            // Total Expected Revenue Card
            _buildRevenueCard(totalRevenue),
            // const SizedBox(width: 12),
            // Average per Student Card
            _buildAverageCard(averagePerStudent),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueCard(int totalRevenue) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Light blue background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1976D2).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Expected Revenue',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1976D2), // Medium blue
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalRevenue.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1), // Dark blue
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageCard(int averagePerStudent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8), // Light green background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF388E3C).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF388E3C).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Average per Student',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF388E3C), // Medium green
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${averagePerStudent}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20), // Dark green
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredVsOptionalChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
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
              const Text(
                'Required vs Optional Fees',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey[400]),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Chart
              SizedBox(
                height: 120,
                width: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: [
                      PieChartSectionData(
                        color: const Color(0xFF3B82F6),
                        value: 64.5,
                        title: '',
                        radius: 35,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFF10B981),
                        value: 35.5,
                        title: '',
                        radius: 35,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Labels with lines
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChartLabel(
                      'Required Fees',
                      '64.5%',
                      const Color(0xFF3B82F6),
                    ),
                    const SizedBox(height: 16),
                    _buildChartLabel(
                      'Optional Fees',
                      '35.5%',
                      const Color(0xFF10B981),
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

  Widget _buildChartLabel(String label, String percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const Spacer(),
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassesOverviewCard() {
    final totalStudents = _gradeClasses.fold<int>(
      0,
      (sum, gradeClass) => sum + gradeClass.studentCount,
    );

    // Find the class with highest total fees
    String highestFeeClass = 'N/A';
    int highestFee = 0;
    for (var gradeClass in _gradeClasses) {
      final classTotal =
          (gradeClass.requiredFees.values.fold(0, (s, fee) => s + fee) +
                  gradeClass.optionalFees.values.fold(0, (s, fee) => s + fee))
              .toInt();
      if (classTotal > highestFee) {
        highestFee = classTotal;
        highestFeeClass = gradeClass.name;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Classes Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildOverviewRow('Total Classes', '${_gradeClasses.length}'),
          const SizedBox(height: 12),
          _buildOverviewRow('Total Students', '$totalStudents'),
          const SizedBox(height: 12),
          _buildOverviewRow('Highest Fee Class', highestFeeClass),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class GradeClassData {
  final String name;
  final int studentCount;
  final Map<String, int> requiredFees;
  final Map<String, int> optionalFees;

  GradeClassData({
    required this.name,
    required this.studentCount,
    required this.requiredFees,
    required this.optionalFees,
  });
}
