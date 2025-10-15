import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/color_pallete.dart';
import 'package:schmgtsystem/widgets/custom_dropdown_select.dart';
import 'package:schmgtsystem/widgets/screen_header.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/models/timetable_model.dart';
import 'package:schmgtsystem/services/dialog_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/services/global_academic_year_service.dart';
import 'package:collection/collection.dart';

class CreateTimetale extends ConsumerStatefulWidget {
  final String? preselectedClassId;

  const CreateTimetale({super.key, this.preselectedClassId});

  @override
  ConsumerState<CreateTimetale> createState() => _CreateTimetaleState();
}

class _CreateTimetaleState extends ConsumerState<CreateTimetale> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DialogService _dialogService = locator<DialogService>();

  // Form controllers
  final TextEditingController _academicYearController = TextEditingController();

  // Selected values
  String? _selectedClass;
  String? _selectedTerm;
  String? _selectedType;
  late GlobalAcademicYearService _academicYearService;
  int _selectedDayIndex = -1;

  // Period configuration
  int _periodDurationMinutes = 45; // Default 45 minutes

  // Custom entries (templates)
  final List<Map<String, dynamic>> _customEntries = [];
  final TextEditingController _customEntryController = TextEditingController();

  // Schedule data
  final Map<String, List<Period>> _schedule = {};
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Available options
  final List<String> _types = ['regular', 'examination'];

  // Time slots - will be generated dynamically based on period duration
  List<String> _timeSlots = [];

  // Generate time slots based on period duration
  // Helper function to format time to 12-hour format
  String _formatTime12Hour(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;

    String period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour;

    if (hour == 0) {
      displayHour = 12; // 12:00 AM
    } else if (hour > 12) {
      displayHour = hour - 12; // 1:00 PM, 2:00 PM, etc.
    }

    return '$displayHour:${minute.toString().padLeft(2, '0')}$period';
  }

  List<String> _generateTimeSlots() {
    if (kDebugMode) {
      print(
        '🕐 _generateTimeSlots: Starting with period duration: $_periodDurationMinutes minutes',
      );
    }

    final Set<String> slotsSet =
        {}; // Use Set to automatically avoid duplicates
    DateTime currentTime = DateTime(2024, 1, 1, 8, 0); // Start at 8:00 AM

    // Generate slots until 5:00 PM
    while (currentTime.hour < 17 && slotsSet.length < 50) {
      final timeString = _formatTime12Hour(currentTime);

      slotsSet.add(timeString);
      if (kDebugMode) {
        print('🕐 _generateTimeSlots: Added slot: $timeString');
      }

      currentTime = currentTime.add(Duration(minutes: _periodDurationMinutes));
    }

    final slots = slotsSet.toList();

    if (kDebugMode) {
      print('🕐 _generateTimeSlots: Generated ${slots.length} slots: $slots');
    }

    return slots;
  }

  // Generate available time slots for a specific day (excluding existing periods)
  List<String> _getAvailableTimeSlotsForDay(String day) {
    if (kDebugMode) {
      print('📅 _getAvailableTimeSlotsForDay: Processing day: $day');
    }

    final existingPeriods = _schedule[day] ?? [];
    final allTimeSlots = _generateTimeSlots();
    final usedTimes = <String>{};

    if (kDebugMode) {
      print(
        '📅 _getAvailableTimeSlotsForDay: Found ${existingPeriods.length} existing periods',
      );
      for (int i = 0; i < existingPeriods.length; i++) {
        final period = existingPeriods[i];
        print(
          '📅 _getAvailableTimeSlotsForDay: Period $i: ${period.subject} (${period.startTime} - ${period.endTime})',
        );
      }
    }

    // Collect all used start times
    for (final period in existingPeriods) {
      if (period.startTime.isNotEmpty) {
        usedTimes.add(period.startTime);
        if (kDebugMode) {
          print(
            '📅 _getAvailableTimeSlotsForDay: Marked as used: ${period.startTime}',
          );
        }
      }
    }

    // Return only unused time slots
    final availableSlots =
        allTimeSlots.where((slot) => !usedTimes.contains(slot)).toList();

    if (kDebugMode) {
      print('📅 _getAvailableTimeSlotsForDay: Used times: $usedTimes');
      print(
        '📅 _getAvailableTimeSlotsForDay: Available slots: $availableSlots',
      );
    }

    return availableSlots;
  }

  @override
  void initState() {
    super.initState();
    _academicYearService = GlobalAcademicYearService();
    _academicYearService.addListener(_onAcademicYearChanged);

    _academicYearController.text =
        _academicYearService.currentAcademicYearString;
    _selectedTerm = _academicYearService.currentTermString;

    _initializeSchedule();
    _loadClasses();
    _loadSubjects();
    _timeSlots = _generateTimeSlots();

    // Set preselected class if provided
    if (widget.preselectedClassId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setPreselectedClass();
      });
    }
  }

  void _setPreselectedClass() async {
    if (widget.preselectedClassId == null) return;

    final classProvider = ref.read(RiverpodProvider.classProvider);
    final classes = classProvider.classData.classes ?? [];

    // Find the class that matches the preselected ID
    final selectedClass = classes.firstWhereOrNull(
      (c) => c.id == widget.preselectedClassId,
    );

    if (selectedClass != null) {
      setState(() {
        _selectedClass = selectedClass.level;
      });

      if (kDebugMode) {
        print(
          'Preselected class set: ${selectedClass.level} (ID: ${selectedClass.id})',
        );
      }
    } else {
      if (kDebugMode) {
        print('Could not find class with ID: ${widget.preselectedClassId}');
      }
    }
  }

  void _loadClasses() async {
    // Load classes when the screen initializes
    final classProvider = ref.read(RiverpodProvider.classProvider);
    await classProvider.getAllClassesWithMetric(context);
  }

  void _loadSubjects() async {
    // Load subjects when the screen initializes
    final subjectProvider = ref.read(RiverpodProvider.subjectProvider);
    await subjectProvider.getAllSubjects(context);
  }

  void _onAcademicYearChanged() {
    if (mounted) {
      setState(() {
        _academicYearController.text =
            _academicYearService.currentAcademicYearString;
        _selectedTerm = _academicYearService.currentTermString;
      });
    }
  }

  @override
  void dispose() {
    _academicYearService.removeListener(_onAcademicYearChanged);
    _academicYearController.dispose();
    _customEntryController.dispose();
    super.dispose();
  }

  void _initializeSchedule() {
    for (String day in _days) {
      _schedule[day] = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = ref.watch(RiverpodProvider.classProvider);
    final timetableProvider = ref.watch(RiverpodProvider.timetableProvider);
    final subjectProvider = ref.watch(RiverpodProvider.subjectProvider);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          100,
        ), // Extra bottom padding for FAB
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: screenBackground,
        ),
        child: Column(
          children: [
            ScreenHeader(group: 'Students', subgroup: 'Create Time Table'),
            const SizedBox(height: 15),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(1, 1),
                      spreadRadius: 2,
                      blurRadius: 2,
                      color: Colors.transparent,
                    ),
                  ],
                  border: Border.all(color: Colors.white),
                ),
                padding: const EdgeInsets.all(15),
                width: double.infinity,
                margin: const EdgeInsets.all(5),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information Section
                        _buildBasicInfoSection(classProvider),
                        const SizedBox(height: 20),

                        // Period Duration Configuration
                        _buildPeriodDurationSection(),
                        const SizedBox(height: 20),

                        // Custom Entries Section
                        _buildCustomEntriesSection(),
                        const SizedBox(height: 20),

                        // Day Selection
                        _buildDaySelection(),
                        const SizedBox(height: 20),

                        // Schedule Section
                        if (_selectedDayIndex != -1) ...[
                          _buildScheduleSection(subjectProvider),
                          const SizedBox(height: 20),
                        ],

                        // Timetable Summary
                        _buildTimetableSummary(),
                        const SizedBox(height: 20),

                        // Form Validation Status
                        _buildValidationStatus(),
                        const SizedBox(height: 20),

                        // Action Buttons
                        _buildActionButtons(timetableProvider),
                        const SizedBox(height: 20), // Extra padding at bottom
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [homeColor, homeColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: homeColor.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: timetableProvider.isLoading ? null : _saveTimetable,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          icon:
              timetableProvider.isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Icon(Icons.add_task),
          label: Text(
            timetableProvider.isLoading ? 'Creating...' : 'CREATE TIMETABLE',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(dynamic classProvider) {
    // Check if class data is available
    final classes = classProvider.classData?.classes ?? [];
    final classNames =
        classes
            .map<String>((c) => c.level?.toString() ?? '')
            .where((String level) => level.isNotEmpty)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 15),

        // Class Selection - Prominent Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.class_, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Class Selection',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (classNames.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[600], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No classes available. Please add classes first.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                CustomDropdown(
                  allValues: classNames,
                  title: 'Select Class',
                  onChanged: (value) {
                    setState(() {
                      _selectedClass = value;
                    }); 
                  },
                ),
              if (_selectedClass != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Selected: $_selectedClass',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Use Column for smaller screens to prevent overflow
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // Stack vertically on smaller screens
              return Column(
                children: [
                  TextFormField(
                    controller: _academicYearController,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Academic Year',
                      border: OutlineInputBorder(),
                      hintText: '2024/2025',
                      prefixIcon: Icon(Icons.calendar_today),
                      suffixIcon: Icon(Icons.lock, color: Colors.grey),
                    ),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.school, color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Term',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedTerm ?? 'Loading...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.lock, color: Colors.grey[400], size: 16),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              // Use Row for larger screens
              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _academicYearController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Academic Year',
                        border: OutlineInputBorder(),
                        hintText: '2024/2025',
                        prefixIcon: Icon(Icons.calendar_today),
                        suffixIcon: Icon(Icons.lock, color: Colors.grey),
                      ),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.school, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Term',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedTerm ?? 'Loading...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.lock, color: Colors.grey[400], size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),

        const SizedBox(height: 16),

        // Type Selection
        CustomDropdown(
          allValues: _types,
          title: 'Timetable Type',
          onChanged: (value) {
            setState(() {
              _selectedType = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPeriodDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Period Duration Configuration',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 15),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Period Duration Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Period Duration Only
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Period Duration (minutes)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _periodDurationMinutes,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items:
                              [30, 35, 40, 45, 50, 55, 60]
                                  .map(
                                    (duration) => DropdownMenuItem(
                                      value: duration,
                                      child: Text('$duration minutes'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _periodDurationMinutes = value;
                                _timeSlots = _generateTimeSlots();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Info',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '💡 Tip:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Breaks and assembly can be added as custom entries with specific start and end times.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue[600],
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomEntriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom Entries & Breaks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 15),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.purple[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Custom Entries',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick Add Buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickAddButton('Assembly', Icons.flag),
                  _buildQuickAddButton('Short Break', Icons.coffee),
                  _buildQuickAddButton('Long Break', Icons.restaurant),
                  _buildQuickAddButton('Lunch Break', Icons.restaurant_menu),
                  _buildQuickAddButton('Prayer Time', Icons.mosque),
                ],
              ),
              const SizedBox(height: 16),

              // Custom Entry Form
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _customEntryController,
                      decoration: const InputDecoration(
                        labelText: 'Custom Entry Template Name',
                        border: OutlineInputBorder(),
                        hintText:
                            'e.g., Sports Time, Library Period, Prayer Time',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _addCustomEntry,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Template'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Custom Entry Templates List
              if (_customEntries.isNotEmpty) ...[
                const Text(
                  'Custom Entry Templates:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      _customEntries.asMap().entries.map((entry) {
                        final index = entry.key;
                        final customEntry = entry.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.purple[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                customEntry['icon'] ?? Icons.event,
                                color: Colors.purple[600],
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                customEntry['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.purple[700],
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _removeCustomEntry(index),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.red[600],
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddButton(String name, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _addQuickEntry(name, icon),
      icon: Icon(icon, size: 16),
      label: Text(name),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[100],
        foregroundColor: Colors.purple[700],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _addQuickEntry(String name, IconData icon) {
    _addCustomEntryTemplate(name, icon);
  }

  void _addCustomEntry() {
    final name = _customEntryController.text.trim();

    if (name.isEmpty) {
      _dialogService.showSnackBar(
        'Please enter a custom entry template name',
        appToastType: AppToastType.error,
      );
      return;
    }

    _addCustomEntryTemplate(name, Icons.event);

    // Clear form
    _customEntryController.clear();
    setState(() {});
  }

  // Add custom entry template
  void _addCustomEntryTemplate(String name, IconData icon) {
    setState(() {
      _customEntries.add({'name': name, 'icon': icon});
    });
  }

  // Add custom entry to schedule with start and end times
  void _addCustomEntryToSchedule(
    String name,
    String startTime,
    String endTime,
    IconData icon,
    String day,
  ) {
    if (kDebugMode) {
      print(
        '🎯 _addCustomEntryToSchedule: Adding "$name" from $startTime to $endTime on $day',
      );
    }

    // Validate the custom entry times before creating
    if (!_validatePeriodTimes(startTime, endTime)) {
      if (kDebugMode) {
        print(
          '❌ _addCustomEntryToSchedule: Validation failed for times: $startTime - $endTime',
        );
      }
      return;
    }

    // Create the custom entry period
    final customPeriod = Period(
      startTime: startTime,
      endTime: endTime,
      subject: name,
      room: 'Special',
    );

    setState(() {
      // Add to schedule
      final periods = _schedule[day] ?? [];
      periods.add(customPeriod);
      _schedule[day] = periods;

      // Add to custom entries list for tracking
      _customEntries.add({
        'name': name,
        'startTime': startTime,
        'endTime': endTime,
        'icon': icon,
        'day': day,
      });

      if (kDebugMode) {
        print('🎯 _addCustomEntryToSchedule: Added custom entry to $day');
        print(
          '🎯 _addCustomEntryToSchedule: Schedule now has ${periods.length} periods',
        );
      }
    });
  }

  // Helper method to add minutes to a time string
  // Helper function to parse 12-hour format time string
  DateTime _parseTime12Hour(String timeString) {
    // Remove AM/PM and parse
    final cleanTime = timeString.replaceAll(RegExp(r'[AP]M'), '').trim();
    final timeParts = cleanTime.split(':');

    if (timeParts.length != 2) {
      throw FormatException('Invalid time format: $timeString');
    }

    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Determine if it's AM or PM
    final isPM = timeString.toUpperCase().contains('PM');

    // Convert to 24-hour format
    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }

    return DateTime(2024, 1, 1, hour, minute);
  }

  // Helper method to check if a subject is a custom entry
  bool _isCustomEntry(String subject) {
    return _customEntries.any((entry) => entry['name'] == subject);
  }

  void _removeCustomEntry(int index) {
    setState(() {
      _customEntries.removeAt(index);
    });
  }

  Widget _buildDaySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Day',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 15),

        Wrap(
          children:
              _days
                  .mapIndexed(
                    (index, day) => InkWell(
                      onTap: () {
                        setState(() {
                          _selectedDayIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              _selectedDayIndex == index
                                  ? homeColor.withOpacity(.8)
                                  : homeColor.withOpacity(.2),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                _selectedDayIndex == index
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildScheduleSection(dynamic subjectProvider) {
    final selectedDay = _days[_selectedDayIndex];
    final periods = _schedule[selectedDay] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Schedule for $selectedDay',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _addPeriod(subjectProvider),
              icon: const Icon(Icons.add),
              label: const Text('Add Period'),
              style: ElevatedButton.styleFrom(
                backgroundColor: homeColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        if (periods.isEmpty)
          const Center(
            child: Text(
              'No periods scheduled for this day',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...periods.asMap().entries.map((entry) {
            final index = entry.key;
            final period = entry.value;
            return _buildPeriodCard(period, index, subjectProvider);
          }).toList(),
      ],
    );
  }

  Widget _buildPeriodCard(Period period, int index, dynamic subjectProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Time
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value:
                              '${period.startTime}-$index', // Make value unique
                          decoration: const InputDecoration(
                            labelText: 'Start',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          items:
                              _timeSlots.map((time) {
                                return DropdownMenuItem(
                                  value:
                                      '$time-$index', // Match the value format
                                  child: Text(time),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              // Extract the actual time part (remove the indices)
                              final parts = value.split('-');
                              final actualTime = parts[0];
                              _updatePeriod(
                                index,
                                period.copyWith(startTime: actualTime),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value:
                              '${period.endTime}-$index', // Make value unique
                          decoration: const InputDecoration(
                            labelText: 'End',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          items:
                              _timeSlots.map((time) {
                                return DropdownMenuItem(
                                  value:
                                      '$time-$index', // Match the value format
                                  child: Text(time),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              // Extract the actual time part (remove the indices)
                              final parts = value.split('-');
                              final actualTime = parts[0];
                              _updatePeriod(
                                index,
                                period.copyWith(endTime: actualTime),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Subject and Custom Entry
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  // Subject Dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Subject',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value:
                              _isCustomEntry(period.subject)
                                  ? null
                                  : period.subject,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Select Subject'),
                            ),
                            ...subjectProvider.subjects
                                .map<DropdownMenuItem<String>>(
                                  (subject) => DropdownMenuItem<String>(
                                    value: subject.name,
                                    child: Text(subject.name),
                                  ),
                                )
                                .toList(),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _updatePeriod(
                                index,
                                period.copyWith(subject: value),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Custom Entry Dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Custom Entry',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value:
                              _isCustomEntry(period.subject)
                                  ? period.subject
                                  : null,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            hintText: 'Select...',
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('None'),
                            ),
                            ..._customEntries.map<DropdownMenuItem<String>>(
                              (customEntry) => DropdownMenuItem<String>(
                                value: customEntry['name'],
                                child: Row(
                                  children: [
                                    Icon(
                                      customEntry['icon'] ?? Icons.event,
                                      size: 16,
                                      color: Colors.purple[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(customEntry['name']),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _updatePeriod(
                                index,
                                period.copyWith(subject: value),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Room
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Room',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    initialValue: period.room ?? '',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      hintText: 'Room No.',
                    ),
                    onChanged: (value) {
                      _updatePeriod(
                        index,
                        period.copyWith(room: value.isEmpty ? null : value),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Actions
            Column(
              children: [
                IconButton(
                  onPressed: () => _removePeriod(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Remove Period',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableSummary() {
    // Calculate summary statistics
    int totalPeriods = 0;
    int daysWithSchedule = 0;
    Set<String> uniqueSubjects = {};

    for (String day in _days) {
      final periods = _schedule[day] ?? [];
      if (periods.isNotEmpty) {
        daysWithSchedule++;
        totalPeriods += periods.length;
        for (Period period in periods) {
          uniqueSubjects.add(period.subject);
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Timetable Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (totalPeriods == 0)
            Text(
              'No periods scheduled yet. Select a day and add periods to create your timetable.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Periods',
                    totalPeriods.toString(),
                    Icons.schedule,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Days Scheduled',
                    daysWithSchedule.toString(),
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Subjects',
                    uniqueSubjects.length.toString(),
                    Icons.subject,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Class',
                    _selectedClass ?? 'Not selected',
                    Icons.class_,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildValidationStatus() {
    // Check if form is ready to be saved
    bool isFormReady =
        _selectedClass != null &&
        _selectedTerm != null &&
        _selectedType != null &&
        _academicYearController.text.trim().isNotEmpty;

    // Check if schedule has any periods
    bool hasPeriods = false;
    for (String day in _days) {
      if ((_schedule[day] ?? []).isNotEmpty) {
        hasPeriods = true;
        break;
      }
    }

    bool canSave = isFormReady && hasPeriods;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: canSave ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: canSave ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            canSave ? Icons.check_circle : Icons.warning,
            color: canSave ? Colors.green[600] : Colors.orange[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canSave
                      ? 'Ready to Create Timetable'
                      : 'Complete Required Fields',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: canSave ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  canSave
                      ? 'All required fields are filled and timetable is ready to be created.'
                      : 'Please select class, term, type, academic year, and add at least one period.',
                  style: TextStyle(
                    fontSize: 14,
                    color: canSave ? Colors.green[600] : Colors.orange[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(dynamic timetableProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[50]!, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Summary section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Review your timetable before saving. Make sure all required fields are filled.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action buttons - Responsive layout
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 500) {
                // Stack vertically on smaller screens
                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _clearSchedule();
                        },
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Clear All'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          side: BorderSide(color: Colors.red[300]!, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [homeColor, homeColor.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: homeColor.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed:
                              timetableProvider.isLoading
                                  ? null
                                  : _saveTimetable,
                          icon:
                              timetableProvider.isLoading
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Icon(Icons.add_task, size: 20),
                          label: Text(
                            timetableProvider.isLoading
                                ? 'Creating...'
                                : 'CREATE TIMETABLE',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Use Row for larger screens
                return Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _clearSchedule();
                        },
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Clear All'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          side: BorderSide(color: Colors.red[300]!, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [homeColor, homeColor.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: homeColor.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed:
                              timetableProvider.isLoading
                                  ? null
                                  : _saveTimetable,
                          icon:
                              timetableProvider.isLoading
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Icon(Icons.add_task, size: 20),
                          label: Text(
                            timetableProvider.isLoading
                                ? 'Creating...'
                                : 'CREATE TIMETABLE',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Helper method to validate period times
  bool _validatePeriodTimes(String startTime, String endTime) {
    try {
      // Parse times to DateTime for comparison
      final startDateTime = _parseTime12Hour(startTime);
      final endDateTime = _parseTime12Hour(endTime);

      // Check if start and end times are the same
      if (startDateTime.isAtSameMomentAs(endDateTime)) {
        _dialogService.showSnackBar(
          'Start time and end time cannot be the same',
          appToastType: AppToastType.error,
        );
        return false;
      }

      // Check if end time is earlier than start time
      if (endDateTime.isBefore(startDateTime)) {
        _dialogService.showSnackBar(
          'End time cannot be earlier than start time',
          appToastType: AppToastType.error,
        );
        return false;
      }

      return true;
    } catch (e) {
      _dialogService.showSnackBar(
        'Invalid time format',
        appToastType: AppToastType.error,
      );
      return false;
    }
  }

  void _addPeriod(dynamic subjectProvider) {
    if (kDebugMode) {
      print('➕ _addPeriod: Starting to add new period');
    }

    if (_selectedDayIndex == -1) {
      if (kDebugMode) {
        print('❌ _addPeriod: No day selected (_selectedDayIndex = -1)');
      }
      return;
    }

    final selectedDay = _days[_selectedDayIndex];
    final periods = _schedule[selectedDay] ?? [];

    if (kDebugMode) {
      print('➕ _addPeriod: Selected day: $selectedDay');
      print('➕ _addPeriod: Current periods count: ${periods.length}');
    }

    // Find next available time slot that's not already used
    String startTime = '8:00AM';
    String endTime = _getEndTime(startTime);

    if (kDebugMode) {
      print('➕ _addPeriod: Initial times: $startTime - $endTime');
    }

    // Get available time slots for this day
    final availableSlots = _getAvailableTimeSlotsForDay(selectedDay);

    if (kDebugMode) {
      print('➕ _addPeriod: Available slots: $availableSlots');
    }

    if (availableSlots.isNotEmpty) {
      // Use the first available slot
      startTime = availableSlots.first;
      endTime = _getEndTime(startTime);
      if (kDebugMode) {
        print(
          '➕ _addPeriod: Using first available slot: $startTime - $endTime',
        );
      }
    } else {
      // If no slots available, find the latest end time and add after it
      if (periods.isNotEmpty) {
        // Sort periods by end time to find the latest
        final sortedPeriods = List<Period>.from(periods);
        sortedPeriods.sort((a, b) => a.endTime.compareTo(b.endTime));
        final latestPeriod = sortedPeriods.last;
        startTime = latestPeriod.endTime;
        endTime = _getEndTime(startTime);
        if (kDebugMode) {
          print(
            '➕ _addPeriod: No available slots, using after latest period: $startTime - $endTime',
          );
        }
      } else {
        if (kDebugMode) {
          print(
            '➕ _addPeriod: No periods exist, using default: $startTime - $endTime',
          );
        }
      }
    }

    if (kDebugMode) {
      print('➕ _addPeriod: Final calculated times: $startTime - $endTime');
    }

    // Get first subject from provider, or use a default if none available
    String defaultSubject = 'Mathematics';
    if (subjectProvider.subjects.isNotEmpty) {
      defaultSubject = subjectProvider.subjects.first.name;
    }

    if (kDebugMode) {
      print('➕ _addPeriod: Using subject: $defaultSubject');
    }

    // Validate the period times before creating
    if (!_validatePeriodTimes(startTime, endTime)) {
      if (kDebugMode) {
        print(
          '❌ _addPeriod: Validation failed for times: $startTime - $endTime',
        );
      }
      return;
    }

    final newPeriod = Period(
      startTime: startTime,
      endTime: endTime,
      subject: defaultSubject,
    );

    if (kDebugMode) {
      print(
        '➕ _addPeriod: Created new period: ${newPeriod.subject} (${newPeriod.startTime} - ${newPeriod.endTime})',
      );
    }

    setState(() {
      _schedule[selectedDay] = [...periods, newPeriod];
      if (kDebugMode) {
        print(
          '➕ _addPeriod: Updated schedule for $selectedDay with ${_schedule[selectedDay]!.length} periods',
        );
      }
    });
  }

  // Helper method to calculate end time based on start time and duration
  String _getEndTime(String startTime) {
    try {
      // Parse 12-hour format time and add duration
      final startDateTime = _parseTime12Hour(startTime);
      final endDateTime = startDateTime.add(
        Duration(minutes: _periodDurationMinutes),
      );

      return _formatTime12Hour(endDateTime);
    } catch (e) {
      if (kDebugMode) {
        print('❌ _getEndTime: Error calculating end time for $startTime: $e');
      }
      return '8:00AM'; // Safe fallback
    }
  }

  void _updatePeriod(int index, Period updatedPeriod) {
    if (kDebugMode) {
      print('🔄 _updatePeriod: Updating period at index $index');
      print(
        '🔄 _updatePeriod: New period: ${updatedPeriod.subject} (${updatedPeriod.startTime} - ${updatedPeriod.endTime})',
      );
    }

    if (_selectedDayIndex == -1) {
      if (kDebugMode) {
        print('❌ _updatePeriod: No day selected');
      }
      return;
    }

    final selectedDay = _days[_selectedDayIndex];
    final periods = _schedule[selectedDay] ?? [];

    if (kDebugMode) {
      print('🔄 _updatePeriod: Selected day: $selectedDay');
      print('🔄 _updatePeriod: Current periods count: ${periods.length}');
    }

    if (index < periods.length) {
      final oldPeriod = periods[index];
      if (kDebugMode) {
        print(
          '🔄 _updatePeriod: Old period: ${oldPeriod.subject} (${oldPeriod.startTime} - ${oldPeriod.endTime})',
        );
      }

      // Validate the updated period times before applying changes
      if (!_validatePeriodTimes(
        updatedPeriod.startTime,
        updatedPeriod.endTime,
      )) {
        if (kDebugMode) {
          print(
            '❌ _updatePeriod: Validation failed for times: ${updatedPeriod.startTime} - ${updatedPeriod.endTime}',
          );
        }
        return;
      }

      setState(() {
        periods[index] = updatedPeriod;
        if (kDebugMode) {
          print('🔄 _updatePeriod: Updated period at index $index');
        }
      });
    } else {
      if (kDebugMode) {
        print(
          '❌ _updatePeriod: Index $index out of bounds (periods.length: ${periods.length})',
        );
      }
    }
  }

  void _removePeriod(int index) {
    if (_selectedDayIndex == -1) return;

    final selectedDay = _days[_selectedDayIndex];
    final periods = _schedule[selectedDay] ?? [];

    if (index < periods.length) {
      setState(() {
        periods.removeAt(index);
      });
    }
  }

  void _clearSchedule() {
    setState(() {
      _initializeSchedule();
      _selectedDayIndex = -1;
      _customEntries.clear(); // Clear custom entries as well
    });
  }

  Future<void> _saveTimetable() async {
    if (!_formKey.currentState!.validate()) {
      _dialogService.showSnackBar(
        'Please fill in all required fields',
        appToastType: AppToastType.error,
      );
      return;
    }

    if (_selectedClass == null ||
        _selectedTerm == null ||
        _selectedType == null) {
      _dialogService.showSnackBar(
        'Please select class and type',
        appToastType: AppToastType.error,
      );
      return;
    }

    // Check if schedule has any periods
    bool hasPeriods = false;
    for (String day in _days) {
      if ((_schedule[day] ?? []).isNotEmpty) {
        hasPeriods = true;
        break;
      }
    }

    if (!hasPeriods) {
      _dialogService.showSnackBar(
        'Please add at least one period to the schedule',
        appToastType: AppToastType.error,
      );
      return;
    }

    // Get current user ID
    final profileProvider = ref.read(RiverpodProvider.profileProvider);
    final currentUserId = profileProvider.user?.id ?? '';

    // Find selected class ID
    final classProvider = ref.read(RiverpodProvider.classProvider);
    final classes = classProvider.classData.classes ?? [];
    final selectedClass = classes.cast<dynamic>().firstWhere(
      (c) => c.level == _selectedClass,
      orElse: () => null,
    );

    if (selectedClass == null) {
      _dialogService.showSnackBar(
        'Selected class not found',
        appToastType: AppToastType.error,
      );
      return;
    }

    // Convert schedule to backend format
    final schedule =
        _days.map((day) {
          final periods = _schedule[day] ?? [];
          return DaySchedule(day: day, periods: periods);
        }).toList();

    final request = CreateTimetableRequest(
      classId: selectedClass.id ?? '',
      academicYear: _academicYearController.text.trim(),
      term: _selectedTerm!,
      type: _selectedType!,
      schedule: schedule,
      createdBy: currentUserId,
      checkTeacherAvailability: true,
    );

    final timetableProvider = ref.read(RiverpodProvider.timetableProvider);
    final success = await timetableProvider.createTimetable(request);

    if (success) {
      final customEntriesCount = _customEntries.length;
      final message =
          customEntriesCount > 0
              ? 'Timetable created successfully with $customEntriesCount custom entries!'
              : 'Timetable created successfully!';

      _dialogService.showSnackBar(message, appToastType: AppToastType.success);

      // Clear form
      _clearSchedule();
      _selectedClass = null;
      _selectedType = null;
      // Don't clear academic year and term as they are now read-only

      // Navigate back or show success
      Navigator.of(context).pop();
    } else {
      _dialogService.showSnackBar(
        timetableProvider.errorMessage ?? 'Failed to create timetable',
        appToastType: AppToastType.error,
      );
    }
  }
}

// Extension to add copyWith method to Period
extension PeriodCopyWith on Period {
  Period copyWith({
    String? startTime,
    String? endTime,
    String? subject,
    String? teacher,
    String? room,
    String? notes,
  }) {
    return Period(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
      room: room ?? this.room,
      notes: notes ?? this.notes,
    );
  }
}
