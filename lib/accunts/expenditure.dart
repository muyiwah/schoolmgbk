import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class ExpenditureScreen extends StatefulWidget {
  const ExpenditureScreen({Key? key}) : super(key: key);

  @override
  State<ExpenditureScreen> createState() => _ExpenditureScreenState();
}

class _ExpenditureScreenState extends State<ExpenditureScreen> {
  String selectedTerm = 'All Terms';
  String selectedMonth = 'All Months';
  String selectedYear = '2024';
  String selectedCategory = 'All Categories';
  String searchQuery = '';

  final List<ExpenseRecord> expenseRecords = [
    ExpenseRecord(
      date: '2024-01-15',
      description: 'Teacher Salaries - January',
      category: 'Salary',
      amount: 450000,
      term: 'Term 2',
      status: 'Paid',
    ),
    ExpenseRecord(
      date: '2024-01-12',
      description: 'Electricity Bill',
      category: 'Utilities',
      amount: 85000,
      term: 'Term 2',
      status: 'Pending',
    ),
    ExpenseRecord(
      date: '2024-01-10',
      description: 'School Event Supplies',
      category: 'Events',
      amount: 125000,
      term: 'Term 2',
      status: 'Paid',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 24),
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildChartsRow(),
            const SizedBox(height: 24),
            _buildExpenseRecords(),
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
          children: const [
            Text(
              'Expenditure Dashboard',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Track school expenses by term, category, and date',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        Row(
          children: [
            _buildActionButton(
              'Export PDF',
              Icons.picture_as_pdf,
              const Color(0xFFEF4444),
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              'Export Excel',
              Icons.table_chart,
              const Color(0xFF10B981),
            ),
            const SizedBox(width: 12),
            _buildActionButton('Print', Icons.print, const Color(0xFF6B7280)),
            const SizedBox(width: 12),
            _buildActionButton(
              'Add New Expense',
              Icons.add,
              const Color(0xFF06B6D4),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown('All Terms', selectedTerm, (value) {
              setState(() => selectedTerm = value!);
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDropdown('All Months', selectedMonth, (value) {
              setState(() => selectedMonth = value!);
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDropdown('2024', selectedYear, (value) {
              setState(() => selectedYear = value!);
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDropdown('All Categories', selectedCategory, (value) {
              setState(() => selectedCategory = value!);
            }),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by keyword or description...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF06B6D4)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
          ),
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: () {
              setState(() {
                selectedTerm = 'All Terms';
                selectedMonth = 'All Months';
                selectedYear = '2024';
                selectedCategory = 'All Categories';
                searchQuery = '';
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    String value,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items:
          [value].map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total This Year',
            '₦2,450,000',
            const Color(0xFFDCFDF7),
            const Color(0xFF06B6D4),
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total This Term',
            '₦820,000',
            const Color(0xFFE0E7FF),
            const Color(0xFF6366F1),
            Icons.calendar_today,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Top Category',
            'Salary',
            const Color(0xFFD1FAE5),
            const Color(0xFF10B981),
            Icons.emoji_events,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Transactions',
            '156',
            const Color(0xFFEDE9FE),
            const Color(0xFF8B5CF6),
            Icons.receipt_long,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color backgroundColor,
    Color iconColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
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
                  color: Color(0xFF6B7280),
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
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsRow() {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildMonthlyExpenseChart()),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildCategoryBreakdownChart()),
      ],
    );
  }

  Widget _buildMonthlyExpenseChart() {
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
            'Monthly Expense Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 600000,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 80,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₦${(value / 1000).toInt()}K',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        );
                      },
                    ),
                  ),
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
                        if (value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          );
                        }
                        return const Text('');
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
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: 450000,
                        color: const Color(0xFF06B6D4),
                        width: 30,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: 380000,
                        color: const Color(0xFF06B6D4),
                        width: 30,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: 520000,
                        color: const Color(0xFF06B6D4),
                        width: 30,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barRods: [
                      BarChartRodData(
                        toY: 410000,
                        color: const Color(0xFF06B6D4),
                        width: 30,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 4,
                    barRods: [
                      BarChartRodData(
                        toY: 480000,
                        color: const Color(0xFF06B6D4),
                        width: 30,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 5,
                    barRods: [
                      BarChartRodData(
                        toY: 350000,
                        color: const Color(0xFF06B6D4),
                        width: 30,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownChart() {
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
            'Category-wise Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 45,
                    color: const Color(0xFF06B6D4),
                    title: '',
                    radius: 60,
                  ),
                  PieChartSectionData(
                    value: 20,
                    color: const Color(0xFF1E3A8A),
                    title: '',
                    radius: 60,
                  ),
                  PieChartSectionData(
                    value: 15,
                    color: const Color(0xFF10B981),
                    title: '',
                    radius: 60,
                  ),
                  PieChartSectionData(
                    value: 12,
                    color: const Color(0xFF8B5CF6),
                    title: '',
                    radius: 60,
                  ),
                  PieChartSectionData(
                    value: 8,
                    color: const Color(0xFFF97316),
                    title: '',
                    radius: 60,
                  ),
                ],
                centerSpaceRadius: 50,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        _buildLegendItem('Salary', const Color(0xFF06B6D4)),
        _buildLegendItem('Utilities', const Color(0xFF1E3A8A)),
        _buildLegendItem('Maintenance', const Color(0xFF10B981)),
        _buildLegendItem('Events', const Color(0xFF8B5CF6)),
        _buildLegendItem('Supplies', const Color(0xFFF97316)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseRecords() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Expense Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          _buildExpenseTable(),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildExpenseTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(2.5),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(1.2),
        5: FlexColumnWidth(1.2),
        6: FlexColumnWidth(1.5),
      },
      children: [
        _buildTableHeader(),
        ...expenseRecords.map((record) => _buildTableRow(record)),
      ],
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFF9FAFB)),
      children:
          [
                'DATE',
                'DESCRIPTION',
                'CATEGORY',
                'AMOUNT',
                'TERM',
                'STATUS',
                'ACTION',
              ]
              .map(
                (header) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    header,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  TableRow _buildTableRow(ExpenseRecord record) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            record.date,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            record.description,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            record.category,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '₦${record.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            record.term,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  record.status == 'Paid'
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              record.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color:
                    record.status == 'Paid'
                        ? const Color(0xFF065F46)
                        : const Color(0xFF92400E),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildActionIcon(Icons.visibility, const Color(0xFF06B6D4)),
              const SizedBox(width: 8),
              _buildActionIcon(Icons.edit, const Color(0xFF6B7280)),
              const SizedBox(width: 8),
              _buildActionIcon(Icons.delete, const Color(0xFFEF4444)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Showing 1 to 10 of 156 results',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          Row(
            children: [
              _buildPaginationButton('Previous', false),
              const SizedBox(width: 8),
              _buildPaginationButton('1', true),
              const SizedBox(width: 8),
              _buildPaginationButton('2', false),
              const SizedBox(width: 8),
              _buildPaginationButton('3', false),
              const SizedBox(width: 8),
              _buildPaginationButton('Next', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF06B6D4) : Colors.white,
        border: Border.all(
          color: isActive ? const Color(0xFF06B6D4) : const Color(0xFFE5E7EB),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.white : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class ExpenseRecord {
  final String date;
  final String description;
  final String category;
  final double amount;
  final String term;
  final String status;

  ExpenseRecord({
    required this.date,
    required this.description,
    required this.category,
    required this.amount,
    required this.term,
    required this.status,
  });
}
