import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/student_model.dart';
import 'package:schmgtsystem/providers/student_provider.dart';
import 'package:schmgtsystem/providers/class_provider.dart';
import 'package:schmgtsystem/providers/provider.dart';

class AllStudentsScreen extends ConsumerStatefulWidget {
  const AllStudentsScreen({super.key});

  @override
  ConsumerState<AllStudentsScreen> createState() => _AllStudentsScreenState();
}

class _AllStudentsScreenState extends ConsumerState<AllStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Filter states
  String _selectedClass = 'All Classes';
  String _selectedGender = 'All Genders';
  String _selectedFeeStatus = 'All Status';

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // Flag to track if we need to reload when returning to screen
  bool _shouldReloadOnReturn = false;

  // Get class options from ClassProvider
  List<String> _getClassOptions(ClassProvider classProvider) {
    final classes = classProvider.classData.classes ?? [];
    final classNames =
        classes
            .map((cls) => cls.level ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
    return ['All Classes', ...classNames];
  }

  // Get class ID from class name
  String? _getClassIdFromName(String className, ClassProvider classProvider) {
    if (className == 'All Classes') return null;

    final classes = classProvider.classData.classes ?? [];
    if (classes.isEmpty) {
      print('Warning: No classes loaded yet, cannot filter by class');
      return null;
    }

    try {
      final classData = classes.firstWhere((cls) => cls.name == className);
      return classData.id;
    } catch (e) {
      print('Warning: Class "$className" not found in available classes');
      return null;
    }
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    final classState = ref.read(RiverpodProvider.classProvider);
    final classId = _getClassIdFromName(_selectedClass, classState);


    await ref
        .read(studentProvider.notifier)
        .getAllStudents(
          context,
          page: _currentPage,
          limit: _itemsPerPage,
          classId: classId,
          gender: _selectedGender == 'All Genders' ? null : _selectedGender,
          feeStatus:
              _selectedFeeStatus == 'All Status' ? null : _selectedFeeStatus,
          search:
              _searchController.text.trim().isEmpty
                  ? null
                  : _searchController.text.trim(),
        );
  }

  void _onSearchChanged() {
    _currentPage = 1;
    _loadStudents();
  }

  void _onFilterChanged() {
    _currentPage = 1;
    _loadStudents();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentProvider);
    final classState = ref.watch(RiverpodProvider.classProvider);
    final students = studentState.students;
    final pagination = studentState.pagination;
    final isLoading = studentState.isLoading;
    final errorMessage = studentState.errorMessage;

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

            // Statistics Cards
            _buildStatisticsCards(students, pagination, classOptions),
            const SizedBox(height: 32),

            // Search and Filters
            _buildSearchAndFilters(classOptions),

            // Filter Status Indicator
            _buildFilterStatusIndicator(),

            const SizedBox(height: 24),

            // Data Table
            Expanded(child: _buildDataTable(students, isLoading, errorMessage)),

            // Pagination
            if (pagination != null) _buildPagination(pagination),
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
            title: 'Classes',
            value: classOptions.length.toString(),
            icon: Icons.class_,
            color: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Avg per Class',
            value:
                pagination != null
                    ? (pagination.totalStudents / classOptions.length)
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
      activeFilters.add('Class: $_selectedClass');
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
                    'CLASS',
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
              itemCount: students.length,
              itemBuilder: (context, index) {
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

                      // Class
                      Expanded(flex: 1, child: Text(student.className)),

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
                              onPressed: () {
                                context.go('/students/single/${student.id}');
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

  Widget _buildPagination(PaginationInfo pagination) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${(_currentPage - 1) * _itemsPerPage + 1} to ${_currentPage * _itemsPerPage} of ${pagination.totalStudents} students',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Row(
            children: [
              TextButton(
                onPressed:
                    pagination.hasPrev
                        ? () => _onPageChanged(_currentPage - 1)
                        : null,
                child: const Text('Previous'),
              ),
              ...List.generate(pagination.totalPages, (index) {
                final page = index + 1;
                final isCurrentPage = page == _currentPage;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child:
                      isCurrentPage
                          ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              page.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          )
                          : TextButton(
                            onPressed: () => _onPageChanged(page),
                            child: Text(page.toString()),
                          ),
                );
              }),
              TextButton(
                onPressed:
                    pagination.hasNext
                        ? () => _onPageChanged(_currentPage + 1)
                        : null,
                child: const Text('Next'),
              ),
            ],
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
      padding: const EdgeInsets.all(20),
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
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Student'),
            content: Text(
              'Are you sure you want to delete ${student.fullName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteStudent(student.id);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteStudent(String studentId) async {
    await ref.read(studentProvider.notifier).deleteStudent(context, studentId);
  }
}
