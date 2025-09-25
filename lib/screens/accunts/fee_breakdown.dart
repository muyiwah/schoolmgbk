import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/models/class_statistics_model.dart';

class PaymentBreakdownScreen extends ConsumerStatefulWidget {
  const PaymentBreakdownScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PaymentBreakdownScreen> createState() =>
      _PaymentBreakdownScreenState();
}

class _PaymentBreakdownScreenState
    extends ConsumerState<PaymentBreakdownScreen> {
  String _selectedTerm = 'Spring Term 2024';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStatistics();
    });
  }

  Future<void> _loadStatistics() async {
    await ref
        .read(RiverpodProvider.classProvider.notifier)
        .getClassStatistics(
          context,
          term: _selectedTerm,
          academicYear: '2025/2026', // You can make this dynamic
        );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFeeBreakdownItem(
    String label,
    String amount,
    String percentage,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            percentage,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddFeeStructureDialog(ClassStatistics classData) async {
    showDialog(
      context: context,
      builder:
          (context) => _AddFeeStructureDialog(
            classData: classData,
            onFeeStructureAdded: () {
              _loadStatistics(); // Refresh the data
            },
          ),
    );
  }

  final List<String> _terms = [
    'Spring Term 2024',
    'Fall Term 2023',
    'Summer Term 2024',
    'Winter Term 2024',
  ];

  @override
  Widget build(BuildContext context) {
    final classState = ref.watch(RiverpodProvider.classProvider);
    final statisticsData = classState.classStatisticsData;
    final classes = statisticsData.classes ?? [];
    final overallStats = statisticsData.overallStats;
    final filters = statisticsData.filters;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(filters),
            const SizedBox(height: 24),
            _buildControlsSection(),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildClassesSection(classes)),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildSummarySection(overallStats)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Filters? filters) {
    final term = filters?.term ?? 'Spring Term 2024';
    final academicYear = filters?.academicYear ?? '2025/2026';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Breakdown – $term $academicYear',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Comprehensive fee overview for all classes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
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
              onPressed: () => _loadStatistics(),
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

  Widget _buildClassesSection(List<ClassStatistics> classes) {
    if (classes.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 48, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'No classes available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Add classes to see fee structures',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            classes.map((classData) {
              final index = classes.indexOf(classData);
              return Container(
                width: 320, // Fixed width for consistent cards
                margin: EdgeInsets.only(
                  right: index < classes.length - 1 ? 16 : 0,
                ),
                child: _buildClassCard(classData),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildClassCard(ClassStatistics classData) {
    final hasFeeStructure = classData.feeStructureDetails != null;
    final studentCount = classData.studentCount ?? 0;
    final capacity = classData.capacity ?? 0;
    final capacityUtilization = classData.capacityUtilization ?? 0;
    final expectedRevenue = classData.expectedRevenue ?? 0;
    final totalPaidAmount = classData.totalPaidAmount ?? 0;
    final paymentCollectionRate = classData.paymentCollectionRate ?? 0;

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
                Expanded(
                  child: Text(
                    '${classData.classLevel?.displayName ?? classData.level ?? 'Unknown'} ${classData.section ?? ''}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$studentCount/$capacity',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Text(
                      '$capacityUtilization% capacity',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fee Structure Status
            Row(
              children: [
                Icon(
                  hasFeeStructure ? Icons.check_circle : Icons.warning,
                  size: 16,
                  color: hasFeeStructure ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  hasFeeStructure ? 'Fee Structure Set' : 'No Fee Structure',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: hasFeeStructure ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (hasFeeStructure) ...[
              // Revenue Information
              _buildInfoRow(
                'Expected Revenue',
                '₦${expectedRevenue.toStringAsFixed(0)}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Paid Amount',
                '₦${totalPaidAmount.toStringAsFixed(0)}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Collection Rate', '$paymentCollectionRate%'),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Avg Fee/Student',
                '₦${classData.averageFeePerStudent?.toStringAsFixed(0) ?? '0'}',
              ),
              const SizedBox(height: 12),

              // Fee Structure Breakdown
              if (classData.feeStructureDetails != null) ...[
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fee Breakdown',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFeeBreakdownItem(
                              'Required',
                              '₦${classData.feeStructureDetails!.requiredFeeAmount?.toStringAsFixed(0) ?? '0'}',
                              '${classData.feeStructureDetails!.requiredFeePercentage ?? 0}%',
                              Colors.red,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildFeeBreakdownItem(
                              'Optional',
                              '₦${classData.feeStructureDetails!.optionalFeeAmount?.toStringAsFixed(0) ?? '0'}',
                              '${classData.feeStructureDetails!.optionalFeePercentage ?? 0}%',
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],

            // Action Button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddFeeStructureDialog(classData),
                icon: Icon(hasFeeStructure ? Icons.edit : Icons.add, size: 16),
                label: Text(
                  hasFeeStructure ? 'Edit Fee Structure' : 'Add Fee Structure',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      hasFeeStructure ? Colors.orange : AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection(OverallStats? overallStats) {
    final totalRevenue = overallStats?.totalExpectedRevenue ?? 0;
    final totalPaidAmount = overallStats?.totalPaidAmount ?? 0;
    final collectionRate = overallStats?.overallCollectionRate ?? 0;

    return Column(
      children: [
        _buildSummaryAnalyticsCard(
          totalRevenue,
          totalPaidAmount,
          collectionRate,
        ),
        const SizedBox(height: 24),
        _buildRequiredVsOptionalChart(overallStats?.feeStructureStats),
        const SizedBox(height: 24),
        _buildClassesOverviewCard(overallStats),
      ],
    );
  }

  Widget _buildSummaryAnalyticsCard(
    int totalRevenue,
    int totalPaidAmount,
    int collectionRate,
  ) {
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

        // Three separate cards
        Column(
          children: [
            // Total Expected Revenue Card
            _buildRevenueCard(totalRevenue),
            const SizedBox(height: 12),
            // Total Paid Amount Card
            _buildPaidAmountCard(totalPaidAmount),
            const SizedBox(height: 12),
            // Collection Rate Card
            _buildCollectionRateCard(collectionRate),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueCard(int totalRevenue) {
    return Container(width: double.infinity,
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
            '£${totalRevenue.toStringAsFixed(0)}',
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

  Widget _buildPaidAmountCard(int totalPaidAmount) {
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
            'Total Paid Amount',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF388E3C), // Medium green
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₦${totalPaidAmount.toStringAsFixed(0)}',
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

  Widget _buildCollectionRateCard(int collectionRate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0), // Light orange background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF57C00).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF57C00).withOpacity(0.1),
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
            'Collection Rate',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF57C00), // Medium orange
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$collectionRate%',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100), // Dark orange
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredVsOptionalChart(FeeStructureStats? feeStructureStats) {
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
                        value:
                            (feeStructureStats?.averageRequiredFeePercentage ??
                                    75)
                                .toDouble(),
                        title: '',
                        radius: 35,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFF10B981),
                        value:
                            (feeStructureStats?.averageOptionalFeePercentage ??
                                    25)
                                .toDouble(),
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
                      '${feeStructureStats?.averageRequiredFeePercentage ?? 75}%',
                      const Color(0xFF3B82F6),
                    ),
                    const SizedBox(height: 16),
                    _buildChartLabel(
                      'Optional Fees',
                      '${feeStructureStats?.averageOptionalFeePercentage ?? 25}%',
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

  Widget _buildClassesOverviewCard(OverallStats? overallStats) {
    final totalStudents = overallStats?.totalStudents ?? 0;
    final totalClasses = overallStats?.totalClasses ?? 0;
    final averageStudentsPerClass = overallStats?.averageStudentsPerClass ?? 0;
    final highestFeeClass = overallStats?.classWithHighestFee?.name ?? 'N/A';

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
          _buildOverviewRow('Total Classes', '$totalClasses'),
          const SizedBox(height: 12),
          _buildOverviewRow('Total Students', '$totalStudents'),
          const SizedBox(height: 12),
          _buildOverviewRow('Avg Students/Class', '$averageStudentsPerClass'),
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

class _AddFeeStructureDialog extends ConsumerStatefulWidget {
  final ClassStatistics classData;
  final VoidCallback onFeeStructureAdded;

  const _AddFeeStructureDialog({
    required this.classData,
    required this.onFeeStructureAdded,
  });

  @override
  ConsumerState<_AddFeeStructureDialog> createState() =>
      _AddFeeStructureDialogState();
}

class _AddFeeStructureDialogState
    extends ConsumerState<_AddFeeStructureDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _baseFeeController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();

  String _selectedTerm = 'First';
  bool _setAsActive = true;
  List<AddOnFee> _addOns = [];

  @override
  void initState() {
    super.initState();
    _academicYearController.text = '2025/2026';
    _addOns = [AddOnFee(name: '', amount: 0, compulsory: true, isActive: true)];
  }

  @override
  void dispose() {
    _baseFeeController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add Fee Structure - ${widget.classData.classLevel?.displayName ?? widget.classData.level} ${widget.classData.section ?? ''}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      _buildSectionTitle('Basic Information'),
                      SizedBox(height: 16),

                      // Term Selection
                      _buildDropdownField(
                        label: 'Term',
                        value: _selectedTerm,
                        items: ['First', 'Second', 'Third'],
                        onChanged:
                            (value) => setState(() => _selectedTerm = value!),
                      ),
                      SizedBox(height: 16),

                      // Academic Year
                      _buildTextField(
                        controller: _academicYearController,
                        label: 'Academic Year',
                        hint: 'e.g., 2025/2026',
                        validator:
                            (value) =>
                                value?.isEmpty == true
                                    ? 'Academic year is required'
                                    : null,
                      ),
                      SizedBox(height: 16),

                      // Base Fee
                      _buildTextField(
                        controller: _baseFeeController,
                        label: 'Base Fee (₦)',
                        hint: 'e.g., 30000',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty == true)
                            return 'Base fee is required';
                          if (int.tryParse(value!) == null)
                            return 'Enter a valid amount';
                          return null;
                        },
                      ),
                      SizedBox(height: 24),

                      // Add-ons Section
                      _buildSectionTitle('Additional Fees'),
                      SizedBox(height: 16),

                      ..._addOns.asMap().entries.map((entry) {
                        final index = entry.key;
                        final addOn = entry.value;
                        return _buildAddOnRow(index, addOn);
                      }).toList(),

                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addAddOn,
                        icon: Icon(Icons.add, size: 16),
                        label: Text('Add Another Fee'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 24),

                      // Set as Active
                      Row(
                        children: [
                          Checkbox(
                            value: _setAsActive,
                            onChanged:
                                (value) => setState(
                                  () => _setAsActive = value ?? true,
                                ),
                          ),
                          Expanded(
                            child: Text(
                              'Set as active fee structure for this class',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Add Fee Structure'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items:
                  items
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
              onChanged: onChanged,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddOnRow(int index, AddOnFee addOn) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: addOn.name,
                  decoration: InputDecoration(
                    labelText: 'Fee Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) => _addOns[index].name = value,
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: TextFormField(
                  initialValue: addOn.amount.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (₦)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged:
                      (value) =>
                          _addOns[index].amount = int.tryParse(value) ?? 0,
                ),
              ),
              SizedBox(width: 12),
              IconButton(
                onPressed: () => _removeAddOn(index),
                icon: Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text('Compulsory', style: TextStyle(fontSize: 14)),
                  value: addOn.compulsory,
                  onChanged:
                      (value) => setState(
                        () => _addOns[index].compulsory = value ?? false,
                      ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: Text('Active', style: TextStyle(fontSize: 14)),
                  value: addOn.isActive,
                  onChanged:
                      (value) => setState(
                        () => _addOns[index].isActive = value ?? true,
                      ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addAddOn() {
    setState(() {
      _addOns.add(
        AddOnFee(name: '', amount: 0, compulsory: false, isActive: true),
      );
    });
  }

  void _removeAddOn(int index) {
    if (_addOns.length > 1) {
      setState(() {
        _addOns.removeAt(index);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Filter out empty add-ons
    final validAddOns =
        _addOns
            .where((addOn) => addOn.name.isNotEmpty && addOn.amount > 0)
            .toList();

    final feeStructureData = {
      'term': _selectedTerm,
      'academicYear': _academicYearController.text.trim(),
      'baseFee': int.parse(_baseFeeController.text.trim()),
      'addOns':
          validAddOns
              .map(
                (addOn) => {
                  'name': addOn.name,
                  'amount': addOn.amount,
                  'compulsory': addOn.compulsory,
                  'isActive': addOn.isActive,
                },
              )
              .toList(),
      'setAsActive': _setAsActive,
      'creatorId':
          '68ccb7b8b576836f0f473c11', // This should come from user context
    };

    final success = await ref
        .read(RiverpodProvider.classProvider.notifier)
        .addFeeStructureToClass(
          context,
          widget.classData.id!,
          feeStructureData,
        );

    if (success) {
      Navigator.of(context).pop();
      widget.onFeeStructureAdded();
    }
  }
}

class AddOnFee {
  String name;
  int amount;
  bool compulsory;
  bool isActive;

  AddOnFee({
    required this.name,
    required this.amount,
    required this.compulsory,
    required this.isActive,
  });
}
