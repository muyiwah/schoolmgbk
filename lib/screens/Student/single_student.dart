import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/widgets/piechart.dart';
import 'package:schmgtsystem/providers/student_provider.dart';
import 'package:schmgtsystem/models/student_full_model.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:schmgtsystem/screens/admin/admin_change_password_screen.dart';

class SingleStudent extends ConsumerStatefulWidget {
  final String studentId;
  const SingleStudent({super.key, required this.studentId});

  @override
  ConsumerState<SingleStudent> createState() => _SingleStudentState();
}

class _SingleStudentState extends ConsumerState<SingleStudent> {
  // Edit mode state
  bool _isEditMode = false;

  // Text controllers for editable fields
  final Map<String, TextEditingController> _textControllers = {};

  // Boolean state variables for SEN and Permissions
  bool? _hasSpecialNeeds;
  bool? _receivingAdditionalSupport;
  bool? _hasEHCP;
  bool? _emergencyMedicalTreatment;
  bool? _administrationOfMedication;
  bool? _firstAidConsent;
  bool? _outingsAndTrips;
  bool? _transportConsent;
  bool? _useOfPhotosVideos;
  bool? _suncreamApplication;
  bool? _observationAndAssessment;
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
  void dispose() {
    // Dispose all text controllers
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
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

                      // Student Details Section
                      _buildStudentDetailsSection(student),
                      const SizedBox(height: 20),
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
                      // const SizedBox(height: 20),
                      // _buildRecentActivitiesCard(),
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
                                            ? CachedNetworkImageProvider(
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
                        Navigator.of(context).pop();
                        _toggleEditMode(student);
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
                                      ? CachedNetworkImageProvider(
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
                                showSnackbar(
                                  context,
                                  'Message sent to $selectedParent',
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
                      ? CachedNetworkImageProvider(
                        student.personalInfo!.profileImage!,
                      )
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
                'Update Student',
                Icons.edit_outlined,
                context,
                student,
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                'Change Password',
                Icons.lock_outline,
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
      case 'Update Student':
        _toggleEditMode(student);
        break;
      case 'Contact Parent':
        _showContactParentModal(context, student);
        break;
      case 'Change Password':
        _navigateToChangePassword(context, student);
        break;
    }
  }

  void _toggleEditMode(Student? student) {
    if (student == null) return;

    setState(() {
      _isEditMode = !_isEditMode;

      if (_isEditMode) {
        _initializeTextControllers(student);
      } else {
        _clearTextControllers();
      }
    });
  }

  void _initializeTextControllers(Student student) {
    // Clear existing controllers
    _clearTextControllers();

    // Initialize controllers with current student data
    _textControllers['firstName'] = TextEditingController(
      text: student.personalInfo?.firstName ?? '',
    );
    _textControllers['lastName'] = TextEditingController(
      text: student.personalInfo?.lastName ?? '',
    );
    _textControllers['middleName'] = TextEditingController(
      text: student.personalInfo?.middleName ?? '',
    );
    _textControllers['dateOfBirth'] = TextEditingController(
      text:
          student.personalInfo?.dateOfBirth?.toIso8601String().split('T')[0] ??
          '',
    );
    _textControllers['gender'] = TextEditingController(
      text: student.personalInfo?.gender ?? '',
    );
    _textControllers['bloodGroup'] = TextEditingController(
      text: student.personalInfo?.bloodGroup ?? '',
    );
    _textControllers['religion'] = TextEditingController(
      text: student.personalInfo?.religion ?? '',
    );
    _textControllers['nationality'] = TextEditingController(
      text: student.personalInfo?.nationality ?? '',
    );
    _textControllers['stateOfOrigin'] = TextEditingController(
      text: student.personalInfo?.stateOfOrigin ?? '',
    );
    _textControllers['localGovernment'] = TextEditingController(
      text: student.personalInfo?.localGovernment ?? '',
    );
    _textControllers['phone'] = TextEditingController(
      text: student.contactInfo?.phone ?? '',
    );
    _textControllers['email'] = TextEditingController(
      text: student.contactInfo?.email ?? '',
    );
    _textControllers['address'] = TextEditingController(
      text:
          '${student.contactInfo?.address?.street ?? ''}, ${student.contactInfo?.address?.city ?? ''}, ${student.contactInfo?.address?.state ?? ''}',
    );
    _textControllers['admissionNumber'] = TextEditingController(
      text: student.admissionNumber ?? '',
    );
    _textControllers['profileImage'] = TextEditingController(
      text: student.personalInfo?.profileImage ?? '',
    );

    // Additional Personal Information
    _textControllers['languagesSpokenAtHome'] = TextEditingController(
      text: student.personalInfo?.languagesSpokenAtHome ?? '',
    );
    _textControllers['ethnicBackground'] = TextEditingController(
      text: student.personalInfo?.ethnicBackground ?? '',
    );
    _textControllers['formOfIdentification'] = TextEditingController(
      text: student.personalInfo?.formOfIdentification ?? '',
    );
    _textControllers['idNumber'] = TextEditingController(
      text: student.personalInfo?.idNumber ?? '',
    );

    // Address Components
    _textControllers['streetNumber'] = TextEditingController(
      text: student.contactInfo?.address?.streetNumber ?? '',
    );
    _textControllers['streetName'] = TextEditingController(
      text: student.contactInfo?.address?.streetName ?? '',
    );
    _textControllers['city'] = TextEditingController(
      text: student.contactInfo?.address?.city ?? '',
    );
    _textControllers['state'] = TextEditingController(
      text: student.contactInfo?.address?.state ?? '',
    );
    _textControllers['country'] = TextEditingController(
      text: student.contactInfo?.address?.country ?? '',
    );
    _textControllers['postalCode'] = TextEditingController(
      text: student.contactInfo?.address?.postalCode ?? '',
    );

    // Medical Information
    _textControllers['gpName'] = TextEditingController(
      text: student.medicalInfo?.generalPractitioner?.name ?? '',
    );
    _textControllers['gpAddress'] = TextEditingController(
      text: student.medicalInfo?.generalPractitioner?.address ?? '',
    );
    _textControllers['gpPhone'] = TextEditingController(
      text: student.medicalInfo?.generalPractitioner?.telephoneNumber ?? '',
    );
    _textControllers['emergencyContactName'] = TextEditingController(
      text: student.medicalInfo?.emergencyContact?.name ?? '',
    );
    _textControllers['emergencyContactRelationship'] = TextEditingController(
      text: student.medicalInfo?.emergencyContact?.relationship ?? '',
    );
    _textControllers['emergencyContactPhone'] = TextEditingController(
      text: student.medicalInfo?.emergencyContact?.phone ?? '',
    );
    _textControllers['emergencyContactEmail'] = TextEditingController(
      text: student.medicalInfo?.emergencyContact?.email ?? '',
    );
    _textControllers['emergencyContactAddress'] = TextEditingController(
      text:
          '${student.medicalInfo?.emergencyContact?.address?.streetNumber ?? ''} ${student.medicalInfo?.emergencyContact?.address?.streetName ?? ''}, ${student.medicalInfo?.emergencyContact?.address?.city ?? ''}, ${student.medicalInfo?.emergencyContact?.address?.state ?? ''}, ${student.medicalInfo?.emergencyContact?.address?.country ?? ''} ${student.medicalInfo?.emergencyContact?.address?.postalCode ?? ''}',
    );
    _textControllers['medicalHistory'] = TextEditingController(
      text: student.medicalInfo?.medicalHistory ?? '',
    );
    _textControllers['allergies'] = TextEditingController(
      text: student.medicalInfo?.allergies?.join(', ') ?? '',
    );
    _textControllers['ongoingMedicalConditions'] = TextEditingController(
      text: student.medicalInfo?.ongoingMedicalConditions ?? '',
    );
    _textControllers['specialNeeds'] = TextEditingController(
      text: student.medicalInfo?.specialNeeds ?? '',
    );
    _textControllers['currentMedication'] = TextEditingController(
      text: student.medicalInfo?.currentMedication ?? '',
    );
    _textControllers['immunisationRecord'] = TextEditingController(
      text: student.medicalInfo?.immunisationRecord ?? '',
    );
    _textControllers['dietaryRequirements'] = TextEditingController(
      text: student.medicalInfo?.dietaryRequirements ?? '',
    );

    // Parent/Guardian Information
    if (student.parentInfo?.father != null) {
      _textControllers['fatherTitle'] = TextEditingController(
        text: student.parentInfo!.father!.personalInfo?.title ?? '',
      );
      _textControllers['fatherName'] = TextEditingController(
        text:
            '${student.parentInfo!.father!.personalInfo!.firstName ?? ''} ${student.parentInfo!.father!.personalInfo!.lastName ?? ''}'
                .trim(),
      );
      _textControllers['fatherMiddleName'] = TextEditingController(
        text: student.parentInfo!.father!.personalInfo?.middleName ?? '',
      );
      _textControllers['fatherDateOfBirth'] = TextEditingController(
        text:
            student.parentInfo!.father!.personalInfo?.dateOfBirth?.toString() ??
            '',
      );
      _textControllers['fatherGender'] = TextEditingController(
        text: student.parentInfo!.father!.personalInfo?.gender ?? '',
      );
      _textControllers['fatherMaritalStatus'] = TextEditingController(
        text: student.parentInfo!.father!.personalInfo?.maritalStatus ?? '',
      );
      _textControllers['fatherPhone'] = TextEditingController(
        text: student.parentInfo!.father!.contactInfo?.primaryPhone ?? '',
      );
      // _textControllers['fatherSecondaryPhone'] = TextEditingController(
      //   text: student.parentInfo!.father!.contactInfo?.secondaryPhone ?? '',
      // );
      _textControllers['fatherEmail'] = TextEditingController(
        text: student.parentInfo!.father!.contactInfo?.email ?? '',
      );
      // _textControllers['fatherAddress'] = TextEditingController(
      //   text:
      //       '${student.parentInfo!.father!.contactInfo?.address?.streetNumber ?? ''} ${student.parentInfo!.father!.contactInfo?.address?.streetName ?? ''}, ${student.parentInfo!.father!.contactInfo?.address?.city ?? ''}, ${student.parentInfo!.father!.contactInfo?.address?.state ?? ''}, ${student.parentInfo!.father!.contactInfo?.address?.country ?? ''} ${student.parentInfo!.father!.contactInfo?.address?.postalCode ?? ''}',
      // );
      _textControllers['fatherOccupation'] = TextEditingController(
        text: student.parentInfo!.father!.professionalInfo?.occupation ?? '',
      );
      _textControllers['fatherEmployer'] = TextEditingController(
        text: student.parentInfo!.father!.professionalInfo?.employer ?? '',
      );
      // _textControllers['fatherWorkPhone'] = TextEditingController(
      //   text: student.parentInfo!.father!.professionalInfo?.workPhone ?? '',
      // );
      _textControllers['fatherAnnualIncome'] = TextEditingController(
        text:
            student.parentInfo!.father!.professionalInfo?.annualIncome
                ?.toString() ??
            '',
      );
      // _textControllers['fatherWorkAddress'] = TextEditingController(
      //   text:
      //       '${student.parentInfo!.father!.professionalInfo?.workAddress?.streetNumber ?? ''} ${student.parentInfo!.father!.professionalInfo?.workAddress?.streetName ?? ''}, ${student.parentInfo!.father!.professionalInfo?.workAddress?.city ?? ''}, ${student.parentInfo!.father!.professionalInfo?.workAddress?.state ?? ''}, ${student.parentInfo!.father!.professionalInfo?.workAddress?.country ?? ''} ${student.parentInfo!.father!.professionalInfo?.workAddress?.postalCode ?? ''}',
      // );
      // _textControllers['fatherIdType'] = TextEditingController(
      //   text: student.parentInfo!.father!.identification?.idType ?? '',
      // );
      // _textControllers['fatherIdNumber'] = TextEditingController(
      //   text: student.parentInfo!.father!.identification?.idNumber ?? '',
      // );
    }

    // Initialize boolean values for SEN and Permissions
    _hasSpecialNeeds = student.senInfo?.hasSpecialNeeds;
    _receivingAdditionalSupport = student.senInfo?.receivingAdditionalSupport;
    _hasEHCP = student.senInfo?.hasEHCP;
    _emergencyMedicalTreatment = student.permissions?.emergencyMedicalTreatment;
    _administrationOfMedication =
        student.permissions?.administrationOfMedication;
    _firstAidConsent = student.permissions?.firstAidConsent;
    _outingsAndTrips = student.permissions?.outingsAndTrips;
    _transportConsent = student.permissions?.transportConsent;
    _useOfPhotosVideos = student.permissions?.useOfPhotosVideos;
    _suncreamApplication = student.permissions?.suncreamApplication;
    _observationAndAssessment = student.permissions?.observationAndAssessment;
  }

  void _clearTextControllers() {
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
  }

  void _navigateToChangePassword(BuildContext context, Student? student) async {
    if (student == null) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => AdminChangePasswordFormScreen(
              userId: student.id ?? '', // Using student.id as userId for now
              userEmail: student.user?.email ?? '',
              userRole: 'student',
              userName:
                  '${student.personalInfo?.firstName ?? ''} ${student.personalInfo?.lastName ?? ''}',
            ),
      ),
    );

    // Refresh student data if password was changed
    if (result == true) {
      // Refresh the student data
      final studentNotifier = ref.read(studentProvider.notifier);
      await studentNotifier.getStudentById(context, student.id ?? '');
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
            '£${student?.financialInfo?.outstandingBalance ?? 0}',
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

  Widget _buildStudentDetailsSection(Student? student) {
    if (student == null) {
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
        child: const Center(
          child: Text(
            'No student data available',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

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
            'Student Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Personal Information
          _buildDetailSection('Personal Information', Icons.person, [
            _buildDetailRow(
              'First Name',
              student.personalInfo?.firstName ?? "",
              fieldKey: 'firstName',
            ),
            _buildDetailRow(
              'Last Name',
              student.personalInfo?.lastName ?? "",
              fieldKey: 'lastName',
            ),
            _buildDetailRow(
              'Middle Name',
              student.personalInfo?.middleName ?? "",
              fieldKey: 'middleName',
            ),
            _buildDetailRow(
              'Date of Birth',
              student.personalInfo?.dateOfBirth?.toString() ?? "",
              fieldKey: 'dateOfBirth',
            ),
            _buildDetailRow('Age', student.age.toString()),
            _buildDetailRow(
              'Gender',
              student.personalInfo?.gender ?? "",
              fieldKey: 'gender',
            ),
            _buildDetailRow(
              'Blood Group',
              student.personalInfo?.bloodGroup ?? "",
              fieldKey: 'bloodGroup',
            ),
            _buildDetailRow(
              'Religion',
              student.personalInfo?.religion ?? "",
              fieldKey: 'religion',
            ),
            _buildDetailRow(
              'Nationality',
              student.personalInfo?.nationality ?? "",
              fieldKey: 'nationality',
            ),
            _buildDetailRow(
              'Locality',
              student.personalInfo?.stateOfOrigin,
              fieldKey: 'stateOfOrigin',
            ),
            _buildDetailRow(
              'Local Government',
              student.personalInfo?.localGovernment ?? "",
              fieldKey: 'localGovernment',
            ),
            // Additional Personal Information
            _buildDetailRow(
              'Languages Spoken at Home',
              student.personalInfo?.languagesSpokenAtHome ?? "",
              fieldKey: 'languagesSpokenAtHome',
            ),
            _buildDetailRow(
              'Ethnic Background',
              student.personalInfo?.ethnicBackground ?? "",
              fieldKey: 'ethnicBackground',
            ),
            _buildDetailRow(
              'Form of Identification',
              student.personalInfo?.formOfIdentification ?? "",
              fieldKey: 'formOfIdentification',
            ),
            _buildDetailRow(
              'ID Number',
              student.personalInfo?.idNumber ?? "",
              fieldKey: 'idNumber',
            ),
            _buildDetailRow(
              'Has Siblings',
              student.personalInfo?.hasSiblings == true ? 'Yes' : 'No',
            ),
            if (student.personalInfo?.siblingDetails != null &&
                student.personalInfo!.siblingDetails!.isNotEmpty)
              _buildDetailRow(
                'Sibling Details',
                student.personalInfo!.siblingDetails!
                    .map(
                      (sibling) =>
                          '${sibling['name'] ?? 'Unknown'} (${sibling['age'] ?? 'Unknown'} years old)',
                    )
                    .join(', '),
              ),
            _buildDetailRow(
              'Phone Number',
              student.contactInfo?.phone ?? "",
              fieldKey: 'phone',
            ),
            _buildDetailRow(
              'Email',
              student.contactInfo?.email ?? "",
              fieldKey: 'email',
            ),
            _buildDetailRow(
              'Address',
              '${student.contactInfo?.address?.street ?? ''}, ${student.contactInfo?.address?.city ?? ''}, ${student.contactInfo?.address?.state ?? ''}',
              fieldKey: 'address',
            ),
            // Address Components
            _buildDetailRow(
              'Street Number',
              student.contactInfo?.address?.streetNumber ?? "",
              fieldKey: 'streetNumber',
            ),
            _buildDetailRow(
              'Street Name',
              student.contactInfo?.address?.streetName ?? "",
              fieldKey: 'streetName',
            ),
            _buildDetailRow(
              'City',
              student.contactInfo?.address?.city ?? "",
              fieldKey: 'city',
            ),
            _buildDetailRow(
              'Locality',
              student.contactInfo?.address?.state ?? "",
              fieldKey: 'locality',
            ),
            _buildDetailRow(
              'Country',
              student.contactInfo?.address?.country ?? "",
              fieldKey: 'country',
            ),
            _buildDetailRow(
              'Postal Code',
              student.contactInfo?.address?.postalCode ?? "",
              fieldKey: 'postalCode',
            ),
          ]),

          const SizedBox(height: 20),

          // Academic Information
          _buildDetailSection('Academic Information', Icons.school, [
            _buildDetailRow(
              'Admission Number',
              student.admissionNumber,
              fieldKey: 'admissionNumber',
            ),
            _buildDetailRow(
              'Class Level',
              student.academicInfo?.currentClass?.level ?? '',
            ),
            _buildDetailRow(
              'Current Class',
              student.academicInfo?.currentClass?.name ?? '',
            ),
            _buildDetailRow(
              'Class ID',
              student.academicInfo?.currentClass?.id ?? '',
            ),
            _buildDetailRow(
              'Academic Year',
              student.academicInfo?.academicYear ?? '',
            ),
            _buildDetailRow(
              'Admission Date',
              student.academicInfo?.admissionDate?.toString() ?? '',
            ),
            _buildDetailRow(
              'Student Type',
              student.academicInfo?.studentType ?? '',
            ),
            _buildDetailRow('Student Status', student.status),
          ]),

          const SizedBox(height: 20),

          // Financial Information
          _buildDetailSection(
            'Financial Information',
            Icons.account_balance_wallet,
            [
              _buildDetailRow(
                'Fee Status',
                student.financialInfo?.feeStatus ?? '',
              ),
              _buildDetailRow(
                'Total Fees',
                student.financialInfo?.totalFees?.toString() ?? '',
              ),
              _buildDetailRow(
                'Paid Amount',
                student.financialInfo?.paidAmount?.toString() ?? '',
              ),
              _buildDetailRow(
                'Outstanding Balance',
                student.financialInfo?.outstandingBalance?.toString() ?? '',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Parent/Guardian Information
          _buildDetailSection('Parent/Guardian Information', Icons.family_restroom, [
            if (student.parentInfo?.father != null) ...[
              // Father Personal Information
              _buildDetailRow(
                'Father Title',
                student.parentInfo?.father?.personalInfo?.title ?? '',
                fieldKey: 'fatherTitle',
              ),
              _buildDetailRow(
                'Father Name',
                '${student.parentInfo?.father?.personalInfo?.firstName ?? ''} ${student.parentInfo?.father?.personalInfo?.lastName ?? ''}'
                    .trim(),
                fieldKey: 'fatherName',
              ),
              _buildDetailRow(
                'Father Middle Name',
                student.parentInfo?.father?.personalInfo?.middleName ?? '',
                fieldKey: 'fatherMiddleName',
              ),
              _buildDetailRow(
                'Father Date of Birth',
                student.parentInfo?.father?.personalInfo?.dateOfBirth
                        ?.toString() ??
                    '',
                fieldKey: 'fatherDateOfBirth',
              ),
              _buildDetailRow(
                'Father Gender',
                student.parentInfo?.father?.personalInfo?.gender ?? '',
                fieldKey: 'fatherGender',
              ),
              _buildDetailRow(
                'Father Marital Status',
                student.parentInfo?.father?.personalInfo?.maritalStatus ?? '',
                fieldKey: 'fatherMaritalStatus',
              ),

              // Father Contact Information - Commented out problematic fields
              // _buildDetailRow(
              //   'Father Secondary Phone',
              //   student.parentInfo?.father?.contactInfo?.secondaryPhone ?? '',
              //   fieldKey: 'fatherSecondaryPhone',
              // ),
              _buildDetailRow(
                'Father Email',
                student.parentInfo?.father?.contactInfo?.email ?? '',
                fieldKey: 'fatherEmail',
              ),
              // _buildDetailRow(
              //   'Father Address',
              //   '${student.parentInfo?.father?.contactInfo?.address?.streetNumber ?? ''} ${student.parentInfo?.father?.contactInfo?.address?.streetName ?? ''}, ${student.parentInfo?.father?.contactInfo?.address?.city ?? ''}, ${student.parentInfo?.father?.contactInfo?.address?.state ?? ''}, ${student.parentInfo?.father?.contactInfo?.address?.country ?? ''} ${student.parentInfo?.father?.contactInfo?.address?.postalCode ?? ''}',
              //   fieldKey: 'fatherAddress',
              // ),

              // Father Professional Information
              _buildDetailRow(
                'Father Occupation',
                student.parentInfo?.father?.professionalInfo?.occupation ?? '',
                fieldKey: 'fatherOccupation',
              ),
              _buildDetailRow(
                'Father Employer',
                student.parentInfo?.father?.professionalInfo?.employer ?? '',
                fieldKey: 'fatherEmployer',
              ),
              // _buildDetailRow(
              //   'Father Work Phone',
              //   student.parentInfo?.father?.professionalInfo?.workPhone ?? '',
              //   fieldKey: 'fatherWorkPhone',
              // ),
              _buildDetailRow(
                'Father Annual Income',
                student.parentInfo?.father?.professionalInfo?.annualIncome
                        ?.toString() ??
                    '',
                fieldKey: 'fatherAnnualIncome',
              ),
              // _buildDetailRow(
              //   'Father Work Address',
              //   '${student.parentInfo?.father?.professionalInfo?.workAddress?.streetNumber ?? ''} ${student.parentInfo?.father?.professionalInfo?.workAddress?.streetName ?? ''}, ${student.parentInfo?.father?.professionalInfo?.workAddress?.city ?? ''}, ${student.parentInfo?.father?.professionalInfo?.workAddress?.state ?? ''}, ${student.parentInfo?.father?.professionalInfo?.workAddress?.country ?? ''} ${student.parentInfo?.father?.professionalInfo?.workAddress?.postalCode ?? ''}',
              //   fieldKey: 'fatherWorkAddress',
              // ),

              // Father Identification - Commented out until models are updated
              // _buildDetailRow(
              //   'Father ID Type',
              //   student.parentInfo?.father?.identification?.idType ?? '',
              //   fieldKey: 'fatherIdType',
              // ),
              // _buildDetailRow(
              //   'Father ID Number',
              //   student.parentInfo?.father?.identification?.idNumber ?? '',
              //   fieldKey: 'fatherIdNumber',
              // ),

              // Father Legal Information - Commented out until models are updated
              // _buildDetailRow(
              //   'Parental Responsibility',
              //   student.parentInfo?.father?.parentalResponsibility == true
              //       ? 'Yes'
              //       : 'No',
              // ),
              // _buildDetailRow(
              //   'Legal Guardianship',
              //   student.parentInfo?.father?.legalGuardianship == true
              //       ? 'Yes'
              //       : 'No',
              // ),
              // _buildDetailRow(
              //   'Authorized to Collect Child',
              //   student.parentInfo?.father?.authorisedToCollectChild == true
              //       ? 'Yes'
              //       : 'No',
              // ),
              // _buildDetailRow(
              //   'Relationship to Child',
              //   student.parentInfo?.father?.relationshipToChild ?? '',
              // ),

              // Father Preferences
              _buildDetailRow(
                'Preferred Contact Method',
                student
                        .parentInfo
                        ?.father
                        ?.preferences
                        ?.preferredContactMethod ??
                    '',
              ),
              _buildDetailRow(
                'Receive Newsletters',
                student.parentInfo?.father?.preferences?.receiveNewsletters ==
                        true
                    ? 'Yes'
                    : 'No',
              ),
              _buildDetailRow(
                'Receive Event Notifications',
                student
                            .parentInfo
                            ?.father
                            ?.preferences
                            ?.receiveEventNotifications ==
                        true
                    ? 'Yes'
                    : 'No',
              ),
            ],
            // if (student.parentInfo!.mother?.personalInfo != null) ...[
            //   _buildDetailRow(
            //     'Mother Name',
            //     student.parentInfo.mother?.personalInfo.fullName,
            //   ),
            //   _buildDetailRow(
            //     'Mother Phone',
            //     student.parentInfo.mother?.contactInfo.phone,
            //   ),
            //   _buildDetailRow(
            //     'Mother Email',
            //     student.parentInfo.mother?.contactInfo.email,
            //   ),
            // ],
            // if (student.parentInfo.guardian != null) ...[
            //   _buildDetailRow(
            //     'Guardian Name',
            //     student.parentInfo.guardian?.personalInfo.fullName,
            //   ),
            //   _buildDetailRow(
            //     'Guardian Phone',
            //     student.parentInfo.guardian?.contactInfo.phone,
            //   ),
            //   _buildDetailRow(
            //     'Guardian Email',
            //     student.parentInfo.guardian?.contactInfo.email,
            //   ),
            // ],
          ]),

          const SizedBox(height: 20),

          // Medical Information
          _buildDetailSection('Medical Information', Icons.medical_services, [
            _buildDetailRow(
              'General Practitioner Name',
              student.medicalInfo?.generalPractitioner?.name ?? '',
              fieldKey: 'gpName',
            ),
            _buildDetailRow(
              'General Practitioner Address',
              student.medicalInfo?.generalPractitioner?.address ?? '',
              fieldKey: 'gpAddress',
            ),
            _buildDetailRow(
              'General Practitioner Phone',
              student.medicalInfo?.generalPractitioner?.telephoneNumber ?? '',
              fieldKey: 'gpPhone',
            ),
            _buildDetailRow(
              'Emergency Contact Name',
              student.medicalInfo?.emergencyContact?.name ?? '',
              fieldKey: 'emergencyContactName',
            ),
            _buildDetailRow(
              'Emergency Contact Relationship',
              student.medicalInfo?.emergencyContact?.relationship ?? '',
              fieldKey: 'emergencyContactRelationship',
            ),
            _buildDetailRow(
              'Emergency Contact Phone',
              student.medicalInfo?.emergencyContact?.phone ?? '',
              fieldKey: 'emergencyContactPhone',
            ),
            _buildDetailRow(
              'Emergency Contact Email',
              student.medicalInfo?.emergencyContact?.email ?? '',
              fieldKey: 'emergencyContactEmail',
            ),
            _buildDetailRow(
              'Emergency Contact Address',
              '${student.medicalInfo?.emergencyContact?.address?.streetNumber ?? ''} ${student.medicalInfo?.emergencyContact?.address?.streetName ?? ''}, ${student.medicalInfo?.emergencyContact?.address?.city ?? ''}, ${student.medicalInfo?.emergencyContact?.address?.state ?? ''}, ${student.medicalInfo?.emergencyContact?.address?.country ?? ''} ${student.medicalInfo?.emergencyContact?.address?.postalCode ?? ''}',
              fieldKey: 'emergencyContactAddress',
            ),
            _buildDetailRow(
              'Authorized to Collect Child (Emergency)',
              student.medicalInfo?.emergencyContact?.authorisedToCollectChild ==
                      true
                  ? 'Yes'
                  : 'No',
            ),
            _buildDetailRow(
              'Medical History',
              student.medicalInfo?.medicalHistory ?? '',
              fieldKey: 'medicalHistory',
            ),
            _buildDetailRow(
              'Allergies',
              student.medicalInfo?.allergies?.join(', ') ?? '',
              fieldKey: 'allergies',
            ),
            _buildDetailRow(
              'Ongoing Medical Conditions',
              student.medicalInfo?.ongoingMedicalConditions ?? '',
              fieldKey: 'ongoingMedicalConditions',
            ),
            _buildDetailRow(
              'Special Needs',
              student.medicalInfo?.specialNeeds ?? '',
              fieldKey: 'specialNeeds',
            ),
            _buildDetailRow(
              'Current Medication',
              student.medicalInfo?.currentMedication ?? '',
              fieldKey: 'currentMedication',
            ),
            _buildDetailRow(
              'Immunization Record',
              student.medicalInfo?.immunisationRecord ?? '',
              fieldKey: 'immunisationRecord',
            ),
            _buildDetailRow(
              'Dietary Requirements',
              student.medicalInfo?.dietaryRequirements ?? '',
              fieldKey: 'dietaryRequirements',
            ),
          ]),
          const SizedBox(height: 20),

          // SEN (Special Educational Needs) Information
          _buildDetailSection(
            'Special Educational Needs',
            Icons.accessibility,
            [
              _buildBooleanDetailRow(
                'Has Special Needs',
                _hasSpecialNeeds,
                fieldKey: 'hasSpecialNeeds',
              ),
              _buildBooleanDetailRow(
                'Receiving Additional Support',
                _receivingAdditionalSupport,
                fieldKey: 'receivingAdditionalSupport',
              ),
              _buildBooleanDetailRow('Has EHCP', _hasEHCP, fieldKey: 'hasEHCP'),
            ],
          ),
          const SizedBox(height: 20),

          // Permissions
          _buildDetailSection('Permissions', Icons.security, [
            _buildBooleanDetailRow(
              'Emergency Medical Treatment',
              _emergencyMedicalTreatment,
              fieldKey: 'emergencyMedicalTreatment',
            ),
            _buildBooleanDetailRow(
              'Administration of Medication',
              _administrationOfMedication,
              fieldKey: 'administrationOfMedication',
            ),
            _buildBooleanDetailRow(
              'First Aid Consent',
              _firstAidConsent,
              fieldKey: 'firstAidConsent',
            ),
            _buildBooleanDetailRow(
              'Outings and Trips',
              _outingsAndTrips,
              fieldKey: 'outingsAndTrips',
            ),
            _buildBooleanDetailRow(
              'Transport Consent',
              _transportConsent,
              fieldKey: 'transportConsent',
            ),
            _buildBooleanDetailRow(
              'Use of Photos/Videos',
              _useOfPhotosVideos,
              fieldKey: 'useOfPhotosVideos',
            ),
            _buildBooleanDetailRow(
              'Suncream Application',
              _suncreamApplication,
              fieldKey: 'suncreamApplication',
            ),
            _buildBooleanDetailRow(
              'Observation and Assessment',
              _observationAndAssessment,
              fieldKey: 'observationAndAssessment',
            ),
          ]),
          const SizedBox(height: 20),

          // Performance and Attendance Data - Commented out until models are updated
          // _buildDetailSection('Performance & Attendance', Icons.analytics, [
          //   _buildDetailRow(
          //     'Has Performance Data',
          //     student.performanceData?.hasPerformanceData == true
          //         ? 'Yes'
          //         : 'No',
          //   ),
          //   if (student.performanceData?.hasPerformanceData == false)
          //     _buildDetailRow(
          //       'Performance Message',
          //       student.performanceData?.message ?? '',
          //     ),
          //   _buildDetailRow(
          //     'Has Attendance Data',
          //     student.attendanceData?.hasAttendanceData == true ? 'Yes' : 'No',
          //   ),
          //   if (student.attendanceData?.hasAttendanceData == false)
          //     _buildDetailRow(
          //       'Attendance Message',
          //       student.attendanceData?.message ?? '',
          //     ),
          //   if (student.attendanceData?.academicTerm != null)
          //     _buildDetailRow(
          //       'Academic Term',
          //       '${student.attendanceData?.academicTerm?.term ?? ''} - ${student.attendanceData?.academicTerm?.academicYear ?? ''}',
          //     ),
          //   if (student.attendanceData?.classInfo != null)
          //     _buildDetailRow(
          //       'Class Info',
          //       '${student.attendanceData?.classInfo?.name ?? ''} (${student.attendanceData?.classInfo?.level ?? ''})',
          //     ),
          // ]),
          const SizedBox(height: 20),

          // Recent Payments
          Builder(
            builder: (context) {
              final studentState = ref.watch(studentProvider);
              final recentPayments =
                  studentState.studentFullModel.data?.recentPayments ?? [];
              if (recentPayments.isNotEmpty) {
                return _buildDetailSection(
                  'Recent Payments',
                  Icons.payment,
                  recentPayments
                      .map(
                        (payment) => _buildDetailRow(
                          'Payment ${recentPayments.indexOf(payment) + 1}',
                          'Amount: £${payment.amount}, Method: ${payment.method}, Status: ${payment.status}, Date: ${payment.createdAt?.toString() ?? ''}',
                        ),
                      )
                      .toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 20),

          // System Information
          _buildDetailSection('System Information', Icons.info, [
            _buildDetailRow('Student ID', student.id),
            _buildDetailRow(
              'Profile Image',
              student.personalInfo?.profileImage,
              fieldKey: 'profileImage',
            ),
          ]),

          // Edit Mode Action Buttons
          if (_isEditMode) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditMode = false;
                      _clearTextControllers();
                    });
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _saveStudentUpdates(student),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Future<void> _saveStudentUpdates(Student student) async {
    final updates = <String, dynamic>{};

    // Check for changes in personal info
    if (_textControllers['firstName']?.text !=
        (student.personalInfo?.firstName ?? '')) {
      updates['personalInfo.firstName'] =
          _textControllers['firstName']?.text ?? '';
    }
    if (_textControllers['lastName']?.text !=
        (student.personalInfo?.lastName ?? '')) {
      updates['personalInfo.lastName'] =
          _textControllers['lastName']?.text ?? '';
    }
    if (_textControllers['middleName']?.text !=
        (student.personalInfo?.middleName ?? '')) {
      updates['personalInfo.middleName'] =
          _textControllers['middleName']?.text ?? '';
    }
    if (_textControllers['gender']?.text !=
        (student.personalInfo?.gender ?? '')) {
      updates['personalInfo.gender'] = _textControllers['gender']?.text ?? '';
    }
    if (_textControllers['bloodGroup']?.text !=
        (student.personalInfo?.bloodGroup ?? '')) {
      updates['personalInfo.bloodGroup'] =
          _textControllers['bloodGroup']?.text ?? '';
    }
    if (_textControllers['religion']?.text !=
        (student.personalInfo?.religion ?? '')) {
      updates['personalInfo.religion'] =
          _textControllers['religion']?.text ?? '';
    }
    if (_textControllers['nationality']?.text !=
        (student.personalInfo?.nationality ?? '')) {
      updates['personalInfo.nationality'] =
          _textControllers['nationality']?.text ?? '';
    }
    if (_textControllers['stateOfOrigin']?.text !=
        (student.personalInfo?.stateOfOrigin ?? '')) {
      updates['personalInfo.stateOfOrigin'] =
          _textControllers['stateOfOrigin']?.text ?? '';
    }
    if (_textControllers['localGovernment']?.text !=
        (student.personalInfo?.localGovernment ?? '')) {
      updates['personalInfo.localGovernment'] =
          _textControllers['localGovernment']?.text ?? '';
    }
    if (_textControllers['profileImage']?.text !=
        (student.personalInfo?.profileImage ?? '')) {
      updates['personalInfo.profileImage'] =
          _textControllers['profileImage']?.text ?? '';
    }

    // Check for changes in contact info
    if (_textControllers['phone']?.text != (student.contactInfo?.phone ?? '')) {
      updates['contactInfo.phone'] = _textControllers['phone']?.text ?? '';
    }
    if (_textControllers['email']?.text != (student.contactInfo?.email ?? '')) {
      updates['contactInfo.email'] = _textControllers['email']?.text ?? '';
    }

    // Handle address field - parse the combined address string
    final addressText = _textControllers['address']?.text ?? '';
    final currentAddress =
        '${student.contactInfo?.address?.street ?? ''}, ${student.contactInfo?.address?.city ?? ''}, ${student.contactInfo?.address?.state ?? ''}';

    print('🔍 DEBUG: Address field update check');
    print('🔍 DEBUG: addressText: "$addressText"');
    print('🔍 DEBUG: currentAddress: "$currentAddress"');
    print(
      '🔍 DEBUG: addressText != currentAddress: ${addressText != currentAddress}',
    );

    if (addressText != currentAddress) {
      // Parse the address string into components
      final addressParts =
          addressText.split(',').map((part) => part.trim()).toList();

      print('🔍 DEBUG: addressParts: $addressParts');

      if (addressParts.isNotEmpty) {
        updates['contactInfo.address.street'] = addressParts[0];
        print('🔍 DEBUG: Setting street: ${addressParts[0]}');
      }
      if (addressParts.length > 1) {
        updates['contactInfo.address.city'] = addressParts[1];
        print('🔍 DEBUG: Setting city: ${addressParts[1]}');
      }
      if (addressParts.length > 2) {
        updates['contactInfo.address.state'] = addressParts[2];
        print('🔍 DEBUG: Setting state: ${addressParts[2]}');
      }
    }

    // Check for changes in academic info
    if (_textControllers['admissionNumber']?.text !=
        (student.admissionNumber ?? '')) {
      updates['admissionNumber'] =
          _textControllers['admissionNumber']?.text ?? '';
    }

    // Check for changes in additional personal info - Commented out until models are updated
    // if (_textControllers['languagesSpokenAtHome']?.text !=
    //     (student.personalInfo?.languagesSpokenAtHome ?? '')) {
    //   updates['personalInfo.languagesSpokenAtHome'] =
    //       _textControllers['languagesSpokenAtHome']?.text ?? '';
    // }
    // if (_textControllers['ethnicBackground']?.text !=
    //     (student.personalInfo?.ethnicBackground ?? '')) {
    //   updates['personalInfo.ethnicBackground'] =
    //       _textControllers['ethnicBackground']?.text ?? '';
    // }
    // if (_textControllers['formOfIdentification']?.text !=
    //     (student.personalInfo?.formOfIdentification ?? '')) {
    //   updates['personalInfo.formOfIdentification'] =
    //       _textControllers['formOfIdentification']?.text ?? '';
    // }
    // if (_textControllers['idNumber']?.text !=
    //     (student.personalInfo?.idNumber ?? '')) {
    //   updates['personalInfo.idNumber'] =
    //       _textControllers['idNumber']?.text ?? '';
    // }

    // Check for changes in address components - Commented out until models are updated
    // if (_textControllers['streetNumber']?.text !=
    //     (student.contactInfo?.address?.streetNumber ?? '')) {
    //   updates['contactInfo.address.streetNumber'] =
    //       _textControllers['streetNumber']?.text ?? '';
    // }
    // if (_textControllers['streetName']?.text !=
    //     (student.contactInfo?.address?.streetName ?? '')) {
    //   updates['contactInfo.address.streetName'] =
    //       _textControllers['streetName']?.text ?? '';
    // }
    // if (_textControllers['city']?.text !=
    //     (student.contactInfo?.address?.city ?? '')) {
    //   updates['contactInfo.address.city'] =
    //       _textControllers['city']?.text ?? '';
    // }
    // if (_textControllers['state']?.text !=
    //     (student.contactInfo?.address?.state ?? '')) {
    //   updates['contactInfo.address.state'] =
    //       _textControllers['state']?.text ?? '';
    // }
    // if (_textControllers['country']?.text !=
    //     (student.contactInfo?.address?.country ?? '')) {
    //   updates['contactInfo.address.country'] =
    //       _textControllers['country']?.text ?? '';
    // }
    // if (_textControllers['postalCode']?.text !=
    //     (student.contactInfo?.address?.postalCode ?? '')) {
    //   updates['contactInfo.address.postalCode'] =
    //       _textControllers['postalCode']?.text ?? '';
    // }

    // Check for changes in medical info - Commented out until models are updated
    // if (_textControllers['gpName']?.text !=
    //     (student.medicalInfo?.generalPractitioner?.name ?? '')) {
    //   updates['medicalInfo.generalPractitioner.name'] =
    //       _textControllers['gpName']?.text ?? '';
    // }
    // if (_textControllers['gpAddress']?.text !=
    //     (student.medicalInfo?.generalPractitioner?.address ?? '')) {
    //   updates['medicalInfo.generalPractitioner.address'] =
    //       _textControllers['gpAddress']?.text ?? '';
    // }
    // if (_textControllers['gpPhone']?.text !=
    //     (student.medicalInfo?.generalPractitioner?.telephoneNumber ?? '')) {
    //   updates['medicalInfo.generalPractitioner.telephoneNumber'] =
    //       _textControllers['gpPhone']?.text ?? '';
    // }
    // if (_textControllers['emergencyContactName']?.text !=
    //     (student.medicalInfo?.emergencyContact?.name ?? '')) {
    //   updates['medicalInfo.emergencyContact.name'] =
    //       _textControllers['emergencyContactName']?.text ?? '';
    // }
    // if (_textControllers['emergencyContactRelationship']?.text !=
    //     (student.medicalInfo?.emergencyContact?.relationship ?? '')) {
    //   updates['medicalInfo.emergencyContact.relationship'] =
    //       _textControllers['emergencyContactRelationship']?.text ?? '';
    // }
    // if (_textControllers['emergencyContactPhone']?.text !=
    //     (student.medicalInfo?.emergencyContact?.phone ?? '')) {
    //   updates['medicalInfo.emergencyContact.phone'] =
    //       _textControllers['emergencyContactPhone']?.text ?? '';
    // }
    // if (_textControllers['emergencyContactEmail']?.text !=
    //     (student.medicalInfo?.emergencyContact?.email ?? '')) {
    //   updates['medicalInfo.emergencyContact.email'] =
    //       _textControllers['emergencyContactEmail']?.text ?? '';
    // }
    // if (_textControllers['medicalHistory']?.text !=
    //     (student.medicalInfo?.medicalHistory ?? '')) {
    //   updates['medicalInfo.medicalHistory'] =
    //       _textControllers['medicalHistory']?.text ?? '';
    // }
    // if (_textControllers['allergies']?.text !=
    //     (student.medicalInfo?.allergies?.join(', ') ?? '')) {
    //   updates['medicalInfo.allergies'] =
    //       _textControllers['allergies']?.text
    //           ?.split(', ')
    //           .where((allergy) => allergy.isNotEmpty)
    //           .toList() ??
    //       [];
    // }
    // if (_textControllers['ongoingMedicalConditions']?.text !=
    //     (student.medicalInfo?.ongoingMedicalConditions ?? '')) {
    //   updates['medicalInfo.ongoingMedicalConditions'] =
    //       _textControllers['ongoingMedicalConditions']?.text ?? '';
    // }
    // if (_textControllers['specialNeeds']?.text !=
    //     (student.medicalInfo?.specialNeeds ?? '')) {
    //   updates['medicalInfo.specialNeeds'] =
    //       _textControllers['specialNeeds']?.text ?? '';
    // }
    // if (_textControllers['currentMedication']?.text !=
    //     (student.medicalInfo?.currentMedication ?? '')) {
    //   updates['medicalInfo.currentMedication'] =
    //       _textControllers['currentMedication']?.text ?? '';
    // }
    // if (_textControllers['immunisationRecord']?.text !=
    //     (student.medicalInfo?.immunisationRecord ?? '')) {
    //   updates['medicalInfo.immunisationRecord'] =
    //       _textControllers['immunisationRecord']?.text ?? '';
    // }
    // if (_textControllers['dietaryRequirements']?.text !=
    //     (student.medicalInfo?.dietaryRequirements ?? '')) {
    //   updates['medicalInfo.dietaryRequirements'] =
    //       _textControllers['dietaryRequirements']?.text ?? '';
    // }

    // Check for changes in parent/guardian info
    if (student.parentInfo?.father != null) {
      final currentFatherName =
          '${student.parentInfo!.father!.personalInfo!.firstName ?? ''} ${student.parentInfo!.father!.personalInfo!.lastName ?? ''}'
              .trim();
      if (_textControllers['fatherName']?.text != currentFatherName) {
        // Parse father name into first and last name
        final fatherNameParts = (_textControllers['fatherName']?.text ?? '')
            .split(' ');
        if (fatherNameParts.isNotEmpty) {
          updates['parentInfo.father.personalInfo.firstName'] =
              fatherNameParts[0];
        }
        if (fatherNameParts.length > 1) {
          updates['parentInfo.father.personalInfo.lastName'] = fatherNameParts
              .sublist(1)
              .join(' ');
        }
      }

      if (_textControllers['fatherTitle']?.text !=
          (student.parentInfo!.father!.personalInfo?.title ?? '')) {
        updates['parentInfo.father.personalInfo.title'] =
            _textControllers['fatherTitle']?.text ?? '';
      }
      if (_textControllers['fatherMiddleName']?.text !=
          (student.parentInfo!.father!.personalInfo?.middleName ?? '')) {
        updates['parentInfo.father.personalInfo.middleName'] =
            _textControllers['fatherMiddleName']?.text ?? '';
      }
      if (_textControllers['fatherGender']?.text !=
          (student.parentInfo!.father!.personalInfo?.gender ?? '')) {
        updates['parentInfo.father.personalInfo.gender'] =
            _textControllers['fatherGender']?.text ?? '';
      }
      if (_textControllers['fatherMaritalStatus']?.text !=
          (student.parentInfo!.father!.personalInfo?.maritalStatus ?? '')) {
        updates['parentInfo.father.personalInfo.maritalStatus'] =
            _textControllers['fatherMaritalStatus']?.text ?? '';
      }
      if (_textControllers['fatherPhone']?.text !=
          (student.parentInfo!.father!.contactInfo?.primaryPhone ?? '')) {
        updates['parentInfo.father.contactInfo.primaryPhone'] =
            _textControllers['fatherPhone']?.text ?? '';
      }
      // if (_textControllers['fatherSecondaryPhone']?.text !=
      //     (student.parentInfo!.father!.contactInfo?.secondaryPhone ?? '')) {
      //   updates['parentInfo.father.contactInfo.secondaryPhone'] =
      //       _textControllers['fatherSecondaryPhone']?.text ?? '';
      // }
      if (_textControllers['fatherEmail']?.text !=
          (student.parentInfo!.father!.contactInfo?.email ?? '')) {
        updates['parentInfo.father.contactInfo.email'] =
            _textControllers['fatherEmail']?.text ?? '';
      }
      if (_textControllers['fatherOccupation']?.text !=
          (student.parentInfo!.father!.professionalInfo?.occupation ?? '')) {
        updates['parentInfo.father.professionalInfo.occupation'] =
            _textControllers['fatherOccupation']?.text ?? '';
      }
      if (_textControllers['fatherEmployer']?.text !=
          (student.parentInfo!.father!.professionalInfo?.employer ?? '')) {
        updates['parentInfo.father.professionalInfo.employer'] =
            _textControllers['fatherEmployer']?.text ?? '';
      }
      // if (_textControllers['fatherWorkPhone']?.text !=
      //     (student.parentInfo!.father!.professionalInfo?.workPhone ?? '')) {
      //   updates['parentInfo.father.professionalInfo.workPhone'] =
      //       _textControllers['fatherWorkPhone']?.text ?? '';
      // }
      if (_textControllers['fatherAnnualIncome']?.text !=
          (student.parentInfo!.father!.professionalInfo?.annualIncome
                  ?.toString() ??
              '')) {
        updates['parentInfo.father.professionalInfo.annualIncome'] =
            int.tryParse(_textControllers['fatherAnnualIncome']?.text ?? '0') ??
            0;
      }
      // if (_textControllers['fatherIdType']?.text !=
      //     (student.parentInfo!.father!.identification?.idType ?? '')) {
      //   updates['parentInfo.father.identification.idType'] =
      //       _textControllers['fatherIdType']?.text ?? '';
      // }
      // if (_textControllers['fatherIdNumber']?.text !=
      //     (student.parentInfo!.father!.identification?.idNumber ?? '')) {
      //   updates['parentInfo.father.identification.idNumber'] =
      //       _textControllers['fatherIdNumber']?.text ?? '';
      // }
    }

    // Check for changes in SEN info
    if (_hasSpecialNeeds != student.senInfo?.hasSpecialNeeds) {
      updates['senInfo.hasSpecialNeeds'] = _hasSpecialNeeds;
      print('🔍 DEBUG: SEN hasSpecialNeeds changed to: $_hasSpecialNeeds');
    }
    if (_receivingAdditionalSupport !=
        student.senInfo?.receivingAdditionalSupport) {
      updates['senInfo.receivingAdditionalSupport'] =
          _receivingAdditionalSupport;
      print(
        '🔍 DEBUG: SEN receivingAdditionalSupport changed to: $_receivingAdditionalSupport',
      );
    }
    if (_hasEHCP != student.senInfo?.hasEHCP) {
      updates['senInfo.hasEHCP'] = _hasEHCP;
      print('🔍 DEBUG: SEN hasEHCP changed to: $_hasEHCP');
    }

    // Check for changes in permissions
    if (_emergencyMedicalTreatment !=
        student.permissions?.emergencyMedicalTreatment) {
      updates['permissions.emergencyMedicalTreatment'] =
          _emergencyMedicalTreatment;
      print(
        '🔍 DEBUG: Permissions emergencyMedicalTreatment changed to: $_emergencyMedicalTreatment',
      );
    }
    if (_administrationOfMedication !=
        student.permissions?.administrationOfMedication) {
      updates['permissions.administrationOfMedication'] =
          _administrationOfMedication;
      print(
        '🔍 DEBUG: Permissions administrationOfMedication changed to: $_administrationOfMedication',
      );
    }
    if (_firstAidConsent != student.permissions?.firstAidConsent) {
      updates['permissions.firstAidConsent'] = _firstAidConsent;
      print(
        '🔍 DEBUG: Permissions firstAidConsent changed to: $_firstAidConsent',
      );
    }
    if (_outingsAndTrips != student.permissions?.outingsAndTrips) {
      updates['permissions.outingsAndTrips'] = _outingsAndTrips;
      print(
        '🔍 DEBUG: Permissions outingsAndTrips changed to: $_outingsAndTrips',
      );
    }
    if (_transportConsent != student.permissions?.transportConsent) {
      updates['permissions.transportConsent'] = _transportConsent;
      print(
        '🔍 DEBUG: Permissions transportConsent changed to: $_transportConsent',
      );
    }
    if (_useOfPhotosVideos != student.permissions?.useOfPhotosVideos) {
      updates['permissions.useOfPhotosVideos'] = _useOfPhotosVideos;
      print(
        '🔍 DEBUG: Permissions useOfPhotosVideos changed to: $_useOfPhotosVideos',
      );
    }
    if (_suncreamApplication != student.permissions?.suncreamApplication) {
      updates['permissions.suncreamApplication'] = _suncreamApplication;
      print(
        '🔍 DEBUG: Permissions suncreamApplication changed to: $_suncreamApplication',
      );
    }
    if (_observationAndAssessment !=
        student.permissions?.observationAndAssessment) {
      updates['permissions.observationAndAssessment'] =
          _observationAndAssessment;
      print(
        '🔍 DEBUG: Permissions observationAndAssessment changed to: $_observationAndAssessment',
      );
    }

    // Parse date of birth
    final dateOfBirthText = _textControllers['dateOfBirth']?.text ?? '';
    if (dateOfBirthText.isNotEmpty &&
        dateOfBirthText !=
            (student.personalInfo?.dateOfBirth?.toIso8601String().split(
                  'T',
                )[0] ??
                '')) {
      try {
        updates['personalInfo.dateOfBirth'] =
            DateTime.parse(dateOfBirthText).toIso8601String();
      } catch (e) {
        // Invalid date format - show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid date format. Please use YYYY-MM-DD format.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (updates.isEmpty) {
      setState(() {
        _isEditMode = false;
        _clearTextControllers();
      });
      return;
    }

    // Debug logging to show what's being sent to backend
    print('🔍 DEBUG: Complete updates object being sent to backend: $updates');
    print('🔍 DEBUG: Updates count: ${updates.length}');

    try {
      final success = await ref
          .read(studentProvider.notifier)
          .updateStudent(context, widget.studentId, updates);

      if (success) {
        setState(() {
          _isEditMode = false;
          _clearTextControllers();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh student data
        await _loadStudent();

        // Return success result to trigger reload in all students screen
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update student. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBooleanDetailRow(String label, bool? value, {String? fieldKey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child:
                _isEditMode && fieldKey != null
                    ? Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Radio<bool>(
                                value: true,
                                groupValue: value,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    switch (fieldKey) {
                                      case 'hasSpecialNeeds':
                                        _hasSpecialNeeds = true;
                                        break;
                                      case 'receivingAdditionalSupport':
                                        _receivingAdditionalSupport = true;
                                        break;
                                      case 'hasEHCP':
                                        _hasEHCP = true;
                                        break;
                                      case 'emergencyMedicalTreatment':
                                        _emergencyMedicalTreatment = true;
                                        break;
                                      case 'administrationOfMedication':
                                        _administrationOfMedication = true;
                                        break;
                                      case 'firstAidConsent':
                                        _firstAidConsent = true;
                                        break;
                                      case 'outingsAndTrips':
                                        _outingsAndTrips = true;
                                        break;
                                      case 'transportConsent':
                                        _transportConsent = true;
                                        break;
                                      case 'useOfPhotosVideos':
                                        _useOfPhotosVideos = true;
                                        break;
                                      case 'suncreamApplication':
                                        _suncreamApplication = true;
                                        break;
                                      case 'observationAndAssessment':
                                        _observationAndAssessment = true;
                                        break;
                                    }
                                  });
                                },
                                activeColor: Colors.blue,
                              ),
                              const Text('Yes', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Radio<bool>(
                                value: false,
                                groupValue: value,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    switch (fieldKey) {
                                      case 'hasSpecialNeeds':
                                        _hasSpecialNeeds = false;
                                        break;
                                      case 'receivingAdditionalSupport':
                                        _receivingAdditionalSupport = false;
                                        break;
                                      case 'hasEHCP':
                                        _hasEHCP = false;
                                        break;
                                      case 'emergencyMedicalTreatment':
                                        _emergencyMedicalTreatment = false;
                                        break;
                                      case 'administrationOfMedication':
                                        _administrationOfMedication = false;
                                        break;
                                      case 'firstAidConsent':
                                        _firstAidConsent = false;
                                        break;
                                      case 'outingsAndTrips':
                                        _outingsAndTrips = false;
                                        break;
                                      case 'transportConsent':
                                        _transportConsent = false;
                                        break;
                                      case 'useOfPhotosVideos':
                                        _useOfPhotosVideos = false;
                                        break;
                                      case 'suncreamApplication':
                                        _suncreamApplication = false;
                                        break;
                                      case 'observationAndAssessment':
                                        _observationAndAssessment = false;
                                        break;
                                    }
                                  });
                                },
                                activeColor: Colors.blue,
                              ),
                              const Text('No', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    )
                    : Text(
                      value == true ? 'Yes' : 'No',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, {String? fieldKey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child:
                _isEditMode &&
                        fieldKey != null &&
                        _textControllers.containsKey(fieldKey)
                    ? TextField(
                      controller: _textControllers[fieldKey],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                    : Text(
                      value ?? 'Not specified',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
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
            '£${student?.financialInfo?.totalFees ?? 0}',
            'Total',
            Colors.blue,
          ),
          _buildPaymentItem(
            'Paid Amount',
            '£${student?.financialInfo?.paidAmount ?? 0}',
            'Paid',
            Colors.green,
          ),
          _buildPaymentItem(
            'Outstanding',
            '£${student?.financialInfo?.outstandingBalance ?? 0}',
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

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey[100] : null,
      ),
    );
  }
}
