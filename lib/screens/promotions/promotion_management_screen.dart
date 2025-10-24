import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/promotion_model.dart';
import 'package:schmgtsystem/providers/promotion_provider.dart';
import 'package:schmgtsystem/providers/class_provider.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/services/global_academic_year_service.dart';

class PromotionManagementScreen extends ConsumerStatefulWidget {
  const PromotionManagementScreen({super.key});

  @override
  ConsumerState<PromotionManagementScreen> createState() =>
      _PromotionManagementScreenState();
}

class _PromotionManagementScreenState
    extends ConsumerState<PromotionManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounceTimer;

  // Filter states
  String _selectedClass = 'All Classes';
  String _selectedPromotionType = 'All Types';
  String _selectedAcademicYear = '';

  // Selection states
  List<String> _selectedStudentIds = [];

  // Bulk promotion states
  String? _selectedFromClassId;
  String? _selectedToClassId;
  String? _selectedFromClassName;
  String? _selectedToClassName;
  List<PromotionEligibleStudent> _bulkPromotionStudents = [];
  bool _isBulkPromotionLoading = false;

  // Toggle for showing/hiding statistics and filters
  bool _showStatisticsAndFilters = true;

  // Pagination (for future use)
  // int _currentPage = 1;
  // final int _itemsPerPage = 50;
  // bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAcademicYear();
      _loadClasses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _loadAcademicYear() {
    final academicYearService = GlobalAcademicYearService();
    setState(() {
      _selectedAcademicYear = academicYearService.currentAcademicYearString;
    });
  }

  Future<void> _loadClasses() async {
    await ref
        .read(RiverpodProvider.classProvider.notifier)
        .getAllClassesWithMetric(context);
  }

  Future<void> _loadEligibleStudents() async {
    if (_selectedClass == 'All Classes') return;

    final classState = ref.read(RiverpodProvider.classProvider);
    final classIds = _getClassIdsFromLevel(_selectedClass, classState);
    final classId = classIds.isNotEmpty ? classIds.first : null;

    if (classId != null) {
      await ref
          .read(promotionEligibleProvider.notifier)
          .getPromotionEligibleStudents(
            classId: classId,
            academicYear: _selectedAcademicYear,
          );
    }
  }

  List<String> _getClassIdsFromLevel(
    String classLevel,
    ClassProvider classProvider,
  ) {
    final classes = classProvider.classData.classes ?? [];
    return classes
        .where((cls) => cls.level == classLevel)
        .map((cls) => cls.id ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
  }

  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadEligibleStudents();
    });
  }

  void _onScroll() {
    // Handle scroll for load more if needed
  }

  // void _onFilterChanged() {
  //   _loadEligibleStudents();
  // }

  void _onClassChanged(String? value) {
    setState(() {
      _selectedClass = value ?? 'All Classes';
      _selectedStudentIds.clear();
    });
    _loadEligibleStudents();
  }

  void _onPromotionTypeChanged(String? value) {
    setState(() {
      _selectedPromotionType = value ?? 'All Types';
    });
  }

  // Bulk promotion methods
  Future<void> _loadStudentsForBulkPromotion(String classId) async {
    setState(() {
      _isBulkPromotionLoading = true;
    });

    try {
      await ref
          .read(promotionEligibleProvider.notifier)
          .getPromotionEligibleStudents(
            classId: classId,
            academicYear: _selectedAcademicYear,
          );

      final promotionState = ref.read(promotionEligibleProvider);
      setState(() {
        _bulkPromotionStudents = promotionState.students;
        _isBulkPromotionLoading = false;
      });
    } catch (e) {
      setState(() {
        _isBulkPromotionLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading students: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _performBulkPromotion() async {
    if (_selectedFromClassId == null || _selectedToClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both source and destination classes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_bulkPromotionStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No students found in the selected class'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isBulkPromotionLoading = true;
    });

    try {
      final studentIds =
          _bulkPromotionStudents.map((student) => student.id).toList();

      final response = await ref
          .read(promotionEligibleProvider.notifier)
          .promoteStudents(
            fromClassId: _selectedFromClassId!,
            toClassId: _selectedToClassId!,
            academicYear: _selectedAcademicYear,
            term: 'First', // You can make this configurable
            promotionType: 'promoted',
            studentIds: studentIds,
            processedBy:
                '68bcd2bdd7349a8d4073bfb3', // This should come from user context
          );

      if (response) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully promoted ${studentIds.length} students from $_selectedFromClassName to $_selectedToClassName',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Reset selections
        setState(() {
          _selectedFromClassId = null;
          _selectedToClassId = null;
          _selectedFromClassName = null;
          _selectedToClassName = null;
          _bulkPromotionStudents.clear();
        });
      } else {}
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error promoting students: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isBulkPromotionLoading = false;
      });
    }
  }

  void _toggleStudentSelection(String studentId) {
    setState(() {
      if (_selectedStudentIds.contains(studentId)) {
        _selectedStudentIds.remove(studentId);
      } else {
        _selectedStudentIds.add(studentId);
      }
    });
  }

  // void _toggleSelectAll() {
  //   setState(() {
  //     _selectAll = !_selectAll;
  //     if (_selectAll) {
  //       _selectedStudentIds = _getFilteredStudents().map((s) => s.id).toList();
  //     } else {
  //       _selectedStudentIds.clear();
  //     }
  //   });
  // }

  List<PromotionEligibleStudent> _getFilteredStudents() {
    final state = ref.read(promotionEligibleProvider);
    var students = state.students;

    // Filter by promotion type
    if (_selectedPromotionType != 'All Types') {
      if (_selectedPromotionType == 'Eligible') {
        students = students.where((s) => s.isEligible).toList();
      } else if (_selectedPromotionType == 'Not Eligible') {
        students = students.where((s) => !s.isEligible).toList();
      }
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      students =
          students
              .where(
                (s) =>
                    s.name.toLowerCase().contains(query) ||
                    s.admissionNumber.toLowerCase().contains(query) ||
                    s.parentName.toLowerCase().contains(query),
              )
              .toList();
    }

    return students;
  }

  Future<void> _promoteSelectedStudents() async {
    if (_selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select students to promote')),
      );
      return;
    }

    final classState = ref.read(RiverpodProvider.classProvider);
    final classIds = _getClassIdsFromLevel(_selectedClass, classState);
    final fromClassId = classIds.isNotEmpty ? classIds.first : null;

    if (fromClassId == null) return;

    // Show promotion dialog
    _showPromotionDialog(fromClassId, _selectedStudentIds);
  }

  Future<void> _promoteAllEligibleStudents() async {
    final eligibleStudents =
        _getFilteredStudents()
            .where((s) => s.isEligible)
            .map((s) => s.id)
            .toList();

    if (eligibleStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No eligible students found')),
      );
      return;
    }

    final classState = ref.read(RiverpodProvider.classProvider);
    final classIds = _getClassIdsFromLevel(_selectedClass, classState);
    final fromClassId = classIds.isNotEmpty ? classIds.first : null;

    if (fromClassId == null) return;

    _showPromotionDialog(fromClassId, eligibleStudents);
  }

  void _showPromotionDialog(String fromClassId, List<String> studentIds) {
    showDialog(
      context: context,
      builder:
          (context) => PromotionDialog(
            fromClassId: fromClassId,
            studentIds: studentIds,
            academicYear: _selectedAcademicYear,
            availableClasses:
                ref.read(promotionEligibleProvider).availableClasses,
            onPromote: (toClassId, promotionType) async {
              final success = await ref
                  .read(promotionEligibleProvider.notifier)
                  .promoteStudents(
                    fromClassId: fromClassId,
                    toClassId: toClassId,
                    academicYear: _selectedAcademicYear,
                    studentIds: studentIds,
                    promotionType: promotionType,
                  );

              if (success) {
                setState(() {
                  _selectedStudentIds.clear();
                });
                _loadEligibleStudents();
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final promotionState = ref.watch(promotionEligibleProvider);
    final classState = ref.watch(RiverpodProvider.classProvider);
    final filteredStudents = _getFilteredStudents();
    final classOptions = _getClassOptions(classState);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Student Promotion Manager',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'View, select, and promote students to the next class or academic session',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
                // Toggle Statistics and Filters Button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showStatisticsAndFilters = !_showStatisticsAndFilters;
                    });
                  },
                  icon: Icon(
                    _showStatisticsAndFilters
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color:
                        _showStatisticsAndFilters
                            ? Colors.white
                            : Color(0xFF64748B),
                    size: 18,
                  ),
                  label: Text(
                    _showStatisticsAndFilters ? 'Hide Cards' : 'Show Cards',
                    style: TextStyle(
                      color:
                          _showStatisticsAndFilters
                              ? Colors.white
                              : Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _showStatisticsAndFilters
                            ? Color(0xFF64748B)
                            : Colors.grey[100],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: _showStatisticsAndFilters ? 2 : 0,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => context.go('/promotions/history'),
                  icon: const Icon(Icons.history, color: Colors.white),
                  label: const Text(
                    'View History',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
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
            const SizedBox(height: 32),

            // Scrollable content
            Expanded(
              child:
                  _showStatisticsAndFilters
                      ? SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Statistics Cards
                            _buildStatisticsCards(
                              promotionState,
                              filteredStudents,
                            ),
                            const SizedBox(height: 32),

                            // Search and Filters
                            _buildSearchAndFilters(classOptions),
                            const SizedBox(height: 24),

                            // Bulk Promotion Section
                            _buildBulkPromotionSection(classState),
                            const SizedBox(height: 24),

                            // Filter Status Indicator
                            _buildFilterStatusIndicator(),
                            const SizedBox(height: 24),

                            // Data Table
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: _buildStudentsTable(
                                filteredStudents,
                                promotionState.isLoading,
                                promotionState.errorMessage,
                              ),
                            ),
                          ],
                        ),
                      )
                      : Column(
                        children: [
                          // Data Table (expanded to fill space)
                          Expanded(
                            child: _buildStudentsTable(
                              filteredStudents,
                              promotionState.isLoading,
                              promotionState.errorMessage,
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

  List<String> _getClassOptions(ClassProvider classProvider) {
    final classes = classProvider.classData.classes ?? [];
    final classLevels =
        classes
            .map((cls) => cls.level ?? '')
            .where((level) => level.isNotEmpty)
            .toSet()
            .toList();
    return ['All Classes', ...classLevels];
  }

  Widget _buildBulkPromotionSection(ClassProvider classProvider) {
    final classes = classProvider.classData.classes ?? [];

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
            children: [
              Icon(Icons.group_add, color: AppColors.secondary, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Bulk Promotion',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Promote all students from one class to another class',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          // Class Selection Row
          Row(
            children: [
              // From Class Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'From Class',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedFromClassId,
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
                      hint: const Text('Select source class'),
                      items:
                          classes.map((cls) {
                            return DropdownMenuItem(
                              value: cls.id,
                              child: Text('${cls.name} (${cls.level})'),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFromClassId = value;
                          _selectedFromClassName =
                              classes.firstWhere((cls) => cls.id == value).name;
                          _bulkPromotionStudents.clear();
                        });
                        if (value != null) {
                          _loadStudentsForBulkPromotion(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Arrow Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // To Class Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To Class',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedToClassId,
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
                      hint: const Text('Select destination class'),
                      items:
                          classes.map((cls) {
                            return DropdownMenuItem(
                              value: cls.id,
                              child: Text('${cls.name} (${cls.level})'),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedToClassId = value;
                          _selectedToClassName =
                              classes.firstWhere((cls) => cls.id == value).name;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Students Count and Promotion Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Students Count
              if (_selectedFromClassId != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _isBulkPromotionLoading
                            ? 'Loading...'
                            : '${_bulkPromotionStudents.length} students',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Promotion Button
              ElevatedButton.icon(
                onPressed:
                    (_selectedFromClassId != null &&
                            _selectedToClassId != null &&
                            _bulkPromotionStudents.isNotEmpty &&
                            !_isBulkPromotionLoading)
                        ? _performBulkPromotion
                        : null,
                icon:
                    _isBulkPromotionLoading
                        ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.group_add, size: 18),
                label: Text(
                  _isBulkPromotionLoading
                      ? 'Processing...'
                      : 'Promote All Students',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
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
    );
  }

  Widget _buildStatisticsCards(
    PromotionEligibleState state,
    List<PromotionEligibleStudent> filteredStudents,
  ) {
    final summary = state.summary;
    final eligibleCount = filteredStudents.where((s) => s.isEligible).length;
    final ineligibleCount = filteredStudents.where((s) => !s.isEligible).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Students',
            value: summary?.totalStudents.toString() ?? '0',
            icon: Icons.groups,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Eligible',
            value: eligibleCount.toString(),
            icon: Icons.check_circle,
            color: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Not Eligible',
            value: ineligibleCount.toString(),
            icon: Icons.cancel,
            color: const Color(0xFFEF4444),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Selected',
            value: _selectedStudentIds.length.toString(),
            icon: Icons.checklist,
            color: const Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(List<String> classOptions) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // First Row - Search and Basic Filters
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => _onSearchChanged(),
                  decoration: InputDecoration(
                    hintText:
                        'Search by name, admission number, or parent name...',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Color(0xFF94A3B8),
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged();
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF6366F1)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 200,
                child: _buildFilterDropdown(
                  value: _selectedClass,
                  items:
                      classOptions
                          .map(
                            (option) => DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            ),
                          )
                          .toList(),
                  onChanged: _onClassChanged,
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 150,
                child: _buildFilterDropdown(
                  value: _selectedPromotionType,
                  items: [
                    DropdownMenuItem(
                      value: 'All Types',
                      child: Text('All Types'),
                    ),
                    DropdownMenuItem(
                      value: 'Eligible',
                      child: Text('Eligible'),
                    ),
                    DropdownMenuItem(
                      value: 'Not Eligible',
                      child: Text('Not Eligible'),
                    ),
                  ],
                  onChanged: _onPromotionTypeChanged,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              ElevatedButton.icon(
                onPressed:
                    _selectedStudentIds.isNotEmpty
                        ? _promoteSelectedStudents
                        : null,
                icon: Icon(Icons.arrow_upward, size: 16),
                label: Text('Promote Selected (${_selectedStudentIds.length})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed:
                    _getFilteredStudents().any((s) => s.isEligible)
                        ? _promoteAllEligibleStudents
                        : null,
                icon: Icon(Icons.group, size: 16),
                label: Text('Promote All Eligible'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedStudentIds.clear();
                  });
                },
                icon: Icon(Icons.clear, size: 16),
                label: Text('Clear Selection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
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

  Widget _buildFilterStatusIndicator() {
    final activeFilters = <String>[];

    if (_selectedClass != 'All Classes') {
      activeFilters.add('Class: $_selectedClass');
    }
    if (_selectedPromotionType != 'All Types') {
      activeFilters.add('Type: $_selectedPromotionType');
    }
    if (_searchController.text.isNotEmpty) {
      activeFilters.add('Search: ${_searchController.text}');
    }

    if (activeFilters.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            activeFilters
                .map(
                  (filter) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(0xFF6366F1).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            if (filter.startsWith('Class:')) {
                              _onClassChanged('All Classes');
                            } else if (filter.startsWith('Type:')) {
                              _onPromotionTypeChanged('All Types');
                            } else if (filter.startsWith('Search:')) {
                              _searchController.clear();
                              _onSearchChanged();
                            }
                          },
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildStudentsTable(
    List<PromotionEligibleStudent> students,
    bool isLoading,
    String? errorMessage,
  ) {
    if (isLoading) {
      return Container(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
              SizedBox(height: 16),
              Text(
                'Error loading students: $errorMessage',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadEligibleStudents,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (students.isEmpty) {
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
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: 50, child: _buildHeaderCell('Select')),
                Expanded(flex: 3, child: _buildHeaderCell('STUDENT')),
                Expanded(flex: 2, child: _buildHeaderCell('ADMISSION NO.')),
                Expanded(flex: 1, child: _buildHeaderCell('GENDER')),
                Expanded(flex: 1, child: _buildHeaderCell('PARENT')),
                Expanded(flex: 1, child: _buildHeaderCell('FEE STATUS')),
                Expanded(flex: 1, child: _buildHeaderCell('ELIGIBILITY')),
                SizedBox(width: 100, child: _buildHeaderCell('ACTIONS')),
              ],
            ),
          ),
          // Student Rows
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return _buildStudentRow(student, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title) {
    return Text(
      title,
      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
    );
  }

  Widget _buildStudentRow(PromotionEligibleStudent student, int rowNumber) {
    final isSelected = _selectedStudentIds.contains(student.id);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        color: isSelected ? Color(0xFF6366F1).withOpacity(0.05) : null,
      ),
      child: Row(
        children: [
          // Selection Checkbox
          SizedBox(
            width: 50,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) => _toggleStudentSelection(student.id),
              activeColor: Color(0xFF6366F1),
            ),
          ),
          // Student Info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF6366F1).withOpacity(0.1),
                  child: Text(
                    student.name.isNotEmpty
                        ? student.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Age: ${student.age}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Admission Number
          Expanded(flex: 2, child: Text(student.admissionNumber)),
          // Gender
          Expanded(flex: 1, child: Text(student.gender)),
          // Parent
          Expanded(flex: 1, child: Text(student.parentName)),
          // Fee Status
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    student.feeStatus == 'paid'
                        ? Color(0xFF10B981).withOpacity(0.1)
                        : student.feeStatus == 'partial'
                        ? Color(0xFFF59E0B).withOpacity(0.1)
                        : Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                student.feeStatus.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color:
                      student.feeStatus == 'paid'
                          ? Color(0xFF10B981)
                          : student.feeStatus == 'partial'
                          ? Color(0xFFF59E0B)
                          : Color(0xFFEF4444),
                ),
              ),
            ),
          ),
          // Eligibility
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    student.isEligible
                        ? Color(0xFF10B981).withOpacity(0.1)
                        : Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                student.isEligible ? 'ELIGIBLE' : 'NOT ELIGIBLE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color:
                      student.isEligible
                          ? Color(0xFF10B981)
                          : Color(0xFFEF4444),
                ),
              ),
            ),
          ),
          // Actions
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        student.isEligible ? AppColors.secondary : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size(0, 0),
                  ),
                  onPressed:
                      student.isEligible
                          ? () => _showPromotionDialog(
                            ref
                                    .read(promotionEligibleProvider)
                                    .currentClass
                                    ?.id ??
                                '',
                            [student.id],
                          )
                          : null,
                  child: Text('Promote', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PromotionDialog extends StatefulWidget {
  final String fromClassId;
  final List<String> studentIds;
  final String academicYear;
  final List<AvailableClass> availableClasses;
  final Function(String?, String) onPromote;

  const PromotionDialog({
    super.key,
    required this.fromClassId,
    required this.studentIds,
    required this.academicYear,
    required this.availableClasses,
    required this.onPromote,
  });

  @override
  State<PromotionDialog> createState() => _PromotionDialogState();
}

class _PromotionDialogState extends State<PromotionDialog> {
  String? _selectedToClassId;
  String _promotionType = 'promoted';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Promote Students'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Promoting ${widget.studentIds.length} student(s)'),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _promotionType,
            decoration: InputDecoration(
              labelText: 'Promotion Type',
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: 'promoted',
                child: Text('Promote to Next Class'),
              ),
              DropdownMenuItem(
                value: 'repeated',
                child: Text('Repeat Same Class'),
              ),
              DropdownMenuItem(value: 'graduated', child: Text('Graduate')),
            ],
            onChanged: (value) {
              setState(() {
                _promotionType = value ?? 'promoted';
                if (_promotionType == 'graduated' ||
                    _promotionType == 'repeated') {
                  _selectedToClassId = null;
                }
              });
            },
          ),
          if (_promotionType == 'promoted') ...[
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedToClassId,
              decoration: InputDecoration(
                labelText: 'To Class',
                border: OutlineInputBorder(),
              ),
              items:
                  widget.availableClasses
                      .where((cls) => cls.availableSlots > 0)
                      .map(
                        (cls) => DropdownMenuItem(
                          value: cls.id,
                          child: Text(
                            '${cls.name} (${cls.availableSlots} slots)',
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedToClassId = value;
                });
              },
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              _promotionType == 'promoted' && _selectedToClassId == null
                  ? null
                  : () {
                    Navigator.of(context).pop();
                    widget.onPromote(_selectedToClassId, _promotionType);
                  },
          child: Text('Promote'),
        ),
      ],
    );
  }
}
