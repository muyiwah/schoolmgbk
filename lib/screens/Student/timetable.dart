import 'package:flutter/material.dart';
import 'package:schmgtsystem/constants/appcolor.dart';

class ExamTimeTable extends StatefulWidget {
  const ExamTimeTable({super.key});

  @override
  State<ExamTimeTable> createState() => _ExamTimeTableState();
}

class _ExamTimeTableState extends State<ExamTimeTable>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime selectedDate = DateTime.now();
  String selectedView = 'Day';
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  final List<String> weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  final List<String> viewTypes = ['Day', 'Week', 'Month'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: weekDays.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title:
            isSearching
                ? TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search exams...',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                )
                : const Text(
                  '2025, 3rd Term Exam Schedule (Grade 3)',
                  style: TextStyle(color: Colors.black),
                ),
        leading:
            isSearching
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      isSearching = false;
                      searchQuery = '';
                      searchController.clear();
                    });
                  },
                )
                : null,
        actions: [
          if (!isSearching) ...[
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.black),
              onPressed: () => _selectDate(context),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) {
                setState(() {
                  selectedView = value;
                });
              },
              itemBuilder:
                  (context) =>
                      viewTypes
                          .map(
                            (view) => PopupMenuItem(
                              value: view,
                              child: Row(
                                children: [
                                  Icon(
                                    view == 'Day'
                                        ? Icons.today
                                        : view == 'Week'
                                        ? Icons.view_week
                                        : Icons.calendar_view_month,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(view),
                                ],
                              ),
                            ),
                          )
                          .toList(),
            ),
          ],
        ],
        bottom:
            selectedView == 'Week'
                ? TabBar(
                  controller: _tabController,
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.deepPurple,
                  tabs: weekDays.map((day) => Tab(text: day)).toList(),
                )
                : PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Text(
                          _getFormattedDate(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        _buildViewButton('Day'),
                        const SizedBox(width: 8),
                        _buildViewButton('Week'),
                      ],
                    ),
                  ),
                ),
      ),
      body:
          selectedView == 'Week'
              ? TabBarView(
                controller: _tabController,
                children: weekDays.map((day) => _buildDayView()).toList(),
              )
              : selectedView == 'Month'
              ? _buildMonthView()
              : _buildDayView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExamDialog(context),
        backgroundColor:AppColors.secondary,
        child: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }

  Widget _buildViewButton(String view) {
    final isSelected = selectedView == view;
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor:
            isSelected ? Colors.deepPurple.shade100 : Colors.deepPurple.shade50,
        foregroundColor:
            isSelected
                ? Colors.deepPurple.shade700
                : Colors.deepPurple.shade600,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: () {
        setState(() {
          selectedView = view;
        });
      },
      child: Text(view),
    );
  }

  Widget _buildDayView() {
    final filteredExams = _getFilteredExams();

    if (filteredExams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty ? 'No exams found' : 'No exams scheduled ',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredExams.length,
      itemBuilder: (context, index) {
        return _buildTimeSlotCard(filteredExams[index]);
      },
    );
  }

  Widget _buildMonthView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 35, // 5 weeks
      itemBuilder: (context, index) {
        final day = index + 1;
        final hasExam = _hasExamOnDay(day);

        return Container(
          decoration: BoxDecoration(
            color: hasExam ? Colors.deepPurple.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  hasExam ? Colors.deepPurple.shade200 : Colors.grey.shade300,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                day.toString(),
                style: TextStyle(
                  fontWeight: hasExam ? FontWeight.bold : FontWeight.normal,
                  color: hasExam ? Colors.deepPurple : Colors.black,
                ),
              ),
              if (hasExam)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSlotCard(Map<String, String> slot) {
    final currentTime = DateTime.now();
    final examTime = _parseTime(slot['time']!);
    final isUpcoming = examTime.isAfter(currentTime);
    final isPast = examTime.isBefore(
      currentTime.subtract(const Duration(minutes: 45)),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _getColorForSlot(slot['color']!).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getColorForSlot(slot['color']!).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getColorForSlot(slot['color']!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    slot['time']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot['subject']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        slot['duration']!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isPast)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20)
                else if (isUpcoming)
                  Icon(Icons.schedule, color: Colors.orange[700], size: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(slot['class']!, style: TextStyle(color: Colors.grey[600])),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      onPressed: () => _showEditExamDialog(context, slot),
                      color: Colors.grey[600],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 16),
                      onPressed: () => _showDeleteConfirmation(context, slot),
                      color: Colors.red[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForSlot(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.amber;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, String>> _getFilteredExams() {
    if (searchQuery.isEmpty) {
      return examSchedule;
    }

    return examSchedule.where((exam) {
      return exam['subject']!.toLowerCase().contains(searchQuery) ||
          exam['class']!.toLowerCase().contains(searchQuery) ||
          exam['time']!.toLowerCase().contains(searchQuery);
    }).toList();
  }

  bool _hasExamOnDay(int day) {
    // Simple logic - you can enhance this based on actual dates
    return day % 3 == 0; // Every 3rd day has an exam
  }

  DateTime _parseTime(String timeStr) {
    // Simple time parsing - enhance based on your needs
    final now = DateTime.now();
    final hour = int.parse(timeStr.split(':')[0]);
    final isAM = timeStr.contains('AM');
    final adjustedHour =
        isAM ? (hour == 12 ? 0 : hour) : (hour == 12 ? 12 : hour + 12);

    return DateTime(now.year, now.month, now.day, adjustedHour, 0);
  }

  String _getFormattedDate() {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return '${weekdays[selectedDate.weekday - 1]} ${months[selectedDate.month - 1]} ${selectedDate.day}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _showAddExamDialog(BuildContext context) {
    final timeController = TextEditingController();
    final subjectController = TextEditingController();
    final classroomController = TextEditingController();
    String selectedColor = 'blue';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Exam'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time (e.g., 8:00 AM)',
                  ),
                ),
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                TextField(
                  controller: classroomController,
                  decoration: const InputDecoration(labelText: 'Classroom'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  value: selectedColor,
                  decoration: const InputDecoration(labelText: 'Color'),
                  items:
                      ['blue', 'yellow', 'purple', 'pink', 'green', 'red']
                          .map(
                            (color) => DropdownMenuItem(
                              value: color,
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _getColorForSlot(color),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(color.toUpperCase()),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    selectedColor = value!;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (timeController.text.isNotEmpty &&
                      subjectController.text.isNotEmpty &&
                      classroomController.text.isNotEmpty) {
                    setState(() {
                      examSchedule.add({
                        'time': timeController.text,
                        'duration':
                            '${timeController.text} - ${_calculateEndTime(timeController.text)}',
                        'subject': subjectController.text,
                        'class': classroomController.text,
                        'color': selectedColor,
                      });
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _showEditExamDialog(BuildContext context, Map<String, String> exam) {
    // Similar to add dialog but with pre-filled values
    _showAddExamDialog(context); // Simplified for this example
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, String> exam) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Exam'),
            content: Text(
              'Are you sure you want to delete ${exam['subject']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    examSchedule.remove(exam);
                  });
                  Navigator.pop(context);
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

  String _calculateEndTime(String startTime) {
    // Simple calculation - add 45 minutes
    final parts = startTime.split(' ');
    final timePart = parts[0];
    final amPm = parts[1];
    final hourMin = timePart.split(':');
    final hour = int.parse(hourMin[0]);
    var minute = int.parse(hourMin[1]);

    minute += 45;
    var newHour = hour;
    if (minute >= 60) {
      newHour += 1;
      minute -= 60;
    }

    return '$newHour:${minute.toString().padLeft(2, '0')} $amPm';
  }

  List<Map<String, String>> examSchedule = [
    {
      'time': '8:00 AM',
      'duration': '8:00 AM - 8:45 AM',
      'subject': '4A - Physics',
      'class': 'Classroom A1',
      'color': 'blue',
    },
    {
      'time': '9:00 AM',
      'duration': '9:00 AM - 9:45 AM',
      'subject': '3B - Physics',
      'class': 'Classroom B3',
      'color': 'yellow',
    },
    {
      'time': '10:00 AM',
      'duration': '10:00 AM - 10:45 AM',
      'subject': '2B - Mathematics',
      'class': 'Classroom B2',
      'color': 'purple',
    },
    {
      'time': '11:00 AM',
      'duration': '11:00 AM - 11:45 AM',
      'subject': '5A - Physics',
      'class': 'Classroom A5',
      'color': 'pink',
    },
    {
      'time': '1:00 PM',
      'duration': '1:00 PM - 1:45 PM',
      'subject': '6C - Chemistry',
      'class': 'Classroom C6',
      'color': 'blue',
    },
    {
      'time': '2:00 PM',
      'duration': '2:00 PM - 2:45 PM',
      'subject': '2B - Physics',
      'class': 'Classroom B2',
      'color': 'yellow',
    },
  ];
}
