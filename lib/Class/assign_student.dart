import 'package:flutter/material.dart';

class Student {
  final String id;
  final String name;
  final String admissionNo;
  final String currentClass;
  final String gender;
  final int age;
  final String? avatarUrl;

  Student({
    required this.id,
    required this.name,
    required this.admissionNo,
    required this.currentClass,
    required this.gender,
    required this.age,
    this.avatarUrl,
  });
}

class AssignStudentsScreen extends StatefulWidget {
  const AssignStudentsScreen({Key? key}) : super(key: key);

  @override
  State<AssignStudentsScreen> createState() => _AssignStudentsScreenState();
}

class _AssignStudentsScreenState extends State<AssignStudentsScreen> {
  String selectedAcademicYear = '2024-2025';
  String selectedFilter = 'Unassigned';
  String selectedClassFilter = 'All Classes';
  String searchQuery = '';
  int currentPage = 1;
  final int totalPages = 3;
  final int totalResults = 12;
  List<bool> selectedStudents = [false, false, false];
  List<String> selectedClasses = [
    'Select Class',
    'Select Class',
    'Select Class',
  ];
  String action = 'Assign';
  int assignedIndex = -1;
  final List<Student> students = [
    Student(
      id: '1',
      name: 'Sarah Johnson',
      admissionNo: 'STU001',
      currentClass: 'Unassigned',
      gender: 'Female',
      age: 12,
    ),
    Student(
      id: '2',
      name: 'Michael Chen',
      admissionNo: 'STU002',
      currentClass: 'Unassigned',
      gender: 'Male',
      age: 11,
    ),
    Student(
      id: '3',
      name: 'Emma Rodriguez',
      admissionNo: 'STU003',
      currentClass: 'Unassigned',
      gender: 'Female',
      age: 13,
    ),
  ];

  final List<String> academicYears = ['2024-2025', '2023-2024', '2022-2023'];
  final List<String> filterOptions = ['Unassigned', 'All Students'];
  final List<String> classOptions = [
    'All Classes',
    'Class A',
    'Class B',
    'Class C',
  ];
  final List<String> assignableClasses = [
    'Select Class',
    'Class A',
    'Class B',
    'Class C',
    'Class D',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildFilters(),
            const SizedBox(height: 32),
            _buildDataTable(),
            const SizedBox(height: 24),
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Assign Students to Classes',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.brightness_6_outlined,
                color: Colors.grey,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'View and manage student class assignments',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _buildAcademicYearDropdown(),
        const SizedBox(width: 16),
        _buildFilterTabs(),
        const SizedBox(width: 16),
        _buildSearchField(),
        const SizedBox(width: 16),
        _buildClassFilterDropdown(),
      ],
    );
  }

  Widget _buildAcademicYearDropdown() {
    return Row(
      children: [
        Text(
          'Academic Year:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedAcademicYear,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedAcademicYear = newValue;
                  });
                }
              },
              items:
                  academicYears.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Row(
      children: [
        Text(
          'Show:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey[100],
          ),
          child: Row(
            children:
                filterOptions.map((option) {
                  final isSelected = selectedFilter == option;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = option;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFF4F46E5)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      width: 250,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by name or ID',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildClassFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedClassFilter,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedClassFilter = newValue;
              });
            }
          },
          items:
              classOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            _buildTableHeader(),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return _buildTableRow(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),
          _buildHeaderCell('Student Name', flex: 3),
          _buildHeaderCell('Admission No.', flex: 2),
          _buildHeaderCell('Current Class', flex: 2),
          _buildHeaderCell('Gender', flex: 1),
          _buildHeaderCell('Age', flex: 1),
          _buildHeaderCell('Assign Class', flex: 2),
          _buildHeaderCell('Action', flex: 1),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          if (title == 'Student Name' ||
              title == 'Admission No.' ||
              title == 'Age')
            Icon(Icons.unfold_more, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildTableRow(int index) {
    final student = students[index];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: selectedStudents[index],
              onChanged: (bool? value) {
                setState(() {
                  selectedStudents[index] = value ?? false;
                });
              },
              activeColor: const Color(0xFF4F46E5),
            ),
          ),
          _buildStudentNameCell(student, flex: 3),
          _buildDataCell(student.admissionNo, flex: 2),
          _buildDataCell(student.currentClass, flex: 2, isUnassigned: true),
          _buildDataCell(student.gender, flex: 1),
          _buildDataCell(student.age.toString(), flex: 1),
          _buildClassDropdownCell(index, flex: 2),
          _buildActionCell(index, flex: 1),
        ],
      ),
    );
  }

  Widget _buildStudentNameCell(Student student, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _getAvatarColor(student.name),
            child: Text(
              student.name.split(' ').map((n) => n[0]).take(2).join(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            student.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(
    String text, {
    int flex = 1,
    bool isUnassigned = false,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isUnassigned ? Colors.grey[500] : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildClassDropdownCell(int index, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(margin: EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal:6, vertical: 0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedClasses[index],
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedClasses[index] = newValue;
                });
              }
            },
            items:
                assignableClasses.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            value == 'Select Class'
                                ? Colors.grey[500]
                                : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
            icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCell(int index, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: ElevatedButton(
        onPressed: () {
          // Handle assign action
          if (action == 'Assign') {
            assignedIndex = index;
            action = 'Assigned';
          } else {
            action = 'Assign';
          }
          setState(() {});
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              (action == 'Assigned' && assignedIndex==index) ? Colors.green : const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
        child: Text(
          ((action == 'Assigned' && assignedIndex == index)?'Assigned':'Assign'),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing 1 to 3 of $totalResults results',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        Row(
          children: [
            _buildPaginationButton('Previous', isEnabled: currentPage > 1),
            const SizedBox(width: 8),
            for (int i = 1; i <= totalPages; i++) _buildPageNumber(i),
            const SizedBox(width: 8),
            _buildPaginationButton('Next', isEnabled: currentPage < totalPages),
          ],
        ),
      ],
    );
  }

  Widget _buildPaginationButton(String text, {required bool isEnabled}) {
    return TextButton(
      onPressed:
          isEnabled
              ? () {
                setState(() {
                  if (text == 'Previous' && currentPage > 1) {
                    currentPage--;
                  } else if (text == 'Next' && currentPage < totalPages) {
                    currentPage++;
                  }
                });
              }
              : null,
      style: TextButton.styleFrom(
        foregroundColor: isEnabled ? Colors.grey[700] : Colors.grey[400],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildPageNumber(int pageNumber) {
    final isActive = pageNumber == currentPage;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentPage = pageNumber;
        });
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? const Color(0xFF4F46E5) : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            pageNumber.toString(),
            style: TextStyle(
              fontSize: 14,
              color: isActive ? Colors.white : Colors.grey[700],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue[600]!,
      Colors.green[600]!,
      Colors.purple[600]!,
      Colors.orange[600]!,
      Colors.red[600]!,
    ];
    return colors[name.hashCode % colors.length];
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Assignment',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Inter'),
      home: const AssignStudentsScreen(),
    );
  }
}

void main() {
  runApp(const MyApp());
}
