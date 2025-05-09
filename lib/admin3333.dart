import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';


class Admin3 extends StatelessWidget {
  const Admin3({super.key});

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
  final List<Student> allStudents = [];
  List<Student> filteredStudents = [];
  final TextEditingController searchController = TextEditingController();

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    // Initialize with mock data
    allStudents.addAll([
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
    ]);

    // Add more mock data
    for (int i = 4; i < 30; i++) {
      allStudents.add(Student(
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

    filteredStudents = List.from(allStudents);
    
    // Initialize pages with search functionality
    _pages.addAll([
      DashboardPage(students: filteredStudents, searchController: searchController, onSearch: _filterStudents),
      PaymentStatusPage(students: filteredStudents, searchController: searchController, onSearch: _filterStudents, onUpdatePayment: _updatePaymentStatus),
      StudentsTablePage(students: filteredStudents, searchController: searchController, onSearch: _filterStudents, onUpdatePayment: _updatePaymentStatus),
    ]);
  }

  void _filterStudents(String query) {
    setState(() {
      filteredStudents = allStudents.where((student) {
        final nameLower = student.name.toLowerCase();
        final idLower = student.id.toLowerCase();
        final classLower = student.className.toLowerCase();
        final parentLower = student.parentName.toLowerCase();
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower) ||
            idLower.contains(searchLower) ||
            classLower.contains(searchLower) ||
            parentLower.contains(searchLower);
      }).toList();
    });
  }

  void _updatePaymentStatus(Student student, int amountPaid) {
    setState(() {
      final index = allStudents.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        final newBalance = student.totalFees - amountPaid;
        final newStatus = newBalance <= 0
            ? FeeStatus.paidFull
            : amountPaid > 0
                ? FeeStatus.paidPart
                : FeeStatus.owing;

        allStudents[index] = student.copyWith(
          balance: newBalance.clamp(0, student.totalFees),
          feeStatus: newStatus,
        );

        // Update filtered list
        _filterStudents(searchController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Management System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Search Students'),
                  content: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by name, ID, class...',
                    ),
                    onChanged: _filterStudents,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        searchController.clear();
                        _filterStudents('');
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
  final List<Student> students;
  final TextEditingController searchController;
  final Function(String) onSearch;

  const DashboardPage({
    super.key,
    required this.students,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final paidFull = students.where((s) => s.feeStatus == FeeStatus.paidFull).length;
    final paidPart = students.where((s) => s.feeStatus == FeeStatus.paidPart).length;
    final owing = students.where((s) => s.feeStatus == FeeStatus.owing).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Statistics cards
          Row(
            children: [
              _buildStatCard('Total Students', students.length, Colors.blue),
              const SizedBox(width: 8),
              _buildStatCard('Paid Full', paidFull, Colors.green),
              const SizedBox(width: 8),
              _buildStatCard('Paid Part', paidPart, Colors.orange),
              const SizedBox(width: 8),
              _buildStatCard('Owing', owing, Colors.red),
            ],
          ),
          const SizedBox(height: 20),
          
          // Charts
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              title: const ChartTitle(text: 'Fee Payment Status'),
              legend: const Legend(isVisible: true),
              series: <ColumnSeries<ChartData, String>>[
                ColumnSeries<ChartData, String>(
                  dataSource: [
                    ChartData('Paid Full', paidFull, Colors.green),
                    ChartData('Paid Part', paidPart, Colors.orange),
                    ChartData('Owing', owing, Colors.red),
                  ],
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  color: Colors.blue,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ),
          
          // Recent students
          const SizedBox(height: 20),
          const Text(
            'Recent Students',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...students.take(5).map((student) => _buildStudentCard(student,context)).toList(),
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

  Widget _buildStudentCard(Student student,context) {
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
      margin: const EdgeInsets.only(bottom: 8),
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
              builder: (context) => StudentDetailsScreen(
                student: student,
                onUpdatePayment: (amount) {
                  // This would be handled by the parent widget
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class PaymentStatusPage extends StatefulWidget {
  final List<Student> students;
  final TextEditingController searchController;
  final Function(String) onSearch;
  final Function(Student, int) onUpdatePayment;

  const PaymentStatusPage({
    super.key,
    required this.students,
    required this.searchController,
    required this.onSearch,
    required this.onUpdatePayment,
  });

  @override
  State<PaymentStatusPage> createState() => _PaymentStatusPageState();
}

class _PaymentStatusPageState extends State<PaymentStatusPage> {
  final List<String> notificationTypes = ['WhatsApp', 'Push Notification'];
  String selectedNotificationType = 'WhatsApp';

  Future<void> _sendReminders(FeeStatus status) async {
    final filteredStudents = widget.students.where((s) => s.feeStatus == status).toList();
    
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

  void _showUpdatePaymentDialog(Student student) {
    final amountController = TextEditingController(
      text: (student.totalFees - student.balance).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Payment for ${student.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount Paid',
                prefixText: 'KES ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Text(
              'Total Fees: KES ${student.totalFees}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Current Balance: KES ${student.balance}',
              style: TextStyle(
                color: student.balance > 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amountPaid = int.tryParse(amountController.text) ?? 0;
              widget.onUpdatePayment(student, amountPaid);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paidFullStudents = widget.students.where((s) => s.feeStatus == FeeStatus.paidFull).toList();
    final paidPartStudents = widget.students.where((s) => s.feeStatus == FeeStatus.paidPart).toList();
    final owingStudents = widget.students.where((s) => s.feeStatus == FeeStatus.owing).toList();

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
                child: Text(student.name.substring(0, 1)),
              ),
              title: Text(student.name),
              subtitle: Text('${student.className} • ${student.parentPhone}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${NumberFormat.currency(symbol: '').format(student.totalFees - student.balance)}/${NumberFormat.currency(symbol: '').format(student.totalFees)}',
                    style: TextStyle(color: color),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showUpdatePaymentDialog(student),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentDetailsScreen(
                      student: student,
                      onUpdatePayment: (amount) {
                        widget.onUpdatePayment(student, amount);
                      },
                    ),
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
  final List<Student> students;
  final TextEditingController searchController;
  final Function(String) onSearch;
  final Function(Student, int) onUpdatePayment;

  const StudentsTablePage({
    super.key,
    required this.students,
    required this.searchController,
    required this.onSearch,
    required this.onUpdatePayment,
  });

  void _showUpdatePaymentDialog(BuildContext context, Student student) {
    final amountController = TextEditingController(
      text: (student.totalFees - student.balance).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Payment for ${student.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount Paid',
                prefixText: 'KES ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Text(
              'Total Fees: KES ${student.totalFees}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Current Balance: KES ${student.balance}',
              style: TextStyle(
                color: student.balance > 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amountPaid = int.tryParse(amountController.text) ?? 0;
              onUpdatePayment(student, amountPaid);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            DataColumn(label: Text('Actions')),
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
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showUpdatePaymentDialog(context, student),
                  ),
                ),
              ],
              onSelectChanged: (selected) {
                if (selected == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentDetailsScreen(
                        student: student,
                        onUpdatePayment: (amount) {
                          onUpdatePayment(student, amount);
                        },
                      ),
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
  final Function(int) onUpdatePayment;

  const StudentDetailsScreen({
    super.key,
    required this.student,
    required this.onUpdatePayment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(student.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showUpdatePaymentDialog(context);
            },
          ),
        ],
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
                  _showUpdatePaymentDialog(context);
                },
                child: const Text('Record Payment', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdatePaymentDialog(BuildContext context) {
    final amountController = TextEditingController(
      text: (student.totalFees - student.balance).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Payment for ${student.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount Paid',
                prefixText: 'KES ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Text(
              'Total Fees: KES ${student.totalFees}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Current Balance: KES ${student.balance}',
              style: TextStyle(
                color: student.balance > 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amountPaid = int.tryParse(amountController.text) ?? 0;
              onUpdatePayment(amountPaid);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment recorded successfully')),
              );
            },
            child: const Text('Record'),
          ),
        ],
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

  Student copyWith({
    String? id,
    String? name,
    String? className,
    FeeStatus? feeStatus,
    int? balance,
    int? totalFees,
    String? parentName,
    String? parentPhone,
    DateTime? admissionDate,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      className: className ?? this.className,
      feeStatus: feeStatus ?? this.feeStatus,
      balance: balance ?? this.balance,
      totalFees: totalFees ?? this.totalFees,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      admissionDate: admissionDate ?? this.admissionDate,
    );
  }
}

class ChartData {
  final String x;
  final int y;
  final Color color;

  ChartData(this.x, this.y, this.color);
}