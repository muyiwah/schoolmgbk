import 'package:flutter/material.dart';
import 'package:schmgtsystem/constants/appcolor.dart';

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

  // Subject assignments for each class
  Map<String, Map<String, bool>> classSubjects = {
    'Class 1A': {
      'MATHEMATICS': true,
      'SCIENCE': true,
      'ENGLISH': true,
      'HISTORY': false,
      'ART': true,
      'MUSIC': false,
      'HISTORY2': false,
      'ART2': true,
      'MUSIC2': false,
      'HISTORY3': false,
      'ART3': true,
      'MUSIC3': false,
    },
    'Class 1B': {
      'MATHEMATICS': true,
      'SCIENCE': false,
      'ENGLISH': true,
      'HISTORY': false,
      'ART': false,
      'MUSIC': true,
      'HISTORY2': false,
      'ART2': true,
      'MUSIC2': false,
      'HISTORY3': false,
      'ART3': true,
      'MUSIC3': false,
    },
    'Class 2A': {
      'MATHEMATICS': true,
      'SCIENCE': true,
      'ENGLISH': true,
      'HISTORY': true,
      'ART': false,
      'MUSIC': true,
      'HISTORY2': false,
      'ART2': true,
      'MUSIC2': false,
      'HISTORY3': false,
      'ART3': true,
      'MUSIC3': false,
    },
  };

  final List<String> grades = ['All Grades', 'Grade 1', 'Grade 2'];
  final List<String> categories = ['All Categories', 'Core', 'Elective'];
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
    setState(() {
      classSubjects[className]![subject] = value;
      // This would normally update the changes pending count based on actual changes
    });
  }

  void _toggleAllForSubject(String subject, bool value) {
    setState(() {
      for (String className in classSubjects.keys) {
        classSubjects[className]![subject] = value;
      }
    });
  }

  void _saveChanges() {
    // Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {
      changesPending = 0;
    });
  }

  void _resetChanges() {
    // Implement reset functionality
    setState(() {
      // Reset to original state
      changesPending = 0;
    });
  }

  void _undoChanges() {
    // Implement undo functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Changes undone')));
  }

  @override
  Widget build(BuildContext context) {
    final subjects = classSubjects.values.first.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Sleek Header
          _buildSleekHeader(),

          // Advanced Search & Filter Bar
          _buildAdvancedSearchBar(),

          // Main Data Table
          Expanded(child: _buildDataTable(subjects)),

          // Bottom Action Bar
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildSleekHeader() {
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
                onPressed: () => showAddSubjectDialog(context),
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
                      right: BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1,
                      ),
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
                        bottom: BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        right: BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                    ),
                    child: _buildClassCell(className, gradeText),
                  );
                }).toList(),
              ],
            ),
          ),
          // Scrollable Subject Columns
          Expanded(
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
                  }).toList(),
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
                      right: BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1,
                      ),
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
                      right: BorderSide(
                        color: Color(0xFFE2E8F0),
                        width: 1,
                      ),
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
          Expanded(
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
      child: GestureDetector(
        onTap: () => _toggleSubject(className, subject, !value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 28,
          height: 28,
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
                    size: 16,
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
  const AddSubjectDialog({super.key});

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _subjectCodeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedClass;

  @override
  void dispose() {
    _subjectNameController.dispose();
    _subjectCodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
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
            Padding(
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
                  const SizedBox(height: 24),

                  // Subject Code Field
                  _buildModernFormField(
                    label: 'Subject Code',
                    controller: _subjectCodeController,
                    hintText: 'e.g., MATH101',
                    helperText: 'Optional short code for internal reference.',
                  ),
                  const SizedBox(height: 24),

                  // Description Field
                  _buildModernFormField(
                    label: 'Description',
                    controller: _descriptionController,
                    hintText: 'Brief description of the subject (optional)',
                    helperText:
                        'Provide a brief description of what this subject covers.',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),

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
                        onPressed: () {
                          if (_subjectNameController.text.isNotEmpty) {
                            Navigator.of(context).pop({
                              'name': _subjectNameController.text,
                              'code': _subjectCodeController.text,
                              'description': _descriptionController.text,
                              'class': _selectedClass,
                            });
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
}

// Usage example:
void showAddSubjectDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const AddSubjectDialog();
    },
  ).then((result) {
    if (result != null) {
      // Handle the returned subject data
      // Subject created: $result
    }
  });
}
