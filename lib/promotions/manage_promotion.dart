import 'package:flutter/material.dart';

class Student {
  final String id;
  final String name;
  final String grade;
  final String currentClass;
  final String nextClass;
  final String status;
  final String? remarks;
  final String? profileImage;

  Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.currentClass,
    required this.nextClass,
    required this.status,
    this.remarks,
    this.profileImage,
  });
}

class StudentPromotionManager extends StatefulWidget {
  @override
  _StudentPromotionManagerState createState() =>
      _StudentPromotionManagerState();
}

class _StudentPromotionManagerState extends State<StudentPromotionManager> {
  String selectedAcademicSession = '2024-2025';
  String selectedCurrentClass = 'JSS1';
  String selectedPromotionStatus = 'All Students';
  String searchQuery = '';
  List<bool> selectedStudents = [];

  final List<Student> students = [
    Student(
      id: 'JSS1/001',
      name: 'Sarah Johnson',
      grade: 'Grade A',
      currentClass: 'JSS1',
      nextClass: 'JSS2',
      status: 'Eligible',
    ),
    Student(
      id: 'JSS1/002',
      name: 'Michael Chen',
      grade: 'Needs Review',
      currentClass: 'JSS1',
      nextClass: 'JSS1 (Repeat)',
      status: 'Manual Review',
    ),
    Student(
      id: 'JSS1/003',
      name: 'Emma Williams',
      grade: 'Already Promoted',
      currentClass: 'JSS1',
      nextClass: 'JSS2',
      status: 'Promoted',
      remarks: 'Excellent performance',
    ),
  ];

  @override
  void initState() {
    super.initState();
    selectedStudents = List.filled(students.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.school, color: Colors.white),
        ),
        title: Text(
          'SchoolAdmin Pro',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey[600]),
            onPressed: () {},
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 20, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
      body: Container(height: double.infinity,
        child: ListView(
          children: [
            _buildHeader(),
            _buildStatsCards(),
            _buildFiltersSection(),
            _buildActionButtons(),
            Container(height: 400, child: _buildStudentsTable()),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Student Promotion Manager',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'View, select, and promote students to the next class or academic session',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeaderButton(
                'Promote Selected',
                Color(0xFF6366F1),
                Icons.arrow_upward,
                () {},
              ),
              SizedBox(width: 12),
              _buildHeaderButton(
                'Promote All Eligible',
                Color(0xFF8B5CF6),
                Icons.group,
                () {},
              ),
              SizedBox(width: 12),
              _buildHeaderButton(
                'Export Promotion List',
                Color(0xFF06B6D4),
                Icons.download,
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildStatCard(
            'Total Students',
            '42',
            Icons.people,
            Color(0xFF3B82F6),
          ),
          _buildStatCard(
            'Eligible',
            '38',
            Icons.check_circle,
            Color(0xFF10B981),
          ),
          _buildStatCard(
            'Promoted',
            '15',
            Icons.trending_up,
            Color(0xFF8B5CF6),
          ),
          _buildStatCard(
            'Pending Review',
            '4',
            Icons.schedule,
            Color(0xFFF59E0B),
          ),
          _buildStatCard(
            'Target Capacity',
            '45',
            Icons.business,
            Color(0xFF06B6D4),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Academic Session',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                _buildDropdown(
                  selectedAcademicSession,
                  ['2024-2025', '2023-2024'],
                  (value) {
                    setState(() => selectedAcademicSession = value!);
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Class',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                _buildDropdown(selectedCurrentClass, ['JSS1', 'JSS2', 'JSS3'], (
                  value,
                ) {
                  setState(() => selectedCurrentClass = value!);
                }),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promotion Status',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                _buildDropdown(
                  selectedPromotionStatus,
                  ['All Students', 'Eligible', 'Promoted'],
                  (value) {
                    setState(() => selectedPromotionStatus = value!);
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Student',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name or ID...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) => setState(() => searchQuery = value),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Padding(
            padding: EdgeInsets.only(top: 24),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.filter_list, size: 16),
              label: Text('Apply Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.grey[700],
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.group, size: 16),
            label: Text('Promote All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.close, size: 16),
            label: Text('Mark Not Eligible'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.refresh, size: 16),
            label: Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTable() {
    return Container(
      margin: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder:
                  (context, index) => _buildStudentRow(students[index], index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 40),
          Expanded(
            flex: 3,
            child: Text(
              'STUDENT',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'STUDENT ID',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'CURRENT CLASS',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'NEXT CLASS',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'STATUS',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'REMARKS',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'ACTIONS',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRow(Student student, int index) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: selectedStudents[index],
            onChanged: (value) {
              setState(() => selectedStudents[index] = value!);
            },
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    student.name[0],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      student.grade,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(student.id)),
          Expanded(flex: 2, child: Text(student.currentClass)),
          Expanded(flex: 2, child: Text(student.nextClass)),
          Expanded(flex: 2, child: _buildStatusChip(student.status)),
          Expanded(
            flex: 2,
            child: Text(
              student.remarks ?? 'Add remarks...',
              style: TextStyle(
                color:
                    student.remarks != null ? Colors.black : Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                if (student.status == 'Promoted')
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 12),
                        SizedBox(width: 4),
                        Text('Promoted', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Promote', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      minimumSize: Size(0, 0),
                    ),
                  ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.edit, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    Color backgroundColor;

    switch (status) {
      case 'Eligible':
        color = Color(0xFF10B981);
        backgroundColor = Color(0xFF10B981).withOpacity(0.1);
        break;
      case 'Manual Review':
        color = Color(0xFFF59E0B);
        backgroundColor = Color(0xFFF59E0B).withOpacity(0.1);
        break;
      case 'Promoted':
        color = Color(0xFF6366F1);
        backgroundColor = Color(0xFF6366F1).withOpacity(0.1);
        break;
      default:
        color = Colors.grey;
        backgroundColor = Colors.grey.withOpacity(0.1);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Promotion Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildActivityItem(
            '15 students promoted from JSS1 to JSS2',
            'Promoted by Admin John • 2 hours ago',
            Color(0xFF10B981),
            Icons.trending_up,
          ),
          SizedBox(height: 12),
          _buildActivityItem(
            '3 students marked for manual review',
            'Updated by Teacher Mary • 4 hours ago',
            Color(0xFFF59E0B),
            Icons.edit,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        TextButton(onPressed: () {}, child: Text('View Details')),
      ],
    );
  }
}
