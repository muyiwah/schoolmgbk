import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/student_model.dart';
import 'package:schmgtsystem/models/class_metrics_model.dart';
import 'package:schmgtsystem/providers/student_provider.dart';
import 'package:schmgtsystem/providers/class_provider.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';

class ManageStudentClass extends ConsumerStatefulWidget {
  const ManageStudentClass({super.key});

  @override
  ConsumerState<ManageStudentClass> createState() => _ManageStudentClassState();
}

class _ManageStudentClassState extends ConsumerState<ManageStudentClass> {
  final TextEditingController _searchController = TextEditingController();

  // Filter states
  String _selectedClass = 'All Classes';
  String _selectedGender = 'All Genders';
  String _selectedFeeStatus = 'All Status';
  String _selectedSortBy = 'name';
  String _selectedSortOrder = 'asc';

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 50;
  bool _hasMoreStudents = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudents();
      _loadClasses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    await ref
        .read(RiverpodProvider.classProvider.notifier)
        .getAllClassesWithMetric(context);
  }

  Future<void> _loadStudents({bool loadMore = false}) async {
    if (loadMore) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    final classState = ref.read(RiverpodProvider.classProvider);
    final classIds = _getClassIdsFromLevel(_selectedClass, classState);
    final classId = classIds.isNotEmpty ? classIds.first : null;

    await ref
        .read(studentProvider.notifier)
        .getAllStudents(
          context,
          page: loadMore ? _currentPage + 1 : 1,
          limit: _itemsPerPage,
          classId: classId,
          gender: _selectedGender == 'All Genders' ? null : _selectedGender,
          feeStatus:
              _selectedFeeStatus == 'All Status' ? null : _selectedFeeStatus,
          search:
              _searchController.text.trim().isEmpty
                  ? null
                  : _searchController.text.trim(),
          sortBy: _selectedSortBy,
          sortOrder: _selectedSortOrder,
        );

    if (loadMore) {
      setState(() {
        _currentPage++;
        _isLoadingMore = false;
        final studentState = ref.read(studentProvider);
        final pagination = studentState.pagination;
        _hasMoreStudents = pagination != null && pagination.hasNext;
      });
    } else {
      setState(() {
        _currentPage = 1;
        final studentState = ref.read(studentProvider);
        final pagination = studentState.pagination;
        _hasMoreStudents = pagination != null && pagination.hasNext;
      });
    }
  }

  Future<void> _loadMoreStudents() async {
    await _loadStudents(loadMore: true);
  }

  void _onSearchChanged() {
    _loadStudents();
  }

  void _onFilterChanged() {
    _loadStudents();
  }

  void _onSortChanged() {
    _loadStudents();
  }

  // Get class options from ClassProvider
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

  // Get class IDs from class level
  List<String> _getClassIdsFromLevel(
    String classLevel,
    ClassProvider classProvider,
  ) {
    if (classLevel == 'All Classes') return [];

    final classes = classProvider.classData.classes ?? [];
    if (classes.isEmpty) return [];

    return classes
        .where((cls) => cls.level == classLevel && cls.id != null)
        .map((cls) => cls.id!)
        .toList();
  }

  // Filter students by class level client-side
  List<StudentModel> _filterStudentsByClassLevel(
    List<StudentModel> students,
    ClassProvider classProvider,
  ) {
    if (_selectedClass == 'All Classes') return students;

    final classIds = _getClassIdsFromLevel(_selectedClass, classProvider);
    if (classIds.isEmpty) return students;

    return students.where((student) {
      return classIds.contains(student.academicInfo.currentClass?.id);
    }).toList();
  }

  Future<void> _assignStudentToClass(StudentModel student) async {
    final classState = ref.read(RiverpodProvider.classProvider);
    final classes = classState.classData.classes ?? [];

    if (classes.isEmpty) {
      showSnackbar(context, 'No classes available');
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.school, color: Color(0xFF6366F1)),
                SizedBox(width: 8),
                Text(
                  'Assign to Class',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: _getAvatarColor(
                          student.personalInfo.firstName,
                        ),
                        backgroundImage:
                            student.personalInfo.profileImage != null &&
                                    student
                                        .personalInfo
                                        .profileImage!
                                        .isNotEmpty
                                ? NetworkImage(
                                  student.personalInfo.profileImage!,
                                )
                                : null,
                        child:
                            student.personalInfo.profileImage == null ||
                                    student.personalInfo.profileImage!.isEmpty
                                ? Text(
                                  student.personalInfo.firstName[0]
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                )
                                : null,
                      ),
                      SizedBox(width: 12),
                      Expanded(
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
                            Text(
                              student.admissionNumber,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              'Current: ${student.classLevel}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Select Class:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: null,
                      hint: Text('Choose a class'),
                      items:
                          classes.map((cls) {
                            return DropdownMenuItem<String>(
                              value: cls.id,
                              child: Text('${cls.level} ${cls.section ?? ''}'),
                            );
                          }).toList(),
                      onChanged: (String? classId) {
                        if (classId != null) {
                          Navigator.of(context).pop();
                          _confirmAssignment(
                            student,
                            classId,
                            classes.firstWhere((c) => c.id == classId),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmAssignment(
    StudentModel student,
    String classId,
    Class classData,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
                SizedBox(width: 8),
                Text(
                  'Confirm Assignment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Assign ${student.fullName} to ${classData.level} ${classData.section ?? ''}?',
                  style: TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 16),
                if (student.academicInfo.currentClass != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Student will be reassigned from ${student.classLevel}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF92400E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final success = await ref
                      .read(studentProvider.notifier)
                      .assignStudentToClass(context, student.id, {
                        "classId": classId,
                      });

                  if (success) {
                    _loadStudents(); // Refresh the list
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF10B981),
                  foregroundColor: Colors.white,
                ),
                child: Text('Assign'),
              ),
            ],
          ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF06B6D4),
    ];
    return colors[name.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentProvider);
    final classState = ref.watch(RiverpodProvider.classProvider);
    final allStudents = studentState.students;
    final pagination = studentState.pagination;
    final isLoading = studentState.isLoading;
    final errorMessage = studentState.errorMessage;

    // Filter students by class level client-side
    final students = _filterStudentsByClassLevel(allStudents, classState);

    // Get dynamic class options
    final classOptions = _getClassOptions(classState);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/classes'),
                  icon: Icon(Icons.arrow_back, color: Color(0xFF64748B)),
                ),
                SizedBox(width: 8),
                Text(
                  'Manage Student Classes',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Spacer(),
                ElevatedButton.icon(
                  onPressed: () => context.go('/students'),
                  icon: Icon(Icons.people, color: Colors.white),
                  label: Text(
                    'View All Students',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),

            // Statistics Cards
            _buildStatisticsCards(students, pagination, classOptions),
            SizedBox(height: 32),

            // Search and Filters
            _buildSearchAndFilters(classOptions),
            SizedBox(height: 24),

            // Filter Status Indicator
            _buildFilterStatusIndicator(),
            SizedBox(height: 24),

            // Data Table
            Expanded(child: _buildDataTable(students, isLoading, errorMessage)),

            // Load More Button
            if (!isLoading && students.isNotEmpty && _hasMoreStudents)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingMore ? null : _loadMoreStudents,
                    icon:
                        _isLoadingMore
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
                            : Icon(Icons.refresh, size: 16),
                    label: Text(
                      _isLoadingMore ? 'Loading...' : 'Load More Students',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(
    List<StudentModel> students,
    PaginationInfo? pagination,
    List<String> classOptions,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Students',
            value: pagination?.totalStudents.toString() ?? '0',
            icon: Icons.groups,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Filtered Students',
            value: students.length.toString(),
            icon: Icons.filter_list,
            color: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Class Levels',
            value: classOptions.length.toString(),
            icon: Icons.class_,
            color: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Unassigned',
            value:
                students
                    .where((s) => s.academicInfo.currentClass == null)
                    .length
                    .toString(),
            icon: Icons.person_off,
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
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
                      onChanged: (value) => _onSearchChanged(),
                      decoration: InputDecoration(
                        hintText: 'Search students...',
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
                    onChanged: (value) {
                      setState(() => _selectedClass = value!);
                      _onFilterChanged();
                    },
                  ),
                ),
                SizedBox(width: 12),
                SizedBox(
                  width: 150,
                  child: _buildFilterDropdown(
                    value: _selectedGender,
                    items:
                        ['All Genders', 'male', 'female']
                            .map(
                              (option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() => _selectedGender = value!);
                      _onFilterChanged();
                    },
                  ),
                ),
                SizedBox(width: 12),
                SizedBox(
                  width: 150,
                  child: _buildFilterDropdown(
                    value: _selectedFeeStatus,
                    items:
                        ['All Status', 'paid', 'partial', 'unpaid']
                            .map(
                              (option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() => _selectedFeeStatus = value!);
                      _onFilterChanged();
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // Second Row - Sort Options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: _buildFilterDropdown(
                    value: _selectedSortBy,
                    items: [
                      DropdownMenuItem(
                        value: 'name',
                        child: Text('Sort by Name'),
                      ),
                      DropdownMenuItem(
                        value: 'admissionNumber',
                        child: Text('Sort by ID'),
                      ),
                      DropdownMenuItem(
                        value: 'classLevel',
                        child: Text('Sort by Class'),
                      ),
                      DropdownMenuItem(
                        value: 'gender',
                        child: Text('Sort by Gender'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedSortBy = value!);
                      _onSortChanged();
                    },
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort, color: Color(0xFF94A3B8), size: 16),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSortOrder =
                                _selectedSortOrder == 'asc' ? 'desc' : 'asc';
                          });
                          _onSortChanged();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedSortOrder == 'asc' ? 'A-Z' : 'Z-A',
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

  Widget _buildFilterStatusIndicator() {
    final activeFilters = <String>[];

    if (_selectedClass != 'All Classes') {
      activeFilters.add('Class Level: $_selectedClass');
    }
    if (_selectedGender != 'All Genders') {
      activeFilters.add('Gender: $_selectedGender');
    }
    if (_selectedFeeStatus != 'All Status') {
      activeFilters.add('Status: $_selectedFeeStatus');
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
      child: Row(
        children: [
          Icon(Icons.filter_list, color: Color(0xFF64748B), size: 16),
          SizedBox(width: 8),
          Text(
            'Active Filters: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              children:
                  activeFilters
                      .map(
                        (filter) => Chip(
                          label: Text(filter, style: TextStyle(fontSize: 12)),
                          backgroundColor: Color(0xFF6366F1).withOpacity(0.1),
                          labelStyle: TextStyle(color: Color(0xFF6366F1)),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFF6366F1),
                          ),
                          onDeleted: () {
                            if (filter.startsWith('Class Level:')) {
                              setState(() => _selectedClass = 'All Classes');
                            } else if (filter.startsWith('Gender:')) {
                              setState(() => _selectedGender = 'All Genders');
                            } else if (filter.startsWith('Status:')) {
                              setState(() => _selectedFeeStatus = 'All Status');
                            } else if (filter.startsWith('Search:')) {
                              _searchController.clear();
                            }
                            _onFilterChanged();
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(
    List<StudentModel> students,
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
              ElevatedButton(onPressed: _loadStudents, child: Text('Retry')),
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
                Expanded(flex: 3, child: _buildHeaderCell('STUDENT')),
                Expanded(flex: 2, child: _buildHeaderCell('ADMISSION NO.')),
                Expanded(flex: 1, child: _buildHeaderCell('CLASS LEVEL')),
                Expanded(flex: 1, child: _buildHeaderCell('GENDER')),
                Expanded(flex: 1, child: _buildHeaderCell('STATUS')),
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
                return _buildStudentRow(student);
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

  Widget _buildStudentRow(StudentModel student) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // Student Info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _getAvatarColor(
                    student.personalInfo.firstName,
                  ),
                  backgroundImage:
                      student.personalInfo.profileImage != null &&
                              student.personalInfo.profileImage!.isNotEmpty
                          ? NetworkImage(student.personalInfo.profileImage!)
                          : null,
                  child:
                      student.personalInfo.profileImage == null ||
                              student.personalInfo.profileImage!.isEmpty
                          ? Text(
                            student.personalInfo.firstName[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : null,
                ),
                SizedBox(width: 12),
                Expanded(
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
                        student.parentName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Admission Number
          Expanded(flex: 2, child: Text(student.admissionNumber)),
          // Class Level
          Expanded(flex: 1, child: Text(student.classLevel)),
          // Gender
          Expanded(flex: 1, child: Text(student.personalInfo.gender)),
          // Status
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    student.financialInfo.feeStatus == 'paid'
                        ? Color(0xFF10B981).withOpacity(0.1)
                        : student.financialInfo.feeStatus == 'partial'
                        ? Color(0xFFF59E0B).withOpacity(0.1)
                        : Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                student.financialInfo.feeStatus.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color:
                      student.financialInfo.feeStatus == 'paid'
                          ? Color(0xFF10B981)
                          : student.financialInfo.feeStatus == 'partial'
                          ? Color(0xFFF59E0B)
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
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _assignStudentToClass(student),
                  child: Text('Assign'),
                ),

                // IconButton(
                //   onPressed: () => _assignStudentToClass(student),
                //   icon: Icon(Icons.school, color: Color(0xFF6366F1), size: 16),
                //   padding: EdgeInsets.zero,
                //   constraints: BoxConstraints(),
                // ),
                // SizedBox(width: 8),
                // IconButton(
                //   onPressed: () => context.go('/students/${student.id}'),
                //   icon: Icon(
                //     Icons.visibility_outlined,
                //     color: Color(0xFF94A3B8),
                //     size: 16,
                //   ),
                //   padding: EdgeInsets.zero,
                //   constraints: BoxConstraints(),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
