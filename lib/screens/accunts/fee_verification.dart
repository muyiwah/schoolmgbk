import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


class PaymentVerificationScreen extends StatefulWidget {
  @override
  _PaymentVerificationScreenState createState() =>
      _PaymentVerificationScreenState();
}

class _PaymentVerificationScreenState extends State<PaymentVerificationScreen> {
  String selectedClass = 'All Classes';
  String selectedStatus = 'All Status';
  List<bool> checkedItems = [false, false, false];
  int currentPage = 1;

  final List<Student> students = [
    Student(
      name: 'Jane Doe',
      id: 'ST123',
      grade: 'Grade 5',
      tuition: 50000,
      books: 15000,
      status: PaymentStatus.needVerification,
      hasReceipt: true,
    ),
    Student(
      name: 'John Smith',
      id: 'ST234',
      grade: 'Grade 6',
      tuition: 0,
      books: 0,
      status: PaymentStatus.verified,
      hasReceipt: true,
      allPaid: true,
    ),
    Student(
      name: 'Sarah Ali',
      id: 'ST345',
      grade: 'Grade 4',
      tuition: 0,
      books: 0,
      status: PaymentStatus.notPaid,
      hasReceipt: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildStatsCards(),
              _buildFilters(),
              _buildDataTable(),
              _buildPagination(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Verification – All Students',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage and verify student payment records',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.download, size: 18),
            label: Text('Export Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4B7BFF),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildStatCard(
            '1,247',
            'Total Students',
            Color(0xFF4B7BFF),
            Color(0xFFEFF6FF),
          ),
          SizedBox(width: 16),
          _buildStatCard(
            '892',
            'Verified',
            Color(0xFF10B981),
            Color(0xFFF0FDF4),
          ),
          SizedBox(width: 16),
          _buildStatCard(
            '234',
            'Need Verification',
            Color(0xFFFBBF24),
            Color(0xFFFEF9E7),
          ),
          SizedBox(width: 16),
          _buildStatCard(
            '121',
            'Not Paid',
            Color(0xFFEF4444),
            Color(0xFFFEF2F2),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    Color textColor,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          _buildDropdown('All Classes', Icons.arrow_drop_down),
          SizedBox(width: 12),
          _buildDropdown('All Status', Icons.arrow_drop_down),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by name or ID...',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          Spacer(),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.check, size: 18),
            label: Text('Bulk Verify'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF86EFAC),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.close, size: 18),
            label: Text('Bulk Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFCA5A5),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(text, style: TextStyle(fontSize: 14, color: Color(0xFF374151))),
          Icon(icon, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  SizedBox(width: 40),
                  Expanded(
                    flex: 2,
                    child: Text('Student', style: _headerStyle()),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('Class', style: _headerStyle()),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Payment Summary', style: _headerStyle()),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('Status', style: _headerStyle()),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('Receipt', style: _headerStyle()),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('Actions', style: _headerStyle()),
                  ),
                ],
              ),
            ),
            // Table Rows
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return _buildStudentRow(students[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentRow(Student student, int index) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB).withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: checkedItems[index],
            onChanged: (value) {
              setState(() {
                checkedItems[index] = value!;
              });
            },
            activeColor: Color(0xFF4B7BFF),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.grey[600]),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      student.id,
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              student.grade,
              style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
            ),
          ),
          Expanded(flex: 2, child: _buildPaymentSummary(student)),
          Expanded(flex: 1, child: _buildStatusBadge(student.status)),
          Expanded(
            flex: 1,
            child:
                student.hasReceipt
                    ? Icon(
                      Icons.attach_file,
                      color: Color(0xFF4B7BFF),
                      size: 20,
                    )
                    : Text('—', style: TextStyle(color: Color(0xFF9CA3AF))),
          ),
          Expanded(flex: 1, child: _buildActions(student.status)),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(Student student) {
    if (student.allPaid) {
      return Text(
        'All fees paid',
        style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
      );
    } else if (student.tuition == 0 && student.books == 0) {
      return Text(
        'None paid',
        style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
      );
    } else {
      return Text(
        'Pending',
        style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
      );
    }
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color bgColor;
    Color textColor;
    String text;
    IconData? icon;

    switch (status) {
      case PaymentStatus.verified:
        bgColor = Color(0xFFF0FDF4);
        textColor = Color(0xFF10B981);
        text = 'Verified';
        icon = Icons.check_circle;
        break;
      case PaymentStatus.needVerification:
        bgColor = Color(0xFFFEF9E7);
        textColor = Color(0xFFF59E0B);
        text = 'Need Verification';
        icon = Icons.warning;
        break;
      case PaymentStatus.notPaid:
        bgColor = Color(0xFFFEF2F2);
        textColor = Color(0xFFEF4444);
        text = 'Not Paid';
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(PaymentStatus status) {
    if (status == PaymentStatus.needVerification) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFF10B981),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.check, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Verify',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.close, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Reject',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return Text('—', style: TextStyle(color: Color(0xFF9CA3AF)));
  }

  Widget _buildPagination() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing 1 to 10 of 1,247 results',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          Row(
            children: [
              TextButton(
                onPressed: currentPage > 1 ? () {} : null,
                child: Text('Previous'),
                style: TextButton.styleFrom(foregroundColor: Color(0xFF6B7280)),
              ),
              _buildPageButton(1, true),
              _buildPageButton(2, false),
              _buildPageButton(3, false),
              TextButton(
                onPressed: () {},
                child: Text('Next'),
                style: TextButton.styleFrom(foregroundColor: Color(0xFF374151)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(int page, bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () {
          setState(() {
            currentPage = page;
          });
        },
        style: TextButton.styleFrom(
          backgroundColor: isActive ? Color(0xFF4B7BFF) : Colors.transparent,
          foregroundColor: isActive ? Colors.white : Color(0xFF6B7280),
          minimumSize: Size(40, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(page.toString()),
      ),
    );
  }

  TextStyle _headerStyle() {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF6B7280),
      letterSpacing: 0.5,
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

enum PaymentStatus { verified, needVerification, notPaid }

class Student {
  final String name;
  final String id;
  final String grade;
  final int tuition;
  final int books;
  final PaymentStatus status;
  final bool hasReceipt;
  final bool allPaid;

  Student({
    required this.name,
    required this.id,
    required this.grade,
    required this.tuition,
    required this.books,
    required this.status,
    required this.hasReceipt,
    this.allPaid = false,
  });
}
