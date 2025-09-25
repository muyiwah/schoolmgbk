import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/color_pallete.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/providers/staff_provider.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';
import 'package:schmgtsystem/widgets/custom_datepicker.dart';
import 'package:schmgtsystem/widgets/custom_dropdown_select.dart';

class AddStaff extends ConsumerStatefulWidget {
  const AddStaff({super.key});

  @override
  ConsumerState<AddStaff> createState() => _AddStaffState();
}

class _AddStaffState extends ConsumerState<AddStaff>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for Personal Information
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _stateOfOriginController =
      TextEditingController();

  // Controllers for Contact Information
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _primaryPhoneController = TextEditingController();
  final TextEditingController _secondaryPhoneController =
      TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  // Controllers for Employment Information
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _joinDateController = TextEditingController();
  final TextEditingController _contractEndDateController =
      TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  // Controllers for Bank Details
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();

  // Controllers for Emergency Contact
  final TextEditingController _emergencyNameController =
      TextEditingController();
  final TextEditingController _emergencyRelationshipController =
      TextEditingController();
  final TextEditingController _emergencyPhoneController =
      TextEditingController();
  final TextEditingController _emergencyAddressController =
      TextEditingController();

  // Controllers for Qualifications
  final List<TextEditingController> _qualificationDegreeControllers = [];
  final List<TextEditingController> _qualificationInstitutionControllers = [];
  final List<TextEditingController> _qualificationYearControllers = [];
  final List<TextEditingController> _qualificationGradeControllers = [];

  // Selected values
  String? _selectedTitle;
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedRole;
  String? _selectedDepartment;
  String? _selectedEmployeeType;

  // Documents
  List<PlatformFile> _selectedDocuments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _nationalityController.text = 'Nigerian';
    _countryController.text = 'Nigeria';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _stateOfOriginController.dispose();
    _emailController.dispose();
    _primaryPhoneController.dispose();
    _secondaryPhoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _positionController.dispose();
    _joinDateController.dispose();
    _contractEndDateController.dispose();
    _salaryController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationshipController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyAddressController.dispose();

    // Dispose qualification controllers
    for (var controller in _qualificationDegreeControllers) {
      controller.dispose();
    }
    for (var controller in _qualificationInstitutionControllers) {
      controller.dispose();
    }
    for (var controller in _qualificationYearControllers) {
      controller.dispose();
    }
    for (var controller in _qualificationGradeControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // Method to prepare data in the new format
  Map<String, dynamic> _prepareStaffData() {
    return {
      "personalInfo": {
        "title": _selectedTitle,
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "middleName":
            _middleNameController.text.trim().isNotEmpty
                ? _middleNameController.text.trim()
                : null,
        "dateOfBirth":
            _dobController.text.trim().isNotEmpty
                ? _dobController.text.trim()
                : null,
        "gender": _selectedGender?.toLowerCase(),
        "maritalStatus": _selectedMaritalStatus,
        "nationality":
            _nationalityController.text.trim().isNotEmpty
                ? _nationalityController.text.trim()
                : "Nigerian",
        "stateOfOrigin":
            _stateOfOriginController.text.trim().isNotEmpty
                ? _stateOfOriginController.text.trim()
                : null,
        "profilePhoto": null, // Will be set after file upload
      },
      "contactInfo": {
        "primaryPhone": _primaryPhoneController.text.trim(),
        "secondaryPhone":
            _secondaryPhoneController.text.trim().isNotEmpty
                ? _secondaryPhoneController.text.trim()
                : null,
        "email": _emailController.text.trim(),
        "address": {
          "street":
              _streetController.text.trim().isNotEmpty
                  ? _streetController.text.trim()
                  : null,
          "city":
              _cityController.text.trim().isNotEmpty
                  ? _cityController.text.trim()
                  : null,
          "state":
              _stateController.text.trim().isNotEmpty
                  ? _stateController.text.trim()
                  : null,
          "country":
              _countryController.text.trim().isNotEmpty
                  ? _countryController.text.trim()
                  : "Nigeria",
          "postalCode":
              _postalCodeController.text.trim().isNotEmpty
                  ? _postalCodeController.text.trim()
                  : null,
        },
      },
      "employmentInfo": {
        "employeeType": _selectedEmployeeType,
        "department": _selectedDepartment,
        "position": _positionController.text.trim(),
        "joinDate":
            _joinDateController.text.trim().isNotEmpty
                ? _joinDateController.text.trim()
                : null,
        "contractEndDate":
            _contractEndDateController.text.trim().isNotEmpty
                ? _contractEndDateController.text.trim()
                : null,
        "salary": _parseSalary(),
        "bankDetails": {
          "bankName":
              _bankNameController.text.trim().isNotEmpty
                  ? _bankNameController.text.trim()
                  : null,
          "accountNumber":
              _accountNumberController.text.trim().isNotEmpty
                  ? _accountNumberController.text.trim()
                  : null,
          "accountName":
              _accountNameController.text.trim().isNotEmpty
                  ? _accountNameController.text.trim()
                  : null,
        },
      },
      "qualifications": _buildQualificationsList(),
      "subjects": [], // Will be populated from backend
      "classes": [], // Will be populated from backend
      "emergencyContact": {
        "name":
            _emergencyNameController.text.trim().isNotEmpty
                ? _emergencyNameController.text.trim()
                : null,
        "relationship":
            _emergencyRelationshipController.text.trim().isNotEmpty
                ? _emergencyRelationshipController.text.trim()
                : null,
        "phone": _emergencyPhoneController.text.trim(),
      },
      "documents": _buildDocumentsList(),
      "status": "active", // Default status
    };
  }

  List<Map<String, dynamic>> _buildQualificationsList() {
    List<Map<String, dynamic>> qualifications = [];
    for (int i = 0; i < _qualificationDegreeControllers.length; i++) {
      if (_qualificationDegreeControllers[i].text.trim().isNotEmpty) {
        // Safely parse year with error handling
        int? year;
        final yearText = _qualificationYearControllers[i].text.trim();
        if (yearText.isNotEmpty) {
          try {
            year = int.parse(yearText);
          } catch (e) {
            print('Warning: Could not parse year "$yearText" as integer: $e');
            // If parsing fails, we'll set it to null
            year = null;
          }
        }

        qualifications.add({
          "degree": _qualificationDegreeControllers[i].text.trim(),
          "institution": _qualificationInstitutionControllers[i].text.trim(),
          "yearCompleted": year,
          "grade":
              _qualificationGradeControllers[i].text.trim().isNotEmpty
                  ? _qualificationGradeControllers[i].text.trim()
                  : null,
          "certificateUrl": null, // Will be set after file upload
        });
      }
    }
    return qualifications;
  }

  List<Map<String, dynamic>> _buildDocumentsList() {
    List<Map<String, dynamic>> documents = [];
    for (var doc in _selectedDocuments) {
      documents.add({
        "name": doc.name,
        "type": doc.name.split('.').last.toUpperCase(),
        "url": null, // This would be set after file upload
        "uploadDate": DateTime.now().toIso8601String(),
      });
    }
    return documents;
  }

  // Helper method to safely parse salary
  int? _parseSalary() {
    final salaryText = _salaryController.text.trim();
    if (salaryText.isEmpty) return null;

    try {
      return int.parse(salaryText);
    } catch (e) {
      print('Warning: Could not parse salary "$salaryText" as integer: $e');
      return null;
    }
  }

  void _addQualification() {
    setState(() {
      _qualificationDegreeControllers.add(TextEditingController());
      _qualificationInstitutionControllers.add(TextEditingController());
      _qualificationYearControllers.add(TextEditingController());
      _qualificationGradeControllers.add(TextEditingController());
    });
  }

  void _removeQualification(int index) {
    setState(() {
      _qualificationDegreeControllers[index].dispose();
      _qualificationInstitutionControllers[index].dispose();
      _qualificationYearControllers[index].dispose();
      _qualificationGradeControllers[index].dispose();
      _qualificationDegreeControllers.removeAt(index);
      _qualificationInstitutionControllers.removeAt(index);
      _qualificationYearControllers.removeAt(index);
      _qualificationGradeControllers.removeAt(index);
    });
  }

  Future<void> _pickDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _selectedDocuments.addAll(result.files);
        });
      }
    } catch (e) {
      showSnackbar(context, 'Error picking documents: $e');
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _selectedDocuments.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    // Basic validation
    if (_firstNameController.text.trim().isEmpty) {
      showSnackbar(context, 'Please enter first name');
      return;
    }
    if (_lastNameController.text.trim().isEmpty) {
      showSnackbar(context, 'Please enter last name');
      return;
    }
    if (_selectedGender == null) {
      showSnackbar(context, 'Please select gender');
      return;
    }
    if (_selectedRole == null) {
      showSnackbar(context, 'Please select role');
      return;
    }
    if (_primaryPhoneController.text.trim().isEmpty) {
      showSnackbar(context, 'Please enter primary phone number');
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      showSnackbar(context, 'Please enter email address');
      return;
    }
    if (_emergencyPhoneController.text.trim().isEmpty) {
      showSnackbar(context, 'Please enter emergency contact phone');
      return;
    }

    // Validate salary field if provided
    final salaryText = _salaryController.text.trim();
    if (salaryText.isNotEmpty) {
      try {
        int.parse(salaryText);
      } catch (e) {
        showSnackbar(context, 'Please enter a valid salary amount');
        return;
      }
    }

    // Validate qualification years if provided
    for (int i = 0; i < _qualificationYearControllers.length; i++) {
      final yearText = _qualificationYearControllers[i].text.trim();
      if (yearText.isNotEmpty) {
        try {
          final year = int.parse(yearText);
          if (year < 1900 || year > DateTime.now().year + 10) {
            showSnackbar(
              context,
              'Please enter a valid year for qualification ${i + 1}',
            );
            return;
          }
        } catch (e) {
          showSnackbar(
            context,
            'Please enter a valid year for qualification ${i + 1}',
          );
          return;
        }
      }
    }

    try {
      final staffData = _prepareStaffData();
      print('Staff Data to be sent: ${staffData.toString()}');

      // Call createStaff from staff provider
      final staffProvider = ref.read(staffNotifierProvider.notifier);
      final result = await staffProvider.createStaff(context, staffData);

      if (result != null) {
        // Staff created successfully
        _clearForm();
        // Navigator.of(context).pop(); // Navigate back to previous screen
      }
    } catch (e) {
      showSnackbar(context, 'Error creating staff: $e');
    }
  }

  // Method to clear all form fields after successful submission
  void _clearForm() {
    // Clear all text controllers
    _firstNameController.clear();
    _lastNameController.clear();
    _middleNameController.clear();
    _dobController.clear();
    _nationalityController.clear();
    _stateOfOriginController.clear();
    _emailController.clear();
    _primaryPhoneController.clear();
    _secondaryPhoneController.clear();
    _streetController.clear();
    _cityController.clear();
    _stateController.clear();
    _countryController.clear();
    _postalCodeController.clear();
    _positionController.clear();
    _joinDateController.clear();
    _contractEndDateController.clear();
    _salaryController.clear();
    _bankNameController.clear();
    _accountNumberController.clear();
    _accountNameController.clear();
    _emergencyNameController.clear();
    _emergencyRelationshipController.clear();
    _emergencyPhoneController.clear();
    _emergencyAddressController.clear();

    // Clear dropdown selections
    setState(() {
      _selectedGender = null;
      _selectedTitle = null;
      _selectedMaritalStatus = null;
      _selectedRole = null;
      _selectedDepartment = null;
      _selectedEmployeeType = null;
    });

    // Clear qualifications
    setState(() {
      _qualificationDegreeControllers.clear();
      _qualificationInstitutionControllers.clear();
      _qualificationYearControllers.clear();
      _qualificationGradeControllers.clear();
    });

    // Clear documents
    setState(() {
      _selectedDocuments.clear();
    });

    // Reset tab to first tab
    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withOpacity(0.1), AppColors.background],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowGrey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: homeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Staff Member',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add new staff member to the system',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Custom Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicator: BoxDecoration(
                        color: homeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textPrimary,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(text: 'Personal Info'),
                        Tab(text: 'Contact Info'),
                        Tab(text: 'Employment Info'),
                        Tab(text: 'Qualifications'),
                        Tab(text: 'Documents'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Form Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowGrey.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPersonalInfoTab(),
                      _buildContactInfoTab(),
                      _buildEmploymentInfoTab(),
                      _buildQualificationsTab(),
                      _buildDocumentsTab(),
                    ],
                  ),
                ),
              ),
            ),
            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowGrey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed:
                        _tabController.index > 0
                            ? () {
                              _tabController.animateTo(
                                _tabController.index - 1,
                              );
                            }
                            : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.border,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_tabController.index < _tabController.length - 1) {
                        _tabController.animateTo(_tabController.index + 1);
                      } else {
                        _submitForm();
                      }
                    },
                    icon: Icon(
                      _tabController.index < _tabController.length - 1
                          ? Icons.arrow_forward
                          : Icons.check,
                    ),
                    label: Text(
                      _tabController.index < _tabController.length - 1
                          ? 'Next'
                          : 'Submit',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: homeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
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

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: homeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: homeColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: homeColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: homeColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Form Fields
          Row(
            children: [
              Expanded(
                child: _buildStyledDropdown(
                  title: 'Title',
                  allValues: const ['Mr', 'Mrs', 'Ms', 'Dr', 'Prof'],
                  onChanged: (value) {
                    setState(() {
                      _selectedTitle = value;
                    });
                  },
                  icon: Icons.title,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStyledInput(
                  title: 'First Name *',
                  controller: _firstNameController,
                  icon: Icons.person,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStyledInput(
                  title: 'Last Name *',
                  controller: _lastNameController,
                  icon: Icons.person,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStyledInput(
                  title: 'Middle Name',
                  controller: _middleNameController,
                  icon: Icons.person_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStyledDatePicker(
                  title: 'Date of Birth',
                  controller: _dobController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStyledDropdown(
                  title: 'Gender *',
                  allValues: const ['male', 'female'],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  icon: Icons.wc,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStyledDropdown(
                  title: 'Marital Status',
                  allValues: const ['single', 'married', 'divorced', 'widowed'],
                  onChanged: (value) {
                    setState(() {
                      _selectedMaritalStatus = value;
                    });
                  },
                  icon: Icons.favorite,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStyledInput(
                  title: 'Nationality *',
                  controller: _nationalityController,
                  icon: Icons.flag,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStyledInput(
            title: 'State of Origin',
            controller: _stateOfOriginController,
            icon: Icons.location_city,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.secondaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.contact_phone,
                  color: AppColors.secondaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Email
          _buildStyledInput(
            title: 'Email Address *',
            controller: _emailController,
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          // Phone Numbers
          Row(
            children: [
              Expanded(
                child: _buildStyledInput(
                  title: 'Primary Phone *',
                  controller: _primaryPhoneController,
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStyledInput(
                  title: 'Secondary Phone',
                  controller: _secondaryPhoneController,
                  icon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Address Section Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: AppColors.secondaryColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Address Information',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Street Address
          _buildStyledInput(
            title: 'Street Address *',
            controller: _streetController,
            icon: Icons.home,
          ),
          const SizedBox(height: 20),
          // City and State
          Row(
            children: [
              Expanded(
                child: _buildStyledInput(
                  title: 'City *',
                  controller: _cityController,
                  icon: Icons.location_city,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStyledInput(
                  title: 'State *',
                  controller: _stateController,
                  icon: Icons.map,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Country and Postal Code
          Row(
            children: [
              Expanded(
                child: _buildStyledInput(
                  title: 'Country',
                  controller: _countryController,
                  icon: Icons.public,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStyledInput(
                  title: 'Postal Code',
                  controller: _postalCodeController,
                  icon: Icons.local_post_office,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmploymentInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Employment Information Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.work_outline,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Employment Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Role and Department Row
          Row(
            children: [
              Expanded(
                child: _buildStyledDropdown(
                  title: 'Role *',
                  allValues: const [
                    "admin",
                    "teacher",
                    'teaching Assistant',
                    'Admissions Officer',
                    'part-time cook',
                    'cook',
                    'caretaker',
                    'driver',
                    'guard',
                    'lab assistant',
                    'library assistant',
                    'security',
                    'cleaner',
                    'stock-keeper',
                    'librarian',
                    'secretary',
                    'principal',
                    'support staff',
                    "accountant",
                    "security",
                    "cleaner",
                    "stock-keeper",
                    "librarian",
                    "secretary",
                    'principal',
                    'support staff',
                    "others",
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  icon: Icons.badge,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStyledDropdown(
                  title: 'Department',
                  allValues: const [
                    'Science',
                    'Arts',
                    'Commerce',
                    'Administration',
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value;
                    });
                  },
                  icon: Icons.business,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Position and Salary Row
          Row(
            children: [
              Expanded(
                child: _buildStyledInput(
                  title: 'Position *',
                  controller: _positionController,
                  icon: Icons.title,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStyledInput(
                  title: 'Salary',
                  controller: _salaryController,
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Join Date and Employee Type Row
          Row(
            children: [
              Expanded(
                child: _buildStyledDatePicker(
                  title: 'Join Date',
                  controller: _joinDateController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStyledDropdown(
                  title: 'Employee Type',
                  allValues: const ['permanent', 'contract', 'part-time'],
                  onChanged: (value) {
                    setState(() {
                      _selectedEmployeeType = value;
                    });
                  },
                  icon: Icons.schedule,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Contract End Date
          _buildStyledDatePicker(
            title: 'Contract End Date',
            controller: _contractEndDateController,
          ),
          const SizedBox(height: 32),

          // Bank Details Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance,
                  color: AppColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bank Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bank Name and Account Number Row
          Row(
            children: [
              Expanded(
                child: _buildStyledInput(
                  title: 'Bank Name',
                  controller: _bankNameController,
                  icon: Icons.account_balance,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStyledInput(
                  title: 'Account Number',
                  controller: _accountNumberController,
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Account Name
          _buildStyledInput(
            title: 'Account Name',
            controller: _accountNameController,
            icon: Icons.person,
          ),
          const SizedBox(height: 32),

          // Emergency Contact Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.tertiary3.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.tertiary3.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.emergency, color: AppColors.tertiary3, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Emergency Contact Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tertiary3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Emergency Contact Name
          _buildStyledInput(
            title: 'Emergency Contact Name *',
            controller: _emergencyNameController,
            icon: Icons.person_pin,
          ),
          const SizedBox(height: 20),

          // Relation and Phone Row
          Row(
            children: [
              Expanded(
                child: _buildStyledInput(
                  title: 'Relationship *',
                  controller: _emergencyRelationshipController,
                  icon: Icons.family_restroom,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStyledInput(
                  title: 'Emergency Phone *',
                  controller: _emergencyPhoneController,
                  icon: Icons.phone_in_talk,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Emergency Address
          _buildStyledInput(
            title: 'Emergency Address',
            controller: _emergencyAddressController,
            icon: Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _buildQualificationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Add Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.school, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Educational Qualifications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _addQualification,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Qualification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (_qualificationDegreeControllers.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: AppColors.textPrimary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No qualifications added yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click "Add Qualification" to add educational background',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...List.generate(_qualificationDegreeControllers.length, (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowGrey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppColors.border.withOpacity(0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.school,
                                  color: AppColors.primary,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Qualification ${index + 1}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => _removeQualification(index),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildStyledInput(
                        title: 'Degree/Certificate *',
                        controller: _qualificationDegreeControllers[index],
                        icon: Icons.workspace_premium,
                      ),
                      const SizedBox(height: 16),
                      _buildStyledInput(
                        title: 'Institution *',
                        controller: _qualificationInstitutionControllers[index],
                        icon: Icons.account_balance,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStyledInput(
                              title: 'Year Completed',
                              controller: _qualificationYearControllers[index],
                              icon: Icons.calendar_today,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStyledInput(
                              title: 'Grade',
                              controller: _qualificationGradeControllers[index],
                              icon: Icons.grade,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Upload Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColorAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryColorAccent.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.folder_open,
                      color: AppColors.primaryColorAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Document Upload',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColorAccent,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _pickDocuments,
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Upload Documents'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColorAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (_selectedDocuments.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: AppColors.textPrimary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No documents uploaded yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click "Upload Documents" to add files (PDF, DOC, Images)',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...List.generate(_selectedDocuments.length, (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowGrey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: AppColors.border.withOpacity(0.5)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColorAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getFileIcon(_selectedDocuments[index].name),
                      color: AppColors.primaryColorAccent,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    _selectedDocuments[index].name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${(_selectedDocuments[index].size / 1024).toStringAsFixed(1)} KB',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary.withOpacity(0.6),
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () => _removeDocument(index),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // Helper method to get file icon based on file extension
  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Styled Input Widget
  Widget _buildStyledInput({
    required String title,
    required TextEditingController controller,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: title,
          prefixIcon: icon != null ? Icon(icon, color: homeColor) : null,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: homeColor, width: 2),
          ),
          labelStyle: TextStyle(
            color: AppColors.textPrimary.withOpacity(0.7),
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // Styled Date Picker Widget
  Widget _buildStyledDatePicker({
    required String title,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomDatePicker(type: title, controller: controller),
    );
  }

  // Styled Dropdown Widget
  Widget _buildStyledDropdown({
    required String title,
    required List<String> allValues,
    required Function(String?) onChanged,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomDropdown(
        title: title,
        allValues: allValues,
        onChanged: onChanged,
      ),
    );
  }
}
