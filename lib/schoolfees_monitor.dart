import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/models/fees_paid_report_model.dart';
import 'package:schmgtsystem/providers/fees_paid_report_provider.dart';
import 'package:schmgtsystem/services/global_academic_year_service.dart';
import 'package:intl/intl.dart';

class PaymentRecord {
  final String parentName;
  final String studentName;
  final String className;
  final String amountPaid;
  final String balance;
  final PaymentStatus status;
  final String? paymentDate;
  final String avatarUrl;

  PaymentRecord({
    required this.parentName,
    required this.studentName,
    required this.className,
    required this.amountPaid,
    required this.balance,
    required this.status,
    this.paymentDate,
    required this.avatarUrl,
  });
}

enum PaymentStatus { paid, partial, notPaid }

class SchoolFeesDashboard extends ConsumerStatefulWidget {
  const SchoolFeesDashboard({super.key});

  @override
  ConsumerState<SchoolFeesDashboard> createState() =>
      _SchoolFeesDashboardState();
}

class _SchoolFeesDashboardState extends ConsumerState<SchoolFeesDashboard> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _tableScrollController = ScrollController();

  String _selectedStatus = 'all';
  String _selectedSortBy = 'outstandingBalance';
  String _selectedSortOrder = 'desc';
  List<bool> _selectedRecords = [];
  bool _showStatisticsAndFilters = true;
  late GlobalAcademicYearService _academicYearService;

  @override
  void initState() {
    super.initState();
    _academicYearService = GlobalAcademicYearService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    ref
        .read(feesPaidReportProvider.notifier)
        .loadFeesPaidReport(
          paymentStatus: _selectedStatus,
          academicYear: _academicYearService.currentAcademicYearString,
          sortBy: _selectedSortBy,
          sortOrder: _selectedSortOrder,
        );
  }

  void _onSearchChanged(String value) {
    if (value.isEmpty) {
      _loadData();
    } else {
      ref
          .read(feesPaidReportProvider.notifier)
          .updateFilters(
            search: value,
            paymentStatus: _selectedStatus,
            academicYear: _academicYearService.currentAcademicYearString,
            sortBy: _selectedSortBy,
            sortOrder: _selectedSortOrder,
          );
    }
  }

  void _onStatusChanged(String value) {
    setState(() {
      _selectedStatus = value.toLowerCase().replaceAll(' ', '');
    });
    ref
        .read(feesPaidReportProvider.notifier)
        .updateFilters(
          paymentStatus: _selectedStatus,
          academicYear: _academicYearService.currentAcademicYearString,
          sortBy: _selectedSortBy,
          sortOrder: _selectedSortOrder,
        );
  }

  void _onSortChanged(String sortBy, String sortOrder) {
    setState(() {
      _selectedSortBy = sortBy;
      _selectedSortOrder = sortOrder;
    });
    ref
        .read(feesPaidReportProvider.notifier)
        .updateFilters(
          paymentStatus: _selectedStatus,
          academicYear: _academicYearService.currentAcademicYearString,
          sortBy: _selectedSortBy,
          sortOrder: _selectedSortOrder,
        );
  }

  String _formatCurrency(int amount) {
    return '£${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd MMM yyyy').format(date);
  }

  PaymentStatus _getPaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'partial':
        return PaymentStatus.partial;
      case 'not paid':
      case 'unpaid':
      case 'owing':
        return PaymentStatus.notPaid;
      default:
        return PaymentStatus.notPaid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final feesPaidReportState = ref.watch(feesPaidReportProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),

              // Scrollable content from statistics cards onwards
              Expanded(
                child:
                    _showStatisticsAndFilters
                        ? SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Statistics Cards
                              _buildStatsCards(
                                feesPaidReportState
                                    .feesPaidReport
                                    ?.data
                                    ?.statistics,
                              ),
                              const SizedBox(height: 24),

                              // Action Buttons
                              _buildActionButtons(),
                              const SizedBox(height: 24),

                              // Filters
                              _buildFilters(),
                              const SizedBox(height: 24),

                              // Data Table with fixed height
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height *
                                    0.6, // 60% of screen height
                                child: _buildPaymentRecords(
                                  feesPaidReportState,
                                ),
                              ),
                            ],
                          ),
                        )
                        : _buildPaymentRecords(feesPaidReportState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.school, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'School Fees Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              'Admin Panel',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        const Spacer(),

        // Toggle Statistics and Filters Button
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _showStatisticsAndFilters = !_showStatisticsAndFilters;
            });
          },
          icon: Icon(
            _showStatisticsAndFilters ? Icons.visibility_off : Icons.visibility,
            color:
                _showStatisticsAndFilters
                    ? Colors.white
                    : const Color(0xFF64748B),
            size: 18,
          ),
          label: Text(
            _showStatisticsAndFilters ? 'Hide Cards' : 'Show Cards',
            style: TextStyle(
              color:
                  _showStatisticsAndFilters
                      ? Colors.white
                      : const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _showStatisticsAndFilters
                    ? const Color(0xFF64748B)
                    : Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: _showStatisticsAndFilters ? 2 : 0,
          ),
        ),
        const SizedBox(width: 8),

        Stack(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildStatsCards(FeesStatistics? statistics) {
    final currentYearStats = statistics?.currentAcademicYear;
    final currentTermStats = statistics?.currentTerm;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Paid',
            currentYearStats?.totalPaid != null
                ? _formatCurrency(currentYearStats!.totalPaid!)
                : '£0',
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Owing',
            currentYearStats?.totalOutstanding != null
                ? _formatCurrency(currentYearStats!.totalOutstanding!)
                : '£0',
            Colors.red,
            Icons.error,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Paid Rate',
            currentYearStats?.totalFees != null &&
                    currentYearStats!.totalFees! > 0
                ? '${((currentYearStats.totalPaid! / currentYearStats.totalFees!) * 100).toStringAsFixed(1)}%'
                : '0%',
            Colors.blue,
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Current Term',
            currentTermStats != null
                ? '${currentTermStats.term} ${currentTermStats.year}'
                : '${_academicYearService.currentTermString} ${_academicYearService.currentAcademicYearString}',
            Colors.purple,
            Icons.calendar_today,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Students',
            currentYearStats?.totalStudents != null
                ? '${currentYearStats!.totalStudents}'
                : '0',
            Colors.orange,
            Icons.people,
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
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.send, size: 18),
          label: const Text('Send Reminders to All Owing'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Export All'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by parent or student name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildDropdown(
          _selectedStatus,
          ['all', 'paid', 'partial', 'unpaid'],
          'Status',
          _onStatusChanged,
        ),
        const SizedBox(width: 16),
        _buildSortDropdown(),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {
            ref.read(feesPaidReportProvider.notifier).refreshData();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    String label,
    Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        hint: Text(label),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        items:
            items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item == 'all'
                      ? 'All Status'
                      : item == 'paid'
                      ? 'Paid'
                      : item == 'partial'
                      ? 'Partial'
                      : item == 'unpaid'
                      ? 'Unpaid'
                      : item,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        value: '${_selectedSortBy}_$_selectedSortOrder',
        underline: const SizedBox(),
        hint: const Text('Sort By'),
        onChanged: (String? newValue) {
          if (newValue != null) {
            final parts = newValue.split('_');
            if (parts.length == 2) {
              _onSortChanged(parts[0], parts[1]);
            }
          }
        },
        items: [
          DropdownMenuItem<String>(
            value: 'outstandingBalance_desc',
            child: const Text('Outstanding Balance (High to Low)'),
          ),
          DropdownMenuItem<String>(
            value: 'outstandingBalance_asc',
            child: const Text('Outstanding Balance (Low to High)'),
          ),
          DropdownMenuItem<String>(
            value: 'paymentRate_desc',
            child: const Text('Payment Rate (High to Low)'),
          ),
          DropdownMenuItem<String>(
            value: 'paymentRate_asc',
            child: const Text('Payment Rate (Low to High)'),
          ),
          DropdownMenuItem<String>(
            value: 'lastPaymentDate_desc',
            child: const Text('Last Payment (Recent)'),
          ),
          DropdownMenuItem<String>(
            value: 'lastPaymentDate_asc',
            child: const Text('Last Payment (Oldest)'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRecords(FeesPaidReportState state) {
    final students = state.feesPaidReport?.data?.students ?? [];
    final pagination = state.feesPaidReport?.data?.pagination;

    // Update selected records list based on current data
    if (_selectedRecords.length != students.length) {
      _selectedRecords = List.generate(students.length, (index) => false);
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(fontSize: 18, color: Colors.red[300]),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(feesPaidReportProvider.notifier).refreshData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (students.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No payment records found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

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
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 40), // Space for checkbox column
                const Expanded(
                  flex: 2,
                  child: Text(
                    'PARENT NAME',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'STUDENT(S)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'CLASS',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'AMOUNT PAID',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'BALANCE',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'STATUS',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'PAYMENT DATE',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 100,
                  child: Text(
                    'ACTIONS',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: ListView.builder(
              controller: _tableScrollController,
              itemCount: students.length,
              itemBuilder: (context, index) {
                return _buildTableRow(students[index], index);
              },
            ),
          ),

          // Pagination
          if (pagination != null) _buildPagination(pagination),
        ],
      ),
    );
  }

  Widget _buildTableRow(StudentFeeRecord record, int index) {
    final paymentStatus = _getPaymentStatus(record.paymentStatus ?? 'unpaid');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Checkbox
          SizedBox(
            width: 40,
            child: Checkbox(
              value:
                  _selectedRecords.length > index
                      ? _selectedRecords[index]
                      : false,
              onChanged: (bool? value) {
                setState(() {
                  if (_selectedRecords.length > index) {
                    _selectedRecords[index] = value!;
                  }
                });
              },
            ),
          ),

          // Parent Name
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _getAvatarColor(record.parentName ?? 'U'),
                  child: Text(
                    (record.parentName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.parentName ?? 'Unknown Parent',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (record.parentEmail != null)
                        Text(
                          record.parentEmail!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.studentName ?? 'Unknown Student',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  record.admissionNumber ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Class Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.className ?? 'Unknown Class',
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  record.classLevel ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Amount Paid
          Expanded(
            child: Text(
              record.paidAmount != null
                  ? _formatCurrency(record.paidAmount!)
                  : '£0',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),

          // Balance
          Expanded(
            child: Text(
              record.outstandingBalance != null
                  ? _formatCurrency(record.outstandingBalance!)
                  : '£0',
              style: TextStyle(
                color:
                    (record.outstandingBalance ?? 0) == 0
                        ? Colors.black
                        : Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),

          // Status
          Expanded(
            child: Column(
              children: [
                _buildStatusBadge(paymentStatus),
                if (record.paymentRate != null)
                  Text(
                    '${record.paymentRate}%',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),

          // Payment Date
          Expanded(
            child: Text(
              _formatDate(record.lastPaymentDate),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Actions
          SizedBox(
            width: 100,
            child:
                _shouldShowProcessButton(record)
                    ? ElevatedButton(
                      onPressed: () => _processPayment(record),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: const Size(0, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Process',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                    : Container(
                      width: 100,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Text(
                          'Paid',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[name.hashCode % colors.length];
  }

  bool _shouldShowProcessButton(StudentFeeRecord record) {
    // Show process button only for students who haven't fully paid
    final paymentStatus = record.paymentStatus?.toLowerCase();
    final outstandingBalance = record.outstandingBalance ?? 0;

    // Debug: Log the decision for process button
    print('Process button check for ${record.studentName}:');
    print(
      '  Payment status: ${record.paymentStatus} (lowercase: $paymentStatus)',
    );
    print('  Outstanding balance: $outstandingBalance');

    final shouldShow =
        paymentStatus == 'unpaid' ||
        paymentStatus == 'partial' ||
        paymentStatus == 'not paid' ||
        paymentStatus == 'owing' ||
        outstandingBalance > 0;

    print('  Should show process button: $shouldShow');

    return shouldShow;
  }

  Future<void> _processPayment(StudentFeeRecord record) async {
    try {
      print('Processing payment for student: ${record.studentName}');
      print('Student ID: ${record.id}');
      print('Outstanding Balance: ${record.outstandingBalance}');

      final uri = Uri(
        path: '/accounts/payment-processing',
        queryParameters: {
          'studentId': record.id ?? '',
          'studentName': record.studentName ?? '',
          'parentName': record.parentName ?? '',
          'className': record.className ?? '',
          'academicYear': _academicYearService.currentAcademicYearString,
          'term': _academicYearService.currentTermString,
          'outstandingBalance': (record.outstandingBalance ?? 0).toString(),
          'paidAmount': (record.paidAmount ?? 0).toString(),
          'paymentStatus': record.paymentStatus ?? '',
        },
      );

      print('Navigating to: ${uri.toString()}');
      final result = await context.push(uri.toString());

      // If payment was processed successfully, refresh the dashboard
      if (result == true) {
        print('Payment processed successfully, refreshing dashboard...');
        await _refreshDashboardData();
      }
    } catch (e) {
      print('Error in _processPayment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error navigating to payment screen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshDashboardData() async {
    try {
      print('Refreshing dashboard data after payment processing...');

      // Force refresh the fees paid report data
      await ref
          .read(feesPaidReportProvider.notifier)
          .loadFeesPaidReport(
            paymentStatus: _selectedStatus,
            academicYear: _academicYearService.currentAcademicYearString,
            sortBy: _selectedSortBy,
            sortOrder: _selectedSortOrder,
          );

      print('Dashboard data refreshed successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dashboard updated with latest payment data'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error refreshing dashboard data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing dashboard: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case PaymentStatus.paid:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        text = 'Paid';
        icon = Icons.check;
        break;
      case PaymentStatus.partial:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        text = 'Partial';
        icon = Icons.warning;
        break;
      case PaymentStatus.notPaid:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        text = 'Not Paid';
        icon = Icons.close;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(Pagination pagination) {
    final currentPage = pagination.currentPage ?? 1;
    final totalPages = pagination.totalPages ?? 1;
    final totalCount = pagination.totalCount ?? 0;
    final hasNext = pagination.hasNext ?? false;
    final hasPrev = pagination.hasPrev ?? false;

    final startRecord = ((currentPage - 1) * 20) + 1;
    final endRecord = (currentPage * 20).clamp(0, totalCount);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            'Showing $startRecord-$endRecord of $totalCount records',
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const Spacer(),
          Row(
            children: [
              TextButton(
                onPressed:
                    hasPrev
                        ? () {
                          ref
                              .read(feesPaidReportProvider.notifier)
                              .changePage(currentPage - 1);
                        }
                        : null,
                child: const Text('Previous'),
              ),
              // Show page numbers
              ...List.generate(
                totalPages.clamp(0, 5), // Show max 5 page numbers
                (index) {
                  final pageNumber = index + 1;
                  final isCurrentPage = pageNumber == currentPage;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child:
                        isCurrentPage
                            ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$pageNumber',
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                            : TextButton(
                              onPressed: () {
                                ref
                                    .read(feesPaidReportProvider.notifier)
                                    .changePage(pageNumber);
                              },
                              child: Text('$pageNumber'),
                            ),
                  );
                },
              ),
              TextButton(
                onPressed:
                    hasNext
                        ? () {
                          ref
                              .read(feesPaidReportProvider.notifier)
                              .changePage(currentPage + 1);
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
}
