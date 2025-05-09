import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';


class Admin1 extends StatelessWidget {
  const Admin1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AdminDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Student> students = [];
  String selectedClass = 'All';
  List<String> classes = ['All', 'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5'];

  @override
  void initState() {
    super.initState();
    // Mock data initialization
    students = [
      Student(
        id: '001',
        name: 'John Doe',
        className: 'Class 1',
        feeStatus: FeeStatus.paidFull,
        balance: 0,
        totalFees: 50000,
        parentName: 'Jane Doe',
        parentPhone: '0712345678',
        admissionDate: DateTime(2023, 1, 10),
      ),
      Student(
        id: '002',
        name: 'Mary Smith',
        className: 'Class 2',
        feeStatus: FeeStatus.paidPart,
        balance: 25000,
        totalFees: 50000,
        parentName: 'Robert Smith',
        parentPhone: '0723456789',
        admissionDate: DateTime(2023, 1, 15),
      ),
      Student(
        id: '003',
        name: 'David Johnson',
        className: 'Class 3',
        feeStatus: FeeStatus.owing,
        balance: 50000,
        totalFees: 50000,
        parentName: 'Sarah Johnson',
        parentPhone: '0734567890',
        admissionDate: DateTime(2023, 1, 20),
      ),
      // Add more students...
    ];
    
    // Add more mock data
    for (int i = 4; i < 30; i++) {
      students.add(Student(
        id: '00$i',
        name: 'Student $i',
        className: 'Class ${i % 5 + 1}',
        feeStatus: FeeStatus.values[i % 3],
        balance: [0, 25000, 50000][i % 3],
        totalFees: 50000,
        parentName: 'Parent $i',
        parentPhone: '07${100000000 + i}',
        admissionDate: DateTime(2023, 1, 1 + i),
      ));
    }
  }

  List<Student> get filteredStudents {
    if (selectedClass == 'All') return students;
    return students.where((student) => student.className == selectedClass).toList();
  }

  Map<String, int> get feeStatistics {
    final filtered = filteredStudents;
    return {
      'Paid Full': filtered.where((s) => s.feeStatus == FeeStatus.paidFull).length,
      'Paid Part': filtered.where((s) => s.feeStatus == FeeStatus.paidPart).length,
      'Owing': filtered.where((s) => s.feeStatus == FeeStatus.owing).length,
    };
  }
  List<ChartData> get chartData {
    return [
      ChartData('Paid Full', feeStatistics['Paid Full']!, Colors.green),
      ChartData('Paid Part', feeStatistics['Paid Part']!, Colors.orange),
      ChartData('Owing', feeStatistics['Owing']!, Colors.red),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Management - Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: StudentSearchDelegate(students: students),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Filter by Class:'),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedClass,
                  items: classes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedClass = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Statistics cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildStatCard('Total Students', filteredStudents.length, Colors.blue),
                const SizedBox(width: 8),
                _buildStatCard('Paid Full', feeStatistics['Paid Full']!, Colors.green),
                const SizedBox(width: 8),
                _buildStatCard('Paid Part', feeStatistics['Paid Part']!, Colors.orange),
                const SizedBox(width: 8),
                _buildStatCard('Owing', feeStatistics['Owing']!, Colors.red),
              ],
            ),
          ),
          
         // Column Chart
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              title: ChartTitle(text: 'Fee Payment Status'),
              legend: Legend(isVisible: true),
              series: <ColumnSeries<ChartData, String>>[
                ColumnSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  color: Colors.blue,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ),
          // Pie chart
          SizedBox(
            height: 200,
            child: SfCircularChart(
              title: ChartTitle(text: 'Fee Payment Distribution'),
              legend: Legend(isVisible: true),
              series: <CircularSeries>[
                PieSeries<ChartData, String>(
                  dataSource: [
                    ChartData('Paid Full', feeStatistics['Paid Full']!, Colors.green),
                    ChartData('Paid Part', feeStatistics['Paid Part']!, Colors.orange),
                    ChartData('Owing', feeStatistics['Owing']!, Colors.red),
                  ],
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  pointColorMapper: (ChartData data, _) => data.color,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ),
          
          // Students list
          Expanded(
            child: ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return _buildStudentCard(student);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              Text(
                value.toString(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    Color statusColor;
    switch (student.feeStatus) {
      case FeeStatus.paidFull:
        statusColor = Colors.green;
        break;
      case FeeStatus.paidPart:
        statusColor = Colors.orange;
        break;
      case FeeStatus.owing:
        default:
        statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(student.name.substring(0, 1))),
        title: Text(student.name),
        subtitle: Text('${student.className} • ${student.feeStatus.name}'),
        trailing: Chip(
          backgroundColor: statusColor.withOpacity(0.2),
          label: Text(
            '${NumberFormat.currency(symbol: '').format(student.totalFees - student.balance)}/${NumberFormat.currency(symbol: '').format(student.totalFees)}',
            style: TextStyle(color: statusColor),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDetailsScreen(student: student),
            ),
          );
        },
      ),
    );
  }
}

class StudentDetailsScreen extends StatelessWidget {
  final Student student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(student.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  student.name.substring(0, 1),
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Student ID', student.id),
            _buildDetailRow('Class', student.className),
            _buildDetailRow('Admission Date', DateFormat('yyyy-MM-dd').format(student.admissionDate)),
            _buildDetailRow('Parent Name', student.parentName),
            _buildDetailRow('Parent Phone', student.parentPhone),
            const SizedBox(height: 20),
            Card(
              color: _getStatusColor(student.feeStatus).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow('Fee Status', student.feeStatus.name),
                    _buildDetailRow('Total Fees', NumberFormat.currency(symbol: 'KES ').format(student.totalFees)),
                    _buildDetailRow('Amount Paid', NumberFormat.currency(symbol: 'KES ').format(student.totalFees - student.balance)),
                    _buildDetailRow('Balance', NumberFormat.currency(symbol: 'KES ').format(student.balance)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // Implement fee payment functionality
                },
                child: const Text('Record Payment', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Color _getStatusColor(FeeStatus status) {
    switch (status) {
      case FeeStatus.paidFull:
        return Colors.green;
      case FeeStatus.paidPart:
        return Colors.orange;
      case FeeStatus.owing:
        return Colors.red;
    }
  }
}

class StudentSearchDelegate extends SearchDelegate {
  final List<Student> students;

  StudentSearchDelegate({required this.students});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = students.where((student) =>
        student.name.toLowerCase().contains(query.toLowerCase()) ||
        student.id.toLowerCase().contains(query.toLowerCase()) ||
        student.className.toLowerCase().contains(query.toLowerCase()));
    
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final student = results.elementAt(index);
        return ListTile(
          title: Text(student.name),
          subtitle: Text('${student.className} • ${student.id}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentDetailsScreen(student: student),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = students.where((student) =>
        student.name.toLowerCase().contains(query.toLowerCase()) ||
        student.id.toLowerCase().contains(query.toLowerCase()) ||
        student.className.toLowerCase().contains(query.toLowerCase()));
    
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final student = suggestions.elementAt(index);
        return ListTile(
          title: Text(student.name),
          subtitle: Text('${student.className} • ${student.id}'),
          onTap: () {
            query = student.name;
            showResults(context);
          },
        );
      },
    );
  }
}

enum FeeStatus { paidFull, paidPart, owing }

class Student {
  final String id;
  final String name;
  final String className;
  final FeeStatus feeStatus;
  final int balance;
  final int totalFees;
  final String parentName;
  final String parentPhone;
  final DateTime admissionDate;

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.feeStatus,
    required this.balance,
    required this.totalFees,
    required this.parentName,
    required this.parentPhone,
    required this.admissionDate,
  });
}

class ChartData {
  final String x;
  final int y;
  final Color color;

  ChartData(this.x, this.y, this.color);
}