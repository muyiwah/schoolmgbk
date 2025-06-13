import 'package:flutter/material.dart';
import 'package:schmgtsystem/constants/appcolor.dart';

class DashboardDetails extends StatefulWidget {
  final Function navigateBack;
  const DashboardDetails({super.key, required this.navigateBack});

  @override
  _DashboardDetailsState createState() => _DashboardDetailsState();
}

class _DashboardDetailsState extends State<DashboardDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedClass = 'All Classes';
  String selectedDepartment = 'All Departments';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(height: double.infinity,
        child: ListView(
          children: [
            _buildHeader(),
            _buildFilters(),
            _buildMetricsRow(),
            _buildTabBar(),
            SizedBox(
              height: 500,
              child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [AppColors.secondary, Color(0xFF8B7CF6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
            
              Text(
                'School Performance Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Detailed insights into student, staff, academic, and financial data',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildHeaderButton(
                'Back to Home',
                Icons.home,
                Colors.transparent,
                Colors.white,
                hasBorder: true,
              ),
              SizedBox(width: 16),

              _buildHeaderButton(
                'Export Report',
                Icons.download,
                Colors.white,
                Color(0xFF6C5CE7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(
    String text,
    IconData icon,
    Color backgroundColor,
    Color textColor, {
    bool hasBorder = false,
  }) {
    return ElevatedButton.icon(
      onPressed: () {
                  widget.navigateBack();

      },
      icon: Icon(icon, color: textColor, size: 18),
      label: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side:
              hasBorder
                  ? BorderSide(color: Colors.white, width: 1.5)
                  : BorderSide.none,
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          _buildDropdown('All Classes', [
            'All Classes',
            'Grade 1',
            'Grade 2',
            'Grade 3',
          ]),
          SizedBox(width: 16),
          _buildDropdown('All Departments', [
            'All Departments',
            'Mathematics',
            'Science',
            'English',
          ]),
          SizedBox(width: 16),
          _buildDatePicker(),
          Spacer(),
          _buildActionButton('Refresh', Icons.refresh, Color(0xFF6C5CE7)),
          SizedBox(width: 12),
          _buildActionButton('Print', Icons.print, Colors.grey[600]!),
        ],
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item,style: TextStyle(fontSize: 14),));
              }).toList(),
          onChanged: (String? newValue) {},
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Text('mm/dd/yyyy', style: TextStyle(color: Colors.grey[600])),
          SizedBox(width: 8),
          Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.white, size: 16),
      label: Text(text, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              'Total Students',
              '1,247',
              '+5.2%',
              Icons.people,
              Colors.blue,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildMetricCard(
              'Total Teachers',
              '67',
              'Active',
              Icons.school,
              Colors.purple,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildMetricCard(
              'Support Staff',
              '23',
              'Active',
              Icons.support_agent,
              Colors.teal,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildMetricCard(
              'Term Income',
              '\$487K',
              '+12.3%',
              Icons.attach_money,
              Colors.green,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildMetricCard(
              'Attendance Rate',
              '94.2%',
              '+2.1%',
              Icons.check_circle,
              Colors.blue,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildMetricCard(
              'Avg Performance',
              '87.5%',
              '+3.2%',
              Icons.trending_up,
              Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            change,
            style: TextStyle(
              color: change.startsWith('+') ? Colors.green : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        labelColor: Color(0xFF6C5CE7),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Color(0xFF6C5CE7),
        indicatorWeight: 3,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people, size: 18),
                SizedBox(width: 8),
                Text('Students'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school, size: 18),
                SizedBox(width: 8),
                Text('Teachers & Staff'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_balance_wallet, size: 18),
                SizedBox(width: 8),
                Text('Accounts'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_available, size: 18),
                SizedBox(width: 8),
                Text('Attendance'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings, size: 18),
                SizedBox(width: 8),
                Text('Operations'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildStudentsTab(),
          _buildPlaceholderTab('Teachers & Staff'),
          _buildPlaceholderTab('Accounts'),
          _buildPlaceholderTab('Attendance'),
          _buildPlaceholderTab('Operations'),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildEnrollmentCard(),
              SizedBox(height: 16),
              _buildNewAdmissionsCard(),
            ],
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildLowAttendanceCard(),
              SizedBox(height: 16),
              _buildOutstandingFeesCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnrollmentCard() {
    return Container(
      padding: EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enrollment by Class',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          _buildEnrollmentRow('Grade 1', 142),
          _buildEnrollmentRow('Grade 2', 138),
          _buildEnrollmentRow('Grade 3', 145),
        ],
      ),
    );
  }

  Widget _buildEnrollmentRow(String grade, int students) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(grade, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(
            '$students students',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewAdmissionsCard() {
    return Container(
      padding: EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Admissions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Text(
            '67',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C5CE7),
            ),
          ),
          Text(
            'This term',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLowAttendanceCard() {
    return Container(
      padding: EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Low Attendance Students',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          _buildAttendanceRow('John Smith', '67%'),
          _buildAttendanceRow('Sarah Johnson', '72%'),
          _buildAttendanceRow('Sarah Johnson', '72%'),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(String name, String percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutstandingFeesCard() {
    return Container(
      padding: EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outstanding Fees',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Text(
            '\$23,450',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          Text(
            '42 students',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            '$tabName Content',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This section is under development',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
