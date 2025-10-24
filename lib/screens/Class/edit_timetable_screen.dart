import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/color_pallete.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/models/timetable_model.dart';
import 'package:schmgtsystem/services/dialog_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/academic_year_helper.dart';
import 'package:collection/collection.dart';

class EditTimetableScreen extends ConsumerStatefulWidget {
  final String classId;
  final String className;
  final TimetableModel? existingTimetable;

  const EditTimetableScreen({
    super.key,
    required this.classId,
    required this.className,
    this.existingTimetable,
  });

  @override
  ConsumerState<EditTimetableScreen> createState() =>
      _EditTimetableScreenState();
}

class _EditTimetableScreenState extends ConsumerState<EditTimetableScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DialogService _dialogService = locator<DialogService>();

  // Form controllers
  final TextEditingController _academicYearController = TextEditingController();

  // Selected values
  String? _selectedTerm;
  String? _selectedType;
  int _selectedDayIndex = 0;
  Map<String, List<Period>> _schedule = {};
  List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  List<String> _terms = ['First', 'Second', 'Third'];
  List<String> _types = ['regular', 'examination', 'special'];

  // Period Configuration State
  int _periodDurationMinutes = 45;

  // Custom Entry State
  List<Map<String, dynamic>> _customEntries = [];
  final TextEditingController _customEntryController = TextEditingController();
  final TextEditingController _customEntryDurationController =
      TextEditingController();

  // Subject selection for periods
  String? _selectedSubjectForPeriod;

  // Time slots
  List<String> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    _initializeFromExistingTimetable();
    _initializeSchedule();
    _timeSlots = _generateTimeSlots();

    // Load subjects after the first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubjects();
    });
  }

  void _initializeFromExistingTimetable() {
    if (widget.existingTimetable != null) {
      final timetable = widget.existingTimetable!;

      // Set form values
      _academicYearController.text = timetable.academicYear;
      _selectedTerm = timetable.term;
      _selectedType = timetable.type;

      // Initialize schedule from existing timetable
      _schedule = {};
      for (final daySchedule in timetable.schedule) {
        _schedule[daySchedule.day] = List<Period>.from(daySchedule.periods);
      }

      if (kDebugMode) {
        print('Initialized from existing timetable: ${timetable.id}');
        print('Academic Year: ${timetable.academicYear}');
        print('Term: ${timetable.term}');
        print('Type: ${timetable.type}');
        print('Schedule days: ${_schedule.keys.toList()}');
      }
    } else {
      // Set default values for new timetable
      _academicYearController.text = AcademicYearHelper.getCurrentAcademicYear(
        ref,
      );
      _selectedTerm = 'First';
      _selectedType = 'regular';
    }
  }

  void _initializeSchedule() {
    for (final day in _days) {
      if (!_schedule.containsKey(day)) {
        _schedule[day] = [];
      }
    }
  }

  void _loadSubjects() async {
    // Load subjects when the screen initializes
    final subjectProvider = ref.read(RiverpodProvider.subjectProvider);
    await subjectProvider.getAllSubjects(context);
  }

  List<String> _generateTimeSlots() {
    final slots = <String>[];
    final startHour = 8;
    final endHour = 16;

    for (int hour = startHour; hour < endHour; hour++) {
      for (int minute = 0; minute < 60; minute += _periodDurationMinutes) {
        final time = DateTime(2024, 1, 1, hour, minute);
        slots.add(_formatTime12Hour(time));
      }
    }

    return slots;
  }

  String _formatTime12Hour(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour}:${minute.toString().padLeft(2, '0')}$period';
  }

  DateTime _parseTime12Hour(String timeString) {
    try {
      final timeRegex = RegExp(
        r'(\d{1,2}):(\d{2})(AM|PM)',
        caseSensitive: false,
      );
      final match = timeRegex.firstMatch(timeString);

      if (match == null) {
        throw FormatException('Invalid time format: $timeString');
      }

      int hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)!.toUpperCase();

      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return DateTime(2024, 1, 1, hour, minute);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing time "$timeString": $e');
      }
      return DateTime(2024, 1, 1, 8, 0);
    }
  }

  String _getEndTime(String startTime) {
    final start = _parseTime12Hour(startTime);
    final end = start.add(Duration(minutes: _periodDurationMinutes));
    return _formatTime12Hour(end);
  }

  String _getEndTimeWithDuration(String startTime, int durationMinutes) {
    final start = _parseTime12Hour(startTime);
    final end = start.add(Duration(minutes: durationMinutes));
    return _formatTime12Hour(end);
  }

  List<String> _getAvailableTimeSlotsForDay(String day) {
    final existingPeriods = _schedule[day] ?? [];
    final usedSlots = <String>{};

    for (final period in existingPeriods) {
      usedSlots.add('${period.startTime} - ${period.endTime}');
    }

    return _timeSlots.where((slot) => !usedSlots.contains(slot)).toList();
  }

  bool _validatePeriodTimes(String startTime, String endTime) {
    if (startTime == endTime) {
      _dialogService.showSnackBar(
        'Start and end time cannot be the same',
        appToastType: AppToastType.error,
      );
      return false;
    }

    final start = _parseTime12Hour(startTime);
    final end = _parseTime12Hour(endTime);

    if (end.isBefore(start)) {
      _dialogService.showSnackBar(
        'End time cannot be earlier than start time',
        appToastType: AppToastType.error,
      );
      return false;
    }

    return true;
  }

  void _addPeriod() {
    if (_selectedSubjectForPeriod == null) {
      _dialogService.showSnackBar(
        'Please select a subject or custom entry',
        appToastType: AppToastType.error,
      );
      return;
    }

    final day = _days[_selectedDayIndex];
    final availableSlots = _getAvailableTimeSlotsForDay(day);

    if (availableSlots.isEmpty) {
      _dialogService.showSnackBar(
        'No available time slots for $day',
        appToastType: AppToastType.error,
      );
      return;
    }

    final startTime = availableSlots.first;
    String endTime;

    // Determine duration based on whether it's a custom entry
    if (_isCustomEntry(_selectedSubjectForPeriod!)) {
      final customEntry = _customEntries.firstWhere(
        (entry) => entry['name'] == _selectedSubjectForPeriod,
      );
      final duration = customEntry['duration'] as int;
      endTime = _getEndTimeWithDuration(startTime, duration);
    } else {
      endTime = _getEndTime(startTime);
    }

    if (!_validatePeriodTimes(startTime, endTime)) {
      return;
    }

    final newPeriod = Period(
      startTime: startTime,
      endTime: endTime,
      subject: _selectedSubjectForPeriod!,
      teacher: null,
      room: null,
      notes: null,
    );

    setState(() {
      _schedule[day]!.add(newPeriod);
      _selectedSubjectForPeriod = null;
    });

    _dialogService.showSnackBar(
      'Period added successfully',
      appToastType: AppToastType.success,
    );
  }

  void _updatePeriod(int periodIndex, Period updatedPeriod) {
    final day = _days[_selectedDayIndex];

    if (!_validatePeriodTimes(updatedPeriod.startTime, updatedPeriod.endTime)) {
      return;
    }

    setState(() {
      _schedule[day]![periodIndex] = updatedPeriod;
    });

    _dialogService.showSnackBar(
      'Period updated successfully',
      appToastType: AppToastType.success,
    );
  }

  void _removePeriod(int periodIndex) {
    final day = _days[_selectedDayIndex];

    setState(() {
      _schedule[day]!.removeAt(periodIndex);
    });

    _dialogService.showSnackBar(
      'Period removed successfully',
      appToastType: AppToastType.success,
    );
  }

  void _clearSchedule() {
    setState(() {
      for (final day in _days) {
        _schedule[day] = [];
      }
    });

    _dialogService.showSnackBar(
      'Schedule cleared successfully',
      appToastType: AppToastType.success,
    );
  }

  bool _isCustomEntry(String subject) {
    return _customEntries.any((entry) => entry['name'] == subject);
  }

  Future<void> _updateTimetable() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTerm == null || _selectedType == null) {
      _dialogService.showSnackBar(
        'Please select term and type',
        appToastType: AppToastType.error,
      );
      return;
    }

    try {
      // Convert schedule to DaySchedule format
      final schedule =
          _days.map((day) {
            return DaySchedule(day: day, periods: _schedule[day] ?? []);
          }).toList();

      // Get current user ID
      final profileProvider = ref.read(RiverpodProvider.profileProvider);
      final currentUserId = profileProvider.user?.id ?? '';

      if (kDebugMode) {
        print('Current user ID: $currentUserId');
        print('Existing createdBy: ${widget.existingTimetable!.createdBy}');
      }

      final updateRequest = UpdateTimetableRequest(
        classId: widget.classId,
        academicYear: _academicYearController.text,
        term: _selectedTerm!,
        type: _selectedType!,
        schedule: schedule,
        createdBy:
            currentUserId.isNotEmpty
                ? currentUserId
                : widget.existingTimetable!.createdBy,
      );

      // Debug: Print the request data
      if (kDebugMode) {
        print('Timetable ID: ${widget.existingTimetable!.id}');
        print('Update Request: ${updateRequest.toJson()}');
        print('Schedule: ${schedule.map((s) => s.toJson()).toList()}');
      }

      // Check if we have a real timetable ID or need to create a new one
      final timetableId = widget.existingTimetable!.id;
      final isTemporaryId = timetableId.startsWith('temp_');

      if (kDebugMode) {
        print('Timetable ID: $timetableId');
        print('Is temporary ID: $isTemporaryId');
      }

      bool success;
      if (isTemporaryId) {
        // Create new timetable
        final createRequest = CreateTimetableRequest(
          classId: widget.classId,
          academicYear: _academicYearController.text,
          term: _selectedTerm!,
          type: _selectedType!,
          schedule: schedule,
          createdBy: 'current_user_id', // TODO: Get actual user ID
          checkTeacherAvailability: false,
        );

        success = await ref
            .read(RiverpodProvider.timetableProvider.notifier)
            .createTimetable(createRequest);
      } else {
        // Update existing timetable
        success = await ref
            .read(RiverpodProvider.timetableProvider.notifier)
            .updateTimetable(timetableId, updateRequest);
      }

      if (success) {
        _dialogService.showSnackBar(
          'Timetable updated successfully',
          appToastType: AppToastType.success,
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        _dialogService.showSnackBar(
          'Failed to update timetable',
          appToastType: AppToastType.error,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Update timetable error: $e');
      }
      _dialogService.showSnackBar(
        'Error updating timetable: $e',
        appToastType: AppToastType.error,
      );
    }
  }

  Future<void> _deleteTimetable() async {
    if (widget.existingTimetable == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Timetable'),
            content: const Text(
              'Are you sure you want to delete this timetable? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final success = await ref
            .read(RiverpodProvider.timetableProvider.notifier)
            .deleteTimetable(widget.existingTimetable!.id);

        if (success) {
          _dialogService.showSnackBar(
            'Timetable deleted successfully',
            appToastType: AppToastType.success,
          );
          Navigator.pop(context, true); // Return true to indicate deletion
        } else {
          _dialogService.showSnackBar(
            'Failed to delete timetable',
            appToastType: AppToastType.error,
          );
        }
      } catch (e) {
        _dialogService.showSnackBar(
          'Error deleting timetable: $e',
          appToastType: AppToastType.error,
        );
      }
    }
  }

  @override
  void dispose() {
    _academicYearController.dispose();
    _customEntryController.dispose();
    _customEntryDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Edit Timetable - ${widget.className}'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          if (widget.existingTimetable != null) ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTimetable,
              tooltip: 'Delete Timetable',
            ),
          ],
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 24),
              _buildDaySelection(),
              const SizedBox(height: 24),
              _buildScheduleSection(),
              const SizedBox(height: 24),
              _buildTimetableSummary(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _updateTimetable,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.save),
        label: const Text('Update Timetable'),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _academicYearController,
                    decoration: const InputDecoration(
                      labelText: 'Academic Year',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter academic year';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTerm,
                    decoration: const InputDecoration(
                      labelText: 'Term',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _terms.map<DropdownMenuItem<String>>((term) {
                          return DropdownMenuItem<String>(
                            value: term,
                            child: Text(term),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTerm = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _types.map<DropdownMenuItem<String>>((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(_capitalizeFirst(type)),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelection() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Day',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleSection() {
    final day = _days[_selectedDayIndex];
    final periods = _schedule[day] ?? [];

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Schedule for ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const Spacer(),
                Text(
                  '${periods.length} periods',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAddPeriodSection(),
            const SizedBox(height: 16),
            _buildPeriodsList(periods),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPeriodSection() {
    final subjectProvider = ref.watch(RiverpodProvider.subjectProvider);
    final subjects = subjectProvider.subjects;
    final allOptions = [
      ...subjects.map((s) => s.name).where((name) => name.isNotEmpty),
      ..._customEntries
          .map((e) => e['name'] as String)
          .where((name) => name.isNotEmpty),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Period',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSubjectForPeriod,
                  decoration: const InputDecoration(
                    labelText: 'Subject/Custom Entry',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      allOptions.isEmpty
                          ? [
                            const DropdownMenuItem<String>(
                              value: 'loading',
                              child: Text('Loading subjects...'),
                            ),
                          ]
                          : allOptions.map<DropdownMenuItem<String>>((option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                  onChanged:
                      allOptions.isEmpty
                          ? null
                          : (value) {
                            setState(() {
                              _selectedSubjectForPeriod = value;
                            });
                          },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _addPeriod,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodsList(List<Period> periods) {
    if (periods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.schedule_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No periods scheduled for ${_days[_selectedDayIndex]}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children:
          periods.asMap().entries.map((entry) {
            final index = entry.key;
            final period = entry.value;
            return _buildPeriodCard(index, period);
          }).toList(),
    );
  }

  Widget _buildPeriodCard(int index, Period period) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getSubjectColor(period.subject).withOpacity(0.1),
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: _getSubjectColor(period.subject),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          period.subject,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${period.startTime} - ${period.endTime}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () => _showEditPeriodDialog(index, period),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              onPressed: () => _removePeriod(index),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPeriodDialog(int index, Period period) {
    final teacherController = TextEditingController(text: period.teacher ?? '');
    final roomController = TextEditingController(text: period.room ?? '');

    // State variables for dropdowns
    String? selectedSubject = period.subject;
    String? selectedStartTime = period.startTime;
    String? selectedEndTime = period.endTime;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              final subjectProvider = ref.watch(
                RiverpodProvider.subjectProvider,
              );
              final subjects = subjectProvider.subjects;
              final subjectOptions = [
                ...subjects.map((s) => s.name).where((name) => name.isNotEmpty),
                ..._customEntries
                    .map((e) => e['name'] as String)
                    .where((name) => name.isNotEmpty),
              ];

              final timeSlots = _timeSlots;

              // Ensure selected values exist in the options
              if (selectedSubject != null &&
                  !subjectOptions.contains(selectedSubject)) {
                selectedSubject = null;
              }
              if (selectedStartTime != null &&
                  !timeSlots.contains(selectedStartTime)) {
                selectedStartTime = null;
              }
              if (selectedEndTime != null &&
                  !timeSlots.contains(selectedEndTime)) {
                selectedEndTime = null;
              }

              return AlertDialog(
                title: const Text('Edit Period'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedSubject,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            subjectOptions.map<DropdownMenuItem<String>>((
                              subject,
                            ) {
                              return DropdownMenuItem<String>(
                                value: subject,
                                child: Text(subject),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedSubject = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedStartTime,
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            timeSlots.map<DropdownMenuItem<String>>((time) {
                              return DropdownMenuItem<String>(
                                value: time,
                                child: Text(time),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedStartTime = value;
                            // Auto-update end time based on period duration
                            if (value != null) {
                              selectedEndTime = _getEndTime(value);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedEndTime,
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            timeSlots.map<DropdownMenuItem<String>>((time) {
                              return DropdownMenuItem<String>(
                                value: time,
                                child: Text(time),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedEndTime = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: teacherController,
                        decoration: const InputDecoration(
                          labelText: 'Teacher (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: roomController,
                        decoration: const InputDecoration(
                          labelText: 'Room (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedSubject == null ||
                          selectedStartTime == null ||
                          selectedEndTime == null) {
                        _dialogService.showSnackBar(
                          'Please select subject, start time, and end time',
                          appToastType: AppToastType.error,
                        );
                        return;
                      }

                      final updatedPeriod = Period(
                        startTime: selectedStartTime!,
                        endTime: selectedEndTime!,
                        subject: selectedSubject!,
                        teacher:
                            teacherController.text.isNotEmpty
                                ? teacherController.text
                                : null,
                        room:
                            roomController.text.isNotEmpty
                                ? roomController.text
                                : null,
                        notes: period.notes,
                      );

                      _updatePeriod(index, updatedPeriod);
                      Navigator.pop(context);
                    },
                    child: const Text('Update'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildTimetableSummary() {
    int totalPeriods = 0;
    for (final day in _days) {
      totalPeriods += _schedule[day]?.length ?? 0;
    }

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timetable Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Periods',
                    totalPeriods.toString(),
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Days Scheduled',
                    _days
                        .where((day) => (_schedule[day]?.isNotEmpty ?? false))
                        .length
                        .toString(),
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Period Duration',
                    '$_periodDurationMinutes min',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _clearSchedule,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _updateTimetable,
            icon: const Icon(Icons.save),
            label: const Text('Update Timetable'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Color _getSubjectColor(String subject) {
    final colors = [
      Colors.blue[600]!,
      Colors.green[600]!,
      Colors.purple[600]!,
      Colors.orange[600]!,
      Colors.red[600]!,
      Colors.teal[600]!,
      Colors.pink[600]!,
      Colors.indigo[600]!,
      Colors.cyan[600]!,
    ];

    final hash = subject.hashCode;
    return colors[hash.abs() % colors.length];
  }
}
