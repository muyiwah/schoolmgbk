import 'package:flutter/material.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/widgets/piechart.dart';
import 'package:schmgtsystem/widgets/screen_header.dart';

class SingleStudent extends StatefulWidget {
  const SingleStudent({super.key});

  @override
  State<SingleStudent> createState() => _SingleStudentState();
}

class _SingleStudentState extends State<SingleStudent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildStudentHeader(),
            const SizedBox(height: 20),

            // Main Content Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column - Main Metrics
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      // Quick Stats Row
                      _buildQuickStatsRow(),
                      const SizedBox(height: 20),

                      // Academic Performance Section
                      _buildAcademicPerformanceSection(),
                      const SizedBox(height: 20),

                      // Assignments & Assessments
                      _buildAssignmentsSection(),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // Right Column - Attendance & Payment
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildAttendanceCard(),
                      const SizedBox(height: 20),
                      _buildPaymentCard(),
                      const SizedBox(height: 20),
                      _buildRecentActivitiesCard(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Modal Functions
  void _showExaminationDetailsModal(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Examination Records',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Term Selector
                Row(
                  children: [
                    _buildTermTab('First Term', true),
                    _buildTermTab('Second Term', false),
                    _buildTermTab('Third Term', false),
                  ],
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Summary Stats
                        Row(
                          children: [
                            Expanded(
                              child: _buildExamStatCard(
                                'Total Average',
                                '85.6%',
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildExamStatCard(
                                'Position',
                                '3rd',
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildExamStatCard(
                                'Grade',
                                'A-',
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Detailed Results Table
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Subject',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'CA (40)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Exam (60)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Total (100)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Grade',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...[
                                'Mathematics',
                                'English Language',
                                'Physics',
                                'Chemistry',
                                'Biology',
                                'Geography',
                                'Economics',
                                'Government',
                              ].map((subject) => _buildExamResultRow(subject)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Teacher's Comments
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Class Teacher\'s Comment',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Jessie has shown excellent improvement in her academic performance this term. She demonstrates strong analytical skills in Science subjects and shows great potential. Keep up the good work!',
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Principal\'s Comment',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'A commendable performance. Jessie should continue to maintain this standard and strive for excellence in all subjects.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProfileModal(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
          
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
  
              color: const Color.fromARGB(255, 254, 249, 249),
          ),
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Student Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header
                        Center(
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.grey[200],
                                    child: const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Jessie Rose Adebayo',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Grade 10 - Science Class',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Personal Information
                        _buildProfileSection('Personal Information', [
                          _buildProfileItem('Student ID', 'ST001234'),
                          _buildProfileItem('Date of Birth', 'March 15, 2008'),
                          _buildProfileItem('Age', '16 years'),
                          _buildProfileItem('Gender', 'Female'),
                          _buildProfileItem('Blood Group', 'O+'),
                          _buildProfileItem('Religion', 'Christianity'),
                        ]),

                        // Contact Information
                        _buildProfileSection('Contact Information', [
                          _buildProfileItem(
                            'Address',
                            'No. 6, Ojoo Road, Ibadan, Oyo State',
                          ), 
                          _buildProfileItem(
                            'Phone Number',
                            '+234 801 234 5678',
                          ),
                          _buildProfileItem(
                            'Email',
                            'jessie.rose@student.school.edu',
                          ),
                          _buildProfileItem(
                            'Emergency Contact',
                            '+234 803 456 7890',
                          ),
                        ]),

                        // Parent/Guardian Information
                        _buildProfileSection('Parent/Guardian Information', [
                          _buildProfileItem(
                            'Father\'s Name',
                            'Mr. John Adebayo',
                          ),
                          _buildProfileItem('Father\'s Occupation', 'Engineer'),
                          _buildProfileItem(
                            'Father\'s Phone',
                            '+234 803 456 7890',
                          ),
                          _buildProfileItem(
                            'Mother\'s Name',
                            'Mrs. Sarah Adebayo',
                          ),
                          _buildProfileItem('Mother\'s Occupation', 'Teacher'),
                          _buildProfileItem(
                            'Mother\'s Phone',
                            '+234 807 123 4567',
                          ),
                        ]),

                        // Academic Information
                        _buildProfileSection('Academic Information', [
                          _buildProfileItem('Admission Date', 'September 2021'),
                          _buildProfileItem('Current Class', 'SS2 Science'),
                          _buildProfileItem('House', 'Blue House'),
                          _buildProfileItem(
                            'Previous School',
                            'St. Mary\'s Junior Secondary School',
                          ),
                        ]),

                        // Medical Information
                        _buildProfileSection('Medical Information', [
                          _buildProfileItem('Allergies', 'None'),
                          _buildProfileItem('Medical Conditions', 'None'),
                          _buildProfileItem('Medications', 'None'),
                          _buildProfileItem(
                            'Doctor\'s Name',
                            'Dr. Michael Johnson',
                          ),
                          _buildProfileItem(
                            'Doctor\'s Phone',
                            '+234 802 345 6789',
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Edit profile functionality
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showContactParentModal(context) {
    final TextEditingController messageController = TextEditingController();
    String selectedParent = 'Both Parents';
    String messageType = 'General';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(16),
                color: const Color.fromARGB(255, 255, 251, 251),

                ),
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Contact Parent',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                  
                      // Student Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              child: Icon(Icons.person),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jessie Rose Adebayo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text('Grade 10 - Science Class'),
                                Text('Student ID: ST001234'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                  
                      // Parent Selection
                      const Text(
                        'Select Recipient',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: selectedParent,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            [
                              'Both Parents',
                              'Father - Mr. John Adebayo',
                              'Mother - Mrs. Sarah Adebayo',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedParent = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                  
                      // Message Type
                      const Text(
                        'Message Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: messageType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items:
                            [
                              'General',
                              'Academic Performance',
                              'Attendance Issue',
                              'Behavioral Concern',
                              'Achievement Recognition',
                              'Fee Payment',
                              'Medical Issue',
                              'Parent-Teacher Meeting',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            messageType = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                  
                      // Message Input
                      const Text(
                        'Message',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(height: 100,
                        child: TextField(
                          controller: messageController,
                          maxLines: null,
                          expands: true,
                          decoration: InputDecoration(
                            hintText: 'Type your message here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          textAlignVertical: TextAlignVertical.top,
                        ),
                      ),
                      const SizedBox(height: 16),
                  
                      // Quick Message Templates
                      const Text(
                        'Quick Templates',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildQuickMessageChip(
                            'Excellent performance this week!',
                            messageController,
                          ),
                          _buildQuickMessageChip(
                            'Please check attendance record',
                            messageController,
                          ),
                          _buildQuickMessageChip(
                            'Outstanding payment reminder',
                            messageController,
                          ),
                          _buildQuickMessageChip(
                            'Parent meeting request',
                            messageController,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                  
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Send message functionality
                              if (messageController.text.isNotEmpty) {
                                // Here you would implement the actual message sending
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Message sent to $selectedParent',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.send),
                            label: const Text('Send Message'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper Widgets for Modals
  Widget _buildTermTab(String term, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        term,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildExamStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

Widget _buildExamResultRow(String subject) {
    final results = <String, Map<String, Object>>{
      'Mathematics': {'ca': 35, 'exam': 53, 'grade': 'A'},
      'English Language': {'ca': 32, 'exam': 50, 'grade': 'B+'},
      'Physics': {'ca': 33, 'exam': 49, 'grade': 'A-'},
      'Chemistry': {'ca': 30, 'exam': 49, 'grade': 'B'},
      'Biology': {'ca': 36, 'exam': 55, 'grade': 'A'},
      'Geography': {'ca': 34, 'exam': 48, 'grade': 'A-'},
      'Economics': {'ca': 31, 'exam': 47, 'grade': 'B+'},
      'Government': {'ca': 33, 'exam': 51, 'grade': 'A-'},
    };

    final result = results[subject]!;

    final int ca = result['ca'] as int;
    final int exam = result['exam'] as int;
    final String grade = result['grade'] as String;
    final int total = ca + exam;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              subject,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text('${result['ca']}')),
          Expanded(child: Text('${result['exam']}')),
          Expanded(
            child: Text(
              '$total',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getGradeColor(
                  result['grade'] as String,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                result['grade'] as String,
                style: TextStyle(
                  color: _getGradeColor(result['grade'] as String),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'A-':
        return Colors.lightGreen;
      case 'B+':
        return Colors.blue;
      case 'B':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  Widget _buildProfileSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: items),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMessageChip(
    String message,
    TextEditingController controller,
  ) {
    return GestureDetector(
      onTap: () {
        controller.text = message;
      },
      child: Chip(
        label: Text(message, style: const TextStyle(fontSize: 12)),
        backgroundColor: Colors.blue[50],
        side: BorderSide(color: Colors.blue[200]!),
      ),
    );
  }

  Widget _buildStudentHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B73FF), Color(0xFF9B59B6), Color(0xFF8E44AD)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Image
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const CircleAvatar(
              radius: 45,
              backgroundImage: null, // Replace with NetworkImage or AssetImage
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
          ),

          const SizedBox(width: 20),

          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jessie Rose',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.school, size: 16, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      'Grade 10 - Science Class',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.numbers, size: 16, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      'Student ID: ST001234',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'No. 6, Ojoo, Ibadan',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Column(
            children: [
              _buildActionButton( ' View Profile     ', Icons.person_outline,context),
              const SizedBox(height: 8),
              _buildActionButton('Contact Parent', Icons.phone_outlined,context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon,BuildContext context) {
    return GestureDetector(
      onTap: () => _handleActionButtonTap(text,context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white70, width: 1),
          color: Colors.white.withOpacity(0.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleActionButtonTap(String action,context) {
    switch (action) {
      case ' View Profile     ':
        _showProfileModal(context);
        break;
      case 'Contact Parent':
        _showContactParentModal(context);
        break;
    }
  }

  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Overall Grade',
            'A-',
            '85.6%',
            Icons.grade,
            Colors.green,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            'Attendance',
            '92%',
            '23/25 days',
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            'Assignments',
            '15/18',
            'Completed',
            Icons.assignment,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            'Rank',
            '#3',
            'in class',
            Icons.emoji_events,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicPerformanceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              const Text(
                'Academic Performance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed:(){ _showExaminationDetailsModal(context);},
                icon: const Icon(Icons.visibility),
                label: const Text('View Details'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Subject Grades
          ...[
            'Mathematics',
            'English',
            'Physics',
            'Chemistry',
            'Biology',
          ].map((subject) => _buildSubjectGrade(subject)),
        ],
      ),
    );
  }

  Widget _buildSubjectGrade(String subject) {
    final grades = {
      'Mathematics': {'grade': 'A', 'score': 88, 'color': Colors.green},
      'English': {'grade': 'B+', 'score': 85, 'color': Colors.blue},
      'Physics': {'grade': 'A-', 'score': 82, 'color': Colors.orange},
      'Chemistry': {'grade': 'B', 'score': 79, 'color': Colors.purple},
      'Biology': {'grade': 'A', 'score': 91, 'color': Colors.teal},
    };

    final data = grades[subject]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              subject,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: (data['score'] as int) / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(data['color'] as Color),
              minHeight: 6,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (data['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              data['grade'] as String,
              style: TextStyle(
                color: data['color'] as Color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${data['score']}%',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Recent Assignments & Assessments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Assignment List
          ...List.generate(4, (index) => _buildAssignmentItem(index)),
        ],
      ),
    );
  }

  Widget _buildAssignmentItem(int index) {
    final assignments = [
      {
        'title': 'Mathematics Quiz 5',
        'subject': 'Mathematics',
        'status': 'Completed',
        'grade': '94%',
        'dueDate': '2 days ago',
        'color': Colors.green,
      },
      {
        'title': 'Physics Lab Report',
        'subject': 'Physics',
        'status': 'Pending',
        'grade': '-',
        'dueDate': 'Due tomorrow',
        'color': Colors.orange,
      },
      {
        'title': 'English Essay',
        'subject': 'English',
        'status': 'Completed',
        'grade': '87%',
        'dueDate': '1 week ago',
        'color': Colors.green,
      },
      {
        'title': 'Chemistry Test',
        'subject': 'Chemistry',
        'status': 'Graded',
        'grade': '82%',
        'dueDate': '3 days ago',
        'color': Colors.blue,
      },
    ];

    final assignment = assignments[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: assignment['color'] as Color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  assignment['subject'] as String,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (assignment['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  assignment['status'] as String,
                  style: TextStyle(
                    color: assignment['color'] as Color,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                assignment['grade'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attendance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // Icon(Icons.more_vert, color: Colors.grey[400]),
            ],
          ),
          const SizedBox(height: 20),

          // Pie Chart
           SizedBox(
            height: 120,
            child: CustomPieChart(
              spiritual: 92, // Present
              education: 8, // Absent
              social: 0,
              identity: 0,
            ),
          ),

          const SizedBox(height: 20),

          // Legend
          Column(
            children: [
              _buildLegendItem('Present', '92%', Colors.purple),
              const SizedBox(height: 8),
              _buildLegendItem('Absent', '8%', Colors.amber),
              const SizedBox(height: 8),
              _buildLegendItem('Late', '2%', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
        const Spacer(),
        Text(
          percentage,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              const Text(
                'Payment Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.payment, color: Colors.grey[400]),
            ],
          ),
          const SizedBox(height: 16),

          // Payment Items
          _buildPaymentItem('Tuition Fee', '₦50,000', 'Paid', Colors.green),
          _buildPaymentItem('Library Fee', '₦2,000', 'Paid', Colors.green),
          _buildPaymentItem('Sports Fee', '₦5,000', 'Pending', Colors.orange),
          _buildPaymentItem('Lab Fee', '₦3,000', 'Overdue', Colors.red),

          const SizedBox(height: 12),
          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Outstanding',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Text(
                '₦8,000',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(
    String item,
    String amount,
    String status,
    Color statusColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Recent Activities',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildActivityItem(
            'Submitted Math Assignment',
            '2 hours ago',
            Icons.assignment_turned_in,
          ),
          _buildActivityItem(
            'Attended Physics Lab',
            '1 day ago',
            Icons.science,
          ),
          _buildActivityItem(
            'Parent Meeting Scheduled',
            '2 days ago',
            Icons.event,
          ),
          _buildActivityItem('Library Book Borrowed', '3 days ago', Icons.book),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String activity, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: Colors.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
