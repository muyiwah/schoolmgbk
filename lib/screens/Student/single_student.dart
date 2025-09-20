import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/widgets/piechart.dart';
import 'package:schmgtsystem/providers/student_provider.dart';
import 'package:schmgtsystem/models/student_full_model.dart';

class SingleStudent extends ConsumerStatefulWidget {
  final String studentId;
  const SingleStudent({super.key, required this.studentId});

  @override
  ConsumerState<SingleStudent> createState() => _SingleStudentState();
}

class _SingleStudentState extends ConsumerState<SingleStudent> {
  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to defer the loading until after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStudent();
    });
  }

  Future<void> _loadStudent() async {
    final studentNotifier = ref.read(studentProvider.notifier);
    await studentNotifier.getStudentById(context, widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    final studentState = ref.watch(studentProvider);
    final student = studentState.studentFullModel.data?.student;

    if (studentState.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Student Profile',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (studentState.errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Student Profile',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading student data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                studentState.errorMessage!,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadStudent,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return _buildStudentContent(student);
  }

  Widget _buildStudentContent(Student? student) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildStudentHeader(student),
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
                      _buildQuickStatsRow(student),
                      const SizedBox(height: 20),

                      // Academic Performance Section
                      _buildAcademicPerformanceSection(student),
                      const SizedBox(height: 20),

                      // Assignments & Assessments
                      _buildAssignmentsSection(student),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // Right Column - Attendance & Payment
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildAttendanceCard(student),
                      const SizedBox(height: 20),
                      _buildPaymentCard(student),
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

  void _showProfileModal(BuildContext context, Student? student) {
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
                                    backgroundImage:
                                        student?.personalInfo?.profileImage !=
                                                    null &&
                                                student!
                                                    .personalInfo!
                                                    .profileImage!
                                                    .isNotEmpty
                                            ? NetworkImage(
                                              student
                                                  .personalInfo!
                                                  .profileImage!,
                                            )
                                            : null,
                                    child:
                                        student?.personalInfo?.profileImage ==
                                                    null ||
                                                student!
                                                    .personalInfo!
                                                    .profileImage!
                                                    .isEmpty
                                            ? const Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.grey,
                                            )
                                            : null,
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
                              Text(
                                '${student?.personalInfo?.firstName ?? ''} ${student?.personalInfo?.lastName ?? ''}'
                                        .trim()
                                        .isEmpty
                                    ? 'Student Name'
                                    : '${student!.personalInfo!.firstName!} ${student.personalInfo!.lastName!}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                student?.academicInfo?.currentClass?.name ??
                                    'No Class Assigned',
                                style: const TextStyle(
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
                          _buildProfileItem(
                            'Student ID',
                            student?.studentId ?? 'N/A',
                          ),
                          _buildProfileItem(
                            'Date of Birth',
                            student?.personalInfo?.dateOfBirth != null
                                ? '${student!.personalInfo!.dateOfBirth!.day}/${student.personalInfo!.dateOfBirth!.month}/${student.personalInfo!.dateOfBirth!.year}'
                                : 'N/A',
                          ),
                          _buildProfileItem(
                            'Age',
                            student?.age?.toString() ?? 'N/A',
                          ),
                          _buildProfileItem(
                            'Gender',
                            student?.personalInfo?.gender ?? 'N/A',
                          ),
                          _buildProfileItem(
                            'Blood Group',
                            student?.personalInfo?.bloodGroup ?? 'N/A',
                          ),
                          _buildProfileItem(
                            'Religion',
                            student?.personalInfo?.religion ?? 'N/A',
                          ),
                        ]),

                        // Contact Information
                        _buildProfileSection('Contact Information', [
                          _buildProfileItem(
                            'Address',
                            student?.contactInfo?.address != null
                                ? '${student!.contactInfo!.address!.street ?? ''}, ${student.contactInfo!.address!.city ?? ''}, ${student.contactInfo!.address!.state ?? ''}'
                                : 'N/A',
                          ),
                          _buildProfileItem(
                            'Phone Number',
                            student?.contactInfo?.phone ?? 'N/A',
                          ),
                          _buildProfileItem(
                            'Email',
                            student?.contactInfo?.email ?? 'N/A',
                          ),
                          _buildProfileItem(
                            'Emergency Contact',
                            'N/A', // This field doesn't exist in the model
                          ),
                        ]),

                        // Parent/Guardian Information
                        _buildProfileSection('Parent/Guardian Information', [
                          _buildProfileItem(
                            'Father\'s Name',
                            student?.parentInfo?.father?.personalInfo != null
                                ? '${student!.parentInfo!.father!.personalInfo!.firstName ?? ''} ${student.parentInfo!.father!.personalInfo!.lastName ?? ''}'
                                    .trim()
                                : 'N/A',
                          ),
                          _buildProfileItem(
                            'Father\'s Occupation',
                            student
                                    ?.parentInfo
                                    ?.father
                                    ?.professionalInfo
                                    ?.occupation ??
                                'N/A',
                          ),
                          _buildProfileItem(
                            'Father\'s Phone',
                            student
                                    ?.parentInfo
                                    ?.father
                                    ?.contactInfo
                                    ?.primaryPhone ??
                                'N/A',
                          ),
                          _buildProfileItem(
                            'Mother\'s Name',
                            'N/A', // Mother info not available in current model
                          ),
                          _buildProfileItem(
                            'Mother\'s Occupation',
                            'N/A',
                          ), // Mother info not available
                          _buildProfileItem(
                            'Mother\'s Phone',
                            'N/A', // Mother info not available
                          ),
                        ]),

                        // Academic Information
                        _buildProfileSection('Academic Information', [
                          _buildProfileItem(
                            'Admission Date',
                            student?.academicInfo?.admissionDate != null
                                ? '${student!.academicInfo!.admissionDate!.day}/${student.academicInfo!.admissionDate!.month}/${student.academicInfo!.admissionDate!.year}'
                                : 'N/A',
                          ),
                          _buildProfileItem(
                            'Current Class',
                            student?.academicInfo?.currentClass?.name ?? 'N/A',
                          ),
                          _buildProfileItem(
                            'House',
                            'N/A',
                          ), // This field doesn't exist in the model
                          _buildProfileItem(
                            'Previous School',
                            'N/A', // This field doesn't exist in the model
                          ),
                        ]),

                        // Medical Information
                        _buildProfileSection('Medical Information', [
                          _buildProfileItem(
                            'Allergies',
                            student?.medicalInfo?.allergies?.join(', ') ??
                                'None',
                          ),
                          _buildProfileItem(
                            'Medical Conditions',
                            student?.medicalInfo?.medicalConditions?.join(
                                  ', ',
                                ) ??
                                'None',
                          ),
                          _buildProfileItem(
                            'Medications',
                            student?.medicalInfo?.medications?.join(', ') ??
                                'None',
                          ),
                          _buildProfileItem(
                            'Doctor\'s Name',
                            student?.medicalInfo?.emergencyContact?.name ??
                                'N/A',
                          ),
                          _buildProfileItem(
                            'Doctor\'s Phone',
                            student?.medicalInfo?.emergencyContact?.phone ??
                                'N/A',
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

  void _showContactParentModal(BuildContext context, Student? student) {
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
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[200],
                              backgroundImage:
                                  student?.personalInfo?.profileImage != null &&
                                          student!
                                              .personalInfo!
                                              .profileImage!
                                              .isNotEmpty
                                      ? NetworkImage(
                                        student.personalInfo!.profileImage!,
                                      )
                                      : null,
                              child:
                                  student?.personalInfo?.profileImage == null ||
                                          student!
                                              .personalInfo!
                                              .profileImage!
                                              .isEmpty
                                      ? const Icon(Icons.person)
                                      : null,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${student?.personalInfo?.firstName ?? ''} ${student?.personalInfo?.lastName ?? ''}'
                                          .trim()
                                          .isEmpty
                                      ? 'Student Name'
                                      : '${student!.personalInfo!.firstName!} ${student.personalInfo!.lastName!}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  student?.academicInfo?.currentClass?.name ??
                                      'No Class Assigned',
                                ),
                                Text(
                                  'Student ID: ${student?.studentId ?? 'N/A'}',
                                ),
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
                      SizedBox(
                        height: 100,
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

  Widget _buildStudentHeader(Student? student) {
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
          // Pr
          //
          //
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          //
          //ofile Image
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey[600],
              backgroundImage:
                  student?.personalInfo?.profileImage != null &&
                          student!.personalInfo!.profileImage!.isNotEmpty
                      ? NetworkImage(student.personalInfo!.profileImage!)
                      : null,
              child:
                  student?.personalInfo?.profileImage == null ||
                          student!.personalInfo!.profileImage!.isEmpty
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
            ),
          ),

          const SizedBox(width: 20),

          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${student?.personalInfo?.firstName ?? 'N/A'} ${student?.personalInfo?.lastName ?? ''}',
                  style: const TextStyle(
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
                      '${student?.academicInfo?.currentClass?.name ?? 'N/A'} - ${student?.academicInfo?.currentClass?.level ?? 'N/A'}',
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
                      'Student ID: ${student?.admissionNumber ?? 'N/A'}',
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
                      '${student?.contactInfo?.address?.street ?? 'N/A'}, ${student?.contactInfo?.address?.city ?? 'N/A'}',
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
              _buildActionButton(
                ' View Profile     ',
                Icons.person_outline,
                context,
                student,
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                'Contact Parent',
                Icons.phone_outlined,
                context,
                student,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    BuildContext context,
    Student? student,
  ) {
    return GestureDetector(
      onTap: () => _handleActionButtonTap(text, context, student),
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

  void _handleActionButtonTap(
    String action,
    BuildContext context,
    Student? student,
  ) {
    switch (action) {
      case ' View Profile     ':
        _showProfileModal(context, student);
        break;
      case 'Contact Parent':
        _showContactParentModal(context, student);
        break;
    }
  }

  Widget _buildQuickStatsRow(Student? student) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Overall Grade',
            student?.performanceData?.latestPerformance?.overallGrade
                    ?.toString()
                    .split('.')
                    .last ??
                'N/A',
            '${student?.performanceData?.latestPerformance?.overallScore?.toStringAsFixed(1) ?? '0'}%',
            Icons.grade,
            Colors.green,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            'Attendance',
            '${student?.attendanceData?.statistics?.summary?.presentPercentage ?? 0}%',
            '${student?.attendanceData?.statistics?.summary?.presentDays ?? 0}/${student?.attendanceData?.statistics?.totalClassDays ?? 0} days',
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            'Fee Status',
            student?.financialInfo?.feeStatus ?? 'N/A',
            '₦${student?.financialInfo?.outstandingBalance ?? 0}',
            Icons.payment,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            'Age',
            '${student?.age ?? 0}',
            'years old',
            Icons.cake,
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

  Widget _buildAcademicPerformanceSection(Student? student) {
    final subjects = student?.performanceData?.termAverages?.subjects ?? [];

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
                onPressed: () {
                  _showExaminationDetailsModal(context);
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View Details'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Subject Grades
          if (subjects.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No performance data available',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          else
            ...subjects.take(5).map((subject) => _buildSubjectGrade(subject)),
        ],
      ),
    );
  }

  Widget _buildSubjectGrade(Subject subject) {
    // Get the actual score or use 0 if not available
    final score = subject.actualScore ?? 0;

    // Determine color based on score
    Color color;
    if (score >= 90) {
      color = Colors.green;
    } else if (score >= 80) {
      color = Colors.blue;
    } else if (score >= 70) {
      color = Colors.orange;
    } else if (score >= 60) {
      color = Colors.purple;
    } else {
      color = Colors.red;
    }

    // Get grade string or calculate from score
    String gradeString;
    if (subject.grade != null) {
      // Convert enum to string (assuming Grade enum has toString method)
      gradeString = subject.grade.toString().split('.').last;
    } else {
      // Calculate grade from score
      if (score >= 90) {
        gradeString = 'A';
      } else if (score >= 80) {
        gradeString = 'B';
      } else if (score >= 70) {
        gradeString = 'C';
      } else if (score >= 60) {
        gradeString = 'D';
      } else {
        gradeString = 'F';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              subject.name ?? 'Unknown Subject',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              gradeString,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$score%',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsSection(Student? student) {
    // Get assignments from the studentFullModel data, not from student directly
    final studentState = ref.watch(studentProvider);
    final assignments =
        studentState.studentFullModel.data?.recentAssignments ?? [];

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
          if (assignments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No assignments found',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          else
            ...assignments
                .take(4)
                .map((assignment) => _buildAssignmentItem(assignment)),
        ],
      ),
    );
  }

  Widget _buildAssignmentItem(RecentAssignment assignment) {
    // Get the student's submission for this assignment
    final submission =
        assignment.submissions?.isNotEmpty == true
            ? assignment.submissions!.first
            : null;

    // Determine status and color based on submission
    String status;
    Color statusColor;
    String grade = '-';

    if (submission != null) {
      status = submission.status ?? 'Submitted';
      if (submission.marks != null && assignment.maxMarks != null) {
        final percentage = (submission.marks! / assignment.maxMarks!) * 100;
        grade = '${percentage.round()}%';
      }

      switch (status.toLowerCase()) {
        case 'graded':
        case 'completed':
          statusColor = Colors.green;
          break;
        case 'submitted':
          statusColor = Colors.blue;
          break;
        case 'pending':
        case 'late':
          statusColor = Colors.orange;
          break;
        default:
          statusColor = Colors.grey;
      }
    } else {
      // Check if assignment is overdue
      if (assignment.dueDate != null &&
          assignment.dueDate!.isBefore(DateTime.now())) {
        status = 'Overdue';
        statusColor = Colors.red;
      } else {
        status = 'Not Submitted';
        statusColor = Colors.orange;
      }
    }

    // Format due date
    String dueDateText = 'No due date';
    if (assignment.dueDate != null) {
      final now = DateTime.now();
      final dueDate = assignment.dueDate!;
      final difference = dueDate.difference(now).inDays;

      if (difference < 0) {
        dueDateText = '${-difference} days ago';
      } else if (difference == 0) {
        dueDateText = 'Due today';
      } else if (difference == 1) {
        dueDateText = 'Due tomorrow';
      } else {
        dueDateText = 'Due in $difference days';
      }
    }

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
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title ?? 'Untitled Assignment',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  assignment.subject ?? 'No Subject',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  dueDateText,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
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
              const SizedBox(height: 4),
              Text(
                grade,
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

  Widget _buildAttendanceCard(Student? student) {
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
              spiritual:
                  (student
                              ?.attendanceData
                              ?.statistics
                              ?.summary
                              ?.presentPercentage ??
                          0)
                      .toInt(), // Present
              education:
                  (student
                              ?.attendanceData
                              ?.statistics
                              ?.summary
                              ?.absentPercentage ??
                          0)
                      .toInt(), // Absent
              social:
                  (student
                              ?.attendanceData
                              ?.statistics
                              ?.summary
                              ?.latePercentage ??
                          0)
                      .toInt(), // Late
              identity:
                  (student
                              ?.attendanceData
                              ?.statistics
                              ?.summary
                              ?.excusedPercentage ??
                          0)
                      .toInt(), // Excused
            ),
          ),

          const SizedBox(height: 20),

          // Legend
          Column(
            children: [
              _buildLegendItem(
                'Present',
                '${student?.attendanceData?.statistics?.summary?.presentPercentage ?? 0}%',
                Colors.purple,
              ),
              const SizedBox(height: 8),
              _buildLegendItem(
                'Absent',
                '${student?.attendanceData?.statistics?.summary?.absentPercentage ?? 0}%',
                Colors.amber,
              ),
              const SizedBox(height: 8),
              _buildLegendItem(
                'Late',
                '${student?.attendanceData?.statistics?.summary?.latePercentage ?? 0}%',
                Colors.orange,
              ),
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

  Widget _buildPaymentCard(Student? student) {
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
          _buildPaymentItem(
            'Total Fees',
            '₦${student?.financialInfo?.totalFees ?? 0}',
            'Total',
            Colors.blue,
          ),
          _buildPaymentItem(
            'Paid Amount',
            '₦${student?.financialInfo?.paidAmount ?? 0}',
            'Paid',
            Colors.green,
          ),
          _buildPaymentItem(
            'Outstanding',
            '₦${student?.financialInfo?.outstandingBalance ?? 0}',
            student?.financialInfo?.feeStatus ?? 'Pending',
            student?.financialInfo?.feeStatus == 'paid'
                ? Colors.green
                : student?.financialInfo?.feeStatus == 'pending'
                ? Colors.orange
                : Colors.red,
          ),

          const SizedBox(height: 12),
          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fee Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                student?.financialInfo?.feeStatus ?? 'N/A',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color:
                      student?.financialInfo?.feeStatus == 'paid'
                          ? Colors.green
                          : student?.financialInfo?.feeStatus == 'pending'
                          ? Colors.orange
                          : Colors.red,
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
