import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';

class StudentRegistrationPage extends StatefulWidget {
  final Function navigateTo;
  const StudentRegistrationPage({Key? key, required this.navigateTo})
    : super(key: key);

  @override
  State<StudentRegistrationPage> createState() =>
      _StudentRegistrationPageState();
}

class _StudentRegistrationPageState extends State<StudentRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _healthNotesController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _occupationController = TextEditingController();
  final _homeAddressController = TextEditingController();
  final _admissionNumberController = TextEditingController();

  // Selected values
  String? _selectedGender;
  String? _selectedNationality;
  String? _selectedAcademicYear = '2024-2025';
  String? _selectedCurrentClass;
  String? _selectedClassArm;
  String? _selectedRelationship;
  String? _selectedStudentType = 'Day';
  DateTime? _selectedDOB;
  DateTime? _selectedAdmissionDate;
  bool _transportNeeded = false;
  bool _scholarshipAwarded = false;

  final List<String> _genders = ['Male', 'Female'];
  final List<String> _nationalities = [
    'Nigerian',
    'American',
    'British',
    'Canadian',
    'Other',
  ];
  final List<String> _classes = [
    'JSS 1',
    'JSS 2',
    'JSS 3',
    'SS 1',
    'SS 2',
    'SS 3',
  ];
  final List<String> _classArms = ['A', 'B', 'C', 'D'];
  final List<String> _relationships = [
    'Father',
    'Mother',
    'Guardian',
    'Uncle',
    'Aunt',
    'Sibling',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _healthNotesController.dispose();
    _parentNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _occupationController.dispose();
    _homeAddressController.dispose();
    _admissionNumberController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            widget.navigateTo();
          },
        ),
        title: const Text(
          'Register New Student',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Student Info', Icons.person),
                _buildStepConnector(),
                _buildStepIndicator(1, 'Class Assignment', Icons.school),
                _buildStepConnector(),
                _buildStepIndicator(2, 'Parent Info', Icons.family_restroom),
                _buildStepConnector(),
                _buildStepIndicator(3, 'Final Details', Icons.check_circle),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildStudentInfoStep(),
                _buildClassAssignmentStep(),
                _buildParentInfoStep(),
                _buildFinalDetailsStep(),
              ],
            ),
          ),

          // Bottom buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep < 3 ? _nextStep : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentStep < 3 ? 'Next' : 'Save & Register',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title, IconData icon) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  isCompleted
                      ? Colors.green
                      : isActive
                      ? const Color(0xFF6366F1)
                      : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isCompleted || isActive ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? const Color(0xFF6366F1) : Colors.grey[600],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector() {
    return Container(
      height: 2,
      width: 20,
      color: Colors.grey[300],
      margin: const EdgeInsets.only(bottom: 24),
    );
  }

  Widget _buildStudentInfoStep() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Student Biodata',
              'Basic information about the student',
            ),
            const SizedBox(height: 24),

            // Photo upload section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Click to upload photo',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Text(
                    'JPG, PNG up to 2MB',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Name fields
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    hint: 'Enter first name',
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    hint: 'Enter last name',
                    isRequired: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _middleNameController,
                    label: 'Middle Name',
                    hint: 'Enter middle name',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Gender',
                    value: _selectedGender,
                    items: _genders,
                    hint: 'Select gender',
                    isRequired: true,
                    onChanged:
                        (value) => setState(() => _selectedGender = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    controller: _dobController,
                    label: 'Date of Birth',
                    hint: 'mm/dd/yyyy',
                    isRequired: true,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _admissionNumberController,
                    label: 'Admission Number',
                    hint: 'Auto-generated',
                    enabled: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildDropdownField(
              label: 'Nationality',
              value: _selectedNationality,
              items: _nationalities,
              hint: 'Select nationality',
              isRequired: true,
              onChanged:
                  (value) => setState(() => _selectedNationality = value),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _addressController,
              label: 'Address',
              hint: 'Enter student address',
              isRequired: true,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _healthNotesController,
              label: 'Health Notes',
              hint: 'Any medical conditions or allergies',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassAssignmentStep() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Class Assignment',
              'Academic placement and enrollment details',
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: 'Academic Year',
                    value: _selectedAcademicYear,
                    items: ['2024-2025', '2025-2026'],
                    hint: 'Select year',
                    isRequired: true,
                    onChanged:
                        (value) =>
                            setState(() => _selectedAcademicYear = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Current Class',
                    value: _selectedCurrentClass,
                    items: _classes,
                    hint: 'Select class',
                    isRequired: true,
                    onChanged:
                        (value) =>
                            setState(() => _selectedCurrentClass = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: 'Class Arm',
                    value: _selectedClassArm,
                    items: _classArms,
                    hint: 'Select arm',
                    onChanged:
                        (value) => setState(() => _selectedClassArm = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    controller: TextEditingController(),
                    label: 'Admission Date',
                    hint: 'mm/dd/yyyy',
                    isRequired: true,
                    onTap: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentInfoStep() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Parent/Guardian Information',
              'Contact details for student\'s guardian',
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _parentNameController,
                    label: 'Full Name',
                    hint: 'Enter parent/guardian name',
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Relationship',
                    value: _selectedRelationship,
                    items: _relationships,
                    hint: 'Select relationship',
                    isRequired: true,
                    onChanged:
                        (value) =>
                            setState(() => _selectedRelationship = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: '+234 XXX XXX XXXX',
                    isRequired: true,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'parent@email.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _occupationController,
              label: 'Occupation',
              hint: 'Enter occupation',
            ),
            const SizedBox(height: 16),

            // ID Upload section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ID Upload',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.upload_file, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Upload ID or Passport',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _homeAddressController,
              label: 'Home Address',
              hint: 'Enter home address',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalDetailsStep() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Additional Details',
              'Transport, boarding and scholarship information',
            ),
            const SizedBox(height: 24),

            // Transport needed
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transport Needed?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: _transportNeeded,
                            onChanged:
                                (value) =>
                                    setState(() => _transportNeeded = value!),
                          ),
                          const Text('Yes'),
                          const SizedBox(width: 16),
                          Radio<bool>(
                            value: false,
                            groupValue: _transportNeeded,
                            onChanged:
                                (value) =>
                                    setState(() => _transportNeeded = value!),
                          ),
                          const Text('No'),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Student Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Day',
                            groupValue: _selectedStudentType,
                            onChanged:
                                (value) => setState(
                                  () => _selectedStudentType = value,
                                ),
                          ),
                          const Text('Day'),
                          const SizedBox(width: 16),
                          Radio<String>(
                            value: 'Boarding',
                            groupValue: _selectedStudentType,
                            onChanged:
                                (value) => setState(
                                  () => _selectedStudentType = value,
                                ),
                          ),
                          const Text('Boarding'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Scholarship awarded
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scholarship Awarded?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _scholarshipAwarded,
                      onChanged:
                          (value) =>
                              setState(() => _scholarshipAwarded = value!),
                    ),
                    const Text('Yes'),
                    const SizedBox(width: 16),
                    Radio<bool>(
                      value: false,
                      groupValue: _scholarshipAwarded,
                      onChanged:
                          (value) =>
                              setState(() => _scholarshipAwarded = value!),
                    ),
                    const Text('No'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            children: [
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
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
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
            filled: !enabled,
            fillColor: enabled ? null : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    bool isRequired = false,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            children: [
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
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
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items:
              items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            children: [
              if (isRequired)
                const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
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
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isDOB) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: isDOB ? DateTime(1900) : DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isDOB) {
          _selectedDOB = picked;
          _dobController.text =
              '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
        } else {
          _selectedAdmissionDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    // if (_formKey.currentState?.validate() ?? false) {
    // Handle form submission

    showSnackbar(context, 'Student registered successfully!');

    // Navigate back or to success page
    // Navigator.pop(context);
    // }
  }
}
