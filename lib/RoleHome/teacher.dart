import 'package:flutter/material.dart';
import 'package:schmgtsystem/widgets/add_assignment_popup.dart';
import 'package:schmgtsystem/widgets/message_popup.dart';
import 'package:schmgtsystem/widgets/todo_popup.dart';

class TeacherDashboardApp extends StatefulWidget {
  const TeacherDashboardApp({super.key});

  @override
  State<TeacherDashboardApp> createState() => _TeacherDashboardAppState();
}

class _TeacherDashboardAppState extends State<TeacherDashboardApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Stats Cards
              _buildStatsCards(),
              const SizedBox(height: 24),

              // Main Content
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      flex: 2,
                      child: ListView(
                        children: [
                          _buildTodaySchedule(),
                          const SizedBox(height: 20),
                          _buildToDoList(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Right Column
                    Expanded(
                      flex: 1,
                      child: ListView(
                        children: [
                          _buildCalendar(),
                          const SizedBox(height: 20),
                          _buildQuickActions(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF00BCD4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage('assets/teacher_avatar.jpg'),
          backgroundColor: Colors.grey,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good Morning, Ms. Johnson',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                'Friday, June 14, 2024',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 24),
              onPressed: () {},
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // IconButton(
        //   icon: const Icon(Icons.settings_outlined, size: 24),
        //   onPressed: () {},
        // ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        _buildStatCard(
          'My Classes',
          '5',
          'Today',
          const Color(0xFF00BCD4),
          Icons.class_,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          'Attendance',
          '3',
          'Due',
          const Color(0xFF00BCD4),
          Icons.people_outline,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          'Exams',
          '2',
          'To Grade',
          const Color(0xFF00BCD4),
          Icons.assignment_outlined,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          'Assignments',
          '7',
          'Pending',
          const Color(0xFF00BCD4),
          Icons.assignment_turned_in_outlined,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          'Announcements',
          '2',
          'Unread',
          const Color(0xFF00BCD4),
          Icons.campaign_outlined,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String number,
    String subtitle,
    Color iconColor,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(icon, color: iconColor, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              number,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: _getSubtitleColor(subtitle),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSubtitleColor(String subtitle) {
    switch (subtitle.toLowerCase()) {
      case 'due':
        return const Color(0xFFFF9800);
      case 'to grade':
        return const Color(0xFF2196F3);
      case 'pending':
        return const Color(0xFF2196F3);
      case 'unread':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  Widget _buildTodaySchedule() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: Color(0xFF00BCD4), size: 20),
              const SizedBox(width: 8),
              const Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildScheduleItem(
            'Mathematics - Grade 10A',
            'Room 203 • 45 minutes',
            '8:00 AM',
            'Current',
            true,
          ),
          const SizedBox(height: 16),
          _buildScheduleItem(
            'Physics - Grade 11B',
            'Lab 1 • 45 minutes',
            '10:15 AM',
            '',
            false,
          ),
          const SizedBox(height: 16),
          _buildScheduleItem(
            'Mathematics - Grade 9C',
            'Room 203 • 45 minutes',
            '1:30 PM',
            '',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    String title,
    String subtitle,
    String time,
    String status,
    bool isCurrent,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFE3F2FD) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border:
            isCurrent
                ? Border.all(color: const Color(0xFF2196F3), width: 2)
                : null,
      ),
      child: Row(
        children: [
          if (isCurrent)
            Container(
              width: 4,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
          if (isCurrent) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              if (status.isNotEmpty)
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToDoList() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist, color: Color(0xFF00BCD4), size: 20),
              const SizedBox(width: 8),
              const Text(
                "To-Do List",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildToDoItem(
            'Grade Physics Test - Grade 11B',
            'Due: Today',
            Colors.red[100]!,
            Colors.red,
            'Urgent',
            Icons.assignment_outlined,
          ),
          const SizedBox(height: 12),
          _buildToDoItem(
            'Submit Attendance - Grade 10A',
            'Due: 5:00 PM',
            Colors.orange[100]!,
            Colors.orange,
            '',
            Icons.people_outline,
          ),
          const SizedBox(height: 12),
          _buildToDoItem(
            'Prepare Lesson Plan - Chapter 5',
            'Due: Monday',
            Colors.blue[100]!,
            Colors.blue,
            '',
            Icons.book_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildToDoItem(
    String title,
    String subtitle,
    Color bgColor,
    Color iconColor,
    String urgency,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (urgency.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                urgency,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: Color(0xFF00BCD4),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                "June 2024",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final today = 14;
    final examDay = 17;
    final holiday = 20;

    return Column(
      children: [
        // Days of week header
        Row(
          children:
              daysOfWeek
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 12),

        // Calendar dates
        Column(
          children: [
            // Week 1
            Row(
              children: [
                _buildCalendarDay('26', false),
                _buildCalendarDay('27', false),
                _buildCalendarDay('28', false),
                _buildCalendarDay('29', false),
                _buildCalendarDay('30', false),
                _buildCalendarDay('31', false),
                _buildCalendarDay('1', true),
              ],
            ),
            // Week 2
            Row(
              children: [
                _buildCalendarDay('2', true),
                _buildCalendarDay('3', true),
                _buildCalendarDay('4', true),
                _buildCalendarDay('5', true),
                _buildCalendarDay('6', true),
                _buildCalendarDay('7', true),
                _buildCalendarDay('8', true),
              ],
            ),
            // Week 3
            Row(
              children: [
                _buildCalendarDay('9', true),
                _buildCalendarDay('10', true),
                _buildCalendarDay('11', true),
                _buildCalendarDay('12', true),
                _buildCalendarDay('13', true),
                _buildCalendarDay('14', true, isToday: true),
                _buildCalendarDay('15', true),
              ],
            ),
            // Week 4
            Row(
              children: [
                _buildCalendarDay('16', true),
                _buildCalendarDay('17', true, isExamDay: true),
                _buildCalendarDay('18', true),
                _buildCalendarDay('19', true),
                _buildCalendarDay('20', true, isHoliday: true),
                _buildCalendarDay('21', true),
                _buildCalendarDay('22', true),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Legend
        Column(
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Exam Day', style: TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Holiday', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarDay(
    String day,
    bool isCurrentMonth, {
    bool isToday = false,
    bool isExamDay = false,
    bool isHoliday = false,
  }) {
    Color? backgroundColor;
    Color textColor =
        isCurrentMonth ? const Color(0xFF2D3748) : Colors.grey[400]!;

    if (isToday) {
      backgroundColor = const Color(0xFF00BCD4);
      textColor = Colors.white;
    }

    return Expanded(
      child: Container(
        height: 36,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),
            if (isExamDay)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (isHoliday)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildQuickActionButton(
                'Mark Attendance',
                Icons.people_outline,
                const Color(0xFF00BCD4),
                Colors.blue[50]!,
                context,
              ),
              const SizedBox(width: 12),
              _buildQuickActionButton(
                'Add Assignment',
                Icons.add,
                const Color(0xFF2D3748),
                Colors.grey[100]!,
                context,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildQuickActionButton(
                'Enter Todo',
                Icons.star,
                const Color(0xFF4CAF50),
                Colors.green[50]!,
                context,
              ),
              const SizedBox(width: 12),
              _buildQuickActionButton(
                'Send Notice',
                Icons.campaign,
                const Color(0xFF9C27B0),
                Colors.purple[50]!,
                context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color iconColor,
    Color backgroundColor,
    context,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (title == 'Enter Todo') {
            showDialog(
              context: context,
              barrierDismissible: true,
              barrierColor: Colors.black.withOpacity(0.5),
              builder: (context) => TeacherTodoPopup(onTodoAdded: (p0) {}),
            );
          } else if (title == 'Send Notice') {
            showDialog(
              context: context,
              barrierDismissible: true,
              barrierColor: Colors.black.withOpacity(0.5),
              builder: (context) => MessagePopup(title: 'Message to Parents'),
            );
          } else if (title == 'Add Assignment') {
            showDialog(
              context: context,
              barrierDismissible: true,
              barrierColor: Colors.black.withOpacity(0.5),
              builder: (context) => AssignmentPopup(),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
