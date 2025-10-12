import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/teacher_model.dart';
import 'package:schmgtsystem/models/class_level_model.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';
import 'package:schmgtsystem/services/global_academic_year_service.dart';

class AddClassDialog extends ConsumerStatefulWidget {
  final String academicYear;
  final TeacherListModel teacherData;
  final VoidCallback? onClassCreated;
  const AddClassDialog({
    Key? key,
    required this.academicYear,
    required this.teacherData,
    this.onClassCreated,
  }) : super(key: key);

  @override
  ConsumerState<AddClassDialog> createState() => _AddClassDialogState();
}

class _AddClassDialogState extends ConsumerState<AddClassDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Basic Information Controllers
  final _classNameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _sectionController = TextEditingController();

  // Classroom Information Controllers
  final _buildingController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _floorController = TextEditingController();

  // Selected values
  String? selectedLevel;
  String? selectedTerm;
  String? selectedClassTeacher = 'No Teacher Assigned'; // Default to no teacher
  String? selectedClassTeacherId;
  Color selectedColor = const Color(0xFF3B82F6); // Default blue color
  bool _isLoading = false;
  bool _isLoadingLevels = false;
  late GlobalAcademicYearService _academicYearService;

  // Dynamic class levels from API
  List<ClassLevelModel> _classLevels = [];

  final List<Color> predefinedColors = [
    const Color(0xFF3B82F6), // Blue
    const Color(0xFF10B981), // Green
    const Color(0xFFF59E0B), // Yellow
    const Color(0xFFEF4444), // Red
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFFF97316), // Orange
    const Color(0xFF84CC16), // Lime
    const Color(0xFFEC4899), // Pink
    const Color(0xFF6B7280), // Gray
  ];

  @override
  void initState() {
    super.initState();
    _academicYearService = GlobalAcademicYearService();
    _academicYearService.addListener(_onAcademicYearChanged);

    _tabController = TabController(length: 2, vsync: this);

    // Set current term from academic year service
    selectedTerm = _academicYearService.currentTermString;

    // Load class levels
    _loadClassLevels();
  }

  Future<void> _loadClassLevels() async {
    setState(() {
      _isLoadingLevels = true;
    });

    try {
      await ref
          .read(RiverpodProvider.classLevelProvider)
          .getAllClassLevels(
            context,
            isActive: true, // Only load active levels
          );

      final classLevelProvider = ref.read(RiverpodProvider.classLevelProvider);
      setState(() {
        _classLevels = classLevelProvider.classLevels;
        _isLoadingLevels = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLevels = false;
      });
      print('Error loading class levels: $e');
    }
  }

  // Helper method to check if class levels are loaded
  bool get hasClassLevels => _classLevels.isNotEmpty && !_isLoadingLevels;

  void _onAcademicYearChanged() {
    if (mounted) {
      setState(() {
        selectedTerm = _academicYearService.currentTermString;
      });
    }
  }

  @override
  void dispose() {
    _academicYearService.removeListener(_onAcademicYearChanged);
    _tabController.dispose();
    _classNameController.dispose();
    _capacityController.dispose();
    _sectionController.dispose();
    _buildingController.dispose();
    _roomNumberController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  Future<void> _saveClass() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get the selected class level data
        final selectedClassLevel = _classLevels.firstWhere(
          (level) => level.displayName == selectedLevel,
          orElse: () => throw Exception('Selected level not found'),
        );

        // Debug logging
        print('Selected Class Level: ${selectedClassLevel.displayName}');
        print('Level Name: ${selectedClassLevel.name}');
        print('Class Level ID: ${selectedClassLevel.id}');
        print(
          'Selected Teacher: ${selectedClassTeacher ?? 'No Teacher Assigned'}',
        );
        print('Teacher ID: ${selectedClassTeacherId ?? 'null'}');

        final Map<String, dynamic> requestBody = {
          "name": _classNameController.text.trim(),
          "level": selectedClassLevel.name, // String level name
          "classLevel": selectedClassLevel.id, // ObjectId reference
          "section":
              _sectionController.text.trim().isNotEmpty
                  ? _sectionController.text.trim()
                  : null,
          "academicYear": _academicYearService.currentAcademicYearString,
          "term": selectedTerm,
          "capacity": int.tryParse(_capacityController.text) ?? 30,
          "color": _colorToHex(selectedColor),
          "classTeacher": selectedClassTeacherId,
          "subjects": [], // Empty array as per your sample
          "classroom": {
            "building": _buildingController.text.trim(),
            "roomNumber": _roomNumberController.text.trim(),
            "floor": _floorController.text.trim(),
          },
        };

        // Debug logging
        print('Creating class with request body: $requestBody');

        await ref
            .read(RiverpodProvider.classProvider)
            .createClass(context, requestBody);

        // Refresh the class list to show the newly created class
        await ref
            .read(RiverpodProvider.classProvider)
            .getAllClassesWithMetric(context);

        if (mounted) {
          Navigator.pop(context);
          showSnackbar(context, 'Class created successfully!');
          // Call the callback to refresh the parent screen
          if (widget.onClassCreated != null) {
            widget.onClassCreated!();
          }
        }
      } catch (e) {
        if (mounted) {
          showSnackbar(context, 'Error creating class: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Widget _buildStyledInput({
    required String label,
    required TextEditingController controller,
    String? hintText,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon:
              icon != null ? Icon(icon, color: AppColors.primary) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildStyledDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
    IconData? icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              icon != null ? Icon(icon, color: AppColors.primary) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildColorPicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Class Color',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                predefinedColors.map((color) {
                  final isSelected = selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected ? Colors.black : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child:
                          isSelected
                              ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                              : null,
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        width: MediaQuery.of(context).size.width * 0.7,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Add New Class',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.info_outline), text: 'Basic Info'),
                  Tab(icon: Icon(Icons.location_on), text: 'Classroom'),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildBasicInfoTab(), _buildClassroomTab()],
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveClass,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Add Class',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Academic Year (read-only)
            _buildStyledInput(
              label: 'Academic Year',
              controller: TextEditingController(
                text: _academicYearService.currentAcademicYearString,
              ),
              icon: Icons.calendar_today,
              enabled: false,
            ),
            const SizedBox(height: 20),

            // Class Name
            _buildStyledInput(
              label: 'Class Name *',
              controller: _classNameController,
              hintText: 'Enter class name (e.g., Pride)',
              icon: Icons.class_,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a class name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Level and Section Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStyledDropdown(
                              label: 'Level *',
                              items:
                                  _isLoadingLevels
                                      ? ['Loading class levels...']
                                      : _classLevels.isEmpty
                                      ? ['No class levels available']
                                      : _classLevels
                                          .map((level) => level.displayName)
                                          .toList(),
                              value: selectedLevel,
                              onChanged:
                                  _isLoadingLevels || _classLevels.isEmpty
                                      ? (value) {}
                                      : (value) {
                                        setState(() {
                                          selectedLevel = value;
                                        });
                                      },
                              icon: Icons.grade,
                              validator: (value) {
                                if (value == null ||
                                    value == 'Loading class levels...' ||
                                    value == 'No class levels available') {
                                  return 'Please select a level';
                                }
                                return null;
                              },
                            ),
                          ),
                          if (_classLevels.isEmpty && !_isLoadingLevels) ...[
                            SizedBox(width: 8),
                            IconButton(
                              onPressed: _loadClassLevels,
                              icon: Icon(
                                Icons.refresh,
                                color: Color(0xFF6366F1),
                              ),
                              tooltip: 'Refresh class levels',
                            ),
                          ],
                        ],
                      ),
                      if (_classLevels.isEmpty && !_isLoadingLevels)
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'No class levels found. Please create some in Class Level Management.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStyledInput(
                    label: 'Section',
                    controller: _sectionController,
                    hintText: 'e.g., A, B, C',
                    icon: Icons.segment,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Term and Capacity Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule, color: Colors.grey.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Term',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedTerm ?? 'Loading...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.lock, color: Colors.grey.shade400, size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStyledInput(
                    label: 'Capacity *',
                    controller: _capacityController,
                    hintText: 'Max students (1-100)',
                    icon: Icons.groups,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter capacity';
                      }
                      final capacity = int.tryParse(value);
                      if (capacity == null || capacity < 1 || capacity > 100) {
                        return 'Enter valid capacity (1-100)';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Class Teacher (Optional)
            _buildStyledDropdown(
              label: 'Class Teacher (Optional)',
              items: [
                'No Teacher Assigned', // Add "No Teacher" option
                ...(widget.teacherData.teachers ?? [])
                    .map((teacher) => teacher.fullName.toString())
                    .toList(),
              ],
              value: selectedClassTeacher ?? 'No Teacher Assigned',
              onChanged: (value) {
                setState(() {
                  selectedClassTeacher = value;
                  // Find teacher ID
                  if (widget.teacherData.teachers != null &&
                      value != null &&
                      value != 'No Teacher Assigned') {
                    final teacher = widget.teacherData.teachers!.firstWhere(
                      (t) => t.fullName.toString() == value,
                      orElse: () => widget.teacherData.teachers!.first,
                    );
                    selectedClassTeacherId = teacher.id;
                  } else {
                    selectedClassTeacherId = null;
                  }
                });
              },
              icon: Icons.person,
            ),
            const SizedBox(height: 20),

            // Color Picker
            _buildColorPicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildClassroomTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Classroom Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),

          // Building
          _buildStyledInput(
            label: 'Building',
            controller: _buildingController,
            hintText: 'e.g., Main Block, Annex Building',
            icon: Icons.business,
          ),
          const SizedBox(height: 20),

          // Room Number and Floor Row
          Row(
            children: [
              Expanded(
                child: _buildStyledInput(
                  label: 'Room Number',
                  controller: _roomNumberController,
                  hintText: 'e.g., 101, A-201',
                  icon: Icons.room,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStyledInput(
                  label: 'Floor',
                  controller: _floorController,
                  hintText: 'e.g., 1st, 2nd, Ground',
                  icon: Icons.stairs,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Classroom information is optional but helps with organization and scheduling.',
                    style: TextStyle(color: Colors.blue.shade800, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
