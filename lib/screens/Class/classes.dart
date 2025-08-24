import 'package:flutter/material.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/widgets/add_class.dart';
import 'package:schmgtsystem/widgets/add_teacher.dart';
import 'package:schmgtsystem/widgets/prompt.dart';

class SchoolClasses extends StatefulWidget {
  final Function navigateTo;
  final Function navigateTo2;
  final Function navigateTo3;
  SchoolClasses({
    super.key,
    required this.navigateTo,
    required this.navigateTo2,
    required this.navigateTo3,
  });

  @override
  State<SchoolClasses> createState() => _SchoolClassesState();
}

class _SchoolClassesState extends State<SchoolClasses> {
  String selectedLevel = 'All Levels';
  String sortBy = 'Sort by Alphabetical';
  bool isGridView = true;

  final List<String> levels = [
    'All Levels',
    'Primary',
    'JSS',
    'SSS',
    'Nursery',
  ];
  final List<String> sortOptions = [
    'Sort by Alphabetical',
    'Sort by Students',
    'Sort by Attendance',
  ];

  prompt(context) {
    CustomDialog(message: 'Do you want to download report?', context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildActionButtons(
              navigate: () {
                widget.navigateTo();
              },
            ),
            const SizedBox(height: 40),
            _buildStatsCards(),
            const SizedBox(height: 40),
            _buildFiltersAndSearch(),
            const SizedBox(height: 24),
            _buildClassesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Classes Overview',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Monitor class-level statistics and drill down into academic and administrative insights',
          style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildActionButtons({required navigate}) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {
             showDialog(
              context: context,
              barrierDismissible: true,
              barrierColor: Colors.black.withOpacity(0.5),
              builder:
                  (context) => AddClassDialog(),
            );
          },
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add New Class'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {
            navigate();
          },
          icon: const Icon(Icons.schedule, size: 20),
          label: const Text('View Timetables'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
            widget.navigateTo3();
          },
          icon: const Icon(Icons.download, size: 20),
          label: const Text('Assign Student'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.tertiary3,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 12),

        ElevatedButton.icon(
          onPressed: () {
            prompt(context);
          },
          icon: const Icon(Icons.download, size: 20),
          label: const Text('Download Report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF06B6D4),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Classes',
            '24',
            Icons.class_,
            const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Students',
            '648',
            Icons.people,
            const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Full Capacity',
            '8',
            Icons.person,
            const Color(0xFF06B6D4),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Missing Teachers',
            '3',
            Icons.warning,
            const Color(0xFFF59E0B),
            isWarning: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Upcoming Events',
            '12',
            Icons.event,
            const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isWarning = false,
  }) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (isWarning) ...[
                const Spacer(),
                Icon(Icons.warning, color: color, size: 16),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search classes or teacher',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildDropdown(selectedLevel, levels, (value) {
          setState(() {
            selectedLevel = value!;
          });
        }),
        const SizedBox(width: 16),
        _buildDropdown(sortBy, sortOptions, (value) {
          setState(() {
            sortBy = value!;
          });
        }),
        const SizedBox(width: 16),
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  isGridView = true;
                });
              },
              icon: Icon(
                Icons.grid_view,
                color: isGridView ? const Color(0xFF6366F1) : Colors.grey,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  isGridView = false;
                });
              },
              icon: Icon(
                Icons.list,
                color: !isGridView ? const Color(0xFF6366F1) : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
        underline: Container(),
      ),
    );
  }

  Widget _buildClassesList() {
    final classes = _getClassData();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        return _buildClassCard(
          classes[index],
          navigateTo2: () {
            widget.navigateTo2();
          },
        );
      },
    );
  }

  Widget _buildClassCard(
    ClassData classData, {
    required Null Function() navigateTo2,
  }) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                classData.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: classData.levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  classData.level,
                  style: TextStyle(
                    color: classData.levelColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(classData.teacherImage),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classData.teacherName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      classData.teacherRole,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // const SizedBox(height: 16),
          _buildClassStats(classData),
          const SizedBox(height: 16),
          if (classData.nextEvent.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: classData.eventColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                classData.nextEvent,
                style: TextStyle(
                  color: classData.eventColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                    classData.isAssignTeacher
      ?    showDialog(
              context: context,
              barrierDismissible: true,
              barrierColor: Colors.black.withOpacity(0.5),
              builder:
                  (context) => AssignNewTeacherDialog(),
            ):

                // AssignNewTeacherDialog
                navigateTo2();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    classData.isAssignTeacher
                        ? Colors.red
                        : AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                classData.isAssignTeacher
                    ? 'Assign Teacher'
                    : 'View Class Details',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassStats(ClassData classData) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Students',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              '${classData.totalStudents}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${classData.maleStudents}',
              style: const TextStyle(fontSize: 10),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${classData.femaleStudents}',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Attendance',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              '${classData.attendance}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: classData.attendance / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            classData.attendance >= 90
                ? Colors.green
                : classData.attendance >= 80
                ? Colors.orange
                : Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Avg Score',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              '${classData.avgScore}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  List<ClassData> _getClassData() {
    return [
      ClassData(
        name: 'Grade 5 - Blue',
        level: 'Primary',
        levelColor: const Color(0xFF6366F1),
        teacherName: 'Mrs. Sarah Johnson',
        teacherRole: 'Class Teacher',
        teacherImage: 'https://via.placeholder.com/32',
        totalStudents: 28,
        maleStudents: 15,
        femaleStudents: 13,
        attendance: 92,
        avgScore: 85,
        nextEvent: 'Next: Math Quiz - Dec 15',
        eventColor: const Color(0xFF3B82F6),
        isAssignTeacher: false,
      ),
      ClassData(
        name: 'Grade 10 - A',
        level: 'JSS',
        levelColor: const Color(0xFF8B5CF6),
        teacherName: 'Mr. David Wilson',
        teacherRole: 'Class Teacher',
        teacherImage: 'https://via.placeholder.com/32',
        totalStudents: 32,
        maleStudents: 18,
        femaleStudents: 14,
        attendance: 88,
        avgScore: 78,
        nextEvent: 'Next: Science Exam - Dec 18',
        eventColor: const Color(0xFF3B82F6),
        isAssignTeacher: false,
      ),
      ClassData(
        name: 'Nursery 2',
        level: 'Nursery',
        levelColor: const Color(0xFF06B6D4),
        teacherName: 'Miss Emily Davis',
        teacherRole: 'Class Teacher',
        teacherImage: 'https://via.placeholder.com/32',
        totalStudents: 20,
        maleStudents: 12,
        femaleStudents: 8,
        attendance: 95,
        avgScore: 90,
        nextEvent: 'Next: Art Activity - Dec 16',
        eventColor: const Color(0xFF10B981),
        isAssignTeacher: false,
      ),
      ClassData(
        name: 'Grade 12 - Science',
        level: 'SSS',
        levelColor: const Color(0xFF8B5CF6),
        teacherName: 'No Teacher Assigned',
        teacherRole: 'Requires Assignment',
        teacherImage: 'https://via.placeholder.com/32',
        totalStudents: 25,
        maleStudents: 14,
        femaleStudents: 11,
        attendance: 75,
        avgScore: 70,
        nextEvent: 'Urgent: Assign Teacher',
        eventColor: const Color(0xFFEF4444),
        isAssignTeacher: true,
      ),
    ];
  }
}

class ClassData {
  final String name;
  final String level;
  final Color levelColor;
  final String teacherName;
  final String teacherRole;
  final String teacherImage;
  final int totalStudents;
  final int maleStudents;
  final int femaleStudents;
  final int attendance;
  final int avgScore;
  final String nextEvent;
  final Color eventColor;
  final bool isAssignTeacher;

  ClassData({
    required this.name,
    required this.level,
    required this.levelColor,
    required this.teacherName,
    required this.teacherRole,
    required this.teacherImage,
    required this.totalStudents,
    required this.maleStudents,
    required this.femaleStudents,
    required this.attendance,
    required this.avgScore,
    required this.nextEvent,
    required this.eventColor,
    required this.isAssignTeacher,
  });
}
