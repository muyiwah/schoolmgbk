import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';



class Admin12 extends StatelessWidget {
  const Admin12({super.key});

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
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const DashboardPage(),
    const PaymentStatusPage(),
    const StudentsTablePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Management System'),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payment Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: 'Students Table',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Dashboard Content'),
    );
  }
}

class PaymentStatusPage extends StatefulWidget {
  const PaymentStatusPage({super.key});

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  List<Student> students = [];
  final List<String> notificationTypes = ['WhatsApp', 'Push Notification'];
  String selectedNotificationType = 'WhatsApp';

  @override
  void initState() {
    super.initState();
    // Initialize with mock data
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
      Student(
        id: '004',
        name: 'John Doe2',
        className: 'Class 1',
        feeStatus: FeeStatus.paidFull,
        balance: 0,
        totalFees: 50000,
        parentName: 'Jane Doe2',
        parentPhone: '0712345678',
        admissionDate: DateTime(2023, 1, 10),
      ),
      Student(
        id: '004',
        name: 'Mary Smith4',
        className: 'Class 2',
        feeStatus: FeeStatus.paidPart,
        balance: 25000,
        totalFees: 50000,
        parentName: 'Robert Smith',
        parentPhone: '0723456789',
        admissionDate: DateTime(2023, 1, 15),
      ),
      Student(
        id: '005',
        name: 'David Johnson5',
        className: 'Class 3',
        feeStatus: FeeStatus.owing,
        balance: 50000,
        totalFees: 50000,
        parentName: 'Sarah Johnson',
        parentPhone: '0734567890',
        admissionDate: DateTime(2023, 1, 20),
      ),
      Student(
        id: '006',
        name: 'John Doe6',
        className: 'Class 1',
        feeStatus: FeeStatus.paidFull,
        balance: 0,
        totalFees: 50000,
        parentName: 'Jane Doe',
        parentPhone: '0712345678',
        admissionDate: DateTime(2023, 1, 10),
      ),
      Student(
        id: '007',
        name: 'Mary Smith7',
        className: 'Class 2',
        feeStatus: FeeStatus.paidPart,
        balance: 25000,
        totalFees: 50000,
        parentName: 'Robert Smith',
        parentPhone: '0723456789',
        admissionDate: DateTime(2023, 1, 15),
      ),
      Student(
        id: '008',
        name: 'David Johnson8',
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
  }

  Future<void> _sendReminders(FeeStatus status) async {
    final filteredStudents = students.where((s) => s.feeStatus == status).toList();
    
    if (selectedNotificationType == 'WhatsApp') {
      for (final student in filteredStudents) {
        final message = status == FeeStatus.paidPart
            ? 'Dear ${student.parentName}, this is a reminder that ${student.name} has a partial payment of ${student.totalFees - student.balance} out of ${student.totalFees}. The remaining balance is ${student.balance}. Please complete the payment soon.'
            : 'Dear ${student.parentName}, this is a reminder that ${student.name} has not made any payment for the current term. The total fee is ${student.totalFees}. Please make the payment as soon as possible.';
        
        final url = 'https://wa.me/${student.parentPhone}?text=${Uri.encodeComponent(message)}';
        
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch WhatsApp for ${student.name}')),
          );
        }
        await Future.delayed(const Duration(seconds: 1)); // Delay to avoid rate limiting
      }
    } else {
      // In a real app, you would integrate with your push notification service here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sending push notifications to ${filteredStudents.length} parents')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final paidFullStudents = students.where((s) => s.feeStatus == FeeStatus.paidFull).toList();
    final paidPartStudents = students.where((s) => s.feeStatus == FeeStatus.paidPart).toList();
    final owingStudents = students.where((s) => s.feeStatus == FeeStatus.owing).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification type selector
          Row(
            children: [
              const Text('Notification Type:'),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedNotificationType,
                items: notificationTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedNotificationType = newValue!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Paid in Full section
          _buildPaymentStatusSection(
            context,
            'Paid in Full (${paidFullStudents.length})',
            paidFullStudents,
            Colors.green,
            null, // No action for paid in full
          ),
          
          // Paid Partially section
          _buildPaymentStatusSection(
            context,
            'Paid Partially (${paidPartStudents.length})',
            paidPartStudents,
            Colors.orange,
            () => _sendReminders(FeeStatus.paidPart),
          ),
          
          // Owing section
          _buildPaymentStatusSection(
            context,
            'Owing (${owingStudents.length})',
            owingStudents,
            Colors.red,
            () => _sendReminders(FeeStatus.owing),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusSection(
    BuildContext context,
    String title,
    List<Student> students,
    Color color,
    VoidCallback? onRemind,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (onRemind != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color.withOpacity(0.2),
                      foregroundColor: color,
                    ),
                    onPressed: onRemind,
                    child: const Text('Send Reminders'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...students.map((student) => ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Text(student.name.substring(0, 1))),
              title: Text(student.name),
              subtitle: Text('${student.className} • ${student.parentPhone}'),
              trailing: Text(
                '${NumberFormat.currency(symbol: '').format(student.totalFees - student.balance)}/${NumberFormat.currency(symbol: '').format(student.totalFees)}',
                style: TextStyle(color: color),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDetailsScreen(student: student),
                  ),
                );
              },
            )).toList(),
          ],
        ),
      ),
    );
  }
}

class StudentsTablePage extends StatelessWidget {
  const StudentsTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, you would get this data from your state management
    final List<Student> students = [
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
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Class')),
            DataColumn(label: Text('Status'), numeric: true),
            DataColumn(label: Text('Paid'), numeric: true),
            DataColumn(label: Text('Balance'), numeric: true),
            DataColumn(label: Text('Total'), numeric: true),
            DataColumn(label: Text('Parent Phone')),
          ],
          rows: students.map((student) {
            final statusColor = student.feeStatus == FeeStatus.paidFull
                ? Colors.green
                : student.feeStatus == FeeStatus.paidPart
                    ? Colors.orange
                    : Colors.red;
            
            return DataRow(
              cells: [
                DataCell(Text(student.id)),
                DataCell(Text(student.name)),
                DataCell(Text(student.className)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      student.feeStatus.name.toUpperCase(),
                      style: TextStyle(color: statusColor),
                    ),
                  ),
                ),
                DataCell(Text(NumberFormat.currency(symbol: '').format(student.totalFees - student.balance))),
                DataCell(Text(NumberFormat.currency(symbol: '').format(student.balance))),
                DataCell(Text(NumberFormat.currency(symbol: '').format(student.totalFees))),
                DataCell(Text(student.parentPhone)),
              ],
              onSelectChanged: (selected) {
                if (selected == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentDetailsScreen(student: student),
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
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