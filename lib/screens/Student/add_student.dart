import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/providers/student_provider.dart';
import 'package:schmgtsystem/models/class_metrics_model.dart';
import 'package:schmgtsystem/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentRegistrationPage extends ConsumerStatefulWidget {
  const StudentRegistrationPage({super.key});

  @override
  ConsumerState<StudentRegistrationPage> createState() =>
      _StudentRegistrationPageState();
}

class _StudentRegistrationPageState
    extends ConsumerState<StudentRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  int _currentStep = 0;
  bool _isLoading = false;
  bool _isLoadingClasses = false;
  List<Class> _classes = [];
  String? _selectedClassId;

  // Image upload variables
  XFile? _selectedImageFile; // Use XFile instead of File for web compatibility
  String? _imageUrl;
  bool _isUploadingImage = false;
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers - Student Personal Info
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _emergencyContactRelationshipController = TextEditingController();

  // Parent controllers - Father
  final _fatherTitleController = TextEditingController();
  final _fatherFirstNameController = TextEditingController();
  final _fatherLastNameController = TextEditingController();
  final _fatherMiddleNameController = TextEditingController();
  final _fatherDobController = TextEditingController();
  final _fatherPhoneController = TextEditingController();
  final _fatherEmailController = TextEditingController();
  final _fatherOccupationController = TextEditingController();
  final _fatherEmployerController = TextEditingController();
  final _fatherIncomeController = TextEditingController();
  final _fatherWorkPhoneController = TextEditingController();
  final _fatherWorkStreetController = TextEditingController();
  final _fatherWorkCityController = TextEditingController();
  final _fatherWorkStateController = TextEditingController();
  final _fatherWorkCountryController = TextEditingController();

  // Parent controllers - Mother
  final _motherTitleController = TextEditingController();
  final _motherFirstNameController = TextEditingController();
  final _motherLastNameController = TextEditingController();
  final _motherMiddleNameController = TextEditingController();
  final _motherDobController = TextEditingController();
  final _motherPhoneController = TextEditingController();
  final _motherEmailController = TextEditingController();
  final _motherOccupationController = TextEditingController();
  final _motherEmployerController = TextEditingController();
  final _motherIncomeController = TextEditingController();

  // Selected values
  String? _selectedGender;
  String? _selectedNationality;
  String? _selectedAcademicYear = '2025/2026';
  String? _selectedStudentType = 'day';
  String? _selectedReligion;
  String? _selectedBloodGroup;
  String? _selectedStateOfOrigin;
  String? _selectedLocalGovernment;
  String? _selectedFatherGender = 'male';
  String? _selectedMotherGender = 'female';
  String? _selectedFatherMaritalStatus;
  String? _selectedMotherMaritalStatus;
  DateTime? _selectedDOB;
  DateTime? _selectedAdmissionDate;
  DateTime? _selectedFatherDOB;
  DateTime? _selectedMotherDOB;

  final List<String> _genders = ['male', 'female'];
  final List<String> _nationalities = [
    'Nigerian',
    'American',
    'British',
    'Canadian',
    'Ghanaian',
    'Other',
  ];
  final List<String> _religions = [
    'Christian',
    'Muslim',
    'Traditional',
    'Other',
  ];
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  final List<String> _states = [
    'Lagos',
    'Abuja',
    'Kano',
    'Rivers',
    'Ogun',
    'Kaduna',
    'Other',
  ];
  final List<String> _localGovernments = [
    'Ikeja',
    'Victoria Island',
    'Lekki',
    'Surulere',
    'Other',
  ];
  final List<String> _academicYears = [
    '2024/2025',
    '2025/2026',
    '2026/2027',
    '2027/2028',
  ];
  final List<String> _studentTypes = ['day', 'boarding'];
  final List<String> _titles = ['Mr', 'Mrs', 'Ms', 'Dr', 'Prof'];
  final List<String> _maritalStatuses = [
    'single',
    'married',
    'divorced',
    'widowed',
  ];
  ClassMetricModel _classData = ClassMetricModel();
  @override
  void initState() {
    super.initState();
    _countryController.text = 'Nigeria';
    _fatherTitleController.text = 'Mr';
    _motherTitleController.text = 'Mrs';
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoadingClasses = true;
    });

    try {
      _classData = await ref
          .read(RiverpodProvider.classProvider)
          .getAllClassesWithMetric(context);

      if (!mounted) return;

      if (_classData.classes != null && _classData.classes!.isNotEmpty) {
        setState(() {
          _classes = _classData.classes!;
          _isLoadingClasses = false;
        });
      } else {
        setState(() {
          _isLoadingClasses = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No classes found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingClasses = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading classes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Student controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _dobController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _medicalConditionsController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _emergencyContactRelationshipController.dispose();

    // Father controllers
    _fatherTitleController.dispose();
    _fatherFirstNameController.dispose();
    _fatherLastNameController.dispose();
    _fatherMiddleNameController.dispose();
    _fatherDobController.dispose();
    _fatherPhoneController.dispose();
    _fatherEmailController.dispose();
    _fatherOccupationController.dispose();
    _fatherEmployerController.dispose();
    _fatherIncomeController.dispose();
    _fatherWorkPhoneController.dispose();
    _fatherWorkStreetController.dispose();
    _fatherWorkCityController.dispose();
    _fatherWorkStateController.dispose();
    _fatherWorkCountryController.dispose();

    // Mother controllers
    _motherTitleController.dispose();
    _motherFirstNameController.dispose();
    _motherLastNameController.dispose();
    _motherMiddleNameController.dispose();
    _motherDobController.dispose();
    _motherPhoneController.dispose();
    _motherEmailController.dispose();
    _motherOccupationController.dispose();
    _motherEmployerController.dispose();
    _motherIncomeController.dispose();

    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Student Registration'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / 5,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6366F1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Step ${_currentStep + 1} of 5',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ),

            // Form pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildPersonalInfoStep(),
                  _buildContactInfoStep(),
                  _buildAcademicInfoStep(),
                  _buildFatherInfoStep(),
                  _buildMotherInfoStep(),
                ],
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleNextOrSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                _currentStep == 4 ? 'Submit' : 'Next',
                                style: const TextStyle(color: Colors.white),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the student\'s personal details',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Profile Image Upload Section
          _buildImageUploadSection(),
          const SizedBox(height: 32),

          // Name fields
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _middleNameController,
                  label: 'Middle Name',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _lastNameController,
            label: 'Last Name',
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Date of Birth
          _buildTextField(
            controller: _dobController,
            label: 'Date of Birth',
            isRequired: true,
            readOnly: true,
            onTap: () => _selectDate(context, true),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          const SizedBox(height: 16),

          // Gender and Nationality
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Gender',
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Nationality',
                  value: _selectedNationality,
                  items: _nationalities,
                  onChanged: (value) {
                    setState(() {
                      _selectedNationality = value;
                    });
                  },
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Religion and Blood Group
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Religion',
                  value: _selectedReligion,
                  items: _religions,
                  onChanged: (value) {
                    setState(() {
                      _selectedReligion = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Blood Group',
                  value: _selectedBloodGroup,
                  items: _bloodGroups,
                  onChanged: (value) {
                    setState(() {
                      _selectedBloodGroup = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // State and LGA
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'State of Origin',
                  value: _selectedStateOfOrigin,
                  items: _states,
                  onChanged: (value) {
                    setState(() {
                      _selectedStateOfOrigin = value;
                    });
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Local Government',
                  value: _selectedLocalGovernment,
                  items: _localGovernments,
                  onChanged: (value) {
                    setState(() {
                      _selectedLocalGovernment = value;
                    });
                  },
                  isRequired: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the student\'s contact details',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Address fields
          _buildTextField(
            controller: _streetController,
            label: 'Street Address',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: 'State',
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
                  controller: _countryController,
                  label: 'Country',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Academic Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the student\'s academic details',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Academic Year and Class
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Academic Year',
                  value: _selectedAcademicYear,
                  items: _academicYears,
                  onChanged: (value) {
                    setState(() {
                      _selectedAcademicYear = value;
                    });
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildClassDropdown()),
            ],
          ),
          const SizedBox(height: 16),

          // Student Type and Admission Date
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Student Type',
                  value: _selectedStudentType,
                  items: _studentTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedStudentType = value;
                    });
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admission Date *',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: TextEditingController(
                        text:
                            _selectedAdmissionDate != null
                                ? '${_selectedAdmissionDate!.day}/${_selectedAdmissionDate!.month}/${_selectedAdmissionDate!.year}'
                                : '',
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, 'admission'),
                      decoration: InputDecoration(
                        hintText: 'Select admission date',
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                _selectedAdmissionDate == null
                                    ? Colors.red
                                    : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                _selectedAdmissionDate == null
                                    ? Colors.red
                                    : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                _selectedAdmissionDate == null
                                    ? Colors.red
                                    : const Color(0xFF6366F1),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (_selectedAdmissionDate == null) {
                          return 'Admission date is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Medical Information
          const Text(
            'Medical Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _allergiesController,
            label: 'Allergies (comma separated)',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _medicationsController,
            label: 'Medications (comma separated)',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _medicalConditionsController,
            label: 'Medical Conditions (comma separated)',
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Emergency Contact
          const Text(
            'Emergency Contact',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _emergencyContactNameController,
                  label: 'Emergency Contact Name',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _emergencyContactRelationshipController,
                  label: 'Relationship',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emergencyContactPhoneController,
            label: 'Emergency Contact Phone',
            keyboardType: TextInputType.phone,
            isRequired: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFatherInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Father\'s Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the father\'s details',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Title and Name
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Title',
                  value: _fatherTitleController.text,
                  items: _titles,
                  onChanged: (value) {
                    setState(() {
                      _fatherTitleController.text = value!;
                    });
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _fatherFirstNameController,
                  label: 'First Name',
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
                  controller: _fatherMiddleNameController,
                  label: 'Middle Name',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _fatherLastNameController,
                  label: 'Last Name',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date of Birth and Gender
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fatherDobController,
                  label: 'Date of Birth',
                  readOnly: true,
                  onTap: () => _selectDate(context, 'father'),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Gender',
                  value: _selectedFatherGender,
                  items: _genders,
                  onChanged: (value) {
                    setState(() {
                      _selectedFatherGender = value;
                    });
                  },
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Marital Status
          _buildDropdown(
            label: 'Marital Status',
            value: _selectedFatherMaritalStatus,
            items: _maritalStatuses,
            onChanged: (value) {
              setState(() {
                _selectedFatherMaritalStatus = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Contact Information
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fatherPhoneController,
                  label: 'Primary Phone',
                  keyboardType: TextInputType.phone,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _fatherEmailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Professional Information
          const Text(
            'Professional Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fatherOccupationController,
                  label: 'Occupation',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _fatherEmployerController,
                  label: 'Employer',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fatherIncomeController,
                  label: 'Annual Income',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _fatherWorkPhoneController,
                  label: 'Work Phone',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Work Address
          const Text(
            'Work Address',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _fatherWorkStreetController,
            label: 'Work Street Address',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fatherWorkCityController,
                  label: 'Work City',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _fatherWorkStateController,
                  label: 'Work State',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _fatherWorkCountryController,
            label: 'Work Country',
          ),
        ],
      ),
    );
  }

  Widget _buildMotherInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mother\'s Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the mother\'s details',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Title and Name
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Title',
                  value: _motherTitleController.text,
                  items: _titles,
                  onChanged: (value) {
                    setState(() {
                      _motherTitleController.text = value!;
                    });
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _motherFirstNameController,
                  label: 'First Name',
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
                  controller: _motherMiddleNameController,
                  label: 'Middle Name',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _motherLastNameController,
                  label: 'Last Name',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date of Birth and Gender
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _motherDobController,
                  label: 'Date of Birth',
                  readOnly: true,
                  onTap: () => _selectDate(context, 'mother'),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Gender',
                  value: _selectedMotherGender,
                  items: _genders,
                  onChanged: (value) {
                    setState(() {
                      _selectedMotherGender = value;
                    });
                  },
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Marital Status
          _buildDropdown(
            label: 'Marital Status',
            value: _selectedMotherMaritalStatus,
            items: _maritalStatuses,
            onChanged: (value) {
              setState(() {
                _selectedMotherMaritalStatus = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Contact Information
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _motherPhoneController,
                  label: 'Primary Phone',
                  keyboardType: TextInputType.phone,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _motherEmailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Professional Information
          const Text(
            'Professional Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _motherOccupationController,
                  label: 'Occupation',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _motherEmployerController,
                  label: 'Employer',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _motherIncomeController,
            label: 'Annual Income',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            suffixIcon: suffixIcon,
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
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
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items:
              items.map((item) {
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

  Widget _buildClassDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Class',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedClassId,
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
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items:
              _isLoadingClasses
                  ? [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Loading classes...'),
                    ),
                  ]
                  : _classes.map((classItem) {
                    return DropdownMenuItem<String>(
                      value: classItem.id,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            classItem.section != null &&
                                    classItem.section!.isNotEmpty
                                ? '${classItem.name} (${classItem.section})'
                                : classItem.name ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${classItem.level} • ${classItem.academicYear}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (classItem.availableSlots != null)
                            Text(
                              '${classItem.availableSlots} slots available',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    classItem.availableSlots! > 0
                                        ? Colors.green[600]
                                        : Colors.red[600],
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
          onChanged:
              _isLoadingClasses
                  ? null
                  : (value) {
                    setState(() {
                      _selectedClassId = value;
                    });
                  },
        ),
      ],
    );
  }

  void _nextStep() {
    if (_currentStep < 4) {
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

  Future<void> _selectDate(BuildContext context, dynamic type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (type == true) {
          // Student DOB
          _selectedDOB = picked;
          _dobController.text =
              '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        } else if (type == 'admission') {
          // Admission date
          _selectedAdmissionDate = picked;
        } else if (type == 'father') {
          // Father DOB
          _selectedFatherDOB = picked;
          _fatherDobController.text =
              '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        } else if (type == 'mother') {
          // Mother DOB
          _selectedMotherDOB = picked;
          _motherDobController.text =
              '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        }
      });
    }
  }

  void _handleNextOrSubmit() {
    if (_currentStep < 4) {
      _nextStep();
    } else {
      // Validate required fields before submission
      if (_selectedAdmissionDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an admission date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      _submitForm();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare the data according to your API structure
      final studentData = {
        'personalInfo': {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'middleName': _middleNameController.text.trim(),
          'dateOfBirth': _selectedDOB?.toIso8601String().split('T')[0],
          'gender': _selectedGender,
          'nationality': _selectedNationality,
          'stateOfOrigin': _selectedStateOfOrigin,
          'localGovernment': _selectedLocalGovernment,
          'religion': _selectedReligion,
          'bloodGroup': _selectedBloodGroup,
          'profileImage': _imageUrl,
        },
        'contactInfo': {
          'address': {
            'street': _streetController.text.trim(),
            'city': _cityController.text.trim(),
            'state': _stateController.text.trim(),
            'country': _countryController.text.trim(),
          },
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
        },
        'academicInfo': {
          'academicYear': _selectedAcademicYear,
          'admissionDate':
              _selectedAdmissionDate?.toIso8601String().split('T')[0],
          'studentType': _selectedStudentType,
          'currentClass': _selectedClassId,
        },
        'assignToClass': _selectedClassId,
        'parentInfo': {
          'fatherData': {
            'personalInfo': {
              'title': _fatherTitleController.text.trim(),
              'firstName': _fatherFirstNameController.text.trim(),
              'lastName': _fatherLastNameController.text.trim(),
              'middleName': _fatherMiddleNameController.text.trim(),
              'dateOfBirth':
                  _selectedFatherDOB?.toIso8601String().split('T')[0],
              'gender': _selectedFatherGender,
              'maritalStatus': _selectedFatherMaritalStatus,
            },
            'contactInfo': {
              'primaryPhone': _fatherPhoneController.text.trim(),
              'email': _fatherEmailController.text.trim(),
              'address': {
                'street': _streetController.text.trim(),
                'city': _cityController.text.trim(),
                'state': _stateController.text.trim(),
                'country': _countryController.text.trim(),
              },
            },
            'professionalInfo': {
              'occupation': _fatherOccupationController.text.trim(),
              'employer': _fatherEmployerController.text.trim(),
              'annualIncome':
                  _fatherIncomeController.text.trim().isNotEmpty
                      ? int.tryParse(_fatherIncomeController.text.trim()) ?? 0
                      : 0,
              'workPhone': _fatherWorkPhoneController.text.trim(),
              'workAddress': {
                'street': _fatherWorkStreetController.text.trim(),
                'city': _fatherWorkCityController.text.trim(),
                'state': _fatherWorkStateController.text.trim(),
                'country': _fatherWorkCountryController.text.trim(),
              },
            },
          },
          'motherData': {
            'personalInfo': {
              'title': _motherTitleController.text.trim(),
              'firstName': _motherFirstNameController.text.trim(),
              'lastName': _motherLastNameController.text.trim(),
              'middleName': _motherMiddleNameController.text.trim(),
              'dateOfBirth':
                  _selectedMotherDOB?.toIso8601String().split('T')[0],
              'gender': _selectedMotherGender,
              'maritalStatus': _selectedMotherMaritalStatus,
            },
            'contactInfo': {
              'primaryPhone': _motherPhoneController.text.trim(),
              'email': _motherEmailController.text.trim(),
              'address': {
                'street': _streetController.text.trim(),
                'city': _cityController.text.trim(),
                'state': _stateController.text.trim(),
                'country': _countryController.text.trim(),
              },
            },
            'professionalInfo': {
              'occupation': _motherOccupationController.text.trim(),
              'employer': _motherEmployerController.text.trim(),
              'annualIncome':
                  _motherIncomeController.text.trim().isNotEmpty
                      ? int.tryParse(_motherIncomeController.text.trim()) ?? 0
                      : 0,
            },
          },
        },
        'medicalInfo': {
          'allergies':
              _allergiesController.text.trim().isNotEmpty
                  ? _allergiesController.text
                      .trim()
                      .split(',')
                      .map((e) => e.trim())
                      .toList()
                  : [],
          'medications':
              _medicationsController.text.trim().isNotEmpty
                  ? _medicationsController.text
                      .trim()
                      .split(',')
                      .map((e) => e.trim())
                      .toList()
                  : [],
          'medicalConditions':
              _medicalConditionsController.text.trim().isNotEmpty
                  ? _medicalConditionsController.text
                      .trim()
                      .split(',')
                      .map((e) => e.trim())
                      .toList()
                  : [],
          'emergencyContact': {
            'name': _emergencyContactNameController.text.trim(),
            'relationship': _emergencyContactRelationshipController.text.trim(),
            'phone': _emergencyContactPhoneController.text.trim(),
          },
        },
      };

      final response = await ref
          .read(studentProvider.notifier)
          .createStudent(context, studentData);

      if (!mounted) return;

      if (response != null) {
        // Refresh the students list to show updated data
        await ref.read(studentProvider.notifier).getAllStudents(context);

        if (!mounted) return;

        // Navigate back to students list
        context.go('/students');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating student: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Image upload methods
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = image;
        });

        // Automatically upload the image
        await _uploadImageToCloudinary();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      // Check if camera is available (not available on web)
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Camera not available on web. Please use gallery instead.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = image;
        });

        // Automatically upload the image
        await _uploadImageToCloudinary();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Test Cloudinary configuration
  // Removed _testCloudinaryConnection method - no longer needed

  // Removed _verifyCredentials method - no longer needed

  Future<void> _uploadImageToCloudinary() async {
    if (_selectedImageFile == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      // Compress the image
      final compressedImageBytes = await _compressImage(_selectedImageFile!);
      debugPrint(
        '📸 Compressed image size: ${compressedImageBytes.length} bytes',
      );

      // Use the new robust upload method
      final uploadedUrl = await _robustCloudinaryUpload(compressedImageBytes);

      if (uploadedUrl != null) {
        setState(() {
          _imageUrl = uploadedUrl;
          debugPrint('✅ Image URL set: $_imageUrl');
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(
          'All upload strategies failed. Please check your Cloudinary configuration.',
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error uploading image';
        if (e.toString().contains('Upload failed')) {
          errorMessage = e.toString();
        } else if (e.toString().contains('SocketException')) {
          errorMessage =
              'Network error. Please check your internet connection.';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Upload timeout. Please try again.';
        } else if (e.toString().contains('All upload presets failed')) {
          errorMessage = 'Upload configuration error. Please contact support.';
        } else {
          errorMessage = 'Error uploading image: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  // New robust upload method with multiple strategies
  Future<String?> _robustCloudinaryUpload(Uint8List imageBytes) async {
    debugPrint('🚀 Starting robust Cloudinary upload...');

    // Strategy 1: Direct upload with your preset
    try {
      debugPrint(
        '📤 Strategy 1: Direct upload with preset "${AppConstants.cloudinaryPreset}"',
      );
      final result = await _directUpload(
        imageBytes,
        AppConstants.cloudinaryPreset,
      );
      if (result != null) {
        debugPrint('✅ Strategy 1 successful!');
        return result;
      }
    } catch (e) {
      debugPrint('❌ Strategy 1 failed: $e');
    }

    // Strategy 2: Upload with base64 encoding
    try {
      debugPrint('📤 Strategy 2: Base64 upload');
      final result = await _base64Upload(imageBytes);
      if (result != null) {
        debugPrint('✅ Strategy 2 successful!');
        return result;
      }
    } catch (e) {
      debugPrint('❌ Strategy 2 failed: $e');
    }

    // Strategy 3: Upload with different presets
    final fallbackPresets = ['unsigned_preset', 'ml_default', 'default'];
    for (String preset in fallbackPresets) {
      try {
        debugPrint('📤 Strategy 3: Trying preset "$preset"');
        final result = await _directUpload(imageBytes, preset);
        if (result != null) {
          debugPrint('✅ Strategy 3 successful with preset "$preset"!');
          return result;
        }
      } catch (e) {
        debugPrint('❌ Strategy 3 failed with preset "$preset": $e');
      }
    }

    debugPrint('❌ All upload strategies failed');
    return null;
  }

  // Direct upload method
  Future<String?> _directUpload(Uint8List imageBytes, String preset) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload',
      ),
    );

    request.fields['upload_preset'] = preset;
    request.fields['folder'] = 'students';
    request.fields['public_id'] =
        'student_${DateTime.now().millisecondsSinceEpoch}';

    // Note: Transformation parameters are not allowed with unsigned uploads
    // The preset should handle transformations if needed

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'student_image.jpg',
      ),
    );

    final response = await request.send().timeout(const Duration(seconds: 30));
    final responseBody = await response.stream.bytesToString();

    debugPrint('📊 Upload response status: ${response.statusCode}');
    debugPrint('📊 Upload response body: $responseBody');

    if (response.statusCode == 200) {
      final data = json.decode(responseBody);
      return data['secure_url'] ?? data['url'];
    } else {
      throw Exception('Upload failed: ${response.statusCode} - $responseBody');
    }
  }

  // Base64 upload method
  Future<String?> _base64Upload(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);

    final response = await http
        .post(
          Uri.parse(
            'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload',
          ),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'file': 'data:image/jpeg;base64,$base64Image',
            'upload_preset': AppConstants.cloudinaryPreset,
            'folder': 'students',
            'public_id': 'student_${DateTime.now().millisecondsSinceEpoch}',
            // Note: Transformation parameters are not allowed with unsigned uploads
          }),
        )
        .timeout(const Duration(seconds: 30));

    debugPrint('📊 Base64 upload response status: ${response.statusCode}');
    debugPrint('📊 Base64 upload response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['secure_url'] ?? data['url'];
    } else {
      throw Exception(
        'Base64 upload failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Uint8List> _compressImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception(
          'Could not decode image. Please try a different image.',
        );
      }

      // Resize image if it's too large (max 800px on longest side)
      img.Image resizedImage = image;
      if (image.width > 800 || image.height > 800) {
        resizedImage = img.copyResize(
          image,
          width: image.width > image.height ? 800 : null,
          height: image.height > image.width ? 800 : null,
          maintainAspect: true,
        );
      }

      // Compress the image with good quality
      final compressedBytes = img.encodeJpg(resizedImage, quality: 90);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      throw Exception('Failed to process image: ${e.toString()}');
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              if (!kIsWeb) // Only show camera option on mobile platforms
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _takePhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImagePreview() {
    if (_imageUrl != null) {
      // Show uploaded image from Cloudinary
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 40, color: Colors.grey);
          },
        ),
      );
    } else if (_selectedImageFile != null) {
      // Show selected image (web-compatible)
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child:
            kIsWeb
                ? Image.network(
                  _selectedImageFile!.path,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    );
                  },
                )
                : Image.file(
                  File(_selectedImageFile!.path),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    );
                  },
                ),
      );
    } else {
      // Show placeholder
      return const Icon(Icons.person, size: 40, color: Colors.grey);
    }
  }

  Widget _buildImageUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Picture',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a clear photo of the student',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Image display and upload button
          Row(
            children: [
              // Image preview
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.grey[100],
                ),
                child: _buildImagePreview(),
              ),
              const SizedBox(width: 16),

              // Upload button and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              _isUploadingImage ? null : _showImagePickerDialog,
                          icon:
                              _isUploadingImage
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.upload),
                          label: Text(
                            _isUploadingImage ? 'Uploading...' : 'Upload Image',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_imageUrl != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[600],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Image uploaded successfully',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
