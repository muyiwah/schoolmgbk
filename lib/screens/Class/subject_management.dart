import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/subject_model.dart';
import 'package:schmgtsystem/providers/subject_provider.dart';
import 'package:schmgtsystem/providers/class_provider.dart';

class SubjectsManagementPage extends StatefulWidget {
  const SubjectsManagementPage({super.key});

  @override
  State<SubjectsManagementPage> createState() => _SubjectsManagementPageState();
}

class _SubjectsManagementPageState extends State<SubjectsManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedGrade = 'All Grades';
  String selectedCategory = 'All Categories';
  String selectedStatus = 'All Status';

  // Synchronized scroll controllers
  late ScrollController _headerScrollController;
  late ScrollController _bodyScrollController;
  int changesPending = 3;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Initialize synchronized scroll controllers
    _headerScrollController = ScrollController();
    _bodyScrollController = ScrollController();

    // Synchronize scrolling between header and body
    _headerScrollController.addListener(_syncHeaderScroll);
    _bodyScrollController.addListener(_syncBodyScroll);

    // Load subjects and classes from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubjectProvider>(
        context,
        listen: false,
      ).getAllSubjects(context);

      Provider.of<ClassProvider>(
        context,
        listen: false,
      ).getAllClassesWithMetric(context);
    });
  }

  // Initialize class subjects data
  void _initializeClassSubjects(
    ClassProvider classProvider,
    SubjectProvider subjectProvider,
  ) {
    if (classSubjects.isEmpty) {
      classSubjects = getClassSubjectsFromProvider(
        classProvider,
        subjectProvider,
      );
      _ensureAllSubjectsAvailable(subjectProvider);
      print('Initialized classSubjects: $classSubjects');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _headerScrollController.dispose();
    _bodyScrollController.dispose();
    super.dispose();
  }

  void _syncHeaderScroll() {
    if (_headerScrollController.hasClients &&
        _bodyScrollController.hasClients) {
      _bodyScrollController.jumpTo(_headerScrollController.offset);
    }
  }

  void _syncBodyScroll() {
    if (_headerScrollController.hasClients &&
        _bodyScrollController.hasClients) {
      _headerScrollController.jumpTo(_bodyScrollController.offset);
    }
  }

  void _onSearchChanged() {
    setState(() {
      // Trigger rebuild when search text changes
    });
  }

  // Subject assignments for each class - will be populated from class provider
  Map<String, Map<String, bool>> classSubjects = {};

  // Helper method to ensure all subjects are available for each class
  void _ensureAllSubjectsAvailable(SubjectProvider subjectProvider) {
    // Get all available subject names
    List<String> allSubjectNames =
        subjectProvider.subjects
            .map((subject) => subject.name.toUpperCase())
            .toList();

    // Ensure each class has entries for all subjects
    for (String className in classSubjects.keys) {
      for (String subjectName in allSubjectNames) {
        if (!classSubjects[className]!.containsKey(subjectName)) {
          classSubjects[className]![subjectName] = false;
        }
      }
    }
  }

  // Helper method to get class data from provider
  Map<String, Map<String, bool>> getClassSubjectsFromProvider(
    ClassProvider classProvider,
    SubjectProvider subjectProvider,
  ) {
    Map<String, Map<String, bool>> result = {};

    if (classProvider.classData.classes != null) {
      print(
        'ClassProvider has ${classProvider.classData.classes!.length} classes',
      );
      for (var classData in classProvider.classData.classes!) {
        String className =
            '${classData.name ?? 'Unknown'} ${classData.section ?? ''}';
        result[className] = {};

        print('Processing class: $className');
        print('Class subjects array: ${classData.subjects ?? []}');
        print(
          'Class subject teachers: ${classData.subjectTeachers?.length ?? 0}',
        );

        // Pre-check subjects based on the class model's subjects array
        if (classData.subjects != null && classData.subjects!.isNotEmpty) {
          for (var subjectId in classData.subjects!) {
            // Find the subject name by ID from the subject provider
            var subject = subjectProvider.subjects.firstWhere(
              (s) => s.id == subjectId,
              orElse:
                  () => Subject(
                    id: subjectId,
                    name: subjectId, // Fallback to ID if subject not found
                    code: '',
                    description: '',
                    category: '',
                    department: '',
                    level: '',
                    isActive: true,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
            );

            result[className]![subject.name.toUpperCase()] = true;
            print('  - Pre-checked subject: ${subject.name} (ID: $subjectId)');
          }
        }

        // Also check subject teachers as a fallback (for backward compatibility)
        if (classData.subjectTeachers != null &&
            classData.subjectTeachers!.isNotEmpty) {
          for (var subjectTeacher in classData.subjectTeachers!) {
            if (subjectTeacher.subject != null) {
              String subjectName = subjectTeacher.subject!.toUpperCase();
              // Only add if not already added from subjects array
              if (!result[className]!.containsKey(subjectName)) {
                result[className]![subjectName] = true;
                print(
                  '  - Additional subject from teachers: ${subjectTeacher.subject}',
                );
              }
            }
          }
        }

        print('Final subjects for $className: ${result[className]}');
      }
    } else {
      print('ClassProvider has no classes data');
    }

    print('Final classSubjects result: $result');
    return result;
  }

  final List<String> grades = ['All Grades', ...Subject.levels];
  final List<String> categories = ['All Categories', ...Subject.categories];
  final List<String> departments = ['All Departments', ...Subject.departments];
  final List<String> statuses = ['All Status', 'Active', 'Inactive'];

  Color getSubjectColor(String subject) {
    switch (subject) {
      case 'MATHEMATICS':
        return Colors.blue.shade100;
      case 'SCIENCE':
        return Colors.green.shade100;
      case 'ENGLISH':
        return Colors.purple.shade100;
      case 'HISTORY':
        return Colors.orange.shade100;
      case 'ART':
        return Colors.red.shade100;
      case 'MUSIC':
        return Colors.indigo.shade100;
      case 'HISTORY2':
        return Colors.orange.shade100;
      case 'ART2':
        return Colors.red.shade100;
      case 'MUSIC2':
        return Colors.indigo.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color getSubjectTextColor(String subject) {
    switch (subject) {
      case 'MATHEMATICS':
        return Colors.blue.shade700;
      case 'SCIENCE':
        return Colors.green.shade700;
      case 'ENGLISH':
        return Colors.purple.shade700;
      case 'HISTORY':
        return Colors.orange.shade700;
      case 'ART':
        return Colors.red.shade700;
      case 'MUSIC':
        return Colors.indigo.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  void _toggleSubject(String className, String subject, bool value) {
    print('=== TOGGLE SUBJECT DEBUG ===');
    print('ClassName: $className');
    print('Subject: $subject');
    print('Value: $value');
    print('ClassSubjects before: $classSubjects');
    print(
      'ClassSubjects contains className: ${classSubjects.containsKey(className)}',
    );
    if (classSubjects.containsKey(className)) {
      print('ClassSubjects[$className]: ${classSubjects[className]}');
    }
    print('==========================');

    setState(() {
      // Ensure the class exists in classSubjects
      if (!classSubjects.containsKey(className)) {
        classSubjects[className] = {};
        print('Created new class entry for: $className');
      }

      // Update the subject assignment
      classSubjects[className]![subject] = value;

      // Increment changes pending counter
      changesPending++;

      print('Toggled $subject for $className to $value');
      print('Changes pending: $changesPending');
      print('ClassSubjects after: $classSubjects');
    });
  }

  void _toggleAllForSubject(String subject, bool value) {
    setState(() {
      int changesCount = 0;
      for (String className in classSubjects.keys) {
        // Only count as change if the value is actually different
        if (classSubjects[className]![subject] != value) {
          classSubjects[className]![subject] = value;
          changesCount++;
        }
      }

      // Update changes pending counter
      changesPending += changesCount;

      print('Toggled all classes for $subject to $value');
      print('Changes made: $changesCount, Total pending: $changesPending');
    });
  }

  // Helper method to convert classSubjects to API format
  Map<String, dynamic> _prepareBulkAssignData(
    ClassProvider classProvider,
    SubjectProvider subjectProvider,
  ) {
    List<Map<String, dynamic>> classSubjectMappings = [];

    if (classProvider.classData.classes != null) {
      for (var classData in classProvider.classData.classes!) {
        String className =
            '${classData.name ?? 'Unknown'} ${classData.section ?? ''}';

        // Get all subjects for this class (both selected and unselected)
        List<String> selectedSubjectIds = [];
        List<String> unselectedSubjectIds = [];

        if (classSubjects.containsKey(className)) {
          classSubjects[className]!.forEach((subjectName, isSelected) {
            // Find subject ID from subject provider
            final subject = subjectProvider.subjects.firstWhere(
              (s) => s.name.toUpperCase() == subjectName,
              orElse:
                  () => Subject(
                    id: subjectName, // Fallback to name if not found
                    name: subjectName,
                    category: 'Core',
                    department: 'General',
                    level: 'Primary',
                    isActive: true,
                  ),
            );

            if (isSelected) {
              selectedSubjectIds.add(subject.id);
            } else {
              unselectedSubjectIds.add(subject.id);
            }
          });
        }

        // Always include the class mapping, even if no subjects are selected
        // This allows the backend to remove all subjects if none are selected
        classSubjectMappings.add({
          'classId': classData.id,
          'subjects': selectedSubjectIds, // Only send selected subjects
          'removedSubjects':
              unselectedSubjectIds, // Track removed subjects for debugging
        });
      }
    }

    return {
      'classSubjectMappings': classSubjectMappings,
      'dryRun': false, // Set to true for testing, false for actual update
    };
  }

  void _saveChanges() async {
    // Get both providers from context
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final subjectProvider = Provider.of<SubjectProvider>(
      context,
      listen: false,
    );

    // Prepare the data for bulk assignment
    final bulkData = _prepareBulkAssignData(classProvider, subjectProvider);

    print('Bulk assignment data: $bulkData');

    // Call the bulk assign subjects method
    final success = await classProvider.bulkAssignSubjects(context, bulkData);

    if (success) {
      setState(() {
        changesPending = 0;
      });
    }
  }

  void _resetChanges() {
    // Reset to original state by reloading data from providers
    setState(() {
      changesPending = 0;
      // Reload class subjects from provider to restore original state
      final classProvider = Provider.of<ClassProvider>(context, listen: false);
      final subjectProvider = Provider.of<SubjectProvider>(
        context,
        listen: false,
      );
      classSubjects = getClassSubjectsFromProvider(
        classProvider,
        subjectProvider,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes reset to original state'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _undoChanges() {
    // Implement undo functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Changes undone')));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<SubjectProvider, ClassProvider>(
      builder: (context, subjectProvider, classProvider, child) {
        // Initialize class subjects data if not already done
        _initializeClassSubjects(classProvider, subjectProvider);

        // Debug: Print current state
        print('=== BUILD METHOD DEBUG ===');
        print('Subjects count: ${subjectProvider.subjects.length}');
        print('Classes count: ${classProvider.classData.classes?.length ?? 0}');
        print('ClassSubjects keys: ${classSubjects.keys.toList()}');
        if (classSubjects.isNotEmpty) {
          String firstClass = classSubjects.keys.first;
          print('First class subjects: ${classSubjects[firstClass]}');
        }
        print('========================');

        if (subjectProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8FAFC),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (subjectProvider.errorMessage != null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${subjectProvider.errorMessage}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => subjectProvider.getAllSubjects(context),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final subjects = subjectProvider.subjects.map((s) => s.name).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Column(
            children: [
              // Sleek Header
              _buildSleekHeader(subjectProvider, classProvider),

              // Advanced Search & Filter Bar
              _buildAdvancedSearchBar(),

              // Main Data Table
              Expanded(child: _buildDataTable(subjects)),

              // Bottom Action Bar
              _buildBottomActionBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSleekHeader(
    SubjectProvider subjectProvider,
    ClassProvider classProvider,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.table_chart,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Subject Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage subject assignments across all classes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            children: [
              _buildIconButton(
                icon: Icons.file_download_outlined,
                tooltip: 'Import CSV',
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                icon: Icons.file_upload_outlined,
                tooltip: 'Export Data',
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed:
                    () => showAddSubjectDialog(
                      context,
                      subjectProvider,
                      classProvider,
                    ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Subject'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
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

  Widget _buildAdvancedSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Search Field
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search classes, subjects, or grades...',
                      hintStyle: TextStyle(color: Color(0xFF64748B)),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF64748B)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Filter Dropdowns
              _buildFilterChip('All Grades', selectedGrade, grades, (value) {
                setState(() => selectedGrade = value!);
              }),
              const SizedBox(width: 8),
              _buildFilterChip('All Categories', selectedCategory, categories, (
                value,
              ) {
                setState(() => selectedCategory = value!);
              }),
              const SizedBox(width: 8),
              _buildFilterChip('All Status', selectedStatus, statuses, (value) {
                setState(() => selectedStatus = value!);
              }),
            ],
          ),

          // Scroll Indicator
          const SizedBox(height: 12),
          _buildScrollIndicator(),
        ],
      ),
    );
  }

  Widget _buildScrollIndicator() {
    final subjects = classSubjects.values.first.keys.toList();
    final hasManySubjects = subjects.length > 6;

    if (!hasManySubjects) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.swipe_left, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            'Scroll horizontally to see all ${subjects.length} subjects',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<String> subjects) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildScrollableTable(subjects),
    );
  }

  Widget _buildScrollableTable(List<String> subjects) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          // Fixed Class Column
          Container(
            width: 200,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // Fixed Header
                Container(
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                    ),
                    border: Border(
                      right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                  ),
                  child: _buildClassColumnHeader(),
                ),
                // Fixed Body Rows
                ...classSubjects.entries.map((entry) {
                  final className = entry.key;
                  final gradeText =
                      className.contains('1') ? 'Grade 1' : 'Grade 2';

                  return Container(
                    height: 70,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                        right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                      ),
                    ),
                    child: _buildClassCell(className, gradeText),
                  );
                }),
              ],
            ),
          ),
          // Scrollable Subject Columns
          SizedBox(
            width: MediaQuery.of(context).size.width - 160, // Fixed width
            child: SingleChildScrollView(
              controller: _bodyScrollController,
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  // Subject Headers
                  Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: _buildSubjectHeaders(subjects),
                  ),
                  // Subject Body Rows
                  ...classSubjects.entries.map((entry) {
                    final className = entry.key;
                    final classData = entry.value;

                    return Container(
                      height: 70,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                      ),
                      child: _buildSubjectRow(classData, subjects, className),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectHeaders(List<String> subjects) {
    return Row(
      children:
          subjects
              .map(
                (subject) => Container(
                  width: 120,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    border: Border(
                      right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                  ),
                  child: _buildSubjectColumnHeader(subject),
                ),
              )
              .toList(),
    );
  }

  Widget _buildSubjectRow(
    Map<String, bool> classData,
    List<String> subjects,
    String className,
  ) {
    print('Building row for class: $className');
    print('ClassData: $classData');
    print('Subjects: $subjects');

    return Row(
      children:
          subjects
              .map(
                (subject) => Container(
                  width: 120,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                  ),
                  child: _buildSubjectCell(
                    subject,
                    classData[subject] ?? false,
                    className,
                  ),
                ),
              )
              .toList(),
    );
  }

  // Custom Table Helper Methods
  Widget _buildClassColumnHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: false,
              onChanged: (value) {
                // Handle select all
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'CLASS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectColumnHeader(String subject) {
    final isAllSelected = classSubjects.values.every(
      (classData) => classData[subject] == true,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: getSubjectColor(subject),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color:
              isAllSelected
                  ? getSubjectTextColor(subject)
                  : const Color(0xFFE2E8F0),
          width: isAllSelected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: isAllSelected,
              onChanged:
                  (value) => _toggleAllForSubject(subject, value ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              activeColor: getSubjectTextColor(subject),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subject,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: getSubjectTextColor(subject),
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildClassCell(String className, String gradeText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: false,
              onChanged: (value) {
                // Handle row selection
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  className,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    gradeText,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCell(String subject, bool value, String className) {
    return Center(
      child: InkWell(
        onTap: () {
          print('Checkbox tapped: $subject for $className');
          _toggleSubject(className, subject, !value);
        },
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: value ? getSubjectColor(subject) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color:
                  value
                      ? getSubjectTextColor(subject)
                      : const Color(0xFFCBD5E1),
              width: 2,
            ),
          ),
          child:
              value
                  ? Icon(
                    Icons.check,
                    size: 18,
                    color: getSubjectTextColor(subject),
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:
                  changesPending > 0
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    changesPending > 0
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF22C55E),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:
                        changesPending > 0
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  changesPending > 0
                      ? '$changesPending changes pending'
                      : 'All changes saved',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        changesPending > 0
                            ? const Color(0xFF92400E)
                            : const Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Action Buttons
          if (changesPending > 0) ...[
            TextButton.icon(
              onPressed: _undoChanges,
              icon: const Icon(Icons.undo, size: 16),
              label: const Text('Undo'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 8),
          ],

          TextButton.icon(
            onPressed: _resetChanges,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 8),

          ElevatedButton.icon(
            onPressed: changesPending > 0 ? _saveChanges : null,
            icon: const Icon(Icons.save, size: 16),
            label: const Text('Save Changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  changesPending > 0
                      ? AppColors.primary
                      : const Color(0xFFCBD5E1),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sleek Helper Methods
  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFF8FAFC),
          foregroundColor: const Color(0xFF64748B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                );
              }).toList(),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF64748B),
            size: 16,
          ),
          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13),
        ),
      ),
    );
  }
}

class AddSubjectDialog extends StatefulWidget {
  final SubjectProvider subjectProvider;

  const AddSubjectDialog({super.key, required this.subjectProvider});

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _subjectCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedDepartment;
  String? _selectedLevel;
  bool _isActive = true;

  @override
  void dispose() {
    _subjectNameController.dispose();
    _subjectCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: screenWidth > 600 ? 600 : screenWidth * 0.9,
        height: screenHeight > 700 ? null : screenHeight * 0.9,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.9,
          maxWidth: screenWidth > 600 ? 600 : screenWidth * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern Header with Gradient
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add New Subject',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create a new subject for your classes',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Modern Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Name Field
                    _buildModernFormField(
                      label: 'Subject Name',
                      isRequired: true,
                      controller: _subjectNameController,
                      hintText: 'Enter subject name',
                      helperText: 'Enter a unique subject name.',
                    ),
                    const SizedBox(height: 20),

                    // Subject Code Field
                    _buildModernFormField(
                      label: 'Subject Code',
                      controller: _subjectCodeController,
                      hintText: 'e.g., MATH101',
                      helperText: 'Optional short code for internal reference.',
                    ),
                    const SizedBox(height: 20),

                    // Description Field
                    _buildModernFormField(
                      label: 'Description',
                      controller: _descriptionController,
                      hintText: 'Brief description of the subject (optional)',
                      helperText:
                          'Provide a brief description of what this subject covers.',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),

                    // Category Field
                    _buildDropdownField(
                      label: 'Category',
                      isRequired: true,
                      value: _selectedCategory,
                      items: Subject.categories,
                      onChanged:
                          (value) => setState(() => _selectedCategory = value),
                      hintText: 'Select subject category',
                      helperText: 'Choose the category for this subject.',
                    ),
                    const SizedBox(height: 20),

                    // Department Field
                    _buildDropdownField(
                      label: 'Department',
                      isRequired: true,
                      value: _selectedDepartment,
                      items: Subject.departments,
                      onChanged:
                          (value) =>
                              setState(() => _selectedDepartment = value),
                      hintText: 'Select department',
                      helperText: 'Choose the department for this subject.',
                    ),
                    const SizedBox(height: 20),

                    // Level Field
                    _buildDropdownField(
                      label: 'Level',
                      isRequired: true,
                      value: _selectedLevel,
                      items: Subject.levels,
                      onChanged:
                          (value) => setState(() => _selectedLevel = value),
                      hintText: 'Select education level',
                      helperText:
                          'Choose the education level for this subject.',
                    ),
                    const SizedBox(height: 20),

                    // Active Status Field
                    _buildSwitchField(
                      label: 'Active Status',
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                      helperText: 'Enable or disable this subject.',
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (_subjectNameController.text.isNotEmpty &&
                                _selectedCategory != null &&
                                _selectedDepartment != null &&
                                _selectedLevel != null) {
                              final subjectData = {
                                'name':
                                    _subjectNameController.text
                                        .trim()
                                        .toUpperCase(),
                                'code':
                                    _subjectCodeController.text
                                        .trim()
                                        .toUpperCase(),
                                'description':
                                    _descriptionController.text.trim(),
                                'category': _selectedCategory!,
                                'department': _selectedDepartment!,
                                'level': _selectedLevel!,
                                'isActive': _isActive,
                              };

                              final success = await widget.subjectProvider
                                  .createSubject(context, subjectData);

                              if (success && mounted) {
                                Navigator.of(context).pop();
                              }
                            } else {
                              print(
                                'Form validation failed - missing required fields',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please fill in all required fields',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: const Text('Save Subject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required String helperText,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
            children:
                isRequired
                    ? [
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Color(0xFFEF4444)),
                      ),
                    ]
                    : [],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Color(0xFF64748B)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          helperText,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hintText,
    required String helperText,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
            children:
                isRequired
                    ? [
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Color(0xFFEF4444)),
                      ),
                    ]
                    : [],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              hint: Text(
                hintText,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              items:
                  items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          helperText,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required String helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              value ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: value ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          helperText,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// Usage example:
void showAddSubjectDialog(
  BuildContext context,
  SubjectProvider subjectProvider,
  ClassProvider classProvider,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AddSubjectDialog(subjectProvider: subjectProvider);
    },
  ).then((result) {
    if (result != null) {
      // Handle the returned subject data
      // Subject created: $result
    }
  });
}
