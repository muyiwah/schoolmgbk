import 'package:flutter/material.dart';





class PaymentRecord {
  final String parentName;
  final String studentName;
  final String className;
  final String amountPaid;
  final String balance;
  final PaymentStatus status;
  final String? paymentDate;
  final String avatarUrl;

  PaymentRecord({
    required this.parentName,
    required this.studentName,
    required this.className,
    required this.amountPaid,
    required this.balance,
    required this.status,
    this.paymentDate,
    required this.avatarUrl,
  });
}

enum PaymentStatus { paid, partial, notPaid }

class SchoolFeesDashboard extends StatefulWidget {
  const SchoolFeesDashboard({super.key});

  @override
  State<SchoolFeesDashboard> createState() => _SchoolFeesDashboardState();
}

class _SchoolFeesDashboardState extends State<SchoolFeesDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All Status';
  String _selectedClass = 'All Classes';
  bool _selectAll = false;
  List<bool> _selectedRecords = List.generate(3, (index) => false);

  final List<PaymentRecord> _paymentRecords = [
    PaymentRecord(
      parentName: 'Mrs. Adeola',
      studentName: 'Tobi A.',
      className: 'JSS 2',
      amountPaid: '₦150,000',
      balance: '₦0',
      status: PaymentStatus.paid,
      paymentDate: '5 Apr 2025',
      avatarUrl: 'assets/images/avatar1.jpg',
    ),
    PaymentRecord(
      parentName: 'Mr. Okeke',
      studentName: 'Ada O.',
      className: 'SS 1',
      amountPaid: '₦100,000',
      balance: '₦50,000',
      status: PaymentStatus.partial,
      avatarUrl: 'assets/images/avatar2.jpg',
    ),
    PaymentRecord(
      parentName: 'Mrs. Musa',
      studentName: 'Yusuf M.',
      className: 'Pry 4',
      amountPaid: '₦0',
      balance: '₦120,000',
      status: PaymentStatus.notPaid,
      avatarUrl: 'assets/images/avatar3.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStatsCards(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 24),
              _buildFilters(),
              const SizedBox(height: 24),
              Expanded(child: _buildPaymentRecords()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.school, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'School Fees Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              'Admin Panel',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        const Spacer(),
        Stack(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Paid',
            '₦4,250,000',
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Owing',
            '₦1,750,000',
            Colors.red,
            Icons.error,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Paid Rate',
            '71%',
            Colors.blue,
            Icons.trending_up,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Current Term',
            '3rd Term 2024/25',
            Colors.purple,
            Icons.calendar_today,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Reminders Sent',
            '35 this week',
            Colors.orange,
            Icons.send,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
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
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.send, size: 18),
          label: const Text('Send Reminders to All Owing'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Export All'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by parent or student name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildDropdown(_selectedStatus, [
          'All Status',
          'Paid',
          'Partial',
          'Not Paid',
        ]),
        const SizedBox(width: 16),
        _buildDropdown(_selectedClass, [
          'All Classes',
          'JSS 1',
          'JSS 2',
          'JSS 3',
          'SS 1',
          'SS 2',
          'SS 3',
          'Pry 1',
          'Pry 2',
          'Pry 3',
          'Pry 4',
          'Pry 5',
          'Pry 6',
        ]),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.filter_list),
          label: const Text('More Filters'),
        ),
      ],
    );
  }

  Widget _buildDropdown(String value, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        onChanged: (String? newValue) {
          setState(() {
            if (items.contains('All Status')) {
              _selectedStatus = newValue!;
            } else {
              _selectedClass = newValue!;
            }
          });
        },
        items:
            items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
      ),
    );
  }

  Widget _buildPaymentRecords() {
    return Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Payment Records',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectAll = !_selectAll;
                      _selectedRecords = List.generate(
                        3,
                        (index) => _selectAll,
                      );
                    });
                  },
                  child: const Text('Select All'),
                ),
              ],
            ),
          ),
          _buildTableHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: _paymentRecords.length,
              itemBuilder: (context, index) {
                return _buildTableRow(_paymentRecords[index], index);
              },
            ),
          ),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(width: 40),
          Expanded(
            flex: 2,
            child: Text(
              'PARENT NAME',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'STUDENT(S)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'CLASS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'AMOUNT PAID',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'BALANCE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'STATUS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'PAYMENT DATE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              'ACTIONS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(PaymentRecord record, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _selectedRecords[index],
            onChanged: (bool? value) {
              setState(() {
                _selectedRecords[index] = value!;
              });
            },
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    record.parentName[0],
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  record.parentName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Expanded(child: Text(record.studentName)),
          Expanded(child: Text(record.className)),
          Expanded(child: Text(record.amountPaid)),
          Expanded(
            child: Text(
              record.balance,
              style: TextStyle(
                color: record.balance == '₦0' ? Colors.black : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(child: _buildStatusBadge(record.status)),
          Expanded(child: Text(record.paymentDate ?? '—')),
          SizedBox(
            width: 80,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  color: Colors.green,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.email_outlined, size: 18),
                  color: Colors.blue,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.message_outlined, size: 18),
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case PaymentStatus.paid:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        text = 'Paid';
        icon = Icons.check;
        break;
      case PaymentStatus.partial:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        text = 'Partial';
        icon = Icons.warning;
        break;
      case PaymentStatus.notPaid:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        text = 'Not Paid';
        icon = Icons.close;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text(
            'Showing 1-3 of 150 records',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
          const Spacer(),
          Row(
            children: [
              TextButton(onPressed: () {}, child: const Text('Previous')),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('1', style: TextStyle(color: Colors.white)),
              ),
              TextButton(onPressed: () {}, child: const Text('2')),
              TextButton(onPressed: () {}, child: const Text('3')),
              TextButton(onPressed: () {}, child: const Text('Next')),
            ],
          ),
        ],
      ),
    );
  }
}
