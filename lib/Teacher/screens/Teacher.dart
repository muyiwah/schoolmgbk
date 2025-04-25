import 'package:flutter/material.dart';
import 'package:schmgtsystem/Teacher/models/teacher_model.dart';

class AddParentScreen extends StatelessWidget {
  const AddParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Add Parent Screen',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

final List<Teacher> dummyTeachers = [
  Teacher(
    name: 'John Doe',
    email: 'john.doe@example.com',
    avatarUrl: 'https://via.placeholder.com/150',
    teacherId: 'TCH001',
    subjects: 'Math, Physics',
    className: 'Grade 10',
    phone: '+1234567890',
    address: '123 Main Street',
  ),
  Teacher(
    name: 'Jane Smith',
    email: 'jane.smith@example.com',
    avatarUrl: 'https://via.placeholder.com/150',
    teacherId: 'TCH002',
    subjects: 'English, History',
    className: 'Grade 9',
    phone: '+1987654321',
    address: '456 Oak Avenue',
  ),
  Teacher(
    name: 'Samuel Lee',
    email: 'samuel.lee@example.com',
    avatarUrl: 'https://via.placeholder.com/150',
    teacherId: 'TCH003',
    subjects: 'Chemistry',
    className: 'Grade 11',
    phone: '+1122334455',
    address: '789 Pine Road',
  ),
];

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  String _searchTerm = '';

  List<Teacher> get _filteredTeachers {
    return dummyTeachers.where((teacher) {
      final term = _searchTerm.toLowerCase();
      return teacher.name.toLowerCase().contains(term) ||
          teacher.email.toLowerCase().contains(term) ||
          teacher.subjects.toLowerCase().contains(term);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Teachers',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name, email or subject...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white10,
            ),
            onChanged: (value) {
              setState(() {
                _searchTerm = value;
              });
            },
          ),
          const SizedBox(height: 20),
          isMobile ? _buildCardList() : _buildDataTable(),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        columns: const [
          DataColumn(label: Text('Info')),
          DataColumn(label: Text('Teacher ID')),
          DataColumn(label: Text('Subjects')),
          DataColumn(label: Text('Class')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Address')),
          DataColumn(label: Text('Actions')),
        ],
        rows:
            _filteredTeachers.map((teacher) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(teacher.avatarUrl),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacher.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              teacher.email,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text(teacher.teacherId)),
                  DataCell(Text(teacher.subjects)),
                  DataCell(Text(teacher.className)),
                  DataCell(Text(teacher.phone)),
                  DataCell(Text(teacher.address)),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCardList() {
    return Column(
      children:
          _filteredTeachers.map((teacher) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(teacher.avatarUrl),
                      radius: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacher.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            teacher.email,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Text('ID: ${teacher.teacherId}'),
                          Text('Subjects: ${teacher.subjects}'),
                          Text('Class: ${teacher.className}'),
                          Text('Phone: ${teacher.phone}'),
                          Text('Address: ${teacher.address}'),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
