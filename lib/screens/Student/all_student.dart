import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/student_model.dart';
import 'package:schmgtsystem/providers/student_provider.dart';
import 'package:schmgtsystem/providers/class_provider.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/screens/Student/single_student.dart';

class AllStudentsScreen extends ConsumerStatefulWidget {
  const AllStudentsScreen({super.key});

  @override
  ConsumerState<AllStudentsScreen> createState() => _AllStudentsScreenState();
}

class _AllStudentsScreenState extends ConsumerState<AllStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _tableScrollController = ScrollController();

  // Filter states
  String _selectedClass = 'All Classes';
  String _selectedGender = 'All Genders';
  String _selectedFeeStatus = 'All Status';

  // Pagination for loading more students
  int _currentPage = 1;
  final int _itemsPerPage = 50; // Load 50 students per page
  bool _isLoadingMore = false;
  //
//
  // Flag to track if we need to reload when returning to screen
  bool _shouldReloadOnReturn = false;
// 
  // Toggle for showing/hiding statistics and filters
  bool _showStatisticsAndFilters = true;

  // Get class options from ClassProvider
  List<String> _getClassOptions(ClassProvider classProvider) {
    final classes = classProvider.classData.classes ?? [];
    final classLevels =
        classes
            .map((cls) => cls.level ?? '')
            .where((level) => level.isNotEmpty)
            .toSet() // Use Set to ensure uniqueness
            .toList();
    return ['All Classes', ...classLevels];
  }

  // Get class IDs from class level (returns all classes with that level)
  List<String> _getClassIdsFromLevel(
    String classLevel,
    ClassProvider classProvider,
  ) {
    if (classLevel == 'All Classes') return [];

    final classes = classProvider.classData.classes ?? [];
    if (classes.isEmpty) {
      print('Warning: No classes loaded yet, cannot filter by class level');
      return [];
    }

    return classes
        .where((cls) => cls.level == classLevel && cls.id != null)
        .map((cls) => cls.id!)
        .toList();
  }

  final List<String> _genderOptions = ['All Genders', 'male', 'female'];

  final List<String> _feeStatusOptions = [
    'All Status',
    'paid',
    'partial',
    'pending',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _tableScrollController.addListener(_onTableScroll);

    // Use WidgetsBinding to defer the loading until after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudents();
      _loadClasses();
    });
  }

  Future<void> _loadClasses() async {
    await ref
        .read(RiverpodProvider.classProvider.notifier)
        .getAllClassesWithMetric(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload students if we're returning from add student screen
    if (_shouldReloadOnReturn) {
      _shouldReloadOnReturn = false;
      _loadStudents();
    }
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
      // Check if student's class ID is in the list of class IDs for this level
      return classIds.contains(student.academicInfo.currentClass?.id);
    }).toList();
  }

  // Check if there are more students available for the current filter
  bool _hasMoreFilteredStudents(
    List<StudentModel> filteredStudents,
    ClassProvider classProvider,
  ) {
    // Get pagination info from the current state
    final studentState = ref.read(studentProvider);
    final pagination = studentState.pagination;

    // If no pagination info, return false
    if (pagination == null) return false;

    // Check if we have reached the total number of students
    if (filteredStudents.length >= pagination.totalStudents) {
      return false;
    }

    // Check if there are more pages available
    if (!pagination.hasNext) {
      return false;
    }

    // If no class filter is applied, check if we have more students from API
    if (_selectedClass == 'All Classes') {
      return pagination.hasNext;
    }

    // For class level filtering, we need to check if there might be more students
    // with this class level in the remaining data
    final allStudents = studentState.students;
    final classIds = _getClassIdsFromLevel(_selectedClass, classProvider);

    // Count how many students with this class level we currently have
    final currentCount =
        allStudents.where((student) {
          return classIds.contains(student.academicInfo.currentClass?.id);
        }).length;

    // If we have fewer students than expected, there might be more
    // This is a simple heuristic - if we have loaded students but fewer than expected
    // for this class level, there might be more to load
    return pagination.hasNext && currentCount > 0;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents({bool loadMore = false}) async {
    if (loadMore) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    // Load students with pagination
    await ref
        .read(studentProvider.notifier)
        .getAllStudents(
          context,
          page: loadMore ? _currentPage + 1 : 1,
          limit: _itemsPerPage,
          classId: null, // Don't filter by class on API level
          gender: _selectedGender == 'All Genders' ? null : _selectedGender,
          feeStatus:
              _selectedFeeStatus == 'All Status' ? null : _selectedFeeStatus,
          search:
              _searchController.text.trim().isEmpty
                  ? null
                  : _searchController.text.trim(),
          loadMore: loadMore,
        );

    if (loadMore) {
      setState(() {
        _currentPage++;
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _currentPage = 1;
      });
    }
  }

  Future<void> _loadMoreStudents() async {
    // Store the current number of students before loading more
    final currentStudentCount = ref.read(studentProvider).students.length;

    await _loadStudents(loadMore: true);

    // After loading more students, scroll to show the newly loaded students
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tableScrollController.hasClients) {
        // Calculate the position to scroll to (approximately where new students start)
        final newStudentCount = ref.read(studentProvider).students.length;
        if (newStudentCount > currentStudentCount) {
          // Scroll to show the newly loaded students
          // Each student row is approximately 80 pixels high
          final scrollPosition = (currentStudentCount * 80).toDouble();
          _tableScrollController.animateTo(
            scrollPosition,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _onScroll() {
    // Removed automatic load more on scroll
    // Load more is now only triggered by button click
  }

  void _onTableScroll() {
    // When table reaches bottom, continue scrolling the main scroll view down
    if (_tableScrollController.position.pixels >=
        _tableScrollController.position.maxScrollExtent - 50) {
      // If table is at bottom and main scroll can still scroll, continue scrolling
      if (_scrollController.hasClients &&
          _scrollController.position.pixels <
              _scrollController.position.maxScrollExtent) {
        _scrollController.animateTo(
          _scrollController.position.pixels + 100,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    }

    // When table reaches top, scroll the main scroll view up to show statistics cards
    if (_tableScrollController.position.pixels <= 50) {
      // If table is at top and main scroll can still scroll up, continue scrolling
      if (_scrollController.hasClients &&
          _scrollController.position.pixels > 0) {
        _scrollController.animateTo(
          _scrollController.position.pixels - 100,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _onSearchChanged() {
    _loadStudents();
  }

  void _onFilterChanged() {
    _loadStudents();
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
                      'All Students',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Browse, search, and manage students across all classes',
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
                  onPressed: () {
                    _shouldReloadOnReturn = true;
                    context.go('/students/add');
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Add New Student',
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
                            _buildStatisticsCards(
                              students,
                              pagination,
                              classOptions,
                            ),
                            const SizedBox(height: 32),

                            // Search and Filters
                            _buildSearchAndFilters(classOptions),

                            // Filter Status Indicator
                            _buildFilterStatusIndicator(),

                            const SizedBox(height: 24),

                            // Data Table with fixed height
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.6, // 60% of screen height
                              child: _buildDataTable(
                                students,
                                isLoading,
                                errorMessage,
                              ),
                            ),

                            // Load More Button or All Students Loaded Message
                            if (!isLoading && students.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      // Student count info
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          'Showing ${students.length} of ${pagination?.totalStudents ?? 0} students',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Show load more button or all loaded message
                                      if (_hasMoreFilteredStudents(
                                        students,
                                        classState,
                                      ))
                                        // Load more button
                                        ElevatedButton.icon(
                                          onPressed:
                                              _isLoadingMore
                                                  ? null
                                                  : _loadMoreStudents,
                                          icon:
                                              _isLoadingMore
                                                  ? SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  )
                                                  : Icon(Icons.add, size: 16),
                                          label: Text(
                                            _isLoadingMore
                                                ? 'Loading...'
                                                : 'Load More Students (${pagination?.currentPageStudents ?? 0} more)',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.secondary,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        )
                                      else
                                        // All students loaded message
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.green[200]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green[600],
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'All students loaded',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.green[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                      : Column(
                        children: [
                          // Data Table (expanded to fill space)
                          Expanded(
                            child: _buildDataTable(
                              students,
                              isLoading,
                              errorMessage,
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
            value: (pagination?.totalStudents ?? 0).toString(),
            icon: Icons.school,
            color: const Color(0xFF059669),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Filtered Students',
            value: students.length.toString(),
            icon: Icons.groups,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Class Levels',
            value: classOptions.length.toString(),
            icon: Icons.class_,
            color: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Avg per Class Level',
            value:
                classOptions.length > 1
                    ? (students.length /
                            (classOptions.length -
                                1)) // Subtract 1 for "All Classes"
                        .round()
                        .toString()
                    : '0',
            icon: Icons.bar_chart,
            color: const Color(0xFF06B6D4),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Male Students',
            value:
                students
                    .where((s) => s.personalInfo.gender.toLowerCase() == 'male')
                    .length
                    .toString(),
            icon: Icons.male,
            color: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Female Students',
            value:
                students
                    .where(
                      (s) => s.personalInfo.gender.toLowerCase() == 'female',
                    )
                    .length
                    .toString(),
            icon: Icons.female,
            color: const Color(0xFFEC4899),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(List<String> classOptions) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _onSearchChanged(),
            decoration: InputDecoration(
              hintText: 'Search by name, admission number, or parent name...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF6366F1)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildDropdown(classOptions, _selectedClass, (value) {
          setState(() => _selectedClass = value!);
          _onFilterChanged();
        }),
        const SizedBox(width: 16),
        _buildDropdown(_genderOptions, _selectedGender, (value) {
          setState(() => _selectedGender = value!);
          _onFilterChanged();
        }),
        const SizedBox(width: 16),
        _buildDropdown(_feeStatusOptions, _selectedFeeStatus, (value) {
          setState(() => _selectedFeeStatus = value!);
          _onFilterChanged();
        }),
      ],
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
      activeFilters.add('Fee Status: $_selectedFeeStatus');
    }
    if (_searchController.text.trim().isNotEmpty) {
      activeFilters.add('Search: "${_searchController.text.trim()}"');
    }

    if (activeFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF0EA5E9), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Color(0xFF0EA5E9), size: 20),
          const SizedBox(width: 8),
          Text(
            'Active Filters: ${activeFilters.join(', ')}',
            style: const TextStyle(
              color: Color(0xFF0EA5E9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedClass = 'All Classes';
                _selectedGender = 'All Genders';
                _selectedFeeStatus = 'All Status';
                _searchController.clear();
              });
              _onFilterChanged();
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Color(0xFF0EA5E9)),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 16, color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStudents,
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
            Icon(Icons.school_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No students found',
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
                const Expanded(
                  flex: 1,
                  child: Text(
                    'NO.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: Text(
                    'STUDENT',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'ADMISSION NO.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    'CLASS LEVEL',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    'GENDER',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 1,
                  child: Text(
                    'FEE STATUS',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
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
                  flex: 1,
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
              itemCount: students.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the bottom when loading more
                if (index == students.length) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                final student = students[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Row Number
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
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
                                          student
                                              .personalInfo
                                              .profileImage!
                                              .isEmpty
                                      ? Text(
                                        student.personalInfo.firstName[0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Age: ${student.age}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Admission No
                      Expanded(flex: 2, child: Text(student.admissionNumber)),

                      // Class Level
                      Expanded(flex: 1, child: Text(student.classLevel)),

                      // Gender
                      Expanded(
                        flex: 1,
                        child: Text(student.personalInfo.gender),
                      ),

                      // Fee Status
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getFeeStatusColor(
                              student.financialInfo.feeStatus,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            student.financialInfo.feeStatus,
                            style: TextStyle(
                              color: _getFeeStatusColor(
                                student.financialInfo.feeStatus,
                              ),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      // Parent Name
                      Expanded(flex: 2, child: Text(student.parentName)),

                      // Actions
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => SingleStudent(
                                          studentId: student.id ?? '',
                                        ),
                                  ),
                                );

                                // If student was updated, reload the students list
                                if (result == true) {
                                  _loadStudents();
                                }
                              },
                              icon: const Icon(
                                Icons.visibility,
                                color: Color(0xFF6366F1),
                                size: 18,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _showDeleteDialog(student);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
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
      padding: const EdgeInsets.all(10),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    List<String> options,
    String value,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(options[0]),
        underline: const SizedBox(),
        items:
            options.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.red,
    ];
    return colors[name.hashCode % colors.length];
  }

  Color _getFeeStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(StudentModel student) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFEF4444),
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Delete Student',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete this student?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 16),

                // Student Info Card
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      // Student Avatar
                      CircleAvatar(
                        radius: 24,
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
                                    fontSize: 16,
                                  ),
                                )
                                : null,
                      ),
                      SizedBox(width: 12),

                      // Student Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.fullName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              student.admissionNumber,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              student.classLevel,
                              style: TextStyle(
                                fontSize: 13,
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

                // Warning Message
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFFDC2626),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This action cannot be undone. All student data, including academic records, will be permanently deleted.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFDC2626),
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteStudent(student.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Delete Student',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Future<void> _deleteStudent(String studentId) async {
    await ref.read(studentProvider.notifier).deleteStudent(context, studentId);
  }
}
