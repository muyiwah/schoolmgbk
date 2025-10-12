import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/models/students_with_fees_model.dart';

class PaymentDetailsScreen extends ConsumerStatefulWidget {
  final String? classId;
  final String? className;

  const PaymentDetailsScreen({Key? key, this.classId, this.className})
    : super(key: key);

  @override
  ConsumerState<PaymentDetailsScreen> createState() =>
      _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends ConsumerState<PaymentDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All Status';
  String _selectedSearchBy = 'name';
  String _selectedTerm = 'All Terms';
  String _selectedAcademicYear = 'All Years';
  String _selectedSortBy = 'name';
  String _selectedSortOrder = 'asc';
  String? _selectedClassId;
  int _currentPage = 1;
  int _limit = 50;

  @override
  void initState() {
    super.initState();
    _loadClassesData();
    _loadStudentsWithFees();
  }

  Future<void> _loadClassesData() async {
    if (widget.classId == null) {
      await ref
          .read(RiverpodProvider.classProvider)
          .getAllClassesWithMetric(context);
    }
  }

  Future<void> _loadStudentsWithFees() async {
    await ref
        .read(RiverpodProvider.classProvider)
        .getStudentsWithFees(
          context,
          search:
              _searchController.text.trim().isNotEmpty
                  ? _searchController.text.trim()
                  : null,
          searchBy: _selectedSearchBy,
          classId: widget.classId ?? _selectedClassId,
          feeStatus:
              _selectedStatus != 'All Status'
                  ? _selectedStatus.toLowerCase()
                  : null,
          term: _selectedTerm != 'All Terms' ? _selectedTerm : null,
          academicYear:
              _selectedAcademicYear != 'All Years'
                  ? _selectedAcademicYear
                  : null,
          sortBy: _selectedSortBy,
          sortOrder: _selectedSortOrder,
          page: _currentPage,
          limit: _limit,
        );
  }

  void _onSearchChanged() {
    _currentPage = 1; // Reset to first page when searching
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudentsWithFees();
    });
  }

  void _onFilterChanged() {
    _currentPage = 1; // Reset to first page when filtering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudentsWithFees();
    });
  }

  void _onSortChanged() {
    _currentPage = 1; // Reset to first page when sorting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudentsWithFees();
    });
  }

  void _resetAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = 'All Status';
      _selectedSearchBy = 'name';
      _selectedTerm = 'All Terms';
      _selectedAcademicYear = 'All Years';
      _selectedSortBy = 'name';
      _selectedSortOrder = 'asc';
      _selectedClassId = null;
      _currentPage = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudentsWithFees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = ref.watch(RiverpodProvider.classProvider);
    final studentsWithFees = classProvider.studentsWithFeesData;
    final isLoading = classProvider.isLoadingStudentsWithFees;
    final error = classProvider.studentsWithFeesError;

    return Scaffold(
      backgroundColor: Color(0xFFFAFBFC),
      body: Column(
        children: [
          // Custom App Bar
          Container(
            height: 64,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.chevron_left, color: Color(0xFF64748B), size: 20),
                SizedBox(width: 8),
                Text(
                  'Payment Breakdown',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Color(0xFF64748B), size: 16),
                SizedBox(width: 8),
                Text(
                  widget.className ?? 'All Classes',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.print_outlined,
                    color: Color(0xFF475569),
                    size: 16,
                  ),
                  label: Text(
                    'Print Report',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.download, size: 16),
                  label: Text(
                    'Export',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Class Payment Details – ${widget.className ?? 'All Classes'} – Spring 2024',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 40),

                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Expected',
                          '£${studentsWithFees.metrics.totalFeesExpected.toStringAsFixed(0)}',
                          Color(0xFF3B82F6),
                          Icons.attach_money_outlined,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildStatCard(
                          'Total Collected',
                          '£${studentsWithFees.metrics.totalFeesCollected.toStringAsFixed(0)}',
                          Color(0xFF10B981),
                          Icons.check_circle_outline,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildStatCard(
                          'Pending Amount',
                          '£${studentsWithFees.metrics.totalFeesOutstanding.toStringAsFixed(0)}',
                          Color(0xFFF59E0B),
                          Icons.schedule_outlined,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildStatCard(
                          'Fully Paid Students',
                          '${studentsWithFees.metrics.totalStudents > 0 ? ((studentsWithFees.metrics.paidStudents / studentsWithFees.metrics.totalStudents) * 100).toStringAsFixed(0) : 0}%',
                          Color(0xFF8B5CF6),
                          Icons.people_outline,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Collection Progress
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Collection Progress',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF475569),
                              ),
                            ),
                            Text(
                              '${studentsWithFees.metrics.totalFeesExpected > 0 ? ((studentsWithFees.metrics.totalFeesCollected / studentsWithFees.metrics.totalFeesExpected) * 100).toStringAsFixed(1) : 0}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value:
                                studentsWithFees.metrics.totalFeesExpected > 0
                                    ? studentsWithFees
                                            .metrics
                                            .totalFeesCollected /
                                        studentsWithFees
                                            .metrics
                                            .totalFeesExpected
                                    : 0.0,
                            backgroundColor: Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF10B981),
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),

                  // Main Table Container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        // Search and Filter Section
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // First Row - Search and Basic Filters
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 300,
                                      child: Container(
                                        height: 40,
                                        child: TextField(
                                          controller: _searchController,
                                          onChanged:
                                              (value) => _onSearchChanged(),
                                          decoration: InputDecoration(
                                            hintText:
                                                'Search student by name or ID...',
                                            hintStyle: TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 14,
                                            ),
                                            prefixIcon: Icon(
                                              Icons.search,
                                              color: Color(0xFF94A3B8),
                                              size: 20,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Color(0xFFE2E8F0),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Color(0xFFE2E8F0),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Color(0xFF6366F1),
                                              ),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                            filled: true,
                                            fillColor: Colors.white,
                                          ),
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    SizedBox(
                                      width: 150,
                                      child: _buildFilterDropdown(
                                        value: _selectedSearchBy,
                                        items: [
                                          DropdownMenuItem(
                                            value: 'name',
                                            child: Text('Search by Name'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'parentName',
                                            child: Text('Search by Parent'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'admissionNumber',
                                            child: Text('Search by ID'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(
                                            () => _selectedSearchBy = value!,
                                          );
                                          _onSearchChanged();
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    SizedBox(
                                      width: 120,
                                      child: _buildFilterDropdown(
                                        value: _selectedStatus,
                                        items:
                                            [
                                                  'All Status',
                                                  'paid',
                                                  'partial',
                                                  'unpaid',
                                                ]
                                                .map(
                                                  (status) => DropdownMenuItem(
                                                    value: status,
                                                    child: Text(status),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (value) {
                                          setState(
                                            () => _selectedStatus = value!,
                                          );
                                          _onFilterChanged();
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: _resetAllFilters,
                                      icon: Icon(Icons.refresh, size: 16),
                                      label: Text('Reset Filters'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF64748B),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              // Second Row - Advanced Filters
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth:
                                        MediaQuery.of(context).size.width - 40,
                                  ),
                                  child: Row(
                                    children: [
                                      // Class Filter (only show if widget.classId is null)
                                      if (widget.classId == null) ...[
                                        SizedBox(
                                          width: 200,
                                          child: _buildClassFilterDropdown(),
                                        ),
                                        SizedBox(width: 12),
                                      ],
                                      SizedBox(
                                        width: 150,
                                        child: _buildFilterDropdown(
                                          value: _selectedTerm,
                                          items:
                                              [
                                                    'All Terms',
                                                    'First',
                                                    'Second',
                                                    'Third',
                                                  ]
                                                  .map(
                                                    (term) => DropdownMenuItem(
                                                      value: term,
                                                      child: Text(term),
                                                    ),
                                                  )
                                                  .toList(),
                                          onChanged: (value) {
                                            setState(
                                              () => _selectedTerm = value!,
                                            );
                                            _onFilterChanged();
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      SizedBox(
                                        width: 150,
                                        child: _buildFilterDropdown(
                                          value: _selectedAcademicYear,
                                          items:
                                              [
                                                    'All Years',
                                                    '2023/2024',
                                                    '2024/2025',
                                                    '2025/2026',
                                                  ]
                                                  .map(
                                                    (year) => DropdownMenuItem(
                                                      value: year,
                                                      child: Text(year),
                                                    ),
                                                  )
                                                  .toList(),
                                          onChanged: (value) {
                                            setState(
                                              () =>
                                                  _selectedAcademicYear =
                                                      value!,
                                            );
                                            _onFilterChanged();
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      SizedBox(
                                        width: 180,
                                        child: _buildFilterDropdown(
                                          value: _selectedSortBy,
                                          items: [
                                            DropdownMenuItem(
                                              value: 'name',
                                              child: Text('Sort by Name'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'feeStatus',
                                              child: Text('Sort by Status'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'totalFees',
                                              child: Text('Sort by Amount'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'outstandingBalance',
                                              child: Text('Sort by Balance'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'admissionNumber',
                                              child: Text('Sort by ID'),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(
                                              () => _selectedSortBy = value!,
                                            );
                                            _onSortChanged();
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Container(
                                        height: 40,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color(0xFFE2E8F0),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.sort,
                                              color: Color(0xFF94A3B8),
                                              size: 16,
                                            ),
                                            SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedSortOrder =
                                                      _selectedSortOrder ==
                                                              'asc'
                                                          ? 'desc'
                                                          : 'asc';
                                                });
                                                _onSortChanged();
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    _selectedSortOrder == 'asc'
                                                        ? 'A-Z'
                                                        : 'Z-A',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF475569),
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Icon(
                                                    _selectedSortOrder == 'asc'
                                                        ? Icons.arrow_upward
                                                        : Icons.arrow_downward,
                                                    color: Color(0xFF94A3B8),
                                                    size: 16,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.notifications_none,
                                          size: 16,
                                        ),
                                        label: Text('Send Reminder'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFFF59E0B),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                      ],
                    ),
                  ),

                  // Table Header
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE2E8F0)),
                        top: BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          child: Checkbox(
                            value: false,
                            onChanged: (v) {},
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(flex: 3, child: _buildHeaderCell('STUDENT')),
                        Expanded(flex: 2, child: _buildHeaderCell('TUITION')),
                        Expanded(flex: 2, child: _buildHeaderCell('BOOKS')),
                        Expanded(flex: 2, child: _buildHeaderCell('UNIFORM')),
                        Expanded(flex: 2, child: _buildHeaderCell('TRANSPORT')),
                        Expanded(flex: 2, child: _buildHeaderCell('SPORTS')),
                        Expanded(flex: 2, child: _buildHeaderCell('TOTAL')),
                        Expanded(flex: 2, child: _buildHeaderCell('BALANCE')),
                        SizedBox(width: 60, child: _buildHeaderCell('ACTIONS')),
                      ],
                    ),
                  ),

                  // Student Rows
                  _buildStudentRowsContent(isLoading, error, studentsWithFees),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color iconColor,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildStatusCell(String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color),
    );
  }

  Widget _buildStudentRowFromData(StudentWithFee student) {
    // Determine colors based on fee status
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'paid':
          return Color(0xFF10B981);
        case 'partial':
          return Color(0xFFF59E0B);
        case 'unpaid':
          return Color(0xFFEF4444);
        default:
          return Color(0xFF94A3B8);
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            child: Checkbox(
              value: false,
              onChanged: (v) {},
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  student.admissionNumber,
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusCell(
              '£${student.totalFees.toStringAsFixed(0)}',
              getStatusColor(student.feeStatus),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusCell(
              '£${student.paidAmount.toStringAsFixed(0)}',
              getStatusColor(student.feeStatus),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusCell(
              '£${student.outstandingBalance.toStringAsFixed(0)}',
              getStatusColor(student.feeStatus),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusCell(
              student.feeStatus.toUpperCase(),
              getStatusColor(student.feeStatus),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusCell(
              student.gender.toUpperCase(),
              Color(0xFF64748B),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusCell(
              '£${student.totalFees.toStringAsFixed(0)}',
              Color(0xFF0F172A),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusCell(
              '£${student.outstandingBalance.toStringAsFixed(0)}',
              getStatusColor(student.feeStatus),
            ),
          ),
          SizedBox(
            width: 60,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.visibility_outlined,
                    color: Color(0xFF6366F1),
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.more_vert,
                    color: Color(0xFF94A3B8),
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)),
        isExpanded: true,
        style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
      ),
    );
  }

  Widget _buildClassFilterDropdown() {
    final classProvider = ref.watch(RiverpodProvider.classProvider);
    final classes = classProvider.classData.classes ?? [];

    List<DropdownMenuItem<String>> classItems = [
      DropdownMenuItem(value: 'All Classes', child: Text('All Classes')),
    ];

    // Add dynamic class options
    for (var classData in classes) {
      classItems.add(
        DropdownMenuItem(
          value: classData.id,
          child: Text('${classData.level} ${classData.section ?? ''}'),
        ),
      );
    }

    return _buildFilterDropdown(
      value: _selectedClassId ?? 'All Classes',
      items: classItems,
      onChanged: (value) {
        setState(
          () => _selectedClassId = value == 'All Classes' ? null : value,
        );
        _onFilterChanged();
      },
    );
  }

  Widget _buildStudentRowsContent(
    bool isLoading,
    String? error,
    StudentsWithFeesModel studentsWithFees,
  ) {
    if (isLoading) {
      return Container(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    } else if (error != null) {
      return Container(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
              SizedBox(height: 16),
              Text(
                'Error loading students: $error',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadStudentsWithFees,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else if (studentsWithFees.students.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.people_outline, color: Color(0xFF94A3B8), size: 48),
              SizedBox(height: 16),
              Text(
                'No students found',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Column(
        children:
            studentsWithFees.students
                .map((student) => _buildStudentRowFromData(student))
                .toList(),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
