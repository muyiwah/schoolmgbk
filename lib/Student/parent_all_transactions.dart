import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PaymentSummaryScreen extends StatefulWidget {
  final Function navigateTo;
  const PaymentSummaryScreen({super.key, required this.navigateTo});

  @override
  State<PaymentSummaryScreen> createState() => _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<PaymentSummaryScreen> {
  String selectedYear = '2024';
  String selectedTerms = 'All Terms';

  final List<String> years = ['2024', '2023', '2022'];
  final List<String> terms = ['All Terms', 'Term 1', 'Term 2', 'Term 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Stack(
              children: [
                Container(width: double.infinity,
                  decoration:  BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
        
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                  child: Column(
                    children: [
                      const Text(
                        'Payment Summary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Track your payments for school fees and other purchases',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Download receipt functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Receipt downloaded')),
                          );
                        },
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Download Receipt'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6366F1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 30,
                  child: GestureDetector(
                    onTap: () {
                      widget.navigateTo();
                    },
                    child: Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                ),
              ],
            ),
            // Main Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Total Paid This Year',
                        amount: '£485,000',
                        isPositive: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Outstanding Balance',
                        amount: '£65,000',
                        isPositive: false,
                        isHighlighted: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Payment Date and Terms Progress
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        title: 'Last Payment Date',
                        value: 'Dec 15, 2024',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoCard(
                        title: 'Terms Cleared',
                        value: '2 of 3',
                        valueColor: const Color(0xFF06B6D4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        value: selectedYear,
                        items: years,
                        onChanged:
                            (value) => setState(() => selectedYear = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        value: selectedTerms,
                        items: terms,
                        onChanged:
                            (value) => setState(() => selectedTerms = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Fee Breakdown Chart
                const Text(
                  'Fee Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(height: 200, child: _buildPieChart()),
                const SizedBox(height: 30),
                // Payments Per Term Chart
                const Text(
                  'Payments Per Term',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(height: 200, child: _buildBarChart()),
                const SizedBox(height: 30),
                // Term Details
                _buildTermDetails(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required bool isPositive,
    bool isHighlighted = false,
  }) {
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
          Text(
            amount,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.red : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    Color? valueColor,
  }) {
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
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: 60,
            color: const Color(0xFF6366F1),
            title: 'Tuition',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          PieChartSectionData(
            value: 15,
            color: const Color(0xFF06B6D4),
            title: 'Books',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          PieChartSectionData(
            value: 15,
            color: const Color(0xFF8B5CF6),
            title: 'Uniform',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          PieChartSectionData(
            value: 7,
            color: const Color(0xFFF59E0B),
            title: 'PTA Fee',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          PieChartSectionData(
            value: 3,
            color: const Color(0xFFEF4444),
            title: 'Others',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 200000,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text('Term 1');
                  case 1:
                    return const Text('Term 2');
                  case 2:
                    return const Text('Term 3');
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text('${(value / 1000).toInt()}k');
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
                toY: 180000,
                color: const Color(0xFF6366F1),
                width: 40,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 175000,
                color: const Color(0xFF6366F1),
                width: 40,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: 130000,
                color: const Color(0xFF6366F1),
                width: 40,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermDetails() {
    return Column(
      children: [
        _buildTermCard(
          termTitle: 'Term 1 - 2024',
          totalFee: '£180,000',
          paid: '£180,000',
          outstanding: '£0',
          status: 'Paid in Full',
          statusColor: Colors.green,
          payments: [
            PaymentItem(
              'Tuition Fee',
              'Jan 15, 2024 • Bank Transfer',
              '£120,000',
            ),
            PaymentItem('Books Pack', 'Jan 20, 2024 • Card Payment', '£35,000'),
            PaymentItem('Uniform', 'Jan 25, 2024 • Wallet', '£25,000'),
          ],
        ),
        const SizedBox(height: 16),
        _buildTermCard(
          termTitle: 'Term 2 - 2024',
          totalFee: '£175,000',
          paid: '£175,000',
          outstanding: '£0',
          status: 'Paid in Full',
          statusColor: Colors.green,
          payments: [
            PaymentItem(
              'Tuition Fee',
              'May 10, 2024 • Bank Transfer',
              '£120,000',
            ),
            PaymentItem(
              'Additional Books',
              'May 15, 2024 • Card Payment',
              '£30,000',
            ),
            PaymentItem('PTA Fee', 'May 20, 2024 • Wallet', '£25,000'),
          ],
        ),
        const SizedBox(height: 16),
        _buildTermCard(
          termTitle: 'Term 3 - 2024',
          totalFee: '£195,000',
          paid: '£130,000',
          outstanding: '£65,000',
          status: 'Partial Payment',
          statusColor: Colors.orange,
          payments: [
            PaymentItem(
              'Tuition Fee',
              'Sep 15, 2024 • Bank Transfer',
              '£120,000',
            ),
            PaymentItem(
              'Outstanding Balance',
              'Books & Development Fee',
              '£65,000',
              isOutstanding: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermCard({
    required String termTitle,
    required String totalFee,
    required String paid,
    required String outstanding,
    required String status,
    required Color statusColor,
    required List<PaymentItem> payments,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  termTitle,
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTermSummaryItem('Total Fee', totalFee),
                    _buildTermSummaryItem('Paid', paid),
                    _buildTermSummaryItem('Outstanding', outstanding),
                  ],
                ),
                const SizedBox(height: 16),
                ...payments.map((payment) => _buildPaymentItem(payment)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermSummaryItem(String label, String amount) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(PaymentItem payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  payment.isOutstanding
                      ? Colors.red.withOpacity(0.1)
                      : const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              payment.isOutstanding
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              color:
                  payment.isOutstanding ? Colors.red : const Color(0xFF6366F1),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  payment.subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            payment.amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: payment.isOutstanding ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentItem {
  final String title;
  final String subtitle;
  final String amount;
  final bool isOutstanding;

  PaymentItem(
    this.title,
    this.subtitle,
    this.amount, {
    this.isOutstanding = false,
  });
}
